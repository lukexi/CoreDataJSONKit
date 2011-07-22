//
//  CDDrawingViewController.m
//  CouchDraw
//
//  Created by Luke Iannini on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CDDrawingViewController.h"
#import "CDDrawingView.h"
#import "CDPath.h"
#import "CDPoint.h"
#import "UIColor+Additions.h"
#import "CoreDataJSONKit.h"

@interface CDDrawingViewController ()

@property (nonatomic, readonly) CDDrawingView *drawingView;
@property (nonatomic, retain) CDPath *currentPath;

@end

@implementation CDDrawingViewController
@synthesize currentPath;
@synthesize managedObjectContext;
@synthesize drawing;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (CDDrawingView *)drawingView
{
    return (CDDrawingView *)self.view;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanRecognizer:)];
    [self.view addGestureRecognizer:recognizer];
}

- (void)setDrawing:(CDDrawing *)aDrawing
{
    if (aDrawing != drawing) 
    {
        [drawing autorelease];
        drawing = [aDrawing retain];
        self.drawingView.paths = drawing.paths;
        [self.drawingView setNeedsDisplay];
    }
}

- (void)handlePanRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CDPoint *point = nil;
    CGPoint touchPoint = [recognizer locationInView:self.drawingView];
    switch (recognizer.state) 
    {
        case UIGestureRecognizerStateBegan:
            self.currentPath = [CDPath insertInManagedObjectContext:self.managedObjectContext];
            self.currentPath.color = [UIColor hc_randomColor];
            [self.drawing addPathsObject:self.currentPath];
            // Use fallthrough of switch \/
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
            point = [CDPoint insertInManagedObjectContext:self.managedObjectContext];
            point.xValue = touchPoint.x;
            point.yValue = touchPoint.y;
            [self.currentPath addPoint:point];
            break;
        default:
            break;
    }
    [self.view setNeedsDisplay];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)printJSON:(id)sender 
{
    NSString *JSONRepresentation = [self.drawing cj_JSONRepresentation];
    NSLog(@"Dictionary Rep! %@", JSONRepresentation);
    CDDrawing *replacedDrawing = [NSManagedObject cj_insertInManagedObjectContext:self.managedObjectContext fromJSONString:JSONRepresentation];
    NSLog(@"Replaced object! %@", replacedDrawing);
    self.drawing = replacedDrawing;
}
@end
