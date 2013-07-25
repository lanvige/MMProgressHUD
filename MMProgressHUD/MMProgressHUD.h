//
//  MMProgressHUD.h
//  MMProgressHUD Demo
//
//  Created by Lanvige Jiang on 7/24/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//


enum {
    MMProgressHUDIndicator = 1,
    MMProgressHUDSuccess,
    MMProgressHUDError,
    MMProgressHUDCustom
};

typedef NSUInteger MMProgressHUDType;


#import <UIKit/UIKit.h>

@interface MMProgressHUD : UIView

+ (void)showIndicatorWithStatus:(NSString*)status;
+ (void)showProgress:(CGFloat)progress status:(NSString*)status;
+ (void)showSuccessWithStatus:(NSString *)status;
+ (void)showErrorWithStatus:(NSString *)status;
+ (void)showImage:(UIImage *)image status:(NSString *)status; // use 28x28 white pngs

+ (void)dismiss;
+ (void)dismissAfterDelay:(NSTimeInterval)delay;

@end
