//
//  ofxBonjourPublisher.mm
//
//  Created by ISHII 2bit on 2014/07/20.
//
//

#include "ofxBonjourPublisher.h"
#include "ofxBonjourConstant.h"
 
#include "ofLog.h"

static const std::string LogTag = "ofxBonjourPublisher";

@interface BonjourPublisherImpl : NSObject {
    NSSocketPort* socket;
    NSNetService *service;
}

- (BOOL)publishForType:(NSString *)type
                  name:(NSString *)name
                  port:(int)port
                domain:(NSString *)domain;

- (BOOL)setTXTRecordData:(NSDictionary *)record;

@end

@implementation BonjourPublisherImpl

- (BOOL)publishForType:(NSString *)type
                  name:(NSString *)name
                  port:(int)port
                domain:(NSString *)domain
{
    socket = [[NSSocketPort alloc] initWithTCPPort:port];
    if (socket) {
        service = [[NSNetService alloc] initWithDomain:domain
                                                  type:type
                                                  name:name
                                                  port:port];
        if (service) {
            [service scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            [service publish];
        } else {
            ofLogVerbose(LogTag) << "invalid NSNetSevice";
        }
    } else {
        ofLogVerbose(LogTag) << "invalid NSSocketPort";
    }
}

- (BOOL)setTXTRecordData:(NSDictionary *)record
{
    if (service) {
        // TODO: check that the record is within the mDNS limits

        return [service setTXTRecordData:[NSNetService dataFromTXTRecordDictionary:record]];
    } else {
        ofLogVerbose(LogTag) << "cannot set mDNS data: NSNetSevice not instanciated";
        return NO;
    }
}

//- (void)dealloc {
//    [socket release];
//    [service release];
//
//    [super dealloc];
//}

@end

ofxBonjourPublisher::ofxBonjourPublisher()
: impl((__bridge_retained void *)[[BonjourPublisherImpl alloc] init]) {}

//__bridge

//void ofxBonjourPublisher::setup() {
//    
//}

bool ofxBonjourPublisher::publish(std::string type, std::string name, std::uint16_t port, std::string domain) {
    return [(__bridge BonjourPublisherImpl *)impl publishForType:@(type.c_str())
                                                   name:@(name.c_str())
                                                   port:port
                                                 domain:@(domain.c_str())] ? true : false;
}

bool ofxBonjourPublisher::setTextRecord(std::vector<std::pair<std::string, std::string>> key_values = {}) {
    NSMutableDictionary * record = [NSMutableDictionary dictionary];
    for (const auto & [key, value]: key_values) [record setValue:@(value.c_str()) forKey: @(key.c_str())];
    return [(BonjourPublisherImpl *)impl setTXTRecordData:record];
}
