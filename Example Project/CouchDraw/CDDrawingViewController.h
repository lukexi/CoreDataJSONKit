//
//  CDDrawingViewController.h
//  CouchDraw
//
//  Created by Luke Iannini on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CDDrawing.h"

@interface CDDrawingViewController : UIViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) CDDrawing *drawing;
- (IBAction)printJSON:(id)sender;

@end
