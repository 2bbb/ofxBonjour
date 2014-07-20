//
//  ofxBonjourBrowser.mm
//
//  Created by ISHII 2bit on 2014/07/20.
//
//

#include "ofxBonjourBrowser.h"

#import <Cocoa/Cocoa.h>
#import <CFNetwork/CFNetwork.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

static const string LogTag = "ofxBonjourBrowser";

@interface BonjourBrowserImpl : NSObject <
    NSNetServiceDelegate,
    NSNetServiceBrowserDelegate
> {
    NSNetServiceBrowser *browser;
    ofxBonjourBrowser *delegate;
}

- (void)setDelegate:(ofxBonjourBrowser *)delegate;
- (void)startBrowse:(NSString *)type
          forDomain:(NSString *)domain;

@end

@implementation BonjourBrowserImpl

- (void)setDelegate:(ofxBonjourBrowser *)_delegate {
    delegate = _delegate;
}

- (void)startBrowse:(NSString *)type forDomain:(NSString *)domain {
    if(browser == nil) {
        browser = [[NSNetServiceBrowser alloc] init];
        browser.delegate = self;
    }
    [browser searchForServicesOfType:type inDomain:domain];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
          didFindService:(NSNetService *)netService
              moreComing:(BOOL)moreComing
{
    NSNetService *service = [[NSNetService alloc] initWithDomain:netService.domain
                                                            type:netService.type
                                                            name:netService.name];
    if(service) {
        service.delegate = self;
        [service resolveWithTimeout:5.0f];
    } else {
        ofLogError(LogTag) << "connect failed.";
    }
}

#pragma mark NSNetServiceDelegate

- (void)netServiceDidResolveAddress:(NSNetService *)netService {
    NSString *name = netService.name;
    NSString *ip = [self getStringFromAddressData:[netService.addresses objectAtIndex:0]];
    NSString *type = netService.type;
    NSString *domain = netService.domain;
    ofLogVerbose(LogTag) << "found: " << type.UTF8String << " : " << name.UTF8String << " = " << ip.UTF8String;
    
    delegate->findService(type.UTF8String, name.UTF8String, ip.UTF8String, domain.UTF8String);
    [netService release];
}

- (NSString *)getStringFromAddressData:(NSData *)dataIn {
    struct sockaddr_in  *socketAddress = (struct sockaddr_in *)[dataIn bytes];
    NSString *ipString = @(inet_ntoa(socketAddress->sin_addr));  ///problem here
    return ipString;
}

- (void)dealloc {
    [browser release];
    [super dealloc];
}

@end

ofxBonjourBrowser::ofxBonjourBrowser()
    : impl([[BonjourBrowserImpl alloc] init])
{
    [(BonjourBrowserImpl *)impl setDelegate:this];
}

void ofxBonjourBrowser::setup() {
}

bool ofxBonjourBrowser::startBrowse(string type, string domain) {
    [(BonjourBrowserImpl *)impl startBrowse:@(type.c_str())
                                  forDomain:@(domain.c_str())];
}

void ofxBonjourBrowser::findService(string type, string name, string ip, string domain) {
    infos.push_back((ofxBonjourServiceInfo){
        .type   = type,
        .name   = name,
        .ip     = ip,
        .domain = domain
    });
}

const vector<ofxBonjourServiceInfo> &ofxBonjourBrowser::getFoundServiceInfo() const {
    return infos;
}
