//
//  DragDropView.h
//  Retini
//
//  Created by Erik Terwan on 16-06-15.
//  Copyright (c) 2015 ET-ID. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DragDropView : NSView

@property BOOL highlight; // If should show the highlighted image
@property BOOL notFound; // If no retina (@2x, @3x) files where found

// Method to check if dragged item is directory or single file
- (void)checkFiles:(NSArray *)fileNames;

@end
