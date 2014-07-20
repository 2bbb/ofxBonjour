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

class ofxBonjourBrowserFoundNotificationReceiverInterface {
public:
    virtual void foundService(string type, string name, string ip, string domain) = 0;
};

class ofxBonjourBrowser {
public:
    ofxBonjourBrowser();
    
    void setup();
    void startBrowse(string type, string domain = "");
    void stopBrowse();
    void foundService(string type, string name, string ip, string domain);
    
    const vector<ofxBonjourServiceInfo> &getFoundServiceInfo() const;
    vector<ofxBonjourServiceInfo> getLastFoundServiceInfo();
    
    void setResolveTimeout(float resolveTimeout);
    void setFoundNotificationReceiver(ofxBonjourBrowserFoundNotificationReceiverInterface *receiver);
    
private:
    void *impl;
    vector<ofxBonjourServiceInfo> infos;
    vector<ofxBonjourServiceInfo> lastFoundInfos;
    
    ofxBonjourBrowserFoundNotificationReceiverInterface *receiver;
};
