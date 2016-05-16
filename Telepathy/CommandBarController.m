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
        NSRange range = [command rangeOfString:SPACE_STR];
        NSString *args = nil;
        if (range.location != NSNotFound) {
            args = [command substringFromIndex:range.location + 1];
            command = [command substringWithRange:NSMakeRange(1, range.location - 1)];
        } else {
            command = [command substringFromIndex:1];
        }
        
        /* Turn on "Spy Mode" */
        if ([command isEqualToString:@"spy"]) {
            [[DataManager sharedManager] setOnSpy:true];
            [self commandExecuted:true];
            return true;
        }
        
        /* Setter for Focus Mode */
        if ([command isEqualToString:@"focus"]) {
            if (!args) return false;
            if ([args isEqualToString:@"on"]) {
                [[DataManager sharedManager] setOnFocus:true];
            } else if ([args isEqualToString:@"off"]) {
                [[DataManager sharedManager] setOnFocus:false];
            } else {
                return false;
            }
            [self commandExecuted:true];
            return true;
        }
        
        /* Add New Anniversary */
        if ([command isEqualToString:@"anniversary"]) {
            if (!args) return false;
            NSRange secondRange = [args rangeOfString:SPACE_STR];
            NSString *name = nil;
            if (range.location == NSNotFound) return false;
            name = [args substringFromIndex:secondRange.location + 1];
            args = [args substringWithRange:NSMakeRange(0, secondRange.location)];
            if ([name length] == 0) return false;
            
            NSCalendar *calender = [NSCalendar currentCalendar];
            
            NSArray *components = [args componentsSeparatedByString:@"/"];
            if ([components count] != 2 && [components count] != 3) return false;
            NSInteger monthValue = [components[0] integerValue];
            NSInteger dayValue = [components[1] integerValue];
            NSInteger yearValue = [calender component:NSCalendarUnitYear fromDate:[NSDate date]];
            if ([components count] == 3) yearValue = [components[2] integerValue];
            
            if (!(monthValue >= 1 && monthValue <= 12 && dayValue >= 1 && dayValue <= 31 &&
                  yearValue >= 1970)) return false;

            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setDay:dayValue];
            [dateComponents setMonth:monthValue];
            [dateComponents setYear:yearValue];
            NSDate *date = [calender dateFromComponents:dateComponents];
            if (!date) return false;
            
            [[DataManager sharedManager] addAnniversary:name date:date callback:^(BOOL success) {
                [self commandExecuted:success];
            }];
            
            return true;
        }
        
        /* Setter for Emotion Index */
        NSInteger eIndex = [command integerValue];
        if (eIndex == 0) return false;
        
        if (eIndex < 1 || eIndex > 5) return false;
        
        [[DataManager sharedManager] setEIndex:eIndex callback:^(BOOL success) {
            [self commandExecuted:success];
        }];
        
        NSMutableArray *mood_char_arr = [[NSMutableArray alloc] initWithObjects:@"[", nil];
        for (int i = 0; i < eIndex; i++) [mood_char_arr addObject:@"♥"];
        for (int i = (int)eIndex; i < 5; i++) [mood_char_arr addObject:@"_"];
        [mood_char_arr addObject:@"]"];
        
        NSString *message = [mood_char_arr componentsJoinedByString:@""];
        if (args && [args length] > 0) {
            message = [NSString stringWithFormat:@"%@ %@", message, args];
        }
        [[DataManager sharedManager] sendMessage:message callback:nil];
        
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

- (IBAction)escapeCommand:(id)sender {
    [self.window close];
}


@end
