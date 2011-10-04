//
//  CJManagedObject.m
//  CouchDraw
//
//  Created by Luke Iannini on 7/21/11.
//  Copyright 2011 Hello, Chair Inc. All rights reserved.
//

#import "CoreDataJSONKit.h"

@interface NSManagedObject ()

// Serialization
- (NSDictionary *)cj_dictionaryRepresentationIgnoringTraversedRelationships:(NSMutableArray *)traversedRelationships;
- (NSArray *)cj_attributeKeysForDictionaryRepresentation;
- (NSArray *)cj_relationshipKeysForDictionaryRepresentation;

// Deserialization
- (void)cj_setAttributesFromDescription:(NSDictionary *)objectDescription;
- (void)cj_setRelationshipsFromDescription:(NSDictionary *)objectDescription;

- (void)cj_saveAndRefresh;

@end

@implementation NSDictionary (CDAdditions)

- (NSString *)cj_JSONString
{
    NSError *error = nil;
    NSString *JSONString = [self JSONStringWithOptions:JKSerializeOptionNone 
                 serializeUnsupportedClassesUsingBlock:^id(id object) 
    {
        return [object cj_JSONRepresentation];
    } error:&error];
    
    if (!JSONString) 
    {
        NSLog(@"CoreDataJSONKit: Error serializing! %@", error);
    }
    return JSONString;
}

- (NSData *)cj_JSONData
{
    NSError *error = nil;
    NSData *JSONData = [self JSONDataWithOptions:JKSerializeOptionNone 
                 serializeUnsupportedClassesUsingBlock:^id(id object) 
                            {
                                return [object cj_JSONRepresentation];
                            } error:&error];
    
    if (!JSONData) 
    {
        NSLog(@"CoreDataJSONKit: Error serializing! %@", error);
    }
    return JSONData;
}

@end

@implementation NSManagedObject (CoreDataJSON)

#pragma mark - Serialization (NSManagedObject => JSON String)

- (NSString *)cj_JSONString
{
    return [[self cj_dictionaryRepresentation] cj_JSONString];
}

- (NSDictionary *)cj_dictionaryRepresentation
{
    return [self cj_dictionaryRepresentationIgnoringTraversedRelationships:nil];
}

- (NSDictionary *)cj_dictionaryRepresentationIgnoringTraversedRelationships:(NSMutableArray *)traversedRelationships
{
    traversedRelationships = traversedRelationships ?: [NSMutableArray array];
    NSMutableDictionary *propertiesDictionary = [NSMutableDictionary dictionary];
    
    NSDictionary *relationshipsByName = [[self entity] relationshipsByName];
    for (NSString *relationshipName in [self cj_relationshipKeysForDictionaryRepresentation]) 
    {
        NSRelationshipDescription *relationship = [relationshipsByName objectForKey:relationshipName];
        // Check our inverse to see if its a relationship we've already traveled down
        NSRelationshipDescription *inverse = [relationship inverseRelationship];
        if ([traversedRelationships containsObject:inverse]) 
        {
            // Skip it if so
            continue;
        }
        
        // Otherwise mark ourselves as traversed so we can skip backlinks in the future
        [traversedRelationships addObject:relationship];
        
        if ([relationship isToMany]) 
        {
            NSSet *relatedObjects = [self valueForKey:relationshipName];
            
            NSMutableArray *objectDictionaries = [NSMutableArray arrayWithCapacity:[relatedObjects count]];
            for (NSManagedObject *relatedObject in relatedObjects)
            {
                NSDictionary *dictionaryRepresentation = [relatedObject cj_dictionaryRepresentationIgnoringTraversedRelationships:
                                                          traversedRelationships];
                [objectDictionaries addObject:dictionaryRepresentation];
            }
            
            [propertiesDictionary setObject:objectDictionaries 
                                     forKey:relationshipName];
        }
        else
        {
            NSManagedObject *relatedObject = [self valueForKey:relationshipName];
            if (relatedObject) 
            {
                [propertiesDictionary setObject:[relatedObject cj_dictionaryRepresentationIgnoringTraversedRelationships:
                                                 traversedRelationships] 
                                         forKey:relationshipName];
            }
            else
            {
                [propertiesDictionary setObject:[NSDictionary dictionary] 
                                         forKey:relationshipName]; 
            }
        }        
    }
    
    NSDictionary *attributesDictionary = [self dictionaryWithValuesForKeys:[self cj_attributeKeysForDictionaryRepresentation]];
    
    [propertiesDictionary addEntriesFromDictionary:attributesDictionary];
    
    [propertiesDictionary setObject:[[self entity] name] forKey:kCJEntityNameKey];
    
    return propertiesDictionary;
}

