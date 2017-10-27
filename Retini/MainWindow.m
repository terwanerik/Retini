//
//  MainWindow.m
//  Retini
//
//  Created by Erik Terwan on 27/10/2017.
//  Copyright © 2017 ET-ID. All rights reserved.
//

#import "MainWindow.h"

@interface MainWindow ()

@property (nonatomic, retain) UpdateModel *updateModel;

@end

@implementation MainWindow

@synthesize jpegQualityField, jpegQualityStepper, settingsButton, pngOutButton;
@synthesize loader;

- (id)init
{
	self = [super init];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag
{
	self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag screen:(NSScreen *)screen
{
	self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag screen:screen];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	self.updateModel = [[UpdateModel alloc] init];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self.updateModel setDelegate:self];
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
	
	[self setBackgroundColor:[NSColor colorWithWhite:0.08 alpha:1.0]];
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
	[self.updateModel checkForUpdates:sender];
}

- (void)updateModel:(id)model didFoundNewVersion:(bool)newVersion sender:(id)sender
{
	if(newVersion) {
		NSAlert *newVersionAlert = [[NSAlert alloc] init];
		[newVersionAlert setMessageText:@"A new version of Retini is found. Would you like to download the update?"];
		[newVersionAlert addButtonWithTitle:@"Update"];
		[newVersionAlert addButtonWithTitle:@"Cancel"];
		[newVersionAlert setDelegate:self];
		[newVersionAlert beginSheetModalForWindow:self
																modalDelegate:self
															 didEndSelector:@selector(alertButtonClicked:returnCode:contextInfo:)
																	contextInfo:nil];
	} else if (sender != nil) {
		NSAlert *newVersionAlert = [[NSAlert alloc] init];
		[newVersionAlert setMessageText:@"No new version is found.. Check GitHub to be sure?"];
		[newVersionAlert addButtonWithTitle:@"GitHub? Letsgo!"];
		[newVersionAlert addButtonWithTitle:@"I'm good."];
		[newVersionAlert setDelegate:nil];
		[newVersionAlert beginSheetModalForWindow:self
																modalDelegate:self
															 didEndSelector:@selector(alertButtonClicked:returnCode:contextInfo:)
																	contextInfo:nil];
	}
}

- (void)updateModel:(UpdateModel *)model didStartDownloading:(bool)downloading
{
	[loader startAnimation:nil];
}

- (void)updateModel:(UpdateModel *)model didFinishDownloading:(bool)successfull
{
	if (successfull) {
		[loader stopAnimation:nil];
	} else {
		NSAlert *newVersionAlert = [[NSAlert alloc] init];
		[newVersionAlert setMessageText:@"Couldn't download new version. Would you like to download it straight from GitHub?"];
		[newVersionAlert addButtonWithTitle:@"GitHub? Letsgo!"];
		[newVersionAlert addButtonWithTitle:@"I'm good."];
		[newVersionAlert setDelegate:nil];
		[newVersionAlert beginSheetModalForWindow:self
																modalDelegate:self
															 didEndSelector:@selector(alertButtonClicked:returnCode:contextInfo:)
																	contextInfo:nil];
	}
}

- (void)updateModel:(UpdateModel *)model didFinishInstalling:(bool)successfull
{
	[[NSApplication sharedApplication] terminate:nil];
}

- (void)alertButtonClicked:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == 1000) {
		if (alert.delegate == self) {
			[self.updateModel downloadNewVersion];
		} else{
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/terwanerik/Retini"]];
		}
	}
}

@end
