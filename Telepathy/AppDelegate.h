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

@interface AppDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate>

@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;

- (IBAction)togglePanel:(id)sender;	

@end

