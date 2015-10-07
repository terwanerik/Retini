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

@property (nonatomic, retain) IBOutlet NSTextField *jpegQualityField;
@property (nonatomic, retain) IBOutlet NSStepper *jpegQualityStepper;

- (IBAction)checkForUpdates:(id)sender;
- (IBAction)stepperDidClick:(id)sender;

@end

@implementation AppDelegate

@synthesize jpegQualityField, jpegQualityStepper;

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	return [self processFile:filename];
}

- (BOOL)processFile:(NSString *)file
{
	[self.dropView checkFiles:@[file]];
	
	return  YES; // Return YES when file processed succesfull, else return NO.
}

- (IBAction)stepperDidClick:(id)sender
{
	if([sender isKindOfClass:[NSStepper class]]){
		NSStepper *stepper = (NSStepper *)sender;
		
		int stepperVal = MIN(MAX([stepper intValue], 1), 10);
		
		[jpegQualityField setStringValue:[NSString stringWithFormat:@"JPEG quality: %i/10", stepperVal]];
		
		[[NSUserDefaults standardUserDefaults] setInteger:stepperVal forKey:@"jpegQuality"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (IBAction)checkForUpdates:(id)sender
{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer]; //to bad github gives the raw content as plain text
	manager.requestSerializer = [AFHTTPRequestSerializer serializer]; //otherwise this would have been AFPlistResponse / requestserializers
	
	[manager GET:@"https://raw.githubusercontent.com/terwanerik/Retini/master/Retini/Info.plist"
																		parameters:nil
																			 success:^(AFHTTPRequestOperation *operation, id responseObject) {
																				 [self checkPlist:responseObject andOrigin:sender];
																			 }
																			 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
																				 // just leave it be.
																			 }];
}

- (void)checkPlist:(NSData *)plistData andOrigin:(id)sender
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
		[newVersionAlert beginSheetModalForWindow:self.window
																modalDelegate:self
															 didEndSelector:@selector(alertButtonClicked:returnCode:contextInfo:)
																	contextInfo:nil];
	} else if(sender != nil){
		NSAlert *newVersionAlert = [[NSAlert alloc] init];
		[newVersionAlert setMessageText:@"No new version is found.. Check GitHub to be sure?"];
		[newVersionAlert addButtonWithTitle:@"GitHub? Letsgo!"];
		[newVersionAlert addButtonWithTitle:@"I'm good."];
		[newVersionAlert setDelegate:nil];
		[newVersionAlert beginSheetModalForWindow:self.window
																modalDelegate:self
															 didEndSelector:@selector(alertButtonClicked:returnCode:contextInfo:)
																	contextInfo:nil];
	}
}

- (void)alertButtonClicked:(NSAlert *)alert
								returnCode:(int)returnCode
							 contextInfo:(void *)contextInfo
{
	if(returnCode == 1000){
		if(alert.delegate == self){
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/terwanerik/Retini/raw/master/Retini.zip"]];
		} else{
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/terwanerik/Retini"]];
		}
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self checkForUpdates:nil];
	
	if([[NSUserDefaults standardUserDefaults] integerForKey:@"jpegQuality"]){
		[jpegQualityStepper setDoubleValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"jpegQuality"]];
	}
	
	int stepperVal = MIN(MAX([jpegQualityStepper intValue], 1), 10);
	
	[jpegQualityStepper setAlphaValue:0.7];
	[jpegQualityField setStringValue:[NSString stringWithFormat:@"JPEG quality: %i/10", stepperVal]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

@end
