//
//  CDDrawingView.m
//  CouchDraw
//
//  Created by Luke Iannini on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CDDrawingView.h"
#import "CDPath.h"
#import "CDPoint.h"
@implementation CDDrawingView
@synthesize paths;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [paths release];
    [super dealloc];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    for (CDPath *path in self.paths)
    {
        [(UIColor *)path.color set];
        [[path bezierPath] stroke];
    }
}


@end
