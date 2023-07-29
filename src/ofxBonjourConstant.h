//
//  ofxBonjourConstant.h
//
//  Created by ISHII 2bit on 2014/07/21.
//
//

#pragma once

#include "ofConstants.h"

#if !TARGET_OS_IOS
#import <Cocoa/Cocoa.h>
#endif

#import <CFNetwork/CFNetwork.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
