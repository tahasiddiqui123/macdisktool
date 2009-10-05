//
//  TWBlockView.h
//  MacDiskTool
//
//  Created by Georg Schölly on 23.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TWBlockView : NSView {

}

- (id) initWithFrame:(NSRect)frame;
- (void) drawRect:(NSRect)rect;
- (BOOL) isFlipped;

@end
