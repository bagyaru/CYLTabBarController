/*
 //  CYLTabBarController
 //  CYLTabBarController
 //
 //  Created by 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong/ ) on 03/06/19.
 //  Copyright © 2019 https://github.com/ChenYilong . All rights reserved.
 */

#import "UIView+CYLBadgeExtention.h"
#import <objc/runtime.h>
#import "CAAnimation+CYLBadgeExtention.h"

#define kCYLBadgeDefaultFont				([UIFont boldSystemFontOfSize:9])

#define kCYLBadgeDefaultMaximumBadgeNumber                     99
#define kCYLBadgeDefaultMargin                (8.0)


static const CGFloat kCYLBadgeDefaultRedDotRadius = 4.f;

@implementation UIView (CYLBadgeExtention)

#pragma mark -- public methods
/**
 *  show badge with red dot style and CYLBadgeAnimTypeNone by default.
 */
- (void)cyl_showBadge {
    [self cyl_showBadgeValue:@"" animationType:CYLBadgeAnimTypeNone];
}

- (void)cyl_showBadgeValue:(NSString *)value animationType:(CYLBadgeAnimType)aniType {
    self.cyl_aniType = aniType;
    [self cyl_showBadgeWithValue:value];

    if (aniType != CYLBadgeAnimTypeNone) {
        [self cyl_beginAnimation];
    }
}

- (void)cyl_showBadgeValue:(NSString *)value {
    [self cyl_showBadgeValue:value animationType:CYLBadgeAnimTypeNone];
}

#pragma mark -- private methods
- (void)cyl_showBadgeWithValue:(NSString *)value {
    if (!value) {
        return;
    }
    NSCharacterSet *numberSet = [NSCharacterSet decimalDigitCharacterSet];
    NSString * trimmedString = [value stringByTrimmingCharactersInSet:numberSet];
    BOOL isNumber = NO;
    if ((trimmedString.length == 0) && (value.length > 0)) {
        isNumber = YES;
    }
    if (isNumber) {
        [self cyl_showNumberBadgeWithValue:[value integerValue]];
        return;
    }

    if ([value isEqualToString:@""]) {
        [self cyl_showRedDotBadge];
        return;
    }
    if ([value isEqualToString:@"new"] || [value isEqualToString:@"NEW"] ) {
        [self cyl_showNewBadge:value];
        return;
    }
    [self cyl_showTextBadge:value];
}

/**
 *  clear badge
 */
- (void)cyl_clearBadge {
    self.cyl_badge.hidden = YES;
}

- (BOOL)cyl_isShowBadge {
    return (self.cyl_badge && !self.cyl_badge.hidden );
}

/**
 *  make bage(if existing) not hiden
 */
- (void)cyl_resumeBadge {
    if (self.cyl_isPauseBadge) {
        self.cyl_badge.hidden = NO;
    }
}

- (BOOL)cyl_isPauseBadge {
    return (self.cyl_badge && self.cyl_badge.hidden == YES);
}

#pragma mark -- private methods
- (void)cyl_showRedDotBadge {
    [self cyl_badgeInit];

    //if badge has been displayed and, in addition, is was not red dot style, we must update UI.
    if (self.cyl_badge.tag != CYLBadgeStyleRedDot) {
        self.cyl_badge.text = @"";
        self.cyl_badge.tag = CYLBadgeStyleRedDot;
        [self resetRedDotBadgeFrame];
        self.cyl_badge.layer.cornerRadius = CGRectGetWidth(self.cyl_badge.frame) / 2;
    }
    self.cyl_badge.hidden = NO;
}

- (void)cyl_showNewBadge:(NSString *)value {
    [self cyl_badgeInit];
    //if badge has been displayed and, in addition, is not red dot style, we must update UI.
    if (self.cyl_badge.tag != CYLBadgeStyleNew) {
        self.cyl_badge.text = value;
        self.cyl_badge.tag = CYLBadgeStyleNew;

        CGRect frame = self.cyl_badge.frame;
        frame.size.width = 22;
        frame.size.height = 13;
        self.cyl_badge.frame = frame;

        self.cyl_badge.center = CGPointMake(CGRectGetWidth(self.frame) + 2 + self.cyl_badgeCenterOffset.x, self.cyl_badgeCenterOffset.y);
        self.cyl_badge.font = kCYLBadgeDefaultFont;
        self.cyl_badge.layer.cornerRadius = CGRectGetHeight(self.cyl_badge.frame) / 3;
    }
    self.cyl_badge.hidden = NO;
}

