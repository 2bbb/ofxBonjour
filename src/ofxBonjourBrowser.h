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
    int port;
};

class ofxBonjourBrowserFoundNotificationReceiverInterface {
public:
    virtual void foundService(const string &type, const string &name, const string &ip, const string &domain, const int port) = 0;
};

class ofxBonjourBrowser {
public:
    ofxBonjourBrowser();
    
    void setup();
    void startBrowse(const string &type, const string &domain = "");
    void stopBrowse();
    void foundService(const string &type, const string &name, const string &ip, const string &domain, const int port);
    
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
