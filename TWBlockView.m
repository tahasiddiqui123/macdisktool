//
//  TWBlockView.m
//  MacDiskTool
//
//  Created by Georg Schölly on 23.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TWBlockView.h"


@implementation TWBlockView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	const CGFloat blockSize = 10.0;
	const CGFloat blockPadding = 5.0;
	const CGFloat totalSize = blockSize + blockPadding * 2.0;
	
	const NSRect topRect = NSMakeRect(blockPadding, blockPadding, blockSize, blockSize);
	const NSRect bottomRect = NSMakeRect(blockPadding, blockPadding, blockSize, blockSize / 1.9);
	const NSRect shadowRect = NSOffsetRect(topRect, 2.0, -2.0);
	
	NSColor *shadowColor = [NSColor grayColor];
	NSColor *topColor = [NSColor colorWithCalibratedRed:0.64 green:0.92 blue:0.74 alpha:1.0];
	NSColor *bottomColor = [NSColor colorWithCalibratedRed:0.42 green:0.87 blue:0.58 alpha:1.0];
		
	NSRect myRect = [self bounds];
	CGFloat height = NSHeight(myRect);
	CGFloat width = NSWidth(myRect);
	
	NSAffineTransform *up = [NSAffineTransform transform];
	[up translateXBy:0.0 yBy:totalSize];
	NSAffineTransform *right = [NSAffineTransform transform];
	[right translateXBy:totalSize yBy:0.0];
	
	NSUInteger rows = height / totalSize;
	NSUInteger columns = width / totalSize;
	
	NSGraphicsContext *context = [NSGraphicsContext currentContext];
	for (NSUInteger i = 0; i < rows; i++) {
		[context saveGraphicsState];
		for (NSUInteger j = 0; j < columns; j++) {
			[shadowColor setFill];
			[NSBezierPath fillRect:shadowRect];
			[topColor setFill];
			[NSBezierPath fillRect:topRect];
			[bottomColor setFill];
			[NSBezierPath fillRect:bottomRect];
			[right concat];
		}
		[context restoreGraphicsState];
		[up concat];
	}
}

- (BOOL) isFlipped
{
	return YES;
}

@end
