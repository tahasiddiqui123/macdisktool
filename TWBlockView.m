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

- (void) awakeFromNib {
}

- (void)drawRect:(NSRect)rect {
	NSRectClip(rect);
	
	const CGFloat blockSize = 10.0;
	const CGFloat blockPadding = 5.0;
	const CGFloat shadowOffset = 2.0;
	const CGFloat totalSize = blockSize + blockPadding * 2.0;
	const NSRect blockRect = NSMakeRect(blockPadding, blockPadding, blockSize, blockSize);
	
	NSRect viewRect = [self bounds];
	viewRect = NSInsetRect(viewRect, -blockPadding, -blockPadding + shadowOffset / 2.0);
	
	NSAffineTransform *move = [NSAffineTransform transform];
	[move translateXBy:-blockPadding yBy:-blockPadding + shadowOffset];
	[move concat];
	
	CGFloat viewHeight = NSHeight(viewRect);
	CGFloat viewWidth = NSWidth(viewRect);

	NSUInteger totalRows = viewHeight / totalSize;
	NSUInteger totalColumns = viewWidth / totalSize;
	
	CGFloat averageWidth = viewWidth / (CGFloat)totalColumns;
	CGFloat averageHeight = viewHeight / (CGFloat)totalRows;
		
	NSRect *rects = malloc(sizeof(NSRect) * totalRows * totalColumns);
	NSRect *rectsPointer = rects;

	for (NSUInteger row = 0; row < totalRows; row++) {
		for (NSUInteger column = 0; column < totalColumns; column++) {
			NSRect theRect = NSOffsetRect(blockRect, round(averageWidth * column), round(averageHeight * row));
			*rectsPointer = theRect;
			rectsPointer++;
		}
	}
	
	NSShadow *shadow = [[NSShadow alloc] init];
	shadow.shadowOffset = NSMakeSize(shadowOffset, -shadowOffset);
	shadow.shadowColor = [NSColor darkGrayColor];
	[shadow set];
	
	[[NSColor greenColor] set];
	NSRectFillList(rects, totalRows * totalColumns);
	free(rects);
}

@end
