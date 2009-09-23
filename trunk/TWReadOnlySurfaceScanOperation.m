//
//  TWReadOnlySurfaceScanOperation.m
//  MacDiskTool
//
//  Created by Georg Schölly on 08.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TWReadOnlySurfaceScanOperation.h"
#import "TWDevice.h"


@implementation TWReadOnlySurfaceScanOperation

- (BOOL)scanBlocksFrom:(UInt64)startBlock count:(UInt64)count error:(NSError **)error {
	BOOL hasError = NO;
	UInt64 blockSize = self.device.blockSize;
	
	void *buffer = malloc(blockSize * count);
	ssize_t bytesRead = pread(self.fileDescriptor,
							  buffer,
							  blockSize * count,
							  startBlock * blockSize);
	// Error
	if (bytesRead < 0) {
		hasError = YES;
		if (error) {
			*error = [NSError errorWithDomain:@"reading" code:bytesRead userInfo:nil];
		}
	}
	free(buffer);
	return !hasError;
}

@end
