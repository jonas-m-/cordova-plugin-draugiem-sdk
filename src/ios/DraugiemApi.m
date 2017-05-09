#import "DraugiemApi.h"
#import "DraugiemSDK.h"

#define NILABLE(obj) ((obj) != nil ? (NSObject*)(obj) : (NSObject*)[NSNull null])

@implementation DraugiemApi

- (void)init:(CDVInvokedUrlCommand*)command {
    NSString* apiKey = [command.arguments objectAtIndex:0];
    NSString* appId = [self.commandDelegate.settings objectForKey:[@"appId" lowercaseString]];
    
    #ifdef DEBUG
    Draugiem.logRequests = YES;
    #endif
    
    [Draugiem startWithAppID:[appId intValue] appKey:apiKey];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)handleOpenURL:(NSNotification*)notification
{
    NSURL* url = [notification object];
    [Draugiem openURL:url sourceApplication:@"lv.draugiem.sdk"];
}

- (void)login:(CDVInvokedUrlCommand*)command {
    [Draugiem logInWithCompletion:^(NSString* apiKey, NSError* error) {
        if (!apiKey) {
            CDVPluginResult* pluginResult = [CDVPluginResult
            	resultWithStatus:CDVCommandStatus_ERROR
            	messageAsDictionary:@{
            		@"code": NILABLE([NSNumber numberWithInteger:error.code]),
            		@"description": NILABLE(error.localizedDescription),
            		@"suggestion": NILABLE(error.localizedRecoverySuggestion)
				}
			];
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        [self.commandDelegate runInBackground:^{
            [Draugiem clientWithCompletion:^(DRUser* user, NSError* error) {
                if (!user) {
                    CDVPluginResult* pluginResult = [CDVPluginResult
                    	resultWithStatus: CDVCommandStatus_ERROR
                    	messageAsDictionary: @{
                    		@"code": NILABLE([NSNumber numberWithInteger:error.code]),
                    		@"description": NILABLE(error.localizedDescription),
                    		@"suggestion": NILABLE(error.localizedRecoverySuggestion)
						}
					];
                    
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    return;
                }
                
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
                formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                formatter.dateFormat = @"yyyy-MM-dd";
                
                CDVPluginResult* pluginResult = [CDVPluginResult
                	resultWithStatus: CDVCommandStatus_OK
                	messageAsDictionary: @{
					   @"apiKey": apiKey,
					   @"user": @{
						   @"id": [NSNumber numberWithLong:user.identificator],
						   @"age": [NSNumber numberWithInteger:user.age],
						   @"sex": user.sex == DRUserSexFemale
						   		? @"female"
						   		: @"male",
						   @"name": user.title,
						   @"nick": NILABLE(user.nick),
						   @"city": user.city,
						   @"imageIcon": user.imageSmallURL.absoluteString,
						   @"imageLarge": user.imageLargeURL.absoluteString,
						   @"birthday": [formatter stringFromDate:user.birthday],
					   }
				    }
				];
				 
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        }];
    }];
}

@end
