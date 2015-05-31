//
//  AppDelegate.m
//  Telepathy
//
//  Created by Michael Hong on 4/22/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "AppDelegate.h"
#import <ParseOSX/ParseOSX.h>
#import "DDHotKey/DDHotKeyCenter.h"
#import <Carbon/Carbon.h>

@implementation AppDelegate

@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;

#pragma mark -

- (void)dealloc {
    [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
}

#pragma mark -

void *kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kContextActivePanel) {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // Set up Parse server
    // [Optional] Power your app with Local Datastore. For more info, go to
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"IQBuX6iAqrVilh9LVNjv0o4hOWy228XueOO5KkbN"
                  clientKey:@"6KSU89Ew0awhCW3OVG0vNiVwcEpUD9gCJGkHaydl"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:nil];
    
    // Set up notification delegate
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    // Install system hot key
    [self registerHotKey];
    
    // Initialize command bar window
    self.commandBarController = [[CommandBarController alloc] initWithWindowNibName:@"CommandBar"];
    
    // Install icon into the menu bar
    self.menubarController = [[MenubarController alloc] init];
    
    // open panel at launch
    [self togglePanel:self];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    // Explicitly invalidate the recurrent timer
    if (self.recurrentTimer) [self.recurrentTimer invalidate];
    return NSTerminateNow;
}

#pragma mark - Actions

- (IBAction)togglePanel:(id)sender {
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
}

- (void)refreshStatusItemView {
    [self.menubarController.statusItemView setNeedsDisplay:YES];
}

#pragma mark - Public accessors

- (PanelController *)panelController {
    if (_panelController == nil) {
        _panelController = [[PanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
    }
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController*)controller {
    return self.menubarController.statusItemView;
}

#pragma mark - System Notifications
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    if (!self.panelController.hasActivePanel) [self togglePanel:self];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return true;
}

- (void) registerRecurrentEvents {
    if (self.recurrentTimer && self.recurrentTimer.valid) return;
    if ([PFUser currentUser]) {
        NSTimeInterval interval = 900;  // 15 minutes
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:interval];
        self.recurrentTimer = [[NSTimer alloc] initWithFireDate:fireDate interval:interval
                                                         target:[DataManager sharedManager] selector:@selector(checkNewNotification)
                                                       userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.recurrentTimer forMode:NSDefaultRunLoopMode];
    }
}

#pragma mark - Hotkey registration

- (void) registerHotKey {
    [[DDHotKeyCenter sharedHotKeyCenter] registerHotKeyWithKeyCode:kVK_ANSI_Q modifierFlags:NSControlKeyMask task:^(NSEvent *event) {
        [self togglePanel:self];
    }];
    
    [[DDHotKeyCenter sharedHotKeyCenter] registerHotKeyWithKeyCode:kVK_ANSI_W modifierFlags:NSControlKeyMask task:^(NSEvent *event) {
        if ([PFUser currentUser]) {
            if (![NSApp isActive]) [NSApp activateIgnoringOtherApps:YES];
            [self.commandBarController.window makeKeyAndOrderFront:self];
            [self.commandBarController.textField becomeFirstResponder];
        }
    }];
}


@end
