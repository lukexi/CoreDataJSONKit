//
//  CoreDataJSONKit.m
//  CoreDataJSONKit
//
//  Created by Luke Iannini on 7/21/11.
//  Copyright 2011 Hello, Chair Inc. All rights reserved.
//

#import "CoreDataJSONKit.h"

@interface CJObjectTraverser : NSObject

+ (CJObjectTraverser *)traverserForManagedObject:(NSManagedObject *)managedObject;

@end

@implementation CJObjectTraverser

+ (CJObjectTraverser *)traverserForManagedObject:(NSManagedObject *)managedObject
{
    return [[self alloc] init];
}

@end

@interface NSManagedObject ()

// Serialization
- (NSDictionary *)cj_dictionaryRepresentationIgnoringInverse:(NSRelationshipDescription *)ignoringInverse;
// Serialization Helpers
- (NSArray *)cj_attributeKeys;
- (NSArray *)cj_relationshipKeys;
- (NSMutableArray *)cj_objectRepresentationsForRelationship:(NSString *)relationshipName 
                                            ignoringInverse:(NSRelationshipDescription *)ignoringInverse;
- (void)cj_addAttributesToPropertiesDictionary:(NSMutableDictionary *)propertiesDictionary;
- (void)cj_addRelationshipsToPropertiesDictionary:(NSMutableDictionary *)propertiesDictionary 
                                  ignoringInverse:(NSRelationshipDescription *)ignoringInverse;
- (id)cj_representationForRelatedObject:(NSManagedObject *)relatedObject 
                        ignoringInverse:(NSRelationshipDescription *)ignoringInverse;
// Deserialization
- (void)cj_setAttributesFromDescription:(NSDictionary *)objectDescription;
- (void)cj_setRelationshipsFromDescription:(NSDictionary *)objectDescription;

- (void)cj_saveAndRefresh;

+ (NSManagedObject *)cj_objectInManagedObjectContext:(NSManagedObjectContext *)context
                                      withEntityName:(NSString *)entityName
                               fromObjectDescription:(id)objectDescription;

+ (NSString *)cj_uniqueIDWithKey:(NSString *)key fromObjectDescription:(id)objectDescription;
+ (NSString *)cj_uniqueIDKeyForEntityForName:(NSString *)entityName
                      inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSString *)cj_entityNameForObjectDescription:(id)objectDescription 
                                   otherwiseUse:(NSString *)entityNameFromRelationshipDescription;
@end

@implementation NSDictionary (CDAdditions)

- (NSString *)cj_JSONString
{
    /*
     iOS4
    NSError *error = nil;
    NSString *JSONString = [self JSONStringWithOptions:JKSerializeOptionNone error:&error];
     */
    NSString *JSONString = [[NSString alloc] initWithData:[self cj_JSONData] encoding:NSUTF8StringEncoding];
    
    return JSONString;
}

- (NSData *)cj_JSONData
{
    NSError *error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    
    /*
     iOS4
     NSError *error = nil;
     NSData *JSONData = [self JSONDataWithOptions:JKSerializeOptionNone error:&error];
     */
    
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
    return [self cj_dictionaryRepresentationIgnoringInverse:nil];
}

- (NSDictionary *)cj_dictionaryRepresentationIgnoringInverse:(NSRelationshipDescription *)ignoringInverse
{
    //NSLog(@"getting representation of %@", [self class]);
    //NSLog(@"traversed: %@", ignoringInverse);
    NSMutableDictionary *propertiesDictionary = [NSMutableDictionary dictionary];
    
    [propertiesDictionary setObject:[[self entity] name] forKey:kCJEntityNameKey];
    
    [self cj_addRelationshipsToPropertiesDictionary:propertiesDictionary 
                                    ignoringInverse:ignoringInverse];
    
    [self cj_addAttributesToPropertiesDictionary:propertiesDictionary];
    
    return propertiesDictionary;
}

#pragma mark - Serialization Helpers

- (NSArray *)cj_attributeKeys
{
    return [[[self entity] attributesByName] allKeys];
}

- (NSArray *)cj_relationshipKeys
{
    return [[[self entity] relationshipsByName] allKeys];
}