- (void)cyl_showTextBadge:(NSString *)value {
    [self cyl_badgeInit];
    if (self.cyl_badge.tag != CYLBadgeStyleOther) {
        self.cyl_badge.tag = CYLBadgeStyleOther;
        self.cyl_badge.text = value;
        [self cyl_adjustLabelWidth:self.cyl_badge];
        CGRect frame = self.cyl_badge.frame;
        frame.size.height = 12;
        if(CGRectGetWidth(frame) < CGRectGetHeight(frame)) {
            frame.size.width = CGRectGetHeight(frame);
        }
        self.cyl_badge.frame = frame;
        self.cyl_badge.center = CGPointMake(CGRectGetWidth(self.frame) + 2 + self.cyl_badgeCenterOffset.x, self.cyl_badgeCenterOffset.y);
        self.cyl_badge.font = [UIFont boldSystemFontOfSize:9];
        
        self.cyl_badge.layer.cornerRadius = CGRectGetHeight(self.cyl_badge.frame) / 2;
        self.cyl_badge.hidden = NO;
        if (value == 0) {
            self.cyl_badge.hidden = YES;
        }
    }
    self.cyl_badge.hidden = NO;
}
    
- (void)cyl_showNumberBadgeWithValue:(NSInteger)value {
    if (value < 0) {
        return;
    }
    [self cyl_badgeInit];
    self.cyl_badge.hidden = (value == 0);
    self.cyl_badge.tag = CYLBadgeStyleNumber;
    self.cyl_badge.font = self.cyl_badgeFont;
    self.cyl_badge.text = (value > self.cyl_badgeMaximumBadgeNumber ?
                       [NSString stringWithFormat:@"%@+", @(self.cyl_badgeMaximumBadgeNumber)] :
                       [NSString stringWithFormat:@"%@", @(value)]);
    [self cyl_adjustLabelWidth:self.cyl_badge];
    CGRect frame = self.cyl_badge.frame;
    frame.size.width += self.cyl_badgeMargin;
    frame.size.height += self.cyl_badgeMargin;
    if(CGRectGetWidth(frame) < CGRectGetHeight(frame)) {
        frame.size.width = CGRectGetHeight(frame);
    }
    self.cyl_badge.frame = frame;
    self.cyl_badge.center = CGPointMake(CGRectGetWidth(self.frame) + 2 + self.cyl_badgeCenterOffset.x, self.cyl_badgeCenterOffset.y);
    self.cyl_badge.layer.cornerRadius = CGRectGetHeight(self.cyl_badge.frame) / 2;
}

//lazy loading
- (void)cyl_badgeInit {
    if (self.cyl_badgeBackgroundColor == nil) {
        self.cyl_badgeBackgroundColor = [UIColor redColor];
    }
    if (self.cyl_badgeTextColor == nil) {
        self.cyl_badgeTextColor = [UIColor whiteColor];
    }
    
    if (!self.cyl_badge) {
        self.cyl_badge = [[UILabel alloc] init];
                          [self resetRedDotBadgeFrame];
        self.cyl_badge.textAlignment = NSTextAlignmentCenter;
        self.cyl_badge.backgroundColor = self.cyl_badgeBackgroundColor;
        self.cyl_badge.textColor = self.cyl_badgeTextColor;
        self.cyl_badge.text = @"";
        self.cyl_badge.tag = CYLBadgeStyleRedDot;//red dot by default
        self.cyl_badge.layer.cornerRadius = CGRectGetWidth(self.cyl_badge.frame) / 2;
        self.cyl_badge.layer.masksToBounds = YES;//very important
        self.cyl_badge.hidden = YES;
        self.cyl_badge.layer.zPosition = MAXFLOAT;

        [self addSubview:self.cyl_badge];
        [self bringSubviewToFront:self.cyl_badge];
    }
}

