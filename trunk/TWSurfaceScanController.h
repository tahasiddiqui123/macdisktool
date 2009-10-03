//
//  TWSurfaceScanController.h
//  MacDiskTool
//
//  Created by Georg Schölly on 09.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TWDevice;
@class TWSurfaceScanOperation;

@interface TWSurfaceScanController : NSObject {
	NSWindowController *windowController;
	TWDevice *device;
	NSOperationQueue *operationQueue;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *progressLabel;
	TWSurfaceScanOperation *operation;
	NSUInteger blocksPerSecond;
	UInt64 lastBlockCount;
}

@property(retain) NSWindowController *windowController;
@property(retain) TWDevice *device;
@property(retain) NSOperationQueue *operationQueue;
@property(retain) TWSurfaceScanOperation *operation;

+ (void)scanDevice:(TWDevice *)theDevice options:(NSDictionary *)options;
- (id)init;
- (void)dealloc;
- (void)scan;

@end
