// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDDrawing.h instead.

#import <CoreData/CoreData.h>


@class CDPath;



@interface CDDrawingID : NSManagedObjectID {}
@end

@interface _CDDrawing : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDDrawingID*)objectID;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* paths;
- (NSMutableSet*)pathsSet;




@end

@interface _CDDrawing (CoreDataGeneratedAccessors)

- (void)addPaths:(NSSet*)value_;
- (void)removePaths:(NSSet*)value_;
- (void)addPathsObject:(CDPath*)value_;
- (void)removePathsObject:(CDPath*)value_;

@end

@interface _CDDrawing (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitivePaths;
- (void)setPrimitivePaths:(NSMutableSet*)value;


@end
