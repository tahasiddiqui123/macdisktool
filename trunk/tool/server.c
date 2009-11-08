/*
 *  server.c
 *  MacDiskTool
 *
 *  Created by Georg Schölly on 06.10.09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "server.h"
#include <sys/socket.h>
#include <pthread.h>
#include <unistd.h>
#include <Security/Authorization.h>
#include "macdisktool.h"

void* processClient(void *data)
{
	int fd = (int)data;
	// keep those variables bigger than the strings scanned by fscanf!!!!
	char commandString[30];
	char device[1024];
	enum kCommand command = kInvalidCommand;
	
	FILE *f = fdopen(fd, "r");
	if (fscanf(f, "%20s %1000s\n", commandString, device) != 2) {
		goto goodbye;
	}
	
	// map command string to enum
	if (strcmp("readwrite", commandString) == 0) {
		command = kReadWriteCommand;
	} else if (strcmp("savereadwrite", commandString) == 0) {
		command = kSaveReadWriteCommand;
	} else if (strcmp("read", commandString) == 0) {
		command = kReadCommand;
	} else {
		goto goodbye;
	}
	
	// get authorization from socket
	AuthorizationExternalForm externalAuthorization;
	if (read(fd, externalAuthorization.bytes, kAuthorizationExternalFormLength) != kAuthorizationExternalFormLength) {
		goto goodbye;
	}
	
	// check if the user is authorized for this operation
	AuthorizationRef authorization;
	if (AuthorizationCreateFromExternalForm(&externalAuthorization, &authorization) != errAuthorizationSuccess) {
		goto goodbye;
	}
	
	AuthorizationItem right;
	AuthorizationRights myRights;
	myRights.count = 1;
	myRights.items = &right;
	
	AuthorizationFlags myFlags;
	myFlags = kAuthorizationFlagDefaults |
			  kAuthorizationFlagInteractionAllowed |
			  kAuthorizationFlagExtendRights;
	
	switch (command) {
		case kReadCommand:
			right.name = "sys.openfile.readonly.";
			break;
		case kSaveReadWriteCommand:
		case kReadWriteCommand:
			right.name = "sys.openfile.readwrite.";
			break;
	}

	// append device path to the name of the right.
	// See man 1 authopen for more information.
	char *rightName = malloc(strlen(right.name) + strlen(device) + 1);
	strcpy(rightName, right.name);
	strcat(rightName, device);
	right.name = rightName;
	
	// authorize
	OSStatus error = AuthorizationCopyRights(authorization,
											 &myRights,
											 kAuthorizationEmptyEnvironment,
											 myFlags,
											 NULL
											 );
	
	if (error == errAuthorizationSuccess) {
		switch (command) {
			case kReadCommand:
				readOnlySurfaceScan(device, fd);
				break;
			case kSaveReadWriteCommand:
				break;
			case kReadWriteCommand:
				break;
		}
	}
	
	// free stuff used for authorization
	AuthorizationFree(authorization, kAuthorizationFlagDefaults);
	free(rightName);

// jump to here *only* if a prior to authorization check fails
// doing otherwise might lead to leaks
goodbye:
	write(fd, GOODBYE, sizeof(GOODBYE));
	// closes fd as well
	fclose(f);
	return NULL;
}

void startServer(int fd)
{
	printf("Starting server…");
	CFMutableArrayRef connections;
	connections = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	
	// start listening
	CFSocketContext context;
	context.version = 0;
	context.info = connections;
	context.retain = CFRetain;
	context.release = CFRelease;
	context.copyDescription = CFCopyDescription;
	
	CFSocketRef serverSocket = CFSocketCreateWithNative(NULL,
														fd,
														kCFSocketAcceptCallBack,
														socketCallBack,
														&context);
	
	CFRunLoopSourceRef runLoopSource = CFSocketCreateRunLoopSource(NULL, serverSocket, 0);	
	CFRunLoopAddSource(CFRunLoopGetCurrent(),
					   runLoopSource,
					   kCFRunLoopCommonModes);
	CFRelease(runLoopSource);
	
	// accept first connection manually if needed
	// because we get an already-connected socket
	// from launchd
	if (CFSocketIsValid(serverSocket)) {
		struct sockaddr addr;
		socklen_t len = sizeof(struct sockaddr);
		int newFd = accept(fd, &addr, &len);
		CFDataRef addrData = CFDataCreate(NULL, (UInt8*)&addr, len);
				
		socketCallBack(serverSocket,
					   kCFSocketAcceptCallBack,
					   addrData,
					   &newFd,
					   context.info);
		CFRelease(addrData);
	}
}

void socketCallBack(CFSocketRef s,
					CFSocketCallBackType callbackType,
					CFDataRef address,
					const void *data,
					void *info)
{
	CFSocketNativeHandle fd;
	switch(callbackType) {
		case kCFSocketAcceptCallBack:
			fd = *(CFSocketNativeHandle*)data;
			pthread_t thread;
			if (pthread_create(&thread, NULL, &processClient, (void*)fd) != 0) {
				send(fd, GOODBYE, sizeof(GOODBYE), 0);
				close(fd);
			}
			break;
	}
}