- (NSArray *)cj_attributeKeysForDictionaryRepresentation
{
    return [[[self entity] attributesByName] allKeys];
}

- (NSArray *)cj_relationshipKeysForDictionaryRepresentation
{
    return [[[self entity] relationshipsByName] allKeys];
}

#pragma mark - Deserialization (JSON String => NSManagedObject)

+ (id)cj_insertInManagedObjectContext:(NSManagedObjectContext *)context
                    fromJSONString:(NSString *)JSONString
{
    return [self cj_insertInManagedObjectContext:context 
                           fromObjectDescription:[JSONString objectFromJSONString]];
}

+ (id)cj_insertInManagedObjectContext:(NSManagedObjectContext *)context
                fromObjectDescription:(NSDictionary *)objectDescription
{
    NSString *entityName = [objectDescription objectForKey:kCJEntityNameKey];
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName 
                                                                   inManagedObjectContext:context];
    
    [managedObject cj_setPropertiesFromDescription:objectDescription];
    
    return managedObject;
}

- (void)cj_setPropertiesFromDescription:(NSDictionary *)objectDescription
{
    [self cj_setAttributesFromDescription:objectDescription];
    [self cj_setRelationshipsFromDescription:objectDescription];
}

- (void)cj_setAttributesFromDescription:(NSDictionary *)objectDescription
{    
    [[[self entity] attributesByName] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) 
     {
         NSAttributeDescription *attributeDescription = obj;
         NSAttributeType attributeType = [attributeDescription attributeType];
         id unserializedObject = nil;
         id objectForKey = [objectDescription objectForKey:key];
         
         if (!objectForKey) 
         {
             return;
         }
         
         if (attributeType == NSTransformableAttributeType) 
         {
             NSString *className = [[attributeDescription userInfo] objectForKey:kCJAttributeClassKey];
             NSAssert3(className, @"Must provide a key '%@' in the userInfo for transformable attribute '%@' to tell CDJSONKit what class of object it should create for the representation: %@", kCJAttributeClassKey, key, objectForKey);
             Class attributeClass = NSClassFromString(className);
             // If the objectForKey is already the same type as what the attribute declares, we're done!
             if ([objectForKey isKindOfClass:attributeClass]) 
             {
                 unserializedObject = objectForKey;
             }
             else
             {
                 // Otherwise, it's an intermediate representation and we can parse it further here.
                 unserializedObject = [attributeClass cj_objectFromJSONRepresentation:objectForKey];
             }
         }
         else if (attributeType == NSDateAttributeType)
         {
             if ([objectForKey isKindOfClass:[NSDate class]]) 
             {
                 unserializedObject = objectForKey;
             }
             else
             {
                 unserializedObject = [NSDate cj_objectFromJSONRepresentation:objectForKey];
             }
         }
         else
         {
             unserializedObject = objectForKey;
         }
         
         if (unserializedObject && ![unserializedObject isKindOfClass:[NSNull class]]) 
         {
             [self setValue:unserializedObject forKey:key];
         }
     }];
}

