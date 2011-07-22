#import "_CDPath.h"

@interface CDPath : _CDPath {}
// Custom logic goes here.

- (void)addPoint:(CDPoint *)aPoint;

@property (nonatomic, retain, readonly) NSMutableArray *sortedPoints;
@property (nonatomic, retain, readonly) UIBezierPath *bezierPath;

@end
