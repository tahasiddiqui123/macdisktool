//
//  TWSurfaceScanController.m
//  MacDiskTool
//
//  Created by Georg Schölly on 09.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TWSurfaceScanController.h"
#import "TWSurfaceScanOperation.h"
#import "TWDevice.h"


@implementation TWSurfaceScanController

@synthesize windowController;
@synthesize device;
@synthesize operationQueue;
@synthesize operation;

- (id) init {
	if (self = [super init]) {
		self.windowController = [[NSWindowController alloc] initWithWindowNibName:@"ScanWindow" owner:self];
		self.operationQueue = [[NSOperationQueue alloc] init];
	}
	return self;
}

+ (void) scanDevice:(TWDevice *)theDevice options:(NSDictionary *)options {
	static NSMutableArray *controllers = nil;
	if (controllers == nil) {
		controllers = [[NSMutableArray array] retain];
	}
	TWSurfaceScanController *newController = [[[TWSurfaceScanController alloc] init] autorelease];
	[controllers addObject:newController];
	newController.device = theDevice;
	[newController scan];
}

- (void)scan
{
	[self.windowController.window makeKeyAndOrderFront:self];
	self.operation = [[[TWSurfaceScanOperation alloc] initSurfaceScanOperationWithDevice:self.device
																				scanMode:TWReadOnlyScanMode] autorelease];
	
	[self.operation addObserver:self
					 forKeyPath:@"scannedBlockCount"
						options:NSKeyValueObservingOptionNew
						context:NULL];
	[self.operationQueue addOperation:self.operation];
}

- (void) updateInterface
{
	static NSNumberFormatter *percentageFormatter = nil;
	if (!percentageFormatter) {
		percentageFormatter = [[NSNumberFormatter alloc] init];
		[percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
	}
	TWSurfaceScanOperation *theOperation = self.operation;
	double progress = (double)theOperation.scannedBlockCount / (double)theOperation.totalBlockCount;
	progressIndicator.doubleValue = progress;
	progressLabel.stringValue = [NSString stringWithFormat:NSLocalizedString(@"Progress: %@", nil),
														   [percentageFormatter stringFromNumber:[NSNumber numberWithDouble:progress]]];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"scannedBlockCount"]) {
		[self performSelectorOnMainThread:@selector(updateInterface)
							   withObject:nil
							waitUntilDone:NO];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

								 
- (void) dealloc {
	self.windowController = nil;
	self.device = nil;
	self.operationQueue = nil;
	[super dealloc];
}

@end
