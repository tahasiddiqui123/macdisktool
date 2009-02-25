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
	NSNumber *blockSize;
	NSNumber *size;
	NSNumber *writable;
	NSImage *icon;
}

@property(copy) NSString *name;
@property(copy) NSString *devicePath;
@property(copy) NSNumber *blockSize;
@property(copy) NSNumber *size;
@property(copy) NSNumber *writable;
@property(retain) NSImage *icon;

@end
