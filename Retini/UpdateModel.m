//
//  UpdateModel.m
//  Retini
//
//  Created by Erik Terwan on 27/10/2017.
//  Copyright © 2017 ET-ID. All rights reserved.
//

#import "UpdateModel.h"
#define GHAPI_URL @"https://api.github.com/repos/terwanerik/Retini/releases"

@interface UpdateModel()

@property (nonatomic, retain) NSString *assetPath;
@property (nonatomic, retain) NSCharacterSet *numberSet;

@end

@implementation UpdateModel

- (id)init
{
	self = [super init];
	
	if (self) {
		self.numberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
	}
	
	return self;
}

- (void)checkForUpdates:(id)sender
{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFJSONResponseSerializer serializer];
	manager.requestSerializer = [AFHTTPRequestSerializer serializer];
	
	[manager GET:GHAPI_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		[self checkVersion:[self parseReleaseResponse:responseObject] andOrigin:sender];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self updateFailed];
	}];
}

- (int)parseReleaseResponse:(NSArray *)response
{
	int versionNumber = 0;
	
	if (![response isKindOfClass:[NSArray class]] || [response count] == 0) {
		return versionNumber;
	}
	
	NSDictionary *latestRelease = [response firstObject];
	
	if (![latestRelease isKindOfClass:[NSDictionary class]] || [latestRelease objectForKey:@"tag_name"] == nil) {
		return versionNumber;
	}
	
	
	NSString *versionTag = [latestRelease objectForKey:@"tag_name"];
	NSString *cleanVersionTag = [[versionTag componentsSeparatedByCharactersInSet:self.numberSet] componentsJoinedByString:@""];
	
	versionNumber = [cleanVersionTag intValue];
	
	NSArray *versionAssets = [latestRelease objectForKey:@"assets"];
	
	if (![versionAssets isKindOfClass:[NSArray class]] || [versionAssets count] == 0) {
		return versionNumber;
	}
	
	for (NSDictionary *dict in versionAssets) {
		if ([[dict objectForKey:@"content_type"] isEqualToString:@"application/zip"]) {
			self.assetPath = [dict objectForKey:@"browser_download_url"];
			
			break;
		}
	}
	
	return versionNumber;
}

- (void)checkVersion:(int)versionNumber andOrigin:(id)sender
{
	// remove dots to get big number. Versioning probably will never go beyond 10 so should work fine atm.
	NSString *versionTag = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString *cleanVersionTag = [[versionTag componentsSeparatedByCharactersInSet:self.numberSet] componentsJoinedByString:@""];
	
	int localVersionNumber = [cleanVersionTag intValue];
	
	if (self.delegate == nil) {
		return;
	}
	
	if ([self.delegate respondsToSelector:@selector(updateModel:didFoundNewVersion:sender:)]) {
		[self.delegate updateModel:self didFoundNewVersion:(versionNumber > localVersionNumber) sender:sender];
	}
}

- (void)downloadNewVersion
{
	if (self.delegate != nil) {
		if ([self.delegate respondsToSelector:@selector(updateModel:didStartDownloading:)]) {
			[self.delegate updateModel:self didStartDownloading:true];
		}
	}
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	manager.requestSerializer = [AFHTTPRequestSerializer serializer];
	
	[manager GET:self.assetPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
			[self installZip:responseObject];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self updateFailed];
	}];
}

- (void)installZip:(NSData *)zip
{
	NSString *filePath = [NSString stringWithFormat:@"%@/Retini.zip", NSTemporaryDirectory()];
	
	if ([[NSFileManager defaultManager] createFileAtPath:filePath  contents:zip attributes:nil]) {
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
		
		if (!error) {
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
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Retini.app"]) {
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

- (void)updateFailed
{
	if (self.delegate != nil) {
		if ([self.delegate respondsToSelector:@selector(updateModel:didFinishDownloading:)]) {
			[self.delegate updateModel:self didFinishDownloading:false];
		}
	}
}

@end
