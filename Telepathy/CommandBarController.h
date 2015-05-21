//
//  CommandBarController.h
//  Telepathy
//
//  Created by Michael Hong on 5/20/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CommandBarController : NSWindowController <NSWindowDelegate, NSTextFieldDelegate>

@property IBOutlet NSImageView *logoView;
@property IBOutlet NSTextField *textField;
@property IBOutlet NSProgressIndicator *progressIndicator;

@end
