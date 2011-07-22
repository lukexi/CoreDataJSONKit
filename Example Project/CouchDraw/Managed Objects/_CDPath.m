// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDPath.m instead.

#import "_CDPath.h"

@implementation CDPathID
@end

@implementation _CDPath

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDPath" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDPath";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDPath" inManagedObjectContext:moc_];
}

- (CDPathID*)objectID {
	return (CDPathID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic color;






@dynamic drawing;

	

@dynamic points;

	
- (NSMutableSet*)pointsSet {
	[self willAccessValueForKey:@"points"];
	NSMutableSet *result = [self mutableSetValueForKey:@"points"];
	[self didAccessValueForKey:@"points"];
	return result;
}
	





@end
