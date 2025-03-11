#import <Foundation/Foundation.h>

@interface BluetoothDevice : NSObject
- (unsigned)listeningMode;
- (BOOL)setListeningMode:(unsigned)arg1;
@end

@interface BluetoothManager : NSObject
+ (id)sharedInstance;
- (id)connectedDevices;
@end

@interface SBApplication: NSObject
@property (nonatomic, readonly) NSString *bundleIdentifier;
@end

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (SBApplication *)nowPlayingApplication;
- (BOOL)isPlaying;
- (BOOL)pauseForEventSource:(long long)arg1;
- (BOOL)playForEventSource:(long long)arg1;
@end
