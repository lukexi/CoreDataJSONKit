#import "CDPath.h"
#import "CDPoint.h"

@interface CDPath ()

@property (nonatomic, retain, readwrite) NSMutableArray *sortedPoints;
@property (nonatomic, retain) NSArray *sortDescriptors;
@property (nonatomic, retain, readwrite) UIBezierPath *bezierPath;
- (void)sortPoints;

@end

@implementation CDPath
@synthesize sortedPoints;
@synthesize sortDescriptors;
@synthesize bezierPath;
// Custom logic goes here.

- (void)addPoint:(CDPoint *)aPoint
{
    aPoint.indexValue = [self.points count];
    [self addPointsObject:aPoint];
    [self.sortedPoints addObject:aPoint];
    [self sortPoints];
    
    // Only add the point if our bezier path has already been accessed and populated,
    // otherwise, wait until the first bezier path access which will automatically populate it.
    if (bezierPath)
    {
        [self.bezierPath addLineToPoint:[aPoint CGPointValue]];
    }
}

- (NSArray *)sortDescriptors
{
    if (!sortDescriptors) {
        self.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"index" 
                                                                                      ascending:YES]];
    }
    return sortDescriptors;
}

- (NSArray *)sortedPoints
{
    if (!sortedPoints) 
    {
        self.sortedPoints = [NSMutableArray arrayWithArray:[self.points allObjects]];
        [self sortPoints];
    }
    return sortedPoints;
}

- (void)sortPoints
{
    [self.sortedPoints sortUsingDescriptors:self.sortDescriptors];
}

- (UIBezierPath *)bezierPath
{
    if (!bezierPath)
    {
        self.bezierPath = [UIBezierPath bezierPath];
        self.bezierPath.lineWidth = 3;
        if ([self.sortedPoints count]) 
        {
            CDPoint *firstPoint = [self.sortedPoints objectAtIndex:0];
            [self.bezierPath moveToPoint:[firstPoint CGPointValue]];
            for (NSUInteger index = 1; index < ([self.sortedPoints count] - 1); index++) 
            {
                CDPoint *point = [self.sortedPoints objectAtIndex:index];
                [self.bezierPath addLineToPoint:[point CGPointValue]];
            }
        }
    }
    return bezierPath;
}

@end
