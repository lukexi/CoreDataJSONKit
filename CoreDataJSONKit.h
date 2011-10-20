//
//  CoreDataJSONKit.h
//  CoreDataJSONKit
//
//  Created by Luke Iannini on 7/21/11.
//  Copyright 2011 Hello, Chair Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

/*
 -Basic usage:
 
 // Get a JSONString from an NSManagedObject to send it off to a server
 NSString *JSONString = [aManagedObject cj_dictionaryRepresentation];
 
 // Turn a JSONString from a server back into a NSManagedObject:
 NSManagedObject *myManagedObject = [NSManagedObject cj_insertInMangedObjectContext:managedObjectContext fromJSONString:JSONString];
 
 
 -Advanced usage:
 To Serialize and deserialize Core Data "Transformable" attributes, add a category on the class implementing:
 
 + (id)cj_objectFromDictionaryRepresentation:(id)dictionaryRepresentation;
 - (id)cj_dictionaryRepresentation;
 
 and then, in the userInfo dictionary for the attribute, add a "class" key with the name of the class as the value (e.g. UIColor)
 
 UIColor and NSURL are supported by default as transformable attributes, so you can see an example of how to implement the transformations at the bottom of this file.
 
 NOTE: NSDate is already supported for serialization and deserialization as a special case, using Core Data's "Date" attribute type.
 
 Specify the key CJEntityUniqueIDKey (with an attribute's name as the value) on an entity's userInfo to tell CDJK about an attribute that stores a persistent unique ID that can be used to prevent CDJK from creating duplicates of the same object. For example, CoreCouchKit specifies its couchID attribute to let CDJK update its documents without creating duplicates.
 
 Specify the CJEntityExcludeInRelationshipsKey (with any value) to prevent an object from being added to a parent's dictionary when it's at the end of a relationship.
 
 Implement the CJRelationshipRepresentation protocol for a more advanced way to control how an entity is represented when at the end of a relationship. Typically this is used to represent an object as an ID string. You can also return nil to exclude the object from its parent's representation, similar to the CJEntityExcludeInRelationshipsKey.
 
 */

#define kCJEntityNameKey @"documentType"
#define kCJAttributeClassKey @"class"
#define kCJEntityUniqueIDKey @"CJEntityUniqueIDKey"
#define kCJEntityExcludeInRelationshipsKey @"CJEntityExcludeInRelationshipsKey"

@interface NSManagedObject (CoreDataJSON)

#pragma mark - Serialization
- (NSString *)cj_JSONString;
- (NSDictionary *)cj_dictionaryRepresentation;

#pragma mark - Deserialization
+ (id)cj_insertInManagedObjectContext:(NSManagedObjectContext *)context
                fromObjectDescription:(NSDictionary *)objectDescription;
+ (id)cj_insertInManagedObjectContext:(NSManagedObjectContext *)context
                       fromJSONString:(NSString *)JSONString;

- (void)cj_setPropertiesFromDescription:(NSDictionary *)objectDescription; // Can be used to update an object

@end

@interface NSDictionary (CDAdditions)

- (NSString *)cj_JSONString;
- (NSData *)cj_JSONData;

@end

// Implement this on objects that will be stored as transformable attributes
// to convert them into JSON-encodable types
@protocol CJJSONRepresentation <NSObject>

+ (id)cj_objectFromJSONRepresentation:(id)JSONRepresentation;
- (id)cj_JSONRepresentation;

@end

// Implement this to use a customized representation of an object
// that's used when it's found in a relationship
@protocol CJRelationshipRepresentation <NSObject>

- (id)cj_relationshipRepresentation;

@end

#pragma mark - JSON Reperesentation Categories

@interface UIColor (CJAdditions) <CJJSONRepresentation>

@end


@interface NSDate (CJAdditions) <CJJSONRepresentation>

+ (NSDateFormatter *)cj_outputFormatter;

@end


@interface NSURL (CJAdditions) <CJJSONRepresentation>

@end
