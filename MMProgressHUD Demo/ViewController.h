//
//  ViewController.h
//  MMProgressHUD Demo
//
//  Created by Lanvige Jiang on 7/24/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *showIndictorButton;
@property (nonatomic, weak) IBOutlet UIButton *showSuccessButton;
@property (nonatomic, weak) IBOutlet UIButton *showFailureButton;

- (IBAction)showIndictorAction:(id)sender;
- (IBAction)showSuccessAction:(id)sender;
- (IBAction)showFailureAction:(id)sender;

@end
