#import "CDPoint.h"

@implementation CDPoint

// Custom logic goes here.

- (CGPoint)CGPointValue
{
    return CGPointMake(self.xValue, self.yValue);
}

@end
