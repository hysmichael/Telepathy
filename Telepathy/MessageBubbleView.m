//
//  MessageBubbleView.m
//  Telepathy
//
//  Created by Michael Hong on 5/17/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "MessageBubbleView.h"
#import "TPTextField.h"

@interface MessageBubbleView()

@property TPTextField *textview;
@property BOOL unread;

@end

static NSString *spaceStr = @" ";

@implementation MessageBubbleView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.textview = [[TPTextField alloc] initWithFrame:NSMakeRect(10.0, 10.0, 240.0, 0.0)];
        [self.textview.cell setWraps:true];
        [self.textview setPreferredMaxLayoutWidth:240.0];
        [self addSubview:self.textview];
    }
    return self;
}

- (CGFloat) setContentObject:(id)object {
    self.unread = !([object[@"isRead"] boolValue]);
    [self setBackgroundColor:(self.unread ? [TPColor darkPurple:0.5] : [TPColor lightPurple:0.5])];
    [self setBoarderRadius:10.0 color:[TPColor mediumPurple] width:2.0];
    NSAttributedString *attrStr = [self attributedStringForText:object[@"text"] andTimeStamp:object[@"postAt"]];
    self.textview.attributedStringValue = attrStr;
    [self.textview sizeToFit];
    return self.textview.frame.size.height + 20.0;
}


- (NSAttributedString *) attributedStringForText:(NSString *) text andTimeStamp:(NSDate *) date {
    NSDate *dateInLocalTime = [[DataManager sharedManager] convertDateFromPartnerTimezoneToSelfTimezone:date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([NSDate daysFromDate:dateInLocalTime toDate:[NSDate date]] == 0) {
        // date is today
        [dateFormatter setDateFormat:@"HH:mm"];
    } else {
        [dateFormatter setDateFormat:@"HH:mm MMM dd"];
    }
    NSString *dateStr = [dateFormatter stringFromDate:dateInLocalTime];
    
    NSColor *textColor = self.unread ? [TPColor defaultBlack] : [TPColor darkGray];
    NSColor *timeColor = self.unread ? [TPColor lightGray] : [TPColor mediumGray];
    
    NSDictionary *textAttributes = @{NSFontAttributeName: [NSFont TPFontWithSize:12.0], NSForegroundColorAttributeName: textColor};
    NSDictionary *timeAttributes = @{NSFontAttributeName: [NSFont TPFontWithSize:10.0] , NSForegroundColorAttributeName: timeColor};
    
    NSAttributedString *textAttrStr = [[NSAttributedString alloc] initWithString:[text stringByAppendingString:spaceStr] attributes:textAttributes];
    NSAttributedString *timeAttrStr = [[NSAttributedString alloc] initWithString:dateStr attributes:timeAttributes];
    
    NSMutableAttributedString *outputStr = [[NSMutableAttributedString alloc] init];
    [outputStr appendAttributedString:textAttrStr];
    [outputStr appendAttributedString:timeAttrStr];
    
    NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paraStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [outputStr addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, [outputStr length])];
    
    return outputStr;
}

@end
