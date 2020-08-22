#import "FlutterPaystackPlugin.h"
#import <sys/utsname.h>
#import "PSTCKRSA.h"
#import "PSTCKAuthViewController.h"


@implementation FlutterPaystackPlugin {
    UIViewController *_viewController;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.wilburt/flutter_paystack"
            binaryMessenger:[registrar messenger]];
    UIViewController *viewController =
    [UIApplication sharedApplication].delegate.window.rootViewController;
  FlutterPaystackPlugin* instance = [[FlutterPaystackPlugin alloc] initWithViewController: viewController];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getDeviceId" isEqualToString:call.method]) {
    result([@"iossdk_" stringByAppendingString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]]);
      
  } else if([@"getUserAgent" isEqualToString:call.method]) {
      result([self.class paystackUserAgentDetails]);
      
  } else if([@"getVersionCode" isEqualToString:call.method]) {
      result(PSTCKSDKBuild);
  } else if([@"getAuthorization" isEqualToString:call.method]) {
      NSDictionary *arguments = [call arguments];
      NSString *url = arguments[@"authUrl"];
      [self requestAuth:url result: result];
      
  } else if([@"getEncryptedData" isEqualToString:call.method]) {
      NSDictionary *arguments = [call arguments];
      NSString *data = arguments[@"stringData"];
      result([PSTCKRSA encryptRSA:data]);
      
  } else {
    result(FlutterMethodNotImplemented);
  }
}


- (void) requestAuth:(NSString * _Nonnull) url result:(FlutterResult)result {
    PSTCKAuthViewController* authorizer = [[[PSTCKAuthViewController alloc] init]
                                           initWithURL:[NSURL URLWithString:url]
                                           handler:^{
                                               [self->_viewController dismissViewControllerAnimated:YES completion:nil];
                                               NSDictionary *response = @{ @"status": @"requery", @"message": @"Reaffirm Transaction Status on Server"};
                                               result([[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[response copy] options:0 error:NULL] encoding:NSUTF8StringEncoding]);
                                           }];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:authorizer];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        nc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self->_viewController presentViewController:nc animated:YES completion:nil];
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

