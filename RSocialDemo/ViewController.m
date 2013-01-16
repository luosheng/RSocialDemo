//
//  ViewController.m
//  RSocialDemo
//
//  Created by Alex Rezit on 16/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "RDoubanAuth.h"
#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) RDoubanAuth *doubanAuth;

- (IBAction)checkButtonPressed:(UIButton *)button;
- (IBAction)loginButtonPressed:(UIButton *)button;
- (IBAction)logoutButtonPressed:(UIButton *)button;

@end

@implementation ViewController

- (void)checkButtonPressed:(UIButton *)button
{
    self.statusLabel.text = NSLocalizedString(@"Checking", nil);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isAuthed = [self.doubanAuth checkAuthorizationUpdate];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = isAuthed ? NSLocalizedString(@"Authed", nil) : NSLocalizedString(@"Not Authed", nil);
        });
    });
}

- (void)loginButtonPressed:(UIButton *)button
{
    [self.doubanAuth authorizeWithCompletionHandler:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
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
    
    RDoubanAuth *doubanAuth = [[[RDoubanAuth alloc] init] autorelease];
    doubanAuth.clientID = @"0bdb1a1a76c3e40b23914e4f644bac21";
    doubanAuth.clientSecret = @"c92655b1f2bea687";
    doubanAuth.redirectURI = @"rsocial://";
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
