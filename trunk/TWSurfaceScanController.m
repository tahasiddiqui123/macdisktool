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
#import "TWTimeIntervalFormatter.h"


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
	
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0
													  target:self
													selector:@selector(sampleProgress:)
													userInfo:nil
													 repeats:YES];
	[self.operation addObserver:self
					 forKeyPath:@"scannedBlockCount"
						options:NSKeyValueObservingOptionNew
						context:NULL];
	[self.operationQueue addOperation:self.operation];
}

- (void) sampleProgress:(NSTimer *)timer
{
	blocksPerSecond = (blocksPerSecond * 4 + (self.operation.scannedBlockCount - lastBlockCount)) / 5;
	lastBlockCount = self.operation.scannedBlockCount;
}

- (void) updateInterface
{
	static NSNumberFormatter *percentageFormatter = nil;
	static TWTimeIntervalFormatter *timeFormatter = nil;
	@synchronized(percentageFormatter) {
		if (!percentageFormatter) {
			percentageFormatter = [[NSNumberFormatter alloc] init];
			[percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
		}
	}
	@synchronized(timeFormatter) {
		if (!timeFormatter) {
			timeFormatter = [[TWTimeIntervalFormatter alloc] init];
			timeFormatter.accuracy = 2;
		}
	}
	TWSurfaceScanOperation *theOperation = self.operation;
	double progress = (double)theOperation.scannedBlockCount / (double)theOperation.totalBlockCount;
	progressIndicator.doubleValue = progress;
	
	NSString *formattedPercentage = [percentageFormatter stringFromNumber:[NSNumber numberWithDouble:progress]];
	NSString *progressText = [NSString stringWithFormat:NSLocalizedString(@"Progress: %@  ", nil), formattedPercentage];
	
	NSAttributedString *formattedRemainingTime;
	if (blocksPerSecond != 0) {
		double remainingTime = 0.0;
		remainingTime = (theOperation.totalBlockCount - theOperation.scannedBlockCount) / blocksPerSecond;
	
		formattedRemainingTime = [timeFormatter attributedStringForObjectValue:[NSNumber numberWithDouble:remainingTime]
														 withDefaultAttributes:[NSDictionary dictionaryWithObject:[NSColor darkGrayColor]
																										   forKey:NSForegroundColorAttributeName]];
	
	} else {
		formattedRemainingTime = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Computing remaining time…", nil)] autorelease];
	}
	NSMutableAttributedString *styledStatusText = [[[NSMutableAttributedString alloc] initWithString:progressText] autorelease];
	[styledStatusText appendAttributedString:formattedRemainingTime];
	
	progressLabel.attributedStringValue = styledStatusText;
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
