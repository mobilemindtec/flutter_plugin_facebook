#import "FacebookPlugin.h"
#import <facebook/facebook-Swift.h>

@implementation FacebookPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFacebookPlugin registerWithRegistrar:registrar];
}
@end
