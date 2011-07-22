//
//  CJManagedObject.h
//  CouchDraw
//
//  Created by Luke Iannini on 7/21/11.
//  Copyright 2011 Hello, Chair Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

/*
 Core usage:
 
 // Get a JSONString from an NSManagedObject to send it off to a server
 NSString *JSONString = [aManagedObject cj_JSONRepresentation];
 
 // Turn a JSONString from a server back into a NSManagedObject:
 NSManagedObject *myManagedObject = [NSManagedObject cj_insertInMangedObjectContext:managedObjectContext fromJSONString:JSONString];
 
 */

@interface NSManagedObject (CoreDataJSON)

#pragma mark - Serialization
- (NSString *)cj_JSONRepresentation;

- (NSDictionary *)cj_dictionaryRepresentation;

// Override these to exclude keys from serialization
- (NSArray *)cj_attributeKeysForDictionaryRepresentation;
- (NSArray *)cj_relationshipKeysForDictionaryRepresentation;

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
