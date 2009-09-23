//
//  TWSurfaceScanOperation.h
//  MacDiskTool
//
//  Created by Georg Schölly on 08.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TWDevice;

typedef enum {
	TWReadOnlyScanMode,
	TWReadWriteScanMode,
	TWReadWriteNonDestructiveScanMode,
} TWSurfaceScanMode;

@interface TWSurfaceScanOperation : NSOperation {
	NSMutableArray *badBlocks;
	TWDevice *device;
	int fileDescriptor;
	UInt64 scannedBlockCount;
	UInt64 totalBlockCount;
}

@property(retain) TWDevice *device;
@property(retain) NSMutableArray *badBlocks;
@property int fileDescriptor;
@property UInt64 scannedBlockCount;
@property UInt64 totalBlockCount;

- (id)initSurfaceScanOperationWithDevice:(TWDevice *)theDevice scanMode:(TWSurfaceScanMode)scanMode;
- (void)dealloc;

- (void)main;

@end

@interface TWSurfaceScanOperation (AbstractMethods)

- (BOOL)scanBlocksFrom:(UInt64)start count:(UInt64)count error:(NSError **)error;

@end

