//
//  AppDelegate.m
//  Retini
//
//  Created by Erik Terwan on 16-06-15.
//  Copyright (c) 2015 ET-ID. All rights reserved.
//

#import "AppDelegate.h"
#import "DragDropView.h"
#import <QuartzCore/QuartzCore.h>

@interface AppDelegate ()

@property (nonatomic, retain) IBOutlet NSLayoutConstraint *topDragConstraint;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *bottomDragConstraint;
@property (nonatomic, retain) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet DragDropView *dropView;

@property (nonatomic, retain) IBOutlet NSButton *settingsButton;
@property (nonatomic, retain) IBOutlet NSTextField *jpegQualityField;
@property (nonatomic, retain) IBOutlet NSStepper *jpegQualityStepper;
@property (nonatomic, retain) IBOutlet NSButton *pngOutButton;

@property (nonatomic, retain) IBOutlet NSProgressIndicator *loader;

- (IBAction)checkForUpdates:(id)sender;
- (IBAction)hitSettings:(id)sender;
- (IBAction)stepperDidClick:(id)sender;
- (IBAction)pngOutDidClick:(id)sender;

@end

@implementation AppDelegate

@synthesize jpegQualityField, jpegQualityStepper, settingsButton, pngOutButton;
@synthesize loader;

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	return [self processFile:filename];
}

- (BOOL)processFile:(NSString *)file
{
	[self.dropView checkFiles:@[file]];
	
	return  YES; // Return YES when file processed succesfull, else return NO.
}

- (IBAction)hitSettings:(id)sender
{
	if(self.bottomDragConstraint.animator.constant == 0){
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			[context setDuration:0.2];
			[context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
			self.topDragConstraint.animator.constant = -105;
			self.bottomDragConstraint.animator.constant = 105;
			
			[settingsButton setTitle:@"Close"];
		} completionHandler:^{
			[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
				[context setDuration:0.3];
				[context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
				self.topDragConstraint.animator.constant = -100;
				self.bottomDragConstraint.animator.constant = 100;
			} completionHandler:nil];
		}];
	} else{
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			[context setDuration:0.15];
			[context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
			self.topDragConstraint.animator.constant = 5;
			self.bottomDragConstraint.animator.constant = -5;
			
			[settingsButton setTitle:@"Settings"];
		} completionHandler:^{
			[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
				[context setDuration:0.2];
				[context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
				self.topDragConstraint.animator.constant = 0;
				self.bottomDragConstraint.animator.constant = 0;
			} completionHandler:nil];
		}];
	}
}

- (IBAction)stepperDidClick:(id)sender
{
	if([sender isKindOfClass:[NSStepper class]]){
		NSStepper *stepper = (NSStepper *)sender;
		
		int stepperVal = MIN(MAX([stepper intValue], 1), 10);
		
		[jpegQualityField setStringValue:[NSString stringWithFormat:@"%i/10", stepperVal]];
		
		[[NSUserDefaults standardUserDefaults] setInteger:stepperVal forKey:@"jpegQuality"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (IBAction)pngOutDidClick:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:[(NSButton *)sender state] forKey:@"pngOut"];
	[[NSUserDefaults standardUserDefaults] synchronize];
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
			//[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/terwanerik/Retini/raw/master/Retini.zip"]];
			
			[self downloadNewZip];
		} else{
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/terwanerik/Retini"]];
		}
	}
}

- (void)downloadNewZip
{
	[loader startAnimation:nil];
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer]; //to bad github gives the raw content as plain text
	manager.requestSerializer = [AFHTTPRequestSerializer serializer]; //otherwise this would have been AFPlistResponse / requestserializers
	
	[manager GET:@"https://github.com/terwanerik/Retini/raw/master/Retini.zip"
		parameters:nil
			 success:^(AFHTTPRequestOperation *operation, id responseObject) {
				 [self installZip:responseObject];
			 }
			 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				 NSAlert *newVersionAlert = [[NSAlert alloc] init];
				 [newVersionAlert setMessageText:@"Couldn't download new version. Would you like to download it straight from GitHub?"];
				 [newVersionAlert addButtonWithTitle:@"GitHub? Letsgo!"];
				 [newVersionAlert addButtonWithTitle:@"I'm good."];
				 [newVersionAlert setDelegate:nil];
				 [newVersionAlert beginSheetModalForWindow:self.window
																		 modalDelegate:self
																		didEndSelector:@selector(alertButtonClicked:returnCode:contextInfo:)
																			 contextInfo:nil];
			 }];
}

- (void)installZip:(NSData *)zip
{
	NSString *filePath = [NSString stringWithFormat:@"%@/Retini.zip", NSTemporaryDirectory()];
	
	if([[NSFileManager defaultManager] createFileAtPath:filePath
																					contents:zip
																					 attributes:nil]){
		
		NSTask *task = [[NSTask alloc] init];
		[task setLaunchPath:@"/usr/bin/unzip"];
		[task setCurrentDirectoryPath:NSTemporaryDirectory()];
		[task setArguments:@[@"-o", @"Retini.zip"]];
		[task launch];
		[task waitUntilExit];
		
		[loader stopAnimation:nil];
		
		NSError *error;
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
		
		if(!error){
			[[NSFileManager defaultManager] moveItemAtPath:[NSString stringWithFormat:@"%@/Retini.app", NSTemporaryDirectory()]
																							toPath:@"/Applications/Retini_tmp.app"
																							 error:&error];
			
			[self relaunchAfterDelay:1.0];
		}
	}
}

- (void)relaunchAfterDelay:(float)seconds
{
	NSTask *task = [[NSTask alloc] init];
	NSMutableArray *args = [NSMutableArray array];
	[args addObject:@"-c"];
	[args addObject:[NSString stringWithFormat:@"sleep %f; open \"%@\"", seconds, @"/Applications/Retini.app"]];
	[task setLaunchPath:@"/bin/sh"];
	[task setArguments:args];
	[task launch];
	
	NSError *error;
	
	if([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Retini.app"]){
		[[NSFileManager defaultManager] removeItemAtPath:@"/Applications/Retini.app" error:&error];
	}
	
	if(!error){
		[[NSFileManager defaultManager] moveItemAtPath:@"/Applications/Retini_tmp.app"
																						toPath:@"/Applications/Retini.app"
																						 error:&error];
		
		[[NSApplication sharedApplication] terminate:nil];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self checkForUpdates:nil];
	
	if([[NSUserDefaults standardUserDefaults] integerForKey:@"jpegQuality"]){
		[jpegQualityStepper setDoubleValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"jpegQuality"]];
	}
	
	if([[NSUserDefaults standardUserDefaults] integerForKey:@"pngOut"]){
		[pngOutButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"pngOut"]];
	}
	
	int stepperVal = MIN(MAX([jpegQualityStepper intValue], 1), 10);
	
	[jpegQualityStepper setAlphaValue:0.7];
	[jpegQualityField setStringValue:[NSString stringWithFormat:@"%i/10", stepperVal]];
	
	[settingsButton setTarget:self];
	[settingsButton setAction:@selector(hitSettings:)];
	
	NSColor *color = [NSColor colorWithWhite:1.0 alpha:0.8];
	NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[pngOutButton attributedTitle]];
	NSRange titleRange = NSMakeRange(0, [colorTitle length]);
	[colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
	[pngOutButton setAttributedTitle:colorTitle];
	
	[self.window setBackgroundColor:[NSColor colorWithWhite:0.08 alpha:1.0]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

@end
