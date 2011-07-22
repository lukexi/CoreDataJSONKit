// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDPath.h instead.

#import <CoreData/CoreData.h>


@class CDDrawing;
@class CDPoint;

@class NSObject;

@interface CDPathID : NSManagedObjectID {}
@end

@interface _CDPath : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDPathID*)objectID;



@property (nonatomic, retain) NSObject *color;

//- (BOOL)validateColor:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) CDDrawing* drawing;
//- (BOOL)validateDrawing:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* points;
- (NSMutableSet*)pointsSet;




@end

@interface _CDPath (CoreDataGeneratedAccessors)

- (void)addPoints:(NSSet*)value_;
- (void)removePoints:(NSSet*)value_;
- (void)addPointsObject:(CDPoint*)value_;
- (void)removePointsObject:(CDPoint*)value_;

@end

@interface _CDPath (CoreDataGeneratedPrimitiveAccessors)


- (NSObject*)primitiveColor;
- (void)setPrimitiveColor:(NSObject*)value;





- (CDDrawing*)primitiveDrawing;
- (void)setPrimitiveDrawing:(CDDrawing*)value;



- (NSMutableSet*)primitivePoints;
- (void)setPrimitivePoints:(NSMutableSet*)value;


@end
