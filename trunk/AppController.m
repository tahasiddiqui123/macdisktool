//
//  AppController.m
//  BadRobin
//
//  Created by Georg Schölly on 22.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"

#import "TWDevice.h"
#import "TWStorageSizeFormatter.h"
#import "RSVerticallyCenteredTextFieldCell.h"
#import "TWSurfaceScanController.h"

@implementation AppController

@synthesize storageDevices;
@synthesize selectedDevicesIndexes;

- (id)init {
	if (self = [super init]) {
		storageDevices = [[TWDevice allDevices] retain];
	}
	return self;
}

- (void)dealloc {
	[storageDevices release];
	[super dealloc];
}

- (void)awakeFromNib {
	devicesTableView.rowHeight = 50.0;
	TWStorageSizeFormatter *sizeFormatter = [[[TWStorageSizeFormatter alloc] init] autorelease];

	[[[devicesTableView tableColumnWithIdentifier:@"size"] dataCell] setFormatter:sizeFormatter];
}

- (IBAction)scan:(id)sender {
	TWDevice *device = [self.storageDevices objectAtIndex:[self.selectedDevicesIndexes firstIndex]];
	[TWSurfaceScanController scanDevice:device options:nil];
}

@end
