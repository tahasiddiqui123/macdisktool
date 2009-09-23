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
	
	const UInt64 tera = 1099511627776;
	const UInt64 giga = 1073741824;
	const UInt64 mega = 1048576;
	const UInt64 kilo = 1024;
	
	UInt64 size = [anObject unsignedLongLongValue];
	
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
