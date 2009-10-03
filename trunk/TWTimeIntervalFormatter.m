//
//  TWTimeIntervalFormatter.m
//  MacDiskTool
//
//  Created by Georg Schölly on 02.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TWTimeIntervalFormatter.h"


@implementation TWTimeIntervalFormatter

@synthesize accuracy;

- (id) init
{
	self = [super init];
	if (self = [super init]) {
		accuracy = 4;
	}
	return self;
}

- (NSString *) stringForObjectValue:(id)anObject
{
	if (![anObject isKindOfClass:[NSNumber class]]) {
        return nil;
    }
	
	NSUInteger localAccuracy = self.accuracy;
	
	NSTimeInterval interval = [anObject doubleValue];
	NSMutableArray *components = [NSMutableArray arrayWithCapacity:localAccuracy];
	
	NSUInteger days = 0;
	NSUInteger hours = 0;
	NSUInteger minutes = 0;
	NSUInteger seconds = 0;
	
	days = (interval / 86400.0);
	hours = (NSUInteger)(interval / 3600.0) % 24;
	minutes = (NSUInteger)(interval / 60.0) % 60;
	seconds = (NSUInteger)interval % 60;
	
	struct list {
		NSUInteger value;
		NSString *singularForm;
		NSString *pluralForm;
	};
	
	struct list list[4];
	list[0].value = days;
	list[0].singularForm = @"1 day";
	list[0].pluralForm = @"%u days";
	list[1].value = hours;
	list[1].singularForm = @"1 hour";
	list[1].pluralForm = @"%u hours";
	list[2].value = minutes;
	list[2].singularForm = @"1 minute";
	list[2].pluralForm = @"%u minutes";
	list[3].value = seconds;
	list[3].singularForm = @"1 second";
	list[3].pluralForm = @"%u seconds";
	
	for (NSUInteger i = 0; i < localAccuracy && i < 4; i++) {
		if (list[i].value == 0 && [components count] == 0) {
			localAccuracy++;
		} else if (list[i].value == 1) {
			[components addObject:NSLocalizedStringFromTable(list[i].singularForm, nil, @"TWTimeIntervalFormatter")];
		} else if (list[i].value > 1) {
			[components addObject:[NSString stringWithFormat:NSLocalizedStringFromTable(list[i].pluralForm, nil, @"TWTimeIntervalFormatter"), list[i].value]];
		}
	}
    return [components componentsJoinedByString:@" "];
}

- (NSAttributedString *) attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes
{
	NSString *theString = [self stringForObjectValue:anObject];
	return [[[NSAttributedString alloc] initWithString:theString attributes:attributes] autorelease];
}

@end
