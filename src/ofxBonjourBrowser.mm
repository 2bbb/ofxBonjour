//
//  ofxBonjourBrowser.mm
//
//  Created by ISHII 2bit on 2014/07/20.
//
//

#include "ofxBonjourBrowser.h"
#include "ofxBonjourConstant.h"

static const string LogTag = "ofxBonjourBrowser";

@interface BonjourBrowserImpl : NSObject <
    NSNetServiceDelegate,
    NSNetServiceBrowserDelegate
> {
    NSNetServiceBrowser *browser;
    ofxBonjourBrowser *delegate;
    
    float resolveTimeout;
}

- (void)setDelegate:(ofxBonjourBrowser *)delegate;
- (void)startBrowse:(NSString *)type
          forDomain:(NSString *)domain;
- (void)stopBrowse;
- (void)setResolveTimeout:(float)resolveTimeout;

@end

@implementation BonjourBrowserImpl

- (instancetype)init {
    self = [super init];
    if(self) {
        resolveTimeout = 5.0f;
    }
    return self;
}

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

- (void)stopBrowse {
    [browser stop];
}

- (void)setResolveTimeout:(float)_resolveTimeout {
    resolveTimeout = _resolveTimeout;
}

#pragma mark NSNetServiceBrowserDelegate

-(void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
          didFindService:(NSNetService *)netService
              moreComing:(BOOL)moreComing
{
    NSNetService *service = [[NSNetService alloc] initWithDomain:netService.domain
                                                            type:netService.type
                                                            name:netService.name];
    if(service) {
        service.delegate = self;
        [service resolveWithTimeout:resolveTimeout];
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
    
    delegate->foundService(type.UTF8String, name.UTF8String, ip.UTF8String, domain.UTF8String);
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
    receiver = NULL;
}

void ofxBonjourBrowser::setup() {
}

void ofxBonjourBrowser::startBrowse(const string &type, const string &domain) {
    [(BonjourBrowserImpl *)impl startBrowse:@(type.c_str())
                                  forDomain:@(domain.c_str())];
}

void ofxBonjourBrowser::stopBrowse() {
    [(BonjourBrowserImpl *)impl stopBrowse];
}

void ofxBonjourBrowser::foundService(const string &type, const string &name, const string &ip, const string &domain) {
    if(receiver != NULL) {
        receiver->foundService(type, name, ip, domain);
    }
    ofxBonjourServiceInfo info = (ofxBonjourServiceInfo){
        .type   = type,
        .name   = name,
        .ip     = ip,
        .domain = domain
    };
    infos.push_back(info);
    lastFoundInfos.push_back(info);
}

const vector<ofxBonjourServiceInfo> &ofxBonjourBrowser::getFoundServiceInfo() const {
    return infos;
}

vector<ofxBonjourServiceInfo> ofxBonjourBrowser::getLastFoundServiceInfo() {
    vector<ofxBonjourServiceInfo> tmp = lastFoundInfos;
    lastFoundInfos.clear();
    return tmp;
}

void ofxBonjourBrowser::setResolveTimeout(float resolveTimeout) {
    [(BonjourBrowserImpl *)impl setResolveTimeout:resolveTimeout];
}

void ofxBonjourBrowser::setFoundNotificationReceiver(ofxBonjourBrowserFoundNotificationReceiverInterface *receiver) {
    this->receiver = receiver;
}
