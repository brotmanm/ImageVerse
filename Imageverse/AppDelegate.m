//
//  AppDelegate.m
//  Imageverse
//
//  Created by Main on 5/23/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "AppDelegate.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate () <AVAudioPlayerDelegate>

@property BOOL playingMusic;
@property AVAudioPlayer * music;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [application setStatusBarHidden:YES];
    
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"ambientspace" ofType:@"mp3"];
    _music = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:musicPath] error:nil];
    _music.delegate = self;
    _music.numberOfLoops = INFINITY;
    _music.volume = 1;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    BOOL muteMusic = [defaults boolForKey:@"muteMusic"];
    if (!muteMusic) {
        [_music play];
        _playingMusic = YES;
    } else {
        _playingMusic = NO;
    }
    
    _oldestIndex = [defaults integerForKey:@"oldestIndex"];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:!_playingMusic forKey:@"muteMusic"];
    [defaults setInteger:_oldestIndex forKey:@"oldestIndex"];
    [defaults synchronize];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)toggleSound {
    if (_playingMusic) {
        _playingMusic = NO;
        [_music pause];
    } else {
        _playingMusic = YES;
        [_music play];
    }
    
    return _playingMusic;
}

@end
