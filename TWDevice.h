//
//  TWDevice.h
//  BadRobin
//
//  Created by Georg Schölly on 23.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TWDevice : NSObject {
	NSString *name;
	NSString *devicePath;
	UInt64 blockSize;
	UInt64 size;
	BOOL writable;
	NSImage *icon;
}

@property(copy) NSString *name;
@property(copy) NSString *devicePath;
@property UInt64 blockSize;
@property UInt64 size;
@property BOOL writable;
@property(retain) NSImage *icon;

+ (NSArray *)allDevices;

@end
