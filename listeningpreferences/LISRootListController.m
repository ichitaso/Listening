@import Foundation;
@import UIKit;
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSSwitchTableCell.h>
#import <Preferences/PSTableCell.h>
#import <SafariServices/SafariServices.h>
#import "../Common.h"

static UIAlertController *alertController;

@interface PSSpecifier (Private)
- (void)setValues:(id)arg1 titles:(id)arg2;
@end

@interface LISRootListController : PSListController
@end

@implementation LISRootListController

- (instancetype)init {
    self = [super init];
    // ReloadPrefs Notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadPrefs" object:nil];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    (CFNotificationCallback)reloadPrefsCallBack,
                                    CFSTR(Reload_Preferences),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPrefs:) name:@"reloadPrefs" object:nil];

    return self;
}

void reloadPrefsCallBack() {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPrefs" object:nil];
}

- (void)reloadPrefs:(NSNotification *)notification {
    NSLog(@"reloadSpecifiers");
    [self reloadSpecifiers];
}

- (NSArray *)specifiers {
    if (_specifiers == nil) {
        NSMutableArray *specifiers = [NSMutableArray array];
        PSSpecifier *spec;
        
        spec = [PSSpecifier preferenceSpecifierNamed:@"Settings"
                                              target:self
                                                 set:Nil
                                                 get:Nil
                                              detail:Nil
                                                cell:PSGroupCell
                                                edit:Nil];
        [specifiers addObject:spec];
        
        spec = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                                              target:self
                                                 set:@selector(setPreferenceValue:specifier:)
                                                 get:@selector(readPreferenceValue:)
                                              detail:Nil
                                                cell:PSSwitchCell
                                                edit:Nil];
        [spec setProperty:@"isEnabled" forKey:@"key"];
        [spec setProperty:@NO forKey:@"default"];
        [specifiers addObject:spec];
        
        spec = [PSSpecifier preferenceSpecifierNamed:@"Listening mode"
                                              target:self
                                                 set:Nil
                                                 get:Nil
                                              detail:Nil
                                                cell:PSGroupCell
                                                edit:Nil];
        [specifiers addObject:spec];
        
        spec = [PSSpecifier preferenceSpecifierNamed:@"listeningMode"
                                              target:self
                                                 set:@selector(setPreferenceValue:specifier:)
                                                 get:@selector(readPreferenceValue:)
                                              detail:Nil
                                                cell:PSSegmentCell
                                                edit:Nil];
        [spec setProperty:@"listeningMode" forKey:@"key"];
        [spec setProperty:@2 forKey:@"default"];
        [spec setProperty:@0 forKey:@"alignment"];
        [spec setValues:@[@3, @2, @1] titles:@[@"Transparency", @"Noise Cancellation", @"Off"]];
        [specifiers addObject:spec];
        
        spec = [PSSpecifier preferenceSpecifierNamed:@"Paused mode"
                                              target:self
                                                 set:Nil
                                                 get:Nil
                                              detail:Nil
                                                cell:PSGroupCell
                                                edit:Nil];
        [specifiers addObject:spec];
        
        spec = [PSSpecifier preferenceSpecifierNamed:@"pausedMode"
                                              target:self
                                                 set:@selector(setPreferenceValue:specifier:)
                                                 get:@selector(readPreferenceValue:)
                                              detail:Nil
                                                cell:PSSegmentCell
                                                edit:Nil];
        [spec setProperty:@"pausedMode" forKey:@"key"];
        [spec setProperty:@2 forKey:@"default"];
        [spec setProperty:@0 forKey:@"alignment"];
        [spec setValues:@[@3, @2, @1] titles:@[@"Transparency", @"Noise Cancellation", @"Off"]];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Links"
                                              target:self
                                                 set:Nil
                                                 get:Nil
                                              detail:Nil
                                                cell:PSGroupCell
                                                edit:Nil];
        [spec setProperty:@"If you like my work, Please a donation by Paypal." forKey:@"footerText"];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Follow me on Twitter"
                                              target:self
                                                 set:nil
                                                 get:nil
                                              detail:nil
                                                cell:PSLinkCell
                                                edit:nil];
        
        spec->action = @selector(openTwitter);
        [spec setProperty:@YES forKey:@"hasIcon"];
        [spec setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"twitter" ofType:@"png"]] forKey:@"iconImage"];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Source Code ❤️"
                                              target:self
                                                 set:Nil
                                                 get:Nil
                                              detail:Nil
                                                cell:PSLinkCell
                                                edit:Nil];
        
        spec->action = @selector(openGithub);
        [spec setProperty:@YES forKey:@"hasIcon"];
        [spec setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"github" ofType:@"png"]] forKey:@"iconImage"];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Donate"
                                              target:self
                                                 set:nil
                                                 get:nil
                                              detail:nil
                                                cell:PSLinkCell
                                                edit:nil];

        spec->action = @selector(donate);
        [spec setProperty:@YES forKey:@"hasIcon"];
        [spec setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"paypal" ofType:@"png"]] forKey:@"iconImage"];
        [specifiers addObject:spec];
        
        spec = [PSSpecifier emptyGroupSpecifier];
        [spec setProperty:CREDITS forKey:@"footerText"];
        [spec setProperty:@1 forKey:@"footerAlignment"];
        [specifiers addObject:spec];
        
        _specifiers = [specifiers copy];
    }
    return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREF_PATH]?:[NSMutableDictionary dictionary];
    [prefs setObject:value forKey:specifier.properties[@"key"]];
    // Reload CCSupport Toggle
    if ([specifier.properties[@"key"] isEqualToString:@"isEnabled"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(ReloadFromPreferences), NULL, NULL, YES);
    }
    [prefs writeToFile:PREF_PATH atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(Notify_Preferences), NULL, NULL, YES);
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    return prefs[specifier.properties[@"key"]]?:[[specifier properties] objectForKey:@"default"];
}

- (void)openTwitter {
    NSString *twitterID = @"ichitaso";

    alertController = [UIAlertController
                       alertControllerWithTitle:@"Follow @ichitaso"
                       message:nil
                       preferredStyle:UIAlertControllerStyleActionSheet];

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open in Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@",twitterID]]
                                               options:@{}
                                     completionHandler:nil];
        }]];
    }

    [alertController addAction:[UIAlertAction actionWithTitle:@"Open in Browser" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self openURLInBrowser:[NSString stringWithFormat:@"https://twitter.com/%@",twitterID]];
        });
    }]];

    // Fix Crash for iPad
    if (IS_PAD) {
        CGRect rect = self.view.frame;
        alertController.popoverPresentationController.sourceView = self.view;
        alertController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(rect)-60,rect.size.height-50, 120,50);
        alertController.popoverPresentationController.permittedArrowDirections = 0;
    } else {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}]];
    }

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)donate {
    [self openURLInBrowser:@"https://cydia.ichitaso.com/donation.html"];
}

- (void)openGithub {
    [self openURLInBrowser:@"https://github.com/ichitaso/Listening"];
}

- (void)openURLInBrowser:(NSString *)url {
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
    [self presentViewController:safari animated:YES completion:nil];
}

@end
