//
//  CDDemoViewController.m
//  CouchDraw
//
//  Created by Luke Iannini on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CDDemoViewController.h"
#import "CoreDataJSONKit.h"
#import "CDDrawing.h"

@implementation CDDemoViewController
@synthesize drawingViewController1;
@synthesize drawingViewController2;
@synthesize textView1;
@synthesize textView2;
@synthesize managedObjectContext;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.drawingViewController1.managedObjectContext = self.managedObjectContext;
    self.drawingViewController2.managedObjectContext = self.managedObjectContext;
    
    self.drawingViewController1.drawing = [CDDrawing insertInManagedObjectContext:self.managedObjectContext];
    self.drawingViewController2.drawing = [CDDrawing insertInManagedObjectContext:self.managedObjectContext];
}

- (void)viewDidUnload
{
    [self setDrawingViewController1:nil];
    [self setDrawingViewController2:nil];
    [self setTextView1:nil];
    [self setTextView2:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc 
{
    [drawingViewController1 release];
    [drawingViewController2 release];
    [textView1 release];
    [textView2 release];
    [super dealloc];
}

- (IBAction)sendDrawing1ToJSON1:(id)sender 
{
    self.textView1.text = [self.drawingViewController1.drawing cj_JSONRepresentation];
}

- (IBAction)sendJSON1ToDrawing2:(id)sender 
{
    self.drawingViewController2.drawing = [NSManagedObject cj_insertInManagedObjectContext:self.managedObjectContext 
                                                                            fromJSONString:self.textView1.text];
}

- (IBAction)sendDrawing2ToJSON2:(id)sender 
{
    self.textView2.text = [self.drawingViewController2.drawing cj_JSONRepresentation];
}

- (IBAction)sendJSON2ToDrawing1:(id)sender 
{
    self.drawingViewController1.drawing = [NSManagedObject cj_insertInManagedObjectContext:self.managedObjectContext 
                                                                            fromJSONString:self.textView2.text];
}

@end
