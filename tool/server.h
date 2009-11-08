/*
 *  server.h
 *  MacDiskTool
 *
 *  Created by Georg Schölly on 06.10.09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _SERVER_H_
#define _SERVER_H_

#define GOODBYE "goodbye\n"
#include <CoreFoundation/CoreFoundation.h>

void startServer(int fd);

void socketCallBack(CFSocketRef s,
					CFSocketCallBackType callbackType,
					CFDataRef address,
					const void *data,
					void *info);
	
#endif
