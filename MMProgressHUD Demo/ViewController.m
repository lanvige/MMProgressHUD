//
//  ViewController.m
//  MMProgressHUD Demo
//
//  Created by Lanvige Jiang on 7/24/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#import "ViewController.h"
#import "MMProgressHUD.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)showHUDButtonAction:(id)sender
{
//    [MMProgressHUD showSuccessWithStatus:@"Loading..."];
//    [MMProgressHUD dismissAfterDelay:3.f];
    
    
    
    
    [MMProgressHUD showErrorWithStatus:@"Loading..."];
    [MMProgressHUD dismissAfterDelay:3.f];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
