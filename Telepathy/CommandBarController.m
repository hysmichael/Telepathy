//
//  CommandBarController.m
//  Telepathy
//
//  Created by Michael Hong on 5/20/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "CommandBarController.h"

#define SPACE_STR @" "

@interface CommandBarController ()

@property BOOL *sendingInProgress;

@end

@implementation CommandBarController

- (void)awakeFromNib {
    NSSize screenSize = [[NSScreen mainScreen] frame].size;
    NSRect frame = NSMakeRect(screenSize.width * 0.25, screenSize.height * 0.7, screenSize.width * 0.5, 100.0);
    
    NSWindow *window = self.window;
    [window setLevel:NSPopUpMenuWindowLevel];
    [window setOpaque:NO];
    [window setBackgroundColor:[NSColor clearColor]];
    [window setFrame:frame display:true];
    
    NSView *view = self.window.contentView;
    view.wantsLayer = true;
    view.layer.cornerRadius = 10.0f;

    NSString *userGender = [[DataManager sharedManager] userSelf][@"gender"];
    [self.logoView setImage:[NSImage imageNamed:[NSString stringWithFormat:@"logo_%@", userGender]]];
    
    self.textField.delegate = self;
    [self.textField setTarget:self];
    [self.textField setAction:@selector(textFieldEntered:)];
    
    [self.progressIndicator stopAnimation:nil];
    self.sendingInProgress = false;
    
    self.window.delegate = self;
}

- (void)windowDidResignKey:(NSNotification *)notification {
    [self.window close];
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    self.textField.placeholderString = @"Telepathy";
}

- (void) textFieldEntered: (id)sender {
    if (!self.sendingInProgress && [self.textField.stringValue length] > 0) {
        [self.progressIndicator startAnimation:nil];
        if (![self parseCommand]) {
            self.textField.stringValue = [NSString new];
            self.textField.placeholderString = @"Invalid Command";
            [self.progressIndicator stopAnimation:nil];
        }
    }
}

- (BOOL) parseCommand {
    NSString *command = self.textField.stringValue;

    if ([command hasPrefix:@"@"]) {
        NSArray *commandArgs = [command componentsSeparatedByString:SPACE_STR];
        command = [[commandArgs firstObject] substringFromIndex:1];
        
        /* Reserved for other commands */
        
        /* Setter for Emotion Index */
        NSInteger eIndex = [command integerValue];
        if (eIndex < 0 || eIndex > 5) return false;
        [[DataManager sharedManager] setEIndex:eIndex callback:^(BOOL success) {
            [self commandExecuted:success];
        }];
        
        return true;
    }
    
    /* Message */
    [[DataManager sharedManager] sendMessage:self.textField.stringValue callback:^(BOOL success) {
        [self commandExecuted:success];
    }];
    
    return true;
}

- (void) commandExecuted:(BOOL) success {
    [self.progressIndicator stopAnimation:nil];
    self.sendingInProgress = false;
    if (success) {
        self.textField.stringValue = [NSString new];
        [self.window close];
    } else {
        /* Message failed to be sent. */
    }
}

@end
