// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDDrawing.m instead.

#import "_CDDrawing.h"

@implementation CDDrawingID
@end

@implementation _CDDrawing

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDDrawing" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDDrawing";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDDrawing" inManagedObjectContext:moc_];
}

- (CDDrawingID*)objectID {
	return (CDDrawingID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic paths;

	
- (NSMutableSet*)pathsSet {
	[self willAccessValueForKey:@"paths"];
	NSMutableSet *result = [self mutableSetValueForKey:@"paths"];
	[self didAccessValueForKey:@"paths"];
	return result;
}
	





@end
