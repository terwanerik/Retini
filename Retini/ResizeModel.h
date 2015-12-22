//
//  ResizeModel.h
//  Retini
//
//  Created by Erik Terwan on 20/12/15.
//  Copyright © 2015 ET-ID. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface ResizeModel : NSObject

// UI
@property (nonatomic, retain) NSProgressIndicator *pngCrushLoader;


// METHODS
- (id)initWithLoader:(NSProgressIndicator *)indicator;
- (BOOL)hasRetinaFiles:(NSArray *)fileNames;

// Check if dragged item is directory or single file
- (void)checkFiles:(NSArray *)fileNames;

@end
