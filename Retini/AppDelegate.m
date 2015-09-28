//
//  AppDelegate.m
//  Retini
//
//  Created by Erik Terwan on 16-06-15.
//  Copyright (c) 2015 ET-ID. All rights reserved.
//

#import "AppDelegate.h"
#import "DragDropView.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet DragDropView *dropView;

@end

@implementation AppDelegate

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	return [self processFile:filename];
}

- (BOOL)processFile:(NSString *)file
{
	[self.dropView checkFiles:@[file]];
	
	return  YES; // Return YES when file processed succesfull, else return NO.
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

@end
