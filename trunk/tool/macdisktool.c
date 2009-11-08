/*
 *  macdisktool.c
 *  MacDiskTool
 *
 *  Created by Georg Schölly on 08.10.09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "macdisktool.h"

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/uio.h>
#include <unistd.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/IOBSD.h>
#include <IOKit/storage/IOMedia.h>
#include <CoreFoundation/CoreFoundation.h>

enum status {
	success = 0,
	error = 1,
	eof = 1,
};

void tryToRead(int fd, enum status map[], off_t start, size_t count, size_t readsize);

void readOnlySurfaceScan(char *path, int statusPipe)
{
	FILE *pipe = fdopen(statusPipe, "r+");
	// look up device number with stat
	struct stat stats;
	if (stat(path, &stats) != 0) {
		return;
	}
	int bsd_major = major(stats.st_rdev);
	int bsd_minor = minor(stats.st_rdev);
	
	CFTypeRef keys[2] = { CFSTR(kIOBSDMajorKey), CFSTR(kIOBSDMinorKey) };
	CFTypeRef values[2];
	values[0] = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &bsd_major);
	values[1] = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &bsd_minor);

	CFDictionaryRef matchingDictionary = CFDictionaryCreate(kCFAllocatorDefault,
															&keys, &values,
															sizeof(keys) / sizeof(*keys),
															&kCFTypeDictionaryKeyCallBacks,
															&kCFTypeDictionaryValueCallBacks);
	
	CFRelease(values[0]);
	CFRelease(values[1]);
	// IOServiceGetMatchingService uses up one reference to the dictionary
	io_service_t service = IOServiceGetMatchingService(kIOMasterPortDefault,
													   matchingDictionary);
	
	if (!service) {
		return;
	}
	CFNumberRef blockSizeProperty = (CFNumberRef)IORegistryEntryCreateCFProperty(service,
                                                                                 CFSTR(kIOMediaPreferredBlockSizeKey),
                                                                                 kCFAllocatorDefault, 0);
	if (!blockSizeProperty) {
		return;
	}
	
	int blockSize;
	CFNumberGetValue(blockSizeProperty, kCFNumberIntType, &blockSize);
	CFRelease(blockSizeProperty);
	
	size_t optimalReadSize = stats.st_blksize;
	unsigned readAtOnce = optimalReadSize / blockSize;
	
	fprintf(pipe, "INFO blocksize %u\n", blockSize);
	fprintf(pipe, "INFO readsize %u\n", optimalReadSize);

	int file = open(path, O_RDONLY);
	off_t pos = 0;
	
	char noEOF = 1;
	enum status map[readAtOnce];
	while (noEOF) {
		// read a large chunk
		tryToRead(file, map, pos, 1, optimalReadSize);
		
		if (map[0] != success) {
			// read again in 1-block chunks
			tryToRead(file, map, pos, readAtOnce, blockSize);
			
			for (unsigned i = 0; i < readAtOnce; i++) {
				if (map[i] == error) {
					fprintf(pipe, "ERROR at %llu\n", (long long unsigned)pos + i);
				} else if (map[i] == eof) {
					// jump out of loop
					noEOF = 0;
					break;
				}
			}
		}
		fprintf(pipe, "INFO position %llu\n", (long long unsigned)pos);
		pos += optimalReadSize;
	}
	fprintf(pipe, "GOODBYE\n");
	close(file);
}

void tryToRead(int fd, enum status map[], off_t start, size_t count, size_t readsize)
{
	void *buffer = malloc(readsize);
	
	//for (off_t pos = start, pos < end; pos += readsize) {
	for (size_t i = 0; i < count; i++) {
		ssize_t bytesRead = pread(fd, buffer, readsize, start);
		
		// ERROR
		if (bytesRead < 0) {
			map[i] = error;
		// EOF
		} else if (bytesRead < readsize) {
			map[i] = eof;
		} else {
			map[i] = success;
			start += readsize;
		}
	}
}