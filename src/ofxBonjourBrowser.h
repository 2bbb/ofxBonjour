//
//  ofxBonjourBrowser.h
//
//  Created by ISHII 2bit on 2014/07/20.
//
//

#pragma once

#include "ofMain.h"

struct ofxBonjourServiceInfo {
    string type;
    string name;
    string ip;
    string domain;
};

class ofxBonjourBrowser {
public:
    ofxBonjourBrowser();
    
    void setup();
    void startBrowse(string type, string domain = "");
    void findService(string type, string name, string ip, string domain);
    
    const vector<ofxBonjourServiceInfo> &getFoundServiceInfo() const;
    
    void setResolveTimeout(float resolveTimeout);
    
private:
    void *impl;
    vector<ofxBonjourServiceInfo> infos;
};
