#import "FcaPoseValidationPlugin.h"
#if __has_include(<fca_pose_validation/fca_pose_validation-Swift.h>)
#import <fca_pose_validation/fca_pose_validation-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "fca_pose_validation-Swift.h"
#endif

@implementation FcaPoseValidationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFcaPoseValidationPlugin registerWithRegistrar:registrar];
}
@end
