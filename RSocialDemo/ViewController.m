//
//  ViewController.m
//  RSocialDemo
//
//  Created by Alex Rezit on 16/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "MBProgressHUD.h"
#import "RSocialDoubanAuth.h"
#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@property (nonatomic, strong) RSocialDoubanAuth *doubanAuth;

- (IBAction)checkButtonPressed:(UIButton *)button;
- (IBAction)loginButtonPressed:(UIButton *)button;
- (IBAction)logoutButtonPressed:(UIButton *)button;

@end

@implementation ViewController

- (void)checkButtonPressed:(UIButton *)button
{
    self.statusLabel.text = NSLocalizedString(@"Checking", nil);
    MBProgressHUD *progressHUD = self.progressHUD;
    progressHUD.labelText = NSLocalizedString(@"Checking...", nil);
    [progressHUD show:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isAuthed = [self.doubanAuth checkAuthorizationUpdate];
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressHUD hide:YES];
            self.statusLabel.text = isAuthed ? NSLocalizedString(@"Authed", nil) : NSLocalizedString(@"Not Authed", nil);
        });
    });
}

- (void)loginButtonPressed:(UIButton *)button
{
    MBProgressHUD *progressHUD = self.progressHUD;
    progressHUD.labelText = NSLocalizedString(@"Logging in...", nil);
    [progressHUD show:YES];
    [self.doubanAuth authorizeWithCompletionHandler:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressHUD hide:YES];
            self.statusLabel.text = success ? NSLocalizedString(@"Authed", nil) : NSLocalizedString(@"Not Authed", nil);
        });
    }];
}

- (void)logoutButtonPressed:(UIButton *)button
{
    [self.doubanAuth logout];
    self.statusLabel.text = self.doubanAuth.isAuthorized ? NSLocalizedString(@"Authed", nil) : NSLocalizedString(@"Not Authed", nil);
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MBProgressHUD *progressHUD = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    progressHUD.minShowTime = 0.3f;
    self.progressHUD = progressHUD;
    [self.view addSubview:progressHUD];
    
    RSocialDoubanAuth *doubanAuth = [[[RSocialDoubanAuth alloc] init] autorelease];
    self.doubanAuth = doubanAuth;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.statusLabel.text = self.doubanAuth.isAuthorized ? NSLocalizedString(@"Authed", nil) : NSLocalizedString(@"Not Authed", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
