#import "FlutterPaystackPlugin.h"
#import <sys/utsname.h>
#import "PSTCKRSA.h"


@implementation FlutterPaystackPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_paystack"
            binaryMessenger:[registrar messenger]];
  FlutterPaystackPlugin* instance = [[FlutterPaystackPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getDeviceId" isEqualToString:call.method]) {
    result([@"iossdk_" stringByAppendingString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]]);
      
  } else if([@"getUserAgent" isEqualToString:call.method]) {
      result([self.class paystackUserAgentDetails]);
      
  } else if([@"getVersionCode" isEqualToString:call.method]) {
      result(PSTCKSDKBuild);
  } else if([@"getAuthorization" isEqualToString:call.method]) {
      result(FlutterMethodNotImplemented);
      
  } else if([@"getEncryptedData" isEqualToString:call.method]) {
      NSDictionary *arguments = [call arguments];
      NSString *data = arguments[@"stringData"];
      result([PSTCKRSA encryptRSA:data]);
      
  } else {
    result(FlutterMethodNotImplemented);
  }
}



+ (NSString *)paystackUserAgentDetails {
    NSMutableDictionary *details = [@{
                                      @"lang": @"objective-c",
                                      @"bindings_version": PSTCKSDKVersion,
                                      } mutableCopy];
#if TARGET_OS_IPHONE
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version) {
        details[@"os_version"] = version;
    }
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceType = @(systemInfo.machine);
    if (deviceType) {
        details[@"type"] = deviceType;
    }
    NSString *model = [UIDevice currentDevice].localizedModel;
    if (model) {
        details[@"model"] = model;
    }
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        NSString *vendorIdentifier = [[[UIDevice currentDevice] performSelector:@selector(identifierForVendor)] performSelector:@selector(UUIDString)];
        if (vendorIdentifier) {
            details[@"vendor_identifier"] = vendorIdentifier;
        }
    }
#endif
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[details copy] options:0 error:NULL] encoding:NSUTF8StringEncoding];
}

@end

