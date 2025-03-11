#import <ControlCenterUIKit/CCUIToggleModule.h>
#import "../Common.h"

@interface UIImage ()
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end

@interface ListeningToggle : CCUIToggleModule
@end

@implementation ListeningToggle

- (instancetype)init {
    self = [super init];
    // ReloadPrefs Notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadListeningToggle" object:nil];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    (CFNotificationCallback)reloadPrefsCallBack,
                                    CFSTR(ReloadFromPreferences),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPrefs:) name:@"reloadListeningToggle" object:nil];

    return self;
}

void reloadPrefsCallBack() {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadListeningToggle" object:nil];
}

- (void)reloadPrefs:(NSNotification *)notification {
    [self setSelected:isEnabled];
}

- (UIImage *)iconGlyph {
    return [UIImage imageNamed:@"Icon" inBundle:[NSBundle bundleForClass:[self class]]];
}

- (UIColor *)selectedColor {
    return [UIColor colorWithRed:0.28 green:0.83 blue:0.70 alpha:1.0];
}

- (BOOL)isSelected {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];

    isEnabled = (BOOL)[dict[@"isEnabled"] ?: @NO boolValue];

    return isEnabled;
}

- (void)setSelected:(BOOL)selected {

    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREF_PATH]?:[NSMutableDictionary dictionary];

    if ([self isSelected]) {
        [prefs setObject:@NO forKey:@"isEnabled"];
    } else {
        [prefs setObject:@YES forKey:@"isEnabled"];
    }

    [prefs writeToFile:PREF_PATH atomically:YES];

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(Reload_Preferences), NULL, NULL, YES);

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(Notify_Preferences), NULL, NULL, YES);

    [super refreshState];
}

@end

__attribute__((constructor))
static void init(void) {
    // Settings Changed
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    settingsChanged,
                                    CFSTR(Notify_Preferences),
                                    NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);

    settingsChanged(NULL, NULL, NULL, NULL, NULL);
}
