//
//  MainWindow.h
//  Retini
//
//  Created by Erik Terwan on 27/10/2017.
//  Copyright © 2017 ET-ID. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "DragDropView.h"
#import "UpdateModel.h"

@interface MainWindow : NSWindow <UpdateModelDelegate, NSAlertDelegate>

@property (nonatomic, retain) IBOutlet DragDropView *dropView;

@property (nonatomic, retain) IBOutlet NSButton *settingsButton;
@property (nonatomic, retain) IBOutlet NSTextField *jpegQualityField;
@property (nonatomic, retain) IBOutlet NSStepper *jpegQualityStepper;
@property (nonatomic, retain) IBOutlet NSButton *pngOutButton;

@property (nonatomic, retain) IBOutlet NSProgressIndicator *loader;

@property (nonatomic, retain) IBOutlet NSLayoutConstraint *topDragConstraint;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *bottomDragConstraint;

- (BOOL)processFile:(NSString *)file;

- (IBAction)checkForUpdates:(id)sender;
- (IBAction)hitSettings:(id)sender;
- (IBAction)stepperDidClick:(id)sender;
- (IBAction)pngOutDidClick:(id)sender;

@end
