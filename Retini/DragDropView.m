//
//  DragDropView.m
//  Retini
//
//  Created by Erik Terwan on 16-06-15.
//  Copyright (c) 2015 ET-ID. All rights reserved.
//

#import "DragDropView.h"
#import "NSImage+Resize.h" // File from https://github.com/nate-parrott/Flashlight

@implementation DragDropView

@synthesize pngCrushLoader;
@synthesize highlight, notFound;

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self){
		[self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
		
		[pngCrushLoader setAlphaValue:0.0];
		
		_resizeModel = [[ResizeModel alloc] initWithLoader:pngCrushLoader];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	
	if(self){
		[self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
		
		[pngCrushLoader setAlphaValue:0.0];
		
		_resizeModel = [[ResizeModel alloc] initWithLoader:pngCrushLoader];
	}
	
	return self;
}

- (void)awakeFromNib
{
	[pngCrushLoader setAlphaValue:0.0];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	highlight = YES;
	notFound = NO;
	
	NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
	
	if(![_resizeModel hasRetinaFiles:draggedFilenames]){
		notFound = YES;
	}
	
	[self setNeedsDisplay:YES];
	
	return NSDragOperationCopy;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	highlight = NO;
	notFound = NO;
	
	[self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	highlight = NO;
	notFound = NO;
	
	[self setNeedsDisplay:YES];
	
	return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
	
	if(![_resizeModel hasRetinaFiles:draggedFilenames]){
		notFound = YES;
		
		[self setNeedsDisplay:YES];
	}
	
	return YES;
}

- (void)checkFiles:(NSArray *)fileNames
{
	[_resizeModel checkFiles:fileNames];
	
	highlight = NO;
	notFound = NO;
	
	[self setNeedsDisplay:YES];
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
	NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
	
	[_resizeModel checkFiles:draggedFilenames];
	
	highlight = NO;
	notFound = NO;
	
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	if(notFound){
		[[NSImage imageNamed:@"homeScreen~noFind"] drawInRect:rect];
	} else if(highlight){
		[[NSImage imageNamed:@"homeScreen~drop"] drawInRect:rect];
	} else{
		[[NSImage imageNamed:@"homeScreen"] drawInRect:rect];
	}
}

@end
