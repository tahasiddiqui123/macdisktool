/*
 *  helper_main.c
 *  MacDiskTool
 *
 *  Created by Georg Schölly on 16.03.09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include <stdio.h>
#include <launch.h>
#include <errno.h>
#include <CoreFoundation/CoreFoundation.h>
#include <getopt.h>
#include <stdlib.h>
#include "server.h"
#include "macdisktool.h"

int getSocketFromLaunchd();

void printVersion()
{
	printf("macdisktool 1.0d\n");
}

void printUsage()
{
	fprintf(stderr, "usage: macdisktool -h\n"
		            "       macdisktool [--server]\n");
}

void printHelp()
{
	printUsage();
}

void sleepBeforeQuit() {
	sleep(11);
}

int main(int argc, char *argv[])
{
	enum kCommand command = kReadCommand;
	static struct option longopts[] = {
		{"server", no_argument, NULL, 'S'},
		{"version", no_argument, NULL, 'V'},
		{"help", no_argument, NULL, 'h'},
		{"readonly", no_argument, NULL, kReadCommand},
		{"readwrite", no_argument, NULL, kReadWriteCommand},
		{"savereadwrite", no_argument, NULL, kSaveReadWriteCommand},
		{NULL, 0, NULL, 0}
	};
	
	longopts[3].flag = &command;
	longopts[4].flag = &command;
	longopts[5].flag = &command;
	
	char server_flag = 0;
	
	char ch;
	while ((ch = getopt_long(argc, argv, "Vh", longopts, NULL)) != -1) {
		switch (ch) {
			case 'S':
				server_flag = 1;
				break;
			case 'V':
				printVersion();
				exit(0);
				break;
			case 'h':
				printHelp();
				exit(0);
				break;
			default:
				printUsage();
				exit(0);
				break;
		}
	}
	
	if (server_flag) {
		// try to connect to launchd
		int socket;
		if ((socket = getSocketFromLaunchd()) != -1) {
			atexit(sleepBeforeQuit);
			startServer(socket);
			CFRunLoopRun();
		} else {
			fprintf(stderr, "Could not connect to launchd, exiting.\n");
			exit(-1);
		}
	} else { /* non-server mode */
		if (argc <= optind) {
			fprintf(stderr, "No device given.\n");
			exit(-1);
		}
		char *path = argv[optind];
		switch (command) {
			case kReadCommand:
				readOnlySurfaceScan(path, fileno(stdout));
				break;
			case kSaveReadWriteCommand:
				break;
			case kReadWriteCommand:
				break;
		}
	}
}

int getSocketFromLaunchd()
{
	// check-in
	launch_data_t checkinRequest = launch_data_new_string(LAUNCH_KEY_CHECKIN);
	launch_data_t checkinResponse = launch_msg(checkinRequest);
	if (!checkinResponse) {
		fprintf(stderr, "launch_msg(checkin_request) failed.\n");
		return -1;
	}
	
	// test if check-in was successful
	launch_data_type_t responseType = launch_data_get_type(checkinResponse);
	if (responseType == LAUNCH_DATA_ERRNO) {
		errno = launch_data_get_errno(checkinResponse);
		fprintf(stderr, "Check-in with launchd failed, error %i.\n", errno);
		return -1;
	} else if (responseType != LAUNCH_DATA_DICTIONARY) {
		fprintf(stderr, "Unknown error, aborting.");
		return -1;
	}
	
	// get socket
	launch_data_t sockets = launch_data_dict_lookup(checkinResponse, LAUNCH_JOBKEY_SOCKETS);
	launch_data_t ipcSocket = launch_data_dict_lookup(sockets, "IPC");
	launch_data_t socket = launch_data_array_get_index(ipcSocket, 0);
	
	int fd = launch_data_get_fd(socket);
	
	// we're done with launchd, free all resources
	launch_data_free(checkinRequest);
    launch_data_free(checkinResponse);

	return fd;
}
