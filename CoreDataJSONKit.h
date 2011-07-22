//
//  CJManagedObject.h
//  CouchDraw
//
//  Created by Luke Iannini on 7/21/11.
//  Copyright 2011 Hello, Chair Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

/*
 -Core usage:
 
 // Get a JSONString from an NSManagedObject to send it off to a server
 NSString *JSONString = [aManagedObject cj_JSONRepresentation];
 
 // Turn a JSONString from a server back into a NSManagedObject:
 NSManagedObject *myManagedObject = [NSManagedObject cj_insertInMangedObjectContext:managedObjectContext fromJSONString:JSONString];
 
 
 -Advanced usage:
 To Serialize and deserialize Core Data "Transformable" attributes, add a category on the class implementing:
 
 + (id)cj_objectFromJSONRepresentation:(id)JSONRepresentation;
 - (id)cj_JSONRepresentation;
 
 and then, in the userInfo dictionary for the attribute, add a "class" key with the name of the class as the value (e.g. UIColor)
 
 UIColor is supported by default as a transformable attribute, so you can see an example of how to implement the transformations at the bottom of this file.
 
 NOTE: NSDate is already supported for serialization and deserialization as a special case, using Core Data's "Date" attribute type.
 
 */

@interface NSManagedObject (CoreDataJSON)

#pragma mark - Serialization
- (NSString *)cj_JSONRepresentation;

- (NSDictionary *)cj_dictionaryRepresentation;

#pragma mark - Deserialization
+ (id)cj_insertInManagedObjectContext:(NSManagedObjectContext *)context
                fromObjectDescription:(NSDictionary *)objectDescription;
+ (id)cj_insertInManagedObjectContext:(NSManagedObjectContext *)context
                       fromJSONString:(NSString *)JSONString;

@end

#pragma mark - JSON Reperesentation Categories

@interface UIColor (CJAdditions)

+ (id)cj_objectFromJSONRepresentation:(id)JSONRepresentation;
- (id)cj_JSONRepresentation;

@end


@interface NSDate (CJAdditions)

+ (id)cj_objectFromJSONRepresentation:(id)JSONRepresentation;
- (id)cj_JSONRepresentation;

+ (NSDateFormatter *)cj_outputFormatter;

@end
