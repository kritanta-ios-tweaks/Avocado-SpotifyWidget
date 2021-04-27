//
// Created by Kritanta on 1/12/21.
// Copyright (c) 2021 ApexTweaks. All rights reserved.
//

#import <objc/runtime.h>
#import "SpotifyWidget.h"
#import "MediaRemote.h"
#include "AVCWidgetServer.h"
#import <SpringBoard/SBMediaController.h>

@interface AVCSpotifyWidget (Private)
@end

@implementation AVCSpotifyWidget
{

}

- (instancetype)init 
{
    self = [super init];
    if (self)
    {
        // always call this line
        [self constructView];

        // If you need -(void)update to be called, tell the widget server how often to call it
        [[AVCWidgetServer sharedInstance] registerWidget:self forUpdatesEvery:1.0f];
    }
    return self;
}

- (void)constructView
{
    // always call this.
    [super constructView];

    // -- This is where I set up the custom view --
    self.view.layer.cornerRadius = (CGFloat)[[[AVCWidgetServer sharedInstance] store] integerForKey:@"AVCWRadius"] ?: 29;
    self.view.layer.masksToBounds = YES;

    self.background = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width + 5,self.view.frame.size.width + 5)];
    self.background.center = self.view.center;
    [self.view addSubview:self.background];

    UIView *blackOverlay = [[UIView alloc] initWithFrame: self.view.frame];
    blackOverlay.layer.backgroundColor = [[UIColor blackColor] CGColor];
    blackOverlay.layer.opacity = 0.6f;
    blackOverlay.userInteractionEnabled = NO; //set this
    [self.view addSubview: blackOverlay];

    self.title = [[UILabel alloc] initWithFrame:CGRectMake(10,self.view.frame.size.height-50,150,20)];
    [self.title setFont:[UIFont systemFontOfSize:13]];
    [self.title setText:@"Nothing Playing"];//Set text in label.
    [self.title setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:1.0f]];//Set text color in label.
    [self.title setFont:[UIFont boldSystemFontOfSize:14]];
    [self.title setLineBreakMode:NSLineBreakByClipping];

    self.subtitle = [[UILabel alloc] initWithFrame:CGRectMake(10,self.view.frame.size.height-30,150,20)];
    [self.subtitle setText:@"Nothing Playing"];//Set text in label.
    [self.subtitle setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:1.0f]];//Set text color in label.
    [self.subtitle setLineBreakMode:NSLineBreakByClipping];

    [self.subtitle setFont:[UIFont systemFontOfSize:12]];

    [self.view addSubview:self.title];
    [self.view addSubview:self.subtitle];

    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.frame = CGRectMake(0, 0, 35, 35);
    [self.playButton setBackgroundImage:kTintedImageNamed(@"play.circle.fill") forState:UIControlStateNormal];
    self.playButton.center = CGPointMake(self.view.frame.size.width / 2.0,self.view.frame.size.height / 2.0 + 00);
    [self.playButton addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.tintColor = [UIColor whiteColor];
    [self.view addSubview:self.playButton];

    UIButton *buttonForward = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonForward.frame = CGRectMake(0, 0, 22, 15.5);
    buttonForward.center = CGPointMake(self.view.frame.size.width / 2.0 + 35,self.view.frame.size.height / 2.0 + 00);
    buttonForward.tintColor = [UIColor whiteColor];
    [buttonForward setBackgroundImage:kTintedImageNamed(@"forward.fill") forState:UIControlStateNormal];
    [buttonForward addTarget:self action:@selector(forward:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:buttonForward];

    UIButton *buttonBackward = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonBackward.frame = CGRectMake(0, 0, 22, 15.5);
    [buttonBackward setBackgroundImage:kTintedImageNamed(@"backward.fill") forState:UIControlStateNormal];
    [buttonBackward addTarget:self action:@selector(reverse:) forControlEvents:UIControlEventTouchUpInside];
    buttonBackward.tintColor = [UIColor whiteColor];
    [self.view addSubview:buttonBackward];
    buttonBackward.center = CGPointMake(self.view.frame.size.width / 2.0 - 35,self.view.frame.size.height / 2.0 + 00);

    // -- end custom view setup --
}


- (void)update {
    // Update the UI on the widget here
    UIImage __block *artwork;

    if ([(SBMediaController*)[objc_getClass("SBMediaController") sharedInstance] isPlaying]) {
        MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
            [UIView animateWithDuration:0.2f animations:^{
                artwork = [UIImage imageWithData:[(__bridge NSDictionary*)information objectForKey:@"kMRMediaRemoteNowPlayingInfoArtworkData"]];

                [self.playButton setBackgroundImage:kTintedImageNamed(@"pause.circle.fill") forState:UIControlStateNormal];
                self.subtitle.text = [(__bridge NSDictionary*)information objectForKey:@"kMRMediaRemoteNowPlayingInfoArtist"];
                self.title.text = [(__bridge NSDictionary*)information objectForKey:@"kMRMediaRemoteNowPlayingInfoTitle"];
                self.background.image = artwork;
            } completion:nil];
        }); } else {
        [UIView animateWithDuration:0.2f animations:^{
            [self.playButton setBackgroundImage:kTintedImageNamed(@"play.circle.fill") forState:UIControlStateNormal];
        } completion:nil];
    }
}

// Some custom functions I add for buttons on the widget
- (void)playPause:(UIButton*)sender {
    MRMediaRemoteSendCommand(kMRTogglePlayPause, 0);
    [self update];
}

- (void)forward:(UIButton*)sender {
    MRMediaRemoteSendCommand(kMRNextTrack, 0);
    [self update];
}

- (void)reverse:(UIButton*)sender {
    MRMediaRemoteSendCommand(kMRPreviousTrack, 0);
    [self update];
}


@end

// Call this method on your widget's class, and tell it the bundle ID of the widget you want to replace
static __attribute__((constructor)) void AVCSpotifyContstructor (int __unused argc, char __unused **argv, char __unused **envp)
{
    [AVCWidgetServer sharedInstance];
    [AVCSpotifyWidget registerClassForIdentifier:@"com.spotify.client.widgetnowplaying"];
}