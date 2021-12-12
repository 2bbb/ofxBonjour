//
//  ofxBonjourPublisher.h
//
//  Created by ISHII 2bit on 2014/07/20.
//
//

#pragma once

#include "ofConstants.h"

#include <string>
#include <cstdint>

class ofxBonjourPublisher {
public:
    ofxBonjourPublisher();
    ~ofxBonjourPublisher();
    void setup();
    bool publish(std::string type, std::string name, std::uint16_t port, std::string domain = "");
private:
    void *impl;
};