- (void)cj_addRelationshipsToPropertiesDictionary:(NSMutableDictionary *)propertiesDictionary 
                                  ignoringInverse:(NSRelationshipDescription *)ignoringInverse
{
    NSLog(@"adding relationships for %@", [self class]);
    NSDictionary *relationshipsByName = [[self entity] relationshipsByName];
    for (NSString *relationshipName in [self cj_relationshipKeys]) 
    {
        NSRelationshipDescription *relationship = [relationshipsByName objectForKey:relationshipName];
        // Check our inverse to see if its a relationship we've already traveled down
        
        
        //NSLog(@"Checking relationship: %@", relationship);
        //NSLog(@"Inverse: %@", inverse);
        NSLog(@"Traversing %@.%@=>%@?", [self class], relationshipName, [[relationship destinationEntity] name]);
        if ([ignoringInverse isEqual:relationship]) 
        {
            NSLog(@"SKIPPING INVERSE");
            // Skip it if so
            continue;
        }
        NSLog(@"YEP");
        
        NSRelationshipDescription *inverse = [relationship inverseRelationship];
        
        if ([[relationship userInfo] objectForKey:kCJPropertyIgnoreKey]) 
        {
            continue;
        }
        
        if ([relationship isToMany]) 
        {
            NSMutableArray *objectDictionaries = [self cj_objectRepresentationsForRelationship:relationshipName 
                                                                               ignoringInverse:inverse];
            
            [propertiesDictionary setObject:objectDictionaries
                                     forKey:relationshipName];
        }
        else
        {
            NSManagedObject *relatedObject = [self valueForKey:relationshipName];
            if (relatedObject) 
            {
                id representation = [self cj_representationForRelatedObject:relatedObject 
                                                            ignoringInverse:inverse];
                if (representation) 
                {
                    [propertiesDictionary setObject:representation
                                             forKey:relationshipName];
                }
            }
            else
            {
                // We use the empty dictionary, '{}' to represent nil to-one relationships
                [propertiesDictionary setObject:[NSDictionary dictionary] 
                                         forKey:relationshipName]; 
            }
        }
    }
}

- (void)cj_addAttributesToPropertiesDictionary:(NSMutableDictionary *)propertiesDictionary
{
    for (NSString *attributeKey in [self cj_attributeKeys]) 
    {
        id object = [self valueForKey:attributeKey];
        if (!object) 
        {
            continue;
        }
        
        if ([[[[[self entity] attributesByName] objectForKey:attributeKey] 
              userInfo] objectForKey:kCJPropertyIgnoreKey]) 
        {
            continue;
        }
        
        id representation = nil;
        
        // NSJSONSerialization requires the object be wrapped in an NSArray or NSDictionary
        BOOL objectHasJSONRepresentation = [NSJSONSerialization isValidJSONObject:[NSArray arrayWithObject:object]];
        if (objectHasJSONRepresentation) 
        {
            representation = object;
        }
        else if ([object respondsToSelector:@selector(cj_JSONRepresentation)])
        {
            representation = [object cj_JSONRepresentation];
        }
        else
        {
            NSAssert2(NO, @"Don't know how to serialize object of class %@. Please implement cj_JSONReprentation in a category to return a valid JSON-encodable object (NSString, NSNumber, NSArray, NSDictionary, or NSNull). Object is: %@", [object class], object);
        }
        [propertiesDictionary setObject:representation forKey:attributeKey];
    }
}

- (NSMutableArray *)cj_objectRepresentationsForRelationship:(NSString *)relationshipName 
                                            ignoringInverse:(NSRelationshipDescription *)ignoringInverse
{
    NSSet *relatedObjects = [self valueForKey:relationshipName];
    
    NSMutableArray *objectDictionaries = [NSMutableArray arrayWithCapacity:[relatedObjects count]];
    for (NSManagedObject *relatedObject in relatedObjects)
    {
        id representation = [self cj_representationForRelatedObject:relatedObject 
                                                    ignoringInverse:ignoringInverse];
        if (representation) 
        {
            [objectDictionaries addObject:representation];
        }
    }
    return objectDictionaries;
}

