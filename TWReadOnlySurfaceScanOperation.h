//
//  TWReadOnlySurfaceScanOperation.h
//  MacDiskTool
//
//  Created by Georg Schölly on 08.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TWSurfaceScanOperation.h"

@interface TWReadOnlySurfaceScanOperation : TWSurfaceScanOperation {
	
}

- (BOOL)scanBlocksFrom:(UInt64)startBlock count:(UInt64)count error:(NSError **)error;

@end
