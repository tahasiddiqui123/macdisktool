//
//  TWStorageSizeFormatter.m
//  BadRobin
//
//  Created by Georg Schölly on 23.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TWStorageSizeFormatter.h"


@implementation TWStorageSizeFormatter

- (NSString *)stringForObjectValue:(id)anObject
{
    if (![anObject isKindOfClass:[NSNumber class]]) {
        return nil;
    }
	
	const unsigned long long tera = 1099511627776;
	const unsigned long long giga = 1073741824;
	const unsigned long long mega = 1048576;
	const unsigned long long kilo = 1024;
	
	unsigned long long size = [anObject unsignedLongLongValue];
	
	if (size >= tera) {
		return [NSString stringWithFormat:@"%llu TB", size / giga];
	} else if (size >= giga) {
		return [NSString stringWithFormat:@"%llu GB", size / giga];
	} else if (size >= mega) {
		return [NSString stringWithFormat:@"%llu MB", size / mega];
	} else if (size >= kilo) {
		return [NSString stringWithFormat:@"%llu KB", size / kilo];
	} else {
		return [NSString stringWithFormat:@"%llu B", size];
	}
}

@end
