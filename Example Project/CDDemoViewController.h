//
//  CDDemoViewController.h
//  CouchDraw
//
//  Created by Luke Iannini on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDDrawingViewController.h"

@interface CDDemoViewController : UIViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet CDDrawingViewController *drawingViewController1;
@property (nonatomic, retain) IBOutlet CDDrawingViewController *drawingViewController2;
@property (nonatomic, retain) IBOutlet UITextView *textView1;
@property (nonatomic, retain) IBOutlet UITextView *textView2;

@end
