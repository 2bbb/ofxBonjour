//
//  ofxBonjourPublisher.h
//
//  Created by ISHII 2bit on 2014/07/20.
//
//

#pragma once

#include "ofMain.h"

class ofxBonjourPublisher {
public:
    ofxBonjourPublisher();
    ~ofxBonjourPublisher();
    void setup();
    bool publish(string type, string name, int port, string domain = "");
private:
    void *impl;
};