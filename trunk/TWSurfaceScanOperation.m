//
//  TWSurfaceScanOperation.m
//  MacDiskTool
//
//  Created by Georg Schölly on 08.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TWSurfaceScanOperation.h"
#import "TWReadOnlySurfaceScanOperation.h"
#import "TWDevice.h"
#import <sys/socket.h>


@interface TWSurfaceScanOperation (PrivateMethods)

- (int)getAuthorizedFileHandle;

@end

@implementation TWSurfaceScanOperation

@synthesize device;
@synthesize badBlocks;
@synthesize fileDescriptor;
@synthesize scannedBlockCount;
@synthesize totalBlockCount;

- (id)initSurfaceScanOperationWithDevice:(TWDevice *)theDevice scanMode:(TWSurfaceScanMode)scanMode {
	// working around bug
	// http://stackoverflow.com/questions/1516905/
	// rdar://7274868
	self = [super init];
	[self release];
	
	Class newClass = Nil;
	if (scanMode == TWReadOnlyScanMode) {
		newClass = [TWReadOnlySurfaceScanOperation class];
	}
	if (self = [[newClass alloc] init]) {
		self.device = theDevice;
		self.scannedBlockCount = 0;
		self.totalBlockCount = theDevice.size / theDevice.blockSize;
	}
	return self;
}

- (void)main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	self.fileDescriptor = [self getAuthorizedFileHandle];
	
	UInt64 blockCount = self.totalBlockCount;
	UInt64 currentBlock = 0;
	const UInt64 scanAtOnce = 64;
	
	while (currentBlock < blockCount) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		if (![self scanBlocksFrom:currentBlock count:scanAtOnce error:nil]) {
			// Error! Loop over every block individually.
			for (UInt64 i = 0; i < scanAtOnce; i++) {
				NSError *error = nil;
				UInt64 address = currentBlock + i;
				if (![self scanBlocksFrom:currentBlock + i count:1 error:&error]) {
					// Bad block
					[self.badBlocks addObject:[NSNumber numberWithUnsignedLongLong:address]];
				}
			}
		}
		currentBlock += scanAtOnce;
		self.scannedBlockCount = currentBlock;
		[pool drain];
	}
	
	close(self.fileDescriptor);
	[pool drain];
}

- (int)getAuthorizedFileHandle {
	int pipe[2];
	
	socketpair(AF_UNIX, SOCK_STREAM, 0, pipe);
	
	if (fork() == 0) {		// child
		// close parent's pipe
		close(pipe[0]);
		dup2(pipe[1], STDOUT_FILENO);
		
		const char *authopenPath = "/usr/libexec/authopen";
		execl(authopenPath, authopenPath, "-stdoutpipe", [self.device.devicePath fileSystemRepresentation], NULL);
		
		NSLog(@"Fatal error, quitting.");
		exit(-1);
	}
	// parent
	// close childs's pipe
	close(pipe[1]);
		
	char buffer[4096];
	struct iovec msg_iov = { &buffer, sizeof(buffer) };
	struct msghdr message;
	const size_t controlLen = sizeof(struct cmsghdr) + sizeof(int);
	struct cmsghdr *msg_control = malloc(controlLen);
	message.msg_name = NULL;
	message.msg_namelen = 0;
	message.msg_iov = &msg_iov;
	message.msg_iovlen = 1;
	message.msg_control = msg_control;
	message.msg_controllen = controlLen;
	
	ssize_t receivedSize = recvmsg(pipe[0], &message, 0);
	if (receivedSize < 0) {
		return -1;
	}
	
	return *(int *)CMSG_DATA(message.msg_control);
}

- (void)dealloc {
	self.device = nil;
	self.badBlocks = nil;
	[super dealloc];
}

@end

@implementation TWSurfaceScanOperation (AbstractMethods)

- (BOOL)scanBlocksFrom:(UInt64)startBlock count:(UInt64)count error:(NSError **)error {
	return NO;
}

@end

