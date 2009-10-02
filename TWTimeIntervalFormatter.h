//
//  TWTimeIntervalFormatter.h
//  MacDiskTool
//
//  Created by Georg Schölly on 02.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TWTimeIntervalFormatter : NSFormatter {
	NSUInteger accuracy;
}

@property NSUInteger accuracy;

- (id) init;
- (NSString *) stringForObjectValue:(id)anObject;
- (NSAttributedString *) attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes;

@end
