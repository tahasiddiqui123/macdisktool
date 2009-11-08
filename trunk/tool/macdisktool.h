/*
 *  macdisktool.h
 *  MacDiskTool
 *
 *  Created by Georg Schölly on 08.10.09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _MACDISKTOOL_H_
#define _MACDISKTOOL_H_

#include <CoreFoundation/CoreFoundation.h>

enum kCommand {
	kInvalidCommand = 0,
	kReadCommand,
	kReadWriteCommand,
	kSaveReadWriteCommand,
};

void readOnlySurfaceScan(char *path, int statusPipe);

#endif
