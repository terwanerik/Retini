//
//  DragDropView.h
//  Retini
//
//  Created by Erik Terwan on 16-06-15.
//  Copyright (c) 2015 ET-ID. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResizeModel.h"

@interface DragDropView : NSView

// Models
@property (nonatomic, retain) ResizeModel *resizeModel;

// UI
@property (nonatomic, retain) IBOutlet NSProgressIndicator *pngCrushLoader;

@property BOOL highlight; // If should show the highlighted image
@property BOOL notFound; // If no retina (@2x, @3x) files where found

// Methods
- (void)checkFiles:(NSArray *)fileNames;

@end
