//
//  AppController.m
//  BadRobin
//
//  Created by Georg Schölly on 22.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <paths.h>
#include <sys/param.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/IOBSD.h>
#include <IOKit/storage/IOMedia.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/Kext/KextManager.h>

#import "TWDevice.h"
#import "TWStorageSizeFormatter.h"
#import "RSVerticallyCenteredTextFieldCell.h"
#import "TWSurfaceScanController.h"

@implementation AppController

@synthesize storageDevices;
@synthesize selectedDevicesIndexes;

- (id)init {
	if (self = [super init]) {
		self.storageDevices = [NSArray array];
	}
	return self;
}

- (void)dealloc {
	self.storageDevices = nil;
	[super dealloc];
}

- (void)awakeFromNib {
	devicesTableView.rowHeight = 50.0;
	TWStorageSizeFormatter *sizeFormatter = [[[TWStorageSizeFormatter alloc] init] autorelease];

	[[[devicesTableView tableColumnWithIdentifier:@"size"] dataCell] setFormatter:sizeFormatter];
	[self populateStorageDevices];
}

- (void)populateStorageDevices {
	// create matching dictionary
	CFMutableDictionaryRef classesToMatch;
	classesToMatch = IOServiceMatching(kIOMediaClass);
	if (classesToMatch == NULL) {
		[NSException raise:@"TWError" format:@"Classes to match could not be created"];
		return;
	}
	
	// get iterator of matching services
	io_iterator_t mediaIterator;
	kern_return_t kernResult;
	kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault,
											  classesToMatch,
											  &mediaIterator);
	
	if (kernResult != KERN_SUCCESS) {
		[NSException raise:@"TWError" format:@"Matching services did not succed."];
	}
	
	// iterate over all found medias
	io_object_t nextMedia;
	NSMutableArray *detectedDevices = [NSMutableArray array];
	while (nextMedia = IOIteratorNext(mediaIterator)) {
		NSMutableDictionary *properties;
		kernResult = IORegistryEntryCreateCFProperties(nextMedia,
														  (CFMutableDictionaryRef *)&properties,
														  kCFAllocatorDefault, 0);
		
		if (kernResult != KERN_SUCCESS) {
			[NSException raise:@"TWError" format:@"Getting properties threw error."];
		}
				
		// is it a whole device or just a partition?
		if ([[properties valueForKey:@"Whole"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
			TWDevice *device = [[[TWDevice alloc] init] autorelease];
			
			device.devicePath = [NSString stringWithFormat:@"%sr%@", _PATH_DEV, [properties valueForKey:@"BSD Name"]];
			device.blockSize = [[properties valueForKey:@"Preferred Block Size"] unsignedLongLongValue];
			device.writable = [[properties valueForKey:@"Writable"] boolValue];
			device.size = [[properties valueForKey:@"Size"] unsignedLongLongValue];
			
			io_name_t name;
			IORegistryEntryGetName(nextMedia, name);
			device.name = [NSString stringWithCString:name encoding:NSASCIIStringEncoding];

			NSString *bundleIdentifier = [properties valueForKeyPath:@"IOMediaIcon.CFBundleIdentifier"];
			NSString *resourceFile = [properties valueForKeyPath:@"IOMediaIcon.IOBundleResourceFile"];
			/* see http://lists.apple.com/archives/darwin-dev/2009/Oct/msg00088.html
			 * for the documentation of KextManagerCreateURLForBundleIdentifier
			 */
			NSURL *bundleURL = (NSURL *)KextManagerCreateURLForBundleIdentifier(NULL, (CFStringRef)bundleIdentifier);
			NSBundle *bundleWithIcon;
			// bundleWithURL is only available on >= MAC OS X 10.6
			if ([NSBundle respondsToSelector:@selector(bundleWithURL:)]) {
				bundleWithIcon = [NSBundle bundleWithURL:bundleURL];
			} else {
				bundleWithIcon = [NSBundle bundleWithPath:[bundleURL path]];
			}
			if (bundleURL) {
				CFRelease(bundleURL);
			}
			NSString *iconPath = [bundleWithIcon pathForResource:resourceFile ofType:nil];
			
			NSImage *icon = [[[NSImage alloc] initWithContentsOfFile:iconPath] autorelease];
			[icon setSize:NSMakeSize(32.0, 32.0)];
			device.icon = icon;
			
			[detectedDevices addObject:device];
		}
		
		// tidy up
		IOObjectRelease(nextMedia);
		CFRelease(properties);
	}
	IOObjectRelease(mediaIterator);
	
	self.storageDevices = detectedDevices;
}

- (IBAction)scan:(id)sender {
	TWDevice *device = [self.storageDevices objectAtIndex:[self.selectedDevicesIndexes firstIndex]];
	[TWSurfaceScanController scanDevice:device options:nil];
}

@end
