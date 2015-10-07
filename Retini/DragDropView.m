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

@synthesize highlight, notFound;

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self){
		[self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	
	if(self){
		[self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
	}
	
	return self;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	highlight = YES;
	notFound = NO;
	
	NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
	
	if(![self hasRetinaFiles:draggedFilenames]){
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
	
	if(![self hasRetinaFiles:draggedFilenames]){
		notFound = YES;
		
		[self setNeedsDisplay:YES];
	}
	
	return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
	NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
	
	[self checkFiles:draggedFilenames];
	
	highlight = NO;
	notFound = NO;
	
	[self setNeedsDisplay:YES];
}

- (BOOL)hasRetinaFiles:(NSArray *)fileNames
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	for(NSString *filename in fileNames){
		BOOL isDir;
		
		if([fileManager fileExistsAtPath:filename isDirectory:&isDir]){
			if(!isDir){
				if([filename containsString:@"@2x"] || [filename containsString:@"@3x"]){
					return YES;
				}
			} else{
				NSMutableArray *dirContents = [NSMutableArray array];
				
				for(NSString *file in [fileManager contentsOfDirectoryAtPath:filename error:nil]){
					[dirContents addObject:[[filename stringByAppendingString:@"/"] stringByAppendingString:file]];
				}
				
				return [self hasRetinaFiles:dirContents];
			}
		}
	}
	
	return NO;
}

- (void)checkFiles:(NSArray *)fileNames
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	for(NSString *filename in fileNames){
		BOOL isDir;
		
		if([fileManager fileExistsAtPath:filename isDirectory:&isDir]){
			if(!isDir){
				[self workFile:filename];
			} else{
				NSMutableArray *dirContents = [NSMutableArray array];
				
				for(NSString *file in [fileManager contentsOfDirectoryAtPath:filename error:nil]){
					[dirContents addObject:[[filename stringByAppendingString:@"/"] stringByAppendingString:file]];
				}
				
				[self checkFiles:dirContents];
			}
		}
	}
}

- (void)workFile:(NSString *)file
{
	if([[file lowercaseString] containsString:@"png"] || [[file lowercaseString] containsString:@"jpeg"] || [[file lowercaseString] containsString:@"jpg"]){
		if([[file lowercaseString] containsString:@"@3x"]){
			[self resize3x:file];
		} else if([[file lowercaseString] containsString:@"@2x"]){
			[self resize2x:file];
		}
	}
}


- (void)resize3x:(NSString *)fileName
{
	NSImage *original = [[NSImage alloc] initWithContentsOfFile:fileName];
	NSImage *newImg2x = [self imageResize:[original copy] newSize:NSMakeSize(original.size.width * 2, original.size.height * 2)];
	
	if([self saveImage:newImg2x toPath:[fileName stringByReplacingOccurrencesOfString:@"@3x" withString:@"@2x"]]){
		NSImage *newImg = [self imageResize:[original copy] newSize:NSMakeSize(original.size.width, original.size.height)];
		[self saveImage:newImg toPath:[fileName stringByReplacingOccurrencesOfString:@"@3x" withString:@""]];
	}
}

- (void)resize2x:(NSString *)fileName
{
	NSImage *original = [[NSImage alloc] initWithContentsOfFile:fileName];
	NSImage *newImg = [self imageResize:original newSize:NSMakeSize(original.size.width, original.size.height)];
	
	[self saveImage:newImg toPath:[fileName stringByReplacingOccurrencesOfString:@"@2x" withString:@""]];
}

- (NSImage *)imageResize:(NSImage *)anImage newSize:(NSSize)newSize
{
	return [anImage resizeImageToSize:newSize];
}

- (BOOL)saveImage:(NSImage *)image toPath:(NSString *)path
{
	if(image != nil){
		[image lockFocus];
		
		NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, [image size].width, [image size].height)];
		
		[image unlockFocus] ;
		
		NSUInteger fileType = NSJPEGFileType;
		
		if([path containsString:@"png"]){
			fileType = NSPNGFileType;
		}
		
		NSData *data = [bitmapRep representationUsingType:fileType properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor]];
		
		return [data writeToFile:path atomically:YES];
	}
	
	return NO;
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	if(notFound){
		[self.window setBackgroundColor:[NSColor colorWithPatternImage:[NSImage imageNamed:@"homeScreen~noFind"]]];
	} else if(highlight){
		[self.window setBackgroundColor:[NSColor colorWithPatternImage:[NSImage imageNamed:@"homeScreen~drop"]]];
	} else{
		[self.window setBackgroundColor:[NSColor colorWithPatternImage:[NSImage imageNamed:@"homeScreen"]]];
	}
}

@end
