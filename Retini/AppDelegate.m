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

- (IBAction)checkForUpdates:(id)sender
{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer]; //to bad github gives the raw content as plain text
	manager.requestSerializer = [AFHTTPRequestSerializer serializer]; //otherwise this would have been AFPlistResponse / requestserializers
	
	[manager GET:@"https://raw.githubusercontent.com/terwanerik/Retini/master/Retini/Info.plist"
																		parameters:nil
																			 success:^(AFHTTPRequestOperation *operation, id responseObject) {
																				 [self checkPlist:responseObject];
																			 }
																			 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
																				 // just leave it be.
																			 }];
}

- (void)checkPlist:(NSData *)plistData
{
	NSString *error;
	NSPropertyListFormat format;
	NSDictionary *plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
	
	// remove dots to get big number. Versioning will never go beyond 10 so should work fine atm.
	int onlineVersion = [[[plist objectForKey:@"CFBundleShortVersionString"] stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
	int myVersion = [[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
	
	if(onlineVersion > myVersion){
		NSAlert *newVersionAlert = [[NSAlert alloc] init];
		[newVersionAlert setMessageText:@"A new version of Retini is found. Would you like to download the update?"];
		[newVersionAlert addButtonWithTitle:@"Update"];
		[newVersionAlert addButtonWithTitle:@"Cancel"];
		[newVersionAlert setDelegate:self];
		[newVersionAlert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(alertButtonClicked:returnCode:contextInfo:) contextInfo:nil];
	}
}

- (void)alertButtonClicked:(NSAlert *)alert
								returnCode:(int)returnCode
							 contextInfo:(void *)contextInfo
{
	if(returnCode == 1000){
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/terwanerik/Retini/raw/master/Retini.zip"]];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self checkForUpdates:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

@end