// Allow related objects to represent themselves differently when at the end of a relationship —
// e.g., if a "Human" has a "Cars" relationship, the "Cars" objects can be represented
// by just their IDs (e.g VIN number) when serializing the Human.
// They can also return nil, or add a value in their entity's userInfo
// for kCJEntityExcludeInRelationshipsKey, to be excluded from the serialization.
- (id)cj_representationForRelatedObject:(NSManagedObject *)relatedObject 
                        ignoringInverse:(NSRelationshipDescription *)ignoringInverse
{
    NSDictionary *userInfo = [[relatedObject entity] userInfo];
    NSString *uniqueIDPropertyName = [userInfo objectForKey:kCJEntityUniqueIDKey];
    BOOL wantsToBeExcluded = [userInfo objectForKey:kCJEntityExcludeInRelationshipsKey] != nil;
    if (uniqueIDPropertyName) 
    {
        NSLog(@"Using %@", [relatedObject valueForKey:uniqueIDPropertyName]);
        return [relatedObject valueForKey:uniqueIDPropertyName];
    }
    else if ([relatedObject conformsToProtocol:@protocol(CJRelationshipRepresentation)]) 
    {
        return [(NSManagedObject <CJRelationshipRepresentation> *)relatedObject cj_relationshipRepresentation];
    }
    else if (wantsToBeExcluded)
    {
        return nil;
    }
    else
    {
        return [relatedObject cj_dictionaryRepresentationIgnoringInverse:ignoringInverse];
    }
    return nil;
}

#pragma mark - Deserialization (JSON String => NSManagedObject)

+ (id)cj_insertInManagedObjectContext:(NSManagedObjectContext *)context
                       fromJSONString:(NSString *)JSONString
{
    /*
     iOS4
    return [self cj_insertInManagedObjectContext:context 
                           fromObjectDescription:[JSONString objectFromJSONString]];
     */
    NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!result) 
    {
        NSLog(@"Error parsing JSON string: %@", JSONString);
    }
    return [self cj_insertInManagedObjectContext:context fromObjectDescription:result];
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

// Loop through the managed object's entity's attributes and query the object description for keys matching those attributes.
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
         
         if ([[attributeDescription userInfo] objectForKey:kCJPropertyIgnoreKey]) 
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

// Loop through the managed object's entity's relationship names and query the object description for keys matching those names.
// We expect an NSArray of NSDictionaries for to-many relationships, and a single NSDictionary for a to-one relationship.
// Alternately, objects can implement the CJRelationshipRepresentation protocol to provide an alternate representation.
// For example, if a Human has a Car, but only wants to represent the Car as a license plate rather than embedding the whole car
// description into the Human.
- (void)cj_setRelationshipsFromDescription:(NSDictionary *)objectDescription
{
    [[[self entity] relationshipsByName] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) 
    {    
        NSRelationshipDescription *relationshipDescription = obj;
        
        if (![objectDescription objectForKey:key]) 
        {
            // Skip missing relationships
            return;
        }
        
        if ([[relationshipDescription userInfo] objectForKey:kCJPropertyIgnoreKey]) 
        {
            return;
        }
        
        NSString *entityNameFromRelationshipDescription = [[relationshipDescription destinationEntity] name];
        
        if ([relationshipDescription isToMany])
        {
            NSArray *childObjectDescriptions = [objectDescription objectForKey:key];
            NSAssert1([childObjectDescriptions isKindOfClass:[NSArray class]], 
                      @"Expected child object description for to-many relationship to be NSArray, but it's: %@", 
                      childObjectDescriptions);
            
            /* Since we are re-building the set of relationships, relationships that have
             been deleted will be naturally removed. Though, their leaf objects will of course
             still exist and will have to be cleaned up. It might be a good idea to keep
             track of which ones are about to be removed and send them a message so they
             have an opportunity to delete themselves if they're dangling.
             */
            NSMutableSet *objectSet = [NSMutableSet setWithCapacity:[childObjectDescriptions count]];
            for (id childObjectDescription in childObjectDescriptions) 
            {
                NSString *entityName = [[self class] cj_entityNameForObjectDescription:childObjectDescription 
                                                                          otherwiseUse:entityNameFromRelationshipDescription];
                
                NSManagedObject *childObject = [NSManagedObject cj_objectInManagedObjectContext:self.managedObjectContext 
                                                                                 withEntityName:entityName
                                                                          fromObjectDescription:childObjectDescription];
                [objectSet addObject:childObject];
            }
            [self setValue:objectSet forKey:key];
        }
        else
        {
            id childObjectDescription = [objectDescription objectForKey:key];
            
            NSString *entityName = [[self class] cj_entityNameForObjectDescription:childObjectDescription 
                                                                      otherwiseUse:entityNameFromRelationshipDescription];
            
            NSManagedObject *childObject = [NSManagedObject cj_objectInManagedObjectContext:self.managedObjectContext 
                                                                             withEntityName:entityName
                                                                      fromObjectDescription:childObjectDescription];
            [self setValue:childObject forKey:key];
        }
    }];
}

