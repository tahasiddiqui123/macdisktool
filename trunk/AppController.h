//
//  AppController.h
//  BadRobin
//
//  Created by Georg Schölly on 22.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TWDevice;

@interface AppController : NSObject {
	IBOutlet NSTableView *devicesTableView;
	NSArray *storageDevices;
	NSIndexSet *selectedDevicesIndexes;
}

@property(copy) NSArray *storageDevices;
@property(retain) NSIndexSet *selectedDevicesIndexes;

- (id)init;
- (void)dealloc;
- (void)awakeFromNib;
- (void)populateStorageDevices;

- (NSBundle *)bundleWithKnownIdentifier:(NSString *)identifier;

- (IBAction)scan:(id)sender;

@end
