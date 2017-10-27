//
//  UpdateModel.m
//  Retini
//
//  Created by Erik Terwan on 27/10/2017.
//  Copyright © 2017 ET-ID. All rights reserved.
//

#import "UpdateModel.h"

@implementation UpdateModel

- (void)checkForUpdates:(id)sender
{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer]; //to bad github gives the raw content as plain text
	manager.requestSerializer = [AFHTTPRequestSerializer serializer]; //otherwise this would have been AFPlistResponse / requestserializers
	
	[manager GET:@"https://raw.githubusercontent.com/terwanerik/Retini/master/Retini/Info.plist" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		[self checkPlist:responseObject andOrigin:sender];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		// just leave it be.
		NSLog(@"checkForUpdates failed");
		if (self.delegate != nil) {
			if ([self.delegate respondsToSelector:@selector(updateModel:didFinishDownloading:)]) {
				[self.delegate updateModel:self didFinishDownloading:false];
			}
		}
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
	
	if (self.delegate != nil) {
		if ([self.delegate respondsToSelector:@selector(updateModel:didFoundNewVersion:sender:)]) {
			[self.delegate updateModel:self didFoundNewVersion:(onlineVersion > myVersion) sender:sender];
		}
	}
}

- (void)downloadNewZip
{
	if (self.delegate != nil) {
		if ([self.delegate respondsToSelector:@selector(updateModel:didStartDownloading:)]) {
			[self.delegate updateModel:self didStartDownloading:true];
		}
	}
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer]; //to bad github gives the raw content as plain text
	manager.requestSerializer = [AFHTTPRequestSerializer serializer]; //otherwise this would have been AFPlistResponse / requestserializers
	
	[manager GET:@"https://github.com/terwanerik/Retini/raw/master/Retini.zip"
		parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
			[self installZip:responseObject];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (self.delegate != nil) {
			if ([self.delegate respondsToSelector:@selector(updateModel:didFinishDownloading:)]) {
				[self.delegate updateModel:self didFinishDownloading:false];
			}
		}
	}];
}


- (void)installZip:(NSData *)zip
{
	NSString *filePath = [NSString stringWithFormat:@"%@/Retini.zip", NSTemporaryDirectory()];
	
	if([[NSFileManager defaultManager] createFileAtPath:filePath  contents:zip attributes:nil]){
		NSTask *task = [[NSTask alloc] init];
		[task setLaunchPath:@"/usr/bin/unzip"];
		[task setCurrentDirectoryPath:NSTemporaryDirectory()];
		[task setArguments:@[@"-o", @"Retini.zip"]];
		[task launch];
		[task waitUntilExit];
		
		if (self.delegate != nil) {
			if ([self.delegate respondsToSelector:@selector(updateModel:didFinishDownloading:)]) {
				[self.delegate updateModel:self didFinishDownloading:true];
			}
		}
		
		NSError *error;
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
		
		if(!error){
			NSString *fromPath = [NSString stringWithFormat:@"%@/Retini.app", NSTemporaryDirectory()];
			NSString *toPath = @"/Applications/Retini_tmp.app";
			
			[[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:&error];
			
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
	
	if (!error) {
		[[NSFileManager defaultManager] moveItemAtPath:@"/Applications/Retini_tmp.app"
																						toPath:@"/Applications/Retini.app"
																						 error:&error];
		if (self.delegate != nil) {
			if ([self.delegate respondsToSelector:@selector(updateModel:didFinishInstalling:)]) {
				[self.delegate updateModel:self didFinishInstalling:true];
			}
		}
	}
}

@end
