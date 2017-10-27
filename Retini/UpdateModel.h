//
//  UpdateModel.h
//  Retini
//
//  Created by Erik Terwan on 27/10/2017.
//  Copyright © 2017 ET-ID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@protocol UpdateModelDelegate;

@interface UpdateModel : NSObject

- (void)checkForUpdates:(id)sender;
- (void)downloadNewZip;

@property (nonatomic, weak) id <UpdateModelDelegate> delegate;

@end

@protocol UpdateModelDelegate <NSObject>

@optional
- (void)updateModel:(UpdateModel *)model didFoundNewVersion:(bool)newVersion sender:(id)sender;
- (void)updateModel:(UpdateModel *)model didStartDownloading:(bool)downloading;
- (void)updateModel:(UpdateModel *)model didFinishDownloading:(bool)successfull;
- (void)updateModel:(UpdateModel *)model didFinishInstalling:(bool)successfull;

@end