// If the datamodel is using subentities, we can't rely on the relationshipDescription destinationEntity to
// give us the specific subentity it should create. This means relationships using alternative objectDescriptions
// (e.g. using a string ID) can't currently be to subentities.
+ (NSString *)cj_entityNameForObjectDescription:(id)objectDescription 
                                   otherwiseUse:(NSString *)entityNameFromRelationshipDescription
{
    NSString *entityName = entityNameFromRelationshipDescription;
    if ([objectDescription isKindOfClass:[NSDictionary class]]) 
    {
        entityName = [objectDescription objectForKey:kCJEntityNameKey] ?: entityName;
    }
    return entityName;
}

// We expect a uniqueID key (whose name is customizable by setting kCJEntityUniqueIDKey in the userInfo for the relevant entity) 
// in a dictionary object description that represents a unique ID for the object we can use for create-or-update.
// If it's not a dictionary object description, we expect it to be a string.
+ (NSString *)cj_uniqueIDWithKey:(NSString *)key 
           fromObjectDescription:(id)objectDescription
{
    return [objectDescription isKindOfClass:[NSDictionary class]] ? 
        [objectDescription valueForKey:key] : 
        objectDescription;
}

+ (NSString *)cj_uniqueIDKeyForEntityForName:(NSString *)entityName
                      inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    return [[entityDescription userInfo] objectForKey:kCJEntityUniqueIDKey];
}

+ (NSManagedObject *)cj_objectInManagedObjectContext:(NSManagedObjectContext *)context
                                      withEntityName:(NSString *)entityName
                               fromObjectDescription:(id)objectDescription
{
    BOOL isDictionaryDescription = [objectDescription isKindOfClass:[NSDictionary class]];
    NSAssert1(isDictionaryDescription || [objectDescription isKindOfClass:[NSString class]], 
              @"Expected child object description for related object to be NSDictionary or NSString, but it's: %@", objectDescription);
    
    // Empty dictionaries represent nil values
    if (isDictionaryDescription && ![objectDescription count]) 
    {
        return nil;
    }
    
    NSManagedObject *managedObject;
    
    // We allow a property to be marked as representing a unique ID for an object so it can be recognzied
    // and updated if it already exists in the local datastore.
    NSString *uniqueIDKey = [self cj_uniqueIDKeyForEntityForName:entityName inManagedObjectContext:context];
    NSString *uniqueID = [self cj_uniqueIDWithKey:uniqueIDKey fromObjectDescription:objectDescription];
    if (uniqueIDKey && uniqueID)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        [request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", uniqueIDKey, uniqueID]];
        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:request error:&error];
        if ([results count]) 
        {
            managedObject = [results objectAtIndex:0];
        }
    }
    
    // Either we're not using uniquing or there was no object matching the uniqueID, so create one.
    if (!managedObject) 
    {
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    }
    
    // Update the object with the known description
    if (isDictionaryDescription) 
    {
        [managedObject cj_setPropertiesFromDescription:objectDescription];
    }
    else if (uniqueIDKey && uniqueID)
    {
        // We just have the object's ID, so we create a placeholder object for you to fill in later (or, if this was a 'baked-in' object to the app, the managed object should already be complete)
        [managedObject setValue:uniqueID forKey:uniqueIDKey];
    }
    return managedObject;
}

// This might be useful for reducing memory usage
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