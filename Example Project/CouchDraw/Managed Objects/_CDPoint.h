// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDPoint.h instead.

#import <CoreData/CoreData.h>


@class CDPath;





@interface CDPointID : NSManagedObjectID {}
@end

@interface _CDPoint : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDPointID*)objectID;



@property (nonatomic, retain) NSNumber *y;

@property int yValue;
- (int)yValue;
- (void)setYValue:(int)value_;

//- (BOOL)validateY:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *x;

@property int xValue;
- (int)xValue;
- (void)setXValue:(int)value_;

//- (BOOL)validateX:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *index;

@property int indexValue;
- (int)indexValue;
- (void)setIndexValue:(int)value_;

//- (BOOL)validateIndex:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) CDPath* path;
//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;




@end

@interface _CDPoint (CoreDataGeneratedAccessors)

@end

@interface _CDPoint (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveY;
- (void)setPrimitiveY:(NSNumber*)value;

- (int)primitiveYValue;
- (void)setPrimitiveYValue:(int)value_;




- (NSNumber*)primitiveX;
- (void)setPrimitiveX:(NSNumber*)value;

- (int)primitiveXValue;
- (void)setPrimitiveXValue:(int)value_;




- (NSNumber*)primitiveIndex;
- (void)setPrimitiveIndex:(NSNumber*)value;

- (int)primitiveIndexValue;
- (void)setPrimitiveIndexValue:(int)value_;





- (CDPath*)primitivePath;
- (void)setPrimitivePath:(CDPath*)value;


@end
