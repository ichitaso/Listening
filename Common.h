@import UIKit;
#include <roothide.h>

#define PREF_PATH jbroot(@"/var/mobile/Library/Preferences/com.ichitaso.listening.plist")
#define Notify_Preferences "com.ichitaso.listening.prefschanged"
#define Reload_Preferences "com.ichitaso.listening.reloadprefs"
#define ReloadFromPreferences "com.ichitaso.listening.reloadtoggles"

#ifdef DEBUG
    #define NSLog(fmt, ...) NSLog((@"ListeningTweak:" fmt), ##__VA_ARGS__)
#else
    #define NSLog(...)
#endif

#define IS_PAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define CREDITS @"© 2015-2025 Cannathea by ichitaso"

static BOOL isEnabled;
static int listeningMode;
static int pausedMode;
static int switchToMode;

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    // Settings Path
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];

    isEnabled = (BOOL)[dict[@"isEnabled"] ?: @NO boolValue];
    listeningMode = (int)[dict[@"listeningMode"] ?: @2 intValue];
    pausedMode = (int)[dict[@"pausedMode"] ?: @2 intValue];
    // Update Settings
    [[NSNotificationCenter defaultCenter] postNotificationName:@Notify_Preferences object:nil];
}

@interface Debug : NSObject
+ (UIWindow*)GetKeyWindow;
+ (void)ShowAlert:(NSString *)title msg:(NSString *)msg;
@end

@implementation Debug
+ (UIWindow *)GetKeyWindow {
    UIWindow *foundWindow = nil;
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        if (window.isKeyWindow) {
            foundWindow = window;
            break;
        }
    }
    return foundWindow;
}
// Shows an alert box. Used for debugging
+ (void)ShowAlert:(NSString *)title msg:(NSString *)msg {

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:msg
                                preferredStyle:UIAlertControllerStyleAlert];
    //Add Buttons
    UIAlertAction *okButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
        //Handle dismiss button action here
    }];
    //Add your buttons to alert controller
    [alert addAction:okButton];

    [[self GetKeyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
}
@end
