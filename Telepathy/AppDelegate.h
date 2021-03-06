//
//  AppDelegate.h
//  Telepathy
//
//  Created by Michael Hong on 4/22/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MenubarController.h"
#import "PanelController.h"
#import "CommandBarController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, PanelControllerDelegate>

@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;
@property (nonatomic, strong) CommandBarController *commandBarController;

@property NSTimer *recurrentTimer;

- (IBAction) togglePanel:(id)sender;
- (void) refreshStatusItemView;
- (void) registerRecurrentEvents;

@end

