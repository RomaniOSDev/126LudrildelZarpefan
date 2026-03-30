#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.mycompany.-26LudrildelZarpefan";

/// The "AppAccent" asset catalog color resource.
static NSString * const ACColorNameAppAccent AC_SWIFT_PRIVATE = @"AppAccent";

/// The "AppBackground" asset catalog color resource.
static NSString * const ACColorNameAppBackground AC_SWIFT_PRIVATE = @"AppBackground";

/// The "AppPrimary" asset catalog color resource.
static NSString * const ACColorNameAppPrimary AC_SWIFT_PRIVATE = @"AppPrimary";

/// The "AppSurface" asset catalog color resource.
static NSString * const ACColorNameAppSurface AC_SWIFT_PRIVATE = @"AppSurface";

/// The "AppTextPrimary" asset catalog color resource.
static NSString * const ACColorNameAppTextPrimary AC_SWIFT_PRIVATE = @"AppTextPrimary";

/// The "AppTextSecondary" asset catalog color resource.
static NSString * const ACColorNameAppTextSecondary AC_SWIFT_PRIVATE = @"AppTextSecondary";

#undef AC_SWIFT_PRIVATE
