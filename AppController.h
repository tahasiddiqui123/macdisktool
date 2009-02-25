//
//  AppController.h
//  BadRobin
//
//  Created by Georg Schölly on 22.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
	IBOutlet NSTableView *devicesTableView;
	NSArray *storageDevices;
}

@property(copy) NSArray *storageDevices;

- (id)init;
- (void)awakeFromNib;
- (void)populateStorageDevices;

- (NSBundle *)bundleWithKnownIdentifier:(NSString *)identifier;

@end
