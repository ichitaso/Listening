#import "Tweak.h"

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
-(void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 {
    %orig;

    NSDictionary *bundleDefaults = [[NSUserDefaults standardUserDefaults]
    persistentDomainForName:@"eu.hrabcak.listeningpreferences"];
    
    id isEnabled = [bundleDefaults valueForKey:@"isEnabled"];
    if ([isEnabled isEqual:@0]) {
        return;
    }

    id listeningMode = [bundleDefaults valueForKey:@"listeningMode"];
    id pausedMode = [bundleDefaults valueForKey:@"pausedMode"];

    id switchToMode;
    if (self.isPlaying == YES) switchToMode = listeningMode;
    else switchToMode = pausedMode;

    if ([switchToMode isEqual:@"3"]) {
        toggleTransparency();
    } else if ([switchToMode isEqual:@"2"]) {
        toggleNoiseCancellation();
    } else if ([switchToMode isEqual:@"1"]) {
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
    if ([[%c(SBMediaController) sharedInstance] nowPlayingApplication].bundleIdentifier != NULL) {
        if (currentListeningMode() == 3) [[%c(SBMediaController) sharedInstance] pauseForEventSource:0];
        if (currentListeningMode() == 2) [[%c(SBMediaController) sharedInstance] playForEventSource:0];
    }
}
%end
