//
//  ResizeModel.m
//  Retini
//
//  Created by Erik Terwan on 20/12/15.
//  Copyright © 2015 ET-ID. All rights reserved.
//

#import "ResizeModel.h"
#import "NSImage+Resize.h"

@implementation ResizeModel

@synthesize pngCrushLoader;

- (id)initWithLoader:(NSProgressIndicator *)indicator
{
	self = [super init];
	
	if(self){
		pngCrushLoader = indicator;
	}
	
	return self;
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
    if(original.representations.count > 0){
        float width = original.representations[0].pixelsWide;
        float height = original.representations[0].pixelsHigh;
        
        NSImage *newImg2x = [self imageResize:[original copy] newSize:NSMakeSize(2*width/3, 2*height/3)];
        
        if([self saveImage:newImg2x toPath:[fileName stringByReplacingOccurrencesOfString:@"@3x" withString:@"@2x"]]){
            NSImage *newImg = [self imageResize:[original copy] newSize:NSMakeSize(width/3, height/3)];
            
            [self saveImage:newImg toPath:[fileName stringByReplacingOccurrencesOfString:@"@3x" withString:@""]];
        }
        
        if([[NSUserDefaults standardUserDefaults] integerForKey:@"pngOut"] == 1){
            [self crushPng:fileName];
        }
    }
}

- (void)resize2x:(NSString *)fileName
{
    NSImage *original = [[NSImage alloc] initWithContentsOfFile:fileName];
    if(original.representations.count > 0){
        float width = original.representations[0].pixelsWide;
        float height = original.representations[0].pixelsHigh;
        
        NSImage *newImg = [self imageResize:original newSize:NSMakeSize(width/2, height/2)];
        
        [self saveImage:newImg toPath:[fileName stringByReplacingOccurrencesOfString:@"@2x" withString:@""]];
        
        if([[NSUserDefaults standardUserDefaults] integerForKey:@"pngOut"] == 1){
            [self crushPng:fileName];
        }
    }
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
		
		float quality = 1.0;
		
		if([[NSUserDefaults standardUserDefaults] integerForKey:@"jpegQuality"]){
			quality = [[NSUserDefaults standardUserDefaults] integerForKey:@"jpegQuality"] / 10;
		}
		
		NSData *data = [bitmapRep representationUsingType:fileType properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:quality] forKey:NSImageCompressionFactor]];
		
		if([[NSUserDefaults standardUserDefaults] integerForKey:@"pngOut"] == 1){
			if([data writeToFile:path atomically:YES]){
				return [self crushPng:path];
			}
		}
		
		return [data writeToFile:path atomically:YES];
	}
	
	return NO;
}

- (BOOL)crushPng:(NSString *)fileName
{
	if(![[fileName lowercaseString] containsString:@"png"]){
		return NO;
	}
	
	[pngCrushLoader setMaxValue:pngCrushLoader.maxValue + 1];
	[pngCrushLoader setAlphaValue:1.0];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		NSTask *task = [[NSTask alloc] init];
		task.launchPath = [[NSBundle mainBundle] pathForResource:@"pngout" ofType:@""];
		task.arguments = @[@"-y", fileName, fileName];
		
		[task launch];
		[task waitUntilExit];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[pngCrushLoader setDoubleValue:pngCrushLoader.doubleValue + 1];
			
			if(pngCrushLoader.doubleValue == pngCrushLoader.maxValue){
				[pngCrushLoader setAlphaValue:0.0];
				[pngCrushLoader setDoubleValue:0];
				[pngCrushLoader setMaxValue:0];
			}
		});
	});
	
	return YES;
}

@end
