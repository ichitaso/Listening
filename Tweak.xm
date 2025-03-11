#import "Tweak.h"
#import "Common.h"

// The original concept of this idea was created by LaughingQuoll with the tweak Banana https://github.com/LaughingQuoll/Banana but of course I have added my own twist

unsigned currentListeningMode() {
    NSArray *connectedDevices = [[%c(BluetoothManager) sharedInstance] connectedDevices];
    if (![connectedDevices count]) return 0;
    return ((BluetoothDevice *)connectedDevices[0]).listeningMode;
}

void toggleCancellationModeOff() {
    NSArray *connectedDevices = [[%c(BluetoothManager) sharedInstance] connectedDevices];
    if (![connectedDevices count]) return;
    [connectedDevices[0] setListeningMode:1];
}

void toggleNoiseCancellation() {
    NSArray *connectedDevices = [[%c(BluetoothManager) sharedInstance] connectedDevices];
    if (![connectedDevices count]) return;
    [connectedDevices[0] setListeningMode:2];
}

void toggleTransparency() {
    NSArray *connectedDevices = [[%c(BluetoothManager) sharedInstance] connectedDevices];
    if (![connectedDevices count]) return;
    [connectedDevices[0] setListeningMode:3];
}

// toggle transparency when media is paused, toggle noise cancellation when media is playing
%hook SBMediaController
- (void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 {
    %orig;
    NSLog(@"_mediaRemoteNowPlayingApplicationIsPlayingDidChange:%@",[[%c(SBMediaController) sharedInstance] nowPlayingApplication].bundleIdentifier);

    NSLog(@"isEnabled:%d currentListeningMode():%u",isEnabled,currentListeningMode());

    if (isEnabled && self.isPlaying == YES) {
        switchToMode = listeningMode;
    } else if (isEnabled) {
        switchToMode = pausedMode;
    }

    NSLog(@"switchToMode:%d pausedMode:%d",switchToMode,pausedMode);

    if (isEnabled && switchToMode == 3) {
        NSLog(@"toggleTransparency");
        toggleTransparency();
    } else if (isEnabled && switchToMode == 2) {
        NSLog(@"toggleNoiseCancellation");
        toggleNoiseCancellation();
    } else if (isEnabled && switchToMode == 1) {
        NSLog(@"toggleCancellationModeOff");
        toggleCancellationModeOff();
    }
}
%end

// toggle media playing when noise cancellation is active, toggle media paused when transparency is active
%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
    %orig;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(togglePlayPauseForListening) name:@"BluetoothAccessorySettingsChanged" object:nil];
}

%new
- (void)togglePlayPauseForListening {
    NSLog(@"BluetoothAccessorySettingsChanged");
    if ([[%c(SBMediaController) sharedInstance] nowPlayingApplication].bundleIdentifier != NULL) {
        if (currentListeningMode() == 3) [[%c(SBMediaController) sharedInstance] pauseForEventSource:0];
        if (currentListeningMode() == 2) [[%c(SBMediaController) sharedInstance] playForEventSource:0];
    }
}
%end

%ctor {
    %init;

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    settingsChanged,
                                    CFSTR(Notify_Preferences),
                                    NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);

    settingsChanged(NULL, NULL, NULL, NULL, NULL);
}