- (void)cj_setRelationshipsFromDescription:(NSDictionary *)objectDescription
{
    [[[self entity] relationshipsByName] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSRelationshipDescription *relationshipDescription = obj;
        
        if (![objectDescription objectForKey:key]) 
        {
            // Skip missing relationships
            return;
        }
        
        if ([relationshipDescription isToMany])
        {
            NSArray *childObjectDescriptions = [objectDescription objectForKey:key];
            NSAssert1([childObjectDescriptions isKindOfClass:[NSArray class]], @"Expected child object description for to-many relationship to be NSArray, but it's: %@", childObjectDescriptions);
            
            NSMutableSet *objectSet = [NSMutableSet setWithCapacity:[childObjectDescriptions count]];
            for (NSDictionary *childObjectDescription in childObjectDescriptions) 
            {
                NSAssert1([childObjectDescription isKindOfClass:[NSDictionary class]], @"Expected child object description for single member of to-many relationship to be NSDictionary, but it's: %@", childObjectDescription);
                
                NSManagedObject *childObject = [NSManagedObject cj_insertInManagedObjectContext:[self managedObjectContext] 
                                                                          fromObjectDescription:childObjectDescription];
                [objectSet addObject:childObject];
            }
            [self setValue:objectSet forKey:key];
        }
        else
        {
            NSDictionary *childObjectDescription = [objectDescription objectForKey:key];
            
            if ([childObjectDescription count]) 
            {
                NSAssert1([childObjectDescription isKindOfClass:[NSDictionary class]], @"Expected child object description for to-one relationship to be NSDictionary, but it's: %@", childObjectDescription);
                NSManagedObject *childObject = [NSManagedObject cj_insertInManagedObjectContext:[self managedObjectContext] 
                                                                          fromObjectDescription:childObjectDescription];
                
                [self setValue:childObject forKey:key];
            }
            else
            {
                [self setValue:nil forKey:key];
            }
        }
    }];
}

- (void)cj_saveAndRefresh
{
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    if (!success) 
    {
        NSLog(@"Error saving during import: %@", error);
    }
    for (NSManagedObject *object in [self.managedObjectContext registeredObjects]) 
    {
        [self.managedObjectContext refreshObject:object mergeChanges:NO];
    }
}

@end

#pragma mark - JSON Representation Categories

#define kRedKey @"red"
#define kGreenKey @"green"
#define kBlueKey @"blue"
#define kAlphaKey @"alpha"

@implementation UIColor (CJAdditions)

+ (id)cj_objectFromJSONRepresentation:(id)JSONRepresentation
{
    return [UIColor colorWithRed:[[JSONRepresentation objectForKey:kRedKey] floatValue] 
                           green:[[JSONRepresentation objectForKey:kGreenKey] floatValue] 
                            blue:[[JSONRepresentation objectForKey:kBlueKey] floatValue] 
                           alpha:[[JSONRepresentation objectForKey:kAlphaKey] floatValue]];
}

- (id)cj_JSONRepresentation
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:components[0]], kRedKey, 
            [NSNumber numberWithFloat:components[1]], kGreenKey,
            [NSNumber numberWithFloat:components[2]], kBlueKey,
            [NSNumber numberWithFloat:components[3]], kAlphaKey,
            nil];
}

@end

@implementation NSDate (CJAdditions)

+ (id)cj_objectFromJSONRepresentation:(id)JSONRepresentation
{
    return [[NSDate cj_outputFormatter] dateFromString:JSONRepresentation];
}

- (id)cj_JSONRepresentation
{
    return [[NSDate cj_outputFormatter] stringFromDate:self];
}

+ (NSDateFormatter *)cj_outputFormatter
{
    static NSDateFormatter *outputFormatter = nil;
    if (!outputFormatter) 
    {
        outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
    }
    return outputFormatter;
}

@end

@implementation NSURL (CJAdditions)

+ (id)cj_objectFromJSONRepresentation:(id)JSONRepresentation
{
    return [NSURL URLWithString:JSONRepresentation];
}

- (id)cj_JSONRepresentation
{
    return [self absoluteString];
}

@end