- (void)resetRedDotBadgeFrame {
    CGFloat redotWidth = kCYLBadgeDefaultRedDotRadius *2;
    if (self.cyl_badgeRadius) {
        redotWidth = self.cyl_badgeRadius *2;
    }
    CGRect frame = CGRectMake(CGRectGetWidth(self.frame), -redotWidth, redotWidth, redotWidth);
    self.cyl_badge.frame = frame;
    self.cyl_badge.center = CGPointMake(CGRectGetWidth(self.frame) + 2 + self.cyl_badgeCenterOffset.x, self.cyl_badgeCenterOffset.y);
}
#pragma mark --  other private methods
- (void)cyl_adjustLabelWidth:(UILabel *)label {
    [label setNumberOfLines:0];
    NSString *s = label.text;
    UIFont *font = [label font];
    CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) ,CGFLOAT_MAX);
	CGSize labelsize;

	if (![s respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		labelsize = [s sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
		
	} else {
		NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		[style setLineBreakMode:NSLineBreakByWordWrapping];
		
		labelsize = [s boundingRectWithSize:size
									options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
								 attributes:@{ NSFontAttributeName:font, NSParagraphStyleAttributeName : style}
									context:nil].size;
	}
    CGRect frame = label.frame;
	frame.size = CGSizeMake(ceilf(labelsize.width), ceilf(labelsize.height));
    [label setFrame:frame];
}

#pragma mark -- animation

//if u want to add badge animation type, follow steps bellow:
//1. go to definition of CYLBadgeAnimType and add new type
//2. go to category of CAAnimation+CYLBadgeExtention to add new animation interface
//3. call that new interface here
- (void)cyl_beginAnimation {
    switch(self.cyl_aniType) {
        case CYLBadgeAnimTypeBreathe:
            [self.cyl_badge.layer addAnimation:[CAAnimation cyl_opacityForever_Animation:1.4]
                                    forKey:kBadgeBreatheAniKey];
            break;
        case CYLBadgeAnimTypeShake:
            [self.cyl_badge.layer addAnimation:[CAAnimation cyl_shake_AnimationRepeatTimes:CGFLOAT_MAX
                                                                          durTimes:1
                                                                            forObj:self.cyl_badge.layer]
                                    forKey:kBadgeShakeAniKey];
            break;
        case CYLBadgeAnimTypeScale:
            [self.cyl_badge.layer addAnimation:[CAAnimation cyl_scaleFrom:1.4
                                                          toScale:0.6
                                                         durTimes:1
                                                              rep:MAXFLOAT]
                                    forKey:kBadgeScaleAniKey];
            break;
        case CYLBadgeAnimTypeBounce:
            [self.cyl_badge.layer addAnimation:[CAAnimation cyl_bounce_AnimationRepeatTimes:CGFLOAT_MAX
                                                                          durTimes:1
                                                                            forObj:self.cyl_badge.layer]
                                    forKey:kBadgeBounceAniKey];
            break;
        case CYLBadgeAnimTypeNone:
        default:
            break;
    }
}


- (void)cyl_removeAnimation {
    if (self.cyl_badge) {
        [self.cyl_badge.layer removeAllAnimations];
    }
}

#pragma mark -- setter/getter
- (UILabel *)cyl_badge {
    return objc_getAssociatedObject(self, &badgeLabelKey);
}

- (void)cyl_setBadge:(UILabel *)label {
    objc_setAssociatedObject(self, &badgeLabelKey, label, OBJC_ASSOCIATION_RETAIN);
}

- (UIFont *)cyl_badgeFont {
	id font = objc_getAssociatedObject(self, &badgeFontKey);
	return font == nil ? kCYLBadgeDefaultFont : font;
}

- (void)cyl_setBadgeFont:(UIFont *)badgeFont {
	objc_setAssociatedObject(self, &badgeFontKey, badgeFont, OBJC_ASSOCIATION_RETAIN);
    if (!self.cyl_badge) {
        [self cyl_badgeInit];
    }
    self.cyl_badge.font = badgeFont;
}

- (UIColor *)cyl_badgeBackgroundColor {
    return objc_getAssociatedObject(self, &badgeBackgroundColorKey);
}

- (void)cyl_setBadgeBackgroundColor:(UIColor *)badgeBackgroundColor {
    objc_setAssociatedObject(self, &badgeBackgroundColorKey, badgeBackgroundColor, OBJC_ASSOCIATION_RETAIN);
    if (!self.cyl_badge) {
        [self cyl_badgeInit];
    }
    self.cyl_badge.backgroundColor = badgeBackgroundColor;
}

- (UIColor *)cyl_badgeTextColor {
    return objc_getAssociatedObject(self, &badgeTextColorKey);
}

- (void)cyl_setBadgeTextColor:(UIColor *)badgeTextColor {
    objc_setAssociatedObject(self, &badgeTextColorKey, badgeTextColor, OBJC_ASSOCIATION_RETAIN);
    if (!self.cyl_badge) {
        [self cyl_badgeInit];
    }
    self.cyl_badge.textColor = badgeTextColor;
}

- (CYLBadgeAnimType)cyl_aniType {
    id obj = objc_getAssociatedObject(self, &badgeAniTypeKey);
    if(obj != nil && [obj isKindOfClass:[NSNumber class]]) {
        return [obj integerValue];
    }
        return CYLBadgeAnimTypeNone;
}

- (void)cyl_setAniType:(CYLBadgeAnimType)aniType {
    NSNumber *numObj = @(aniType);
    objc_setAssociatedObject(self, &badgeAniTypeKey, numObj, OBJC_ASSOCIATION_RETAIN);
    if (!self.cyl_badge) {
        [self cyl_badgeInit];
    }
    [self cyl_removeAnimation];
    [self cyl_beginAnimation];
}

- (CGRect)cyl_badgeFrame {
    id obj = objc_getAssociatedObject(self, &badgeFrameKey);
    if (obj != nil && [obj isKindOfClass:[NSDictionary class]] && [obj count] == 4) {
        CGFloat x = [obj[@"x"] floatValue];
        CGFloat y = [obj[@"y"] floatValue];
        CGFloat width = [obj[@"width"] floatValue];
        CGFloat height = [obj[@"height"] floatValue];
        return  CGRectMake(x, y, width, height);
    }
        return CGRectZero;
}

- (void)cyl_setBadgeFrame:(CGRect)badgeFrame {
    NSDictionary *frameInfo = @{@"x" : @(badgeFrame.origin.x), @"y" : @(badgeFrame.origin.y),
                                @"width" : @(badgeFrame.size.width), @"height" : @(badgeFrame.size.height)};
    objc_setAssociatedObject(self, &badgeFrameKey, frameInfo, OBJC_ASSOCIATION_RETAIN);
    if (!self.cyl_badge) {
        [self cyl_badgeInit];
    }
    self.cyl_badge.frame = badgeFrame;
}

- (CGPoint)cyl_badgeCenterOffset {
    id obj = objc_getAssociatedObject(self, &badgeCenterOffsetKey);
    if (obj != nil && [obj isKindOfClass:[NSDictionary class]] && [obj count] == 2) {
        CGFloat x = [obj[@"x"] floatValue];
        CGFloat y = [obj[@"y"] floatValue];
        return CGPointMake(x, y);
    } 
        return CGPointZero;
}

- (void)cyl_setBadgeCenterOffset:(CGPoint)badgeCenterOff {
    NSDictionary *cenerInfo = @{@"x" : @(badgeCenterOff.x), @"y" : @(badgeCenterOff.y)};
    objc_setAssociatedObject(self, &badgeCenterOffsetKey, cenerInfo, OBJC_ASSOCIATION_RETAIN);
    if (!self.cyl_badge) {
        [self cyl_badgeInit];
    }
    self.cyl_badge.center = CGPointMake(CGRectGetWidth(self.frame) + 2 + badgeCenterOff.x, badgeCenterOff.y);
}

//badgeRadiusKey

- (void)cyl_setBadgeRadius:(CGFloat)badgeRadius {
    objc_setAssociatedObject(self, &badgeRadiusKey, [NSNumber numberWithFloat:badgeRadius], OBJC_ASSOCIATION_RETAIN);
    if (!self.cyl_badge) {
        [self cyl_badgeInit];
    }
}

- (CGFloat)cyl_badgeRadius {
    return [objc_getAssociatedObject(self, &badgeRadiusKey) floatValue];
}

- (void)cyl_setBadgeMargin:(CGFloat)badgeMargin {
    objc_setAssociatedObject(self, &badgeMarginKey, [NSNumber numberWithFloat:badgeMargin], OBJC_ASSOCIATION_RETAIN);
    if (!self.cyl_badge) {
        [self cyl_badgeInit];
    }
}

- (CGFloat)cyl_badgeMargin {
    id margin = objc_getAssociatedObject(self, &badgeMarginKey);
    return margin == nil ? kCYLBadgeDefaultMargin : [margin floatValue];
}

- (NSInteger)cyl_badgeMaximumBadgeNumber {
    id obj = objc_getAssociatedObject(self, @selector(cyl_badgeMaximumBadgeNumber));
    if(obj != nil && [obj isKindOfClass:[NSNumber class]]) {
        return [obj integerValue];
    }
        return kCYLBadgeDefaultMaximumBadgeNumber;
}

- (void)cyl_setBadgeMaximumBadgeNumber:(NSInteger)badgeMaximumBadgeNumber {
    NSNumber *numObj = @(badgeMaximumBadgeNumber);
    objc_setAssociatedObject(self, @selector(cyl_badgeMaximumBadgeNumber), numObj, OBJC_ASSOCIATION_RETAIN);
    if (!self.cyl_badge) {
        [self cyl_badgeInit];
    }
}

//- (NSInteger)cyl_badgeMaximumBadgeNumber {
//    NSNumber *badgeMaximumBadgeNucyl_setBadgeMaximumBadgeNumbermberObject = objc_getAssociatedObject(self, @selector(cyl_badgeMaximumBadgeNumber));
//    if(badgeMaximumBadgeNumberObject != nil && [badgeMaximumBadgeNumberObject isKindOfClass:[NSNumber class]]) {
//        return [badgeMaximumBadgeNumberObject integerValue];
//    } else {
//        return kCYLBadgeDefaultMaximumBadgeNumber;
//    }
//}
//
//- (void):(NSInteger)badgeMaximumBadgeNumber {
//#warning Attention:`numberWithBool` ,If it is other Number type change this method.
//    NSNumber *badgeMaximumBadgeNumberObject = @(badgeMaximumBadgeNumber);
//    objc_setAssociatedObject(self, @selector(cyl_badgeMaximumBadgeNumber), badgeMaximumBadgeNumberObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

@end
