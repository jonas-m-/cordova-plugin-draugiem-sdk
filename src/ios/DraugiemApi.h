#import <Cordova/CDV.h>

@interface DraugiemApi : CDVPlugin

- (void)init:(CDVInvokedUrlCommand*)command;
- (void)login:(CDVInvokedUrlCommand*)command;

@end
