#import "PaystackFlutterPlugin.h"
#import <paystack_flutter/paystack_flutter-Swift.h>

@implementation PaystackFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPaystackFlutterPlugin registerWithRegistrar:registrar];
}
@end
