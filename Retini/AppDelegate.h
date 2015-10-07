//
//  AppDelegate.h
//  Retini
//
//  Created by Erik Terwan on 16-06-15.
//  Copyright (c) 2015 ET-ID. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSAlertDelegate>

- (BOOL)processFile:(NSString *)file;

@end

