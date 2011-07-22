// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDPoint.m instead.

#import "_CDPoint.h"

@implementation CDPointID
@end

@implementation _CDPoint

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDPoint" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDPoint";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDPoint" inManagedObjectContext:moc_];
}

- (CDPointID*)objectID {
	return (CDPointID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"yValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"y"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"xValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"x"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"indexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"index"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic y;



- (int)yValue {
	NSNumber *result = [self y];
	return [result intValue];
}

- (void)setYValue:(int)value_ {
	[self setY:[NSNumber numberWithInt:value_]];
}

- (int)primitiveYValue {
	NSNumber *result = [self primitiveY];
	return [result intValue];
}

- (void)setPrimitiveYValue:(int)value_ {
	[self setPrimitiveY:[NSNumber numberWithInt:value_]];
}





@dynamic x;



- (int)xValue {
	NSNumber *result = [self x];
	return [result intValue];
}

- (void)setXValue:(int)value_ {
	[self setX:[NSNumber numberWithInt:value_]];
}

- (int)primitiveXValue {
	NSNumber *result = [self primitiveX];
	return [result intValue];
}

- (void)setPrimitiveXValue:(int)value_ {
	[self setPrimitiveX:[NSNumber numberWithInt:value_]];
}





@dynamic index;



- (int)indexValue {
	NSNumber *result = [self index];
	return [result intValue];
}

- (void)setIndexValue:(int)value_ {
	[self setIndex:[NSNumber numberWithInt:value_]];
}

- (int)primitiveIndexValue {
	NSNumber *result = [self primitiveIndex];
	return [result intValue];
}

- (void)setPrimitiveIndexValue:(int)value_ {
	[self setPrimitiveIndex:[NSNumber numberWithInt:value_]];
}





@dynamic path;

	





@end
