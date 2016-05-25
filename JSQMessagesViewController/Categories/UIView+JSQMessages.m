//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "UIView+JSQMessages.h"

@implementation UIView (JSQMessages)

- (void)jsq_pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:attribute
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:subview
                                                     attribute:attribute
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}

- (void)jsq_pinAllEdgesOfSubview:(UIView *)subview
{
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeBottom];
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeTop];
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeLeading];
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeTrailing];
}

- (void)jsq_pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute withValue:(CGFloat)value
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:attribute
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:subview
                                                     attribute:attribute
                                                    multiplier:1.0f
                                                      constant:value]];
}

- (void)jsq_pinAllEdgesOfMediaView:(UIView *)subview isOutgoing:(BOOL)isOutgoing
{
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeBottom withValue:0];
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeTop withValue:0];
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeLeading withValue:isOutgoing?-10:10];
    [self jsq_pinSubview:subview toEdge:NSLayoutAttributeTrailing withValue:isOutgoing?-5:10];
}

@end
