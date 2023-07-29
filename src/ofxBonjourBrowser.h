//
//  ofxBonjourBrowser.h
//
//  Created by ISHII 2bit on 2014/07/20.
//
//

#pragma once

#include <string>
#include <vector>
#include <map>

struct ofxBonjourServiceInfo {
    std::string type;
    std::string name;
    std::string ip;
    std::string domain;
    std::uint16_t port;
};

class ofxBonjourBrowserFoundNotificationReceiverInterface {
public:
    virtual void foundService(const std::string &type, const std::string &name, const std::string &ip, const std::string &domain, const std::uint16_t port, std::map<std::string,std::string> txt) = 0;
};

class ofxBonjourBrowser {
public:
    ofxBonjourBrowser();
    
    void setup();
    void startBrowse(const std::string &type, const std::string &domain = "");
    void stopBrowse();
    void foundService(const std::string &type, const std::string &name, const std::string &ip, const std::string &domain, const std::uint16_t port, std::map<std::string,std::string> txt);
    
    const std::vector<ofxBonjourServiceInfo> &getFoundServiceInfo() const;
    std::vector<ofxBonjourServiceInfo> getLastFoundServiceInfo();
    
    void setResolveTimeout(float resolveTimeout);
    void setFoundNotificationReceiver(ofxBonjourBrowserFoundNotificationReceiverInterface *receiver);
    
private:
    void *impl;
    std::vector<ofxBonjourServiceInfo> infos;
    std::vector<ofxBonjourServiceInfo> lastFoundInfos;
    
    ofxBonjourBrowserFoundNotificationReceiverInterface *receiver;
};
