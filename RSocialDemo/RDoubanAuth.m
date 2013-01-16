//
//  RDoubanAuth.m
//  RSocialDemo
//
//  Created by Alex Rezit on 16/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "NSString+URLCoding.h"
#import "RHTTPRequest.h"
#import "RDoubanAuth.h"

#define kRDoubanAuthKeyAccessToken @"AccessToken"
#define kRDoubanAuthKeyRefreshToken @"RefreshToken"
#define kRDoubanAuthKeyAccessTokenTimeout @"AccessTokenTimeout"
#define kRDoubanAuthKeyRefreshTokenTimeout @"RefreshTokenTimeout"

NSString * const kRDoubanAuthPromptLink = @"https://www.douban.com/service/auth2/auth";
NSString * const kRDoubanAuthAccessTokenLink = @"https://www.douban.com/service/auth2/token";

// Use this offset to avoid inexactness when determining whether the tokens are valid.
// For example, if the expires_in value is 3600 (60 min), the token will appear to be invalid after (60 - 5) = 55 min.
NSTimeInterval const kRDoubanAuthTimeoutOffset = 300; // 5 min

@interface RDoubanAuth ()

@property (nonatomic, readonly) BOOL isAccessTokenValid;
@property (nonatomic, readonly) BOOL isRefreshTokenValid;

@property (nonatomic, assign) dispatch_semaphore_t isAuthorizingViaWebViewSem;

// Auth flow
- (void)promptWithWebView;
- (void)getAccessTokenWithAuthCode;
- (void)getAccessTokenWithRefreshToken;

@end

@implementation RDoubanAuth

#pragma mark - External

// Status

- (BOOL)isAuthorized
{
    return self.isAccessTokenValid;
}

- (BOOL)checkAuthorizationUpdate
{
    BOOL isAuthorized = NO;
    if (self.isAccessTokenValid) {
        isAuthorized = YES;
    } else {
        if (self.isRefreshTokenValid) {
            [self getAccessTokenWithRefreshToken];
        }
        if (self.isAccessTokenValid) {
            isAuthorized = YES;
        }
    }
    return isAuthorized;
}

// Actions

- (void)authorizeWithCompletionHandler:(void (^)(BOOL success))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success = NO;
        if (self.isAccessTokenValid) {
            success = YES;
        } else {
            self.accessToken = nil;
            self.accessTokenTimeout = nil;
            if (self.isRefreshTokenValid) {
                [self getAccessTokenWithRefreshToken];
            } else {
                self.refreshToken = nil;
                self.refreshTokenTimeout = nil;
            }
            if (!self.accessToken) {
                dispatch_semaphore_t isAuthorizingViaWebViewSem = dispatch_semaphore_create(0);
                self.isAuthorizingViaWebViewSem = isAuthorizingViaWebViewSem;
                [self promptWithWebView];
                dispatch_semaphore_wait(isAuthorizingViaWebViewSem, DISPATCH_TIME_FOREVER);
                dispatch_release(isAuthorizingViaWebViewSem);
                self.isAuthorizingViaWebViewSem = NULL;
                [self getAccessTokenWithAuthCode];
            }
            if (self.isAccessTokenValid) {
                success = YES;
            }
        }
        completion(success);
    });
}

- (void)logout
{
    self.code = nil;
    self.accessToken = nil;
    self.accessTokenTimeout = nil;
    self.refreshToken = nil;
    self.refreshTokenTimeout = nil;
}

#pragma mark - Getters and setters

- (BOOL)isAccessTokenValid
{
    BOOL isAccessTokenValid = NO;
    if (self.accessToken && self.accessTokenTimeout) {
        NSDate *currentDate = [NSDate date];
        NSComparisonResult comparisonResult = [currentDate compare:[self.accessTokenTimeout dateByAddingTimeInterval:kRDoubanAuthTimeoutOffset]];
        if (comparisonResult == NSOrderedAscending) {
            isAccessTokenValid = YES;
        }
    }
    return isAccessTokenValid;
}

- (BOOL)isRefreshTokenValid
{
    BOOL isRefreshTokenValid = NO;
    if (self.refreshToken && self.refreshTokenTimeout) {
        NSDate *currentDate = [NSDate date];
        NSComparisonResult comparisonResult = [currentDate compare:[self.refreshTokenTimeout dateByAddingTimeInterval:kRDoubanAuthTimeoutOffset]];
        if (comparisonResult == NSOrderedAscending) {
            isRefreshTokenValid = YES;
        }
    }
    return isRefreshTokenValid;
}

#warning ATTENTION!!!
#warning STORE TOKENS IN PLAIN TEXT IS NOT SAFE!!!
#warning PLEASE MODIFY THIS PART WHEN YOU USE MY CODE!!!

- (NSString *)accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRDoubanAuthKeyAccessToken];
}

- (NSString *)refreshToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRDoubanAuthKeyRefreshToken];
}

- (NSDate *)accessTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRDoubanAuthKeyAccessTokenTimeout];
}

- (NSDate *)refreshTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRDoubanAuthKeyRefreshTokenTimeout];
}

- (void)setAccessToken:(NSString *)accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:accessToken forKey:kRDoubanAuthKeyAccessToken];
    [userDefaults synchronize];
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:refreshToken forKey:kRDoubanAuthKeyRefreshToken];
    [userDefaults synchronize];
}

- (void)setAccessTokenTimeout:(NSDate *)accessTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:accessTokenTimeout forKey:kRDoubanAuthKeyAccessTokenTimeout];
    [userDefaults synchronize];
}

- (void)setRefreshTokenTimeout:(NSDate *)refreshTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:refreshTokenTimeout forKey:kRDoubanAuthKeyRefreshTokenTimeout];
    [userDefaults synchronize];
}

#pragma mark - Auth flow

- (void)promptWithWebView
{
    // Find the window on the top.
    UIApplication *application = [UIApplication sharedApplication];
    UIWindow *topWindow = application.keyWindow;
    if (topWindow.windowLevel != UIWindowLevelNormal) {
        for (UIWindow *window in application.windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                topWindow = window;
                break;
            }
        }
    }
    
    if (!self.scope) {
        self.scope = @[];
    }
    NSDictionary *authRequestDictionary = @{
    @"client_id" : self.clientID,
    @"client_secret" : self.clientSecret,
    @"redirect_uri" : self.redirectURI,
    @"response_type" : @"code",
    @"scope" : self.scope
    };
    NSURL *urlWithData = [NSURL URLWithString:[kRDoubanAuthPromptLink stringByAppendingFormat:@"?%@", [NSString stringWithURLEncodedDictionary:authRequestDictionary]]];
    UINavigationController *navigationController = [RSocialAuthWebViewController navigationControllerWithAuthURL:urlWithData callbackURL:[NSURL URLWithString:self.redirectURI] delegate:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [topWindow.rootViewController presentViewController:navigationController animated:YES completion:nil];
    });
}

- (void)getAccessTokenWithAuthCode
{
    if (self.code) {
        NSURL *requestURL = [NSURL URLWithString:kRDoubanAuthAccessTokenLink];
        NSDictionary *requestDictionary = @{
        @"client_id" : self.clientID,
        @"client_secret" : self.clientSecret,
        @"redirect_uri" : self.redirectURI,
        @"grant_type" : @"code",
        @"code" : self.code
        };
        NSDictionary *responseHeaders = nil;
        NSDictionary *responseDictionary = [RHTTPRequest sendSynchronousRequestForURL:requestURL
                                                                               method:HTTPMethodPOST
                                                                              headers:nil
                                                                          requestBody:requestDictionary
                                                                      responseHeaders:&responseHeaders];
        if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
            self.accessToken = responseDictionary[@"access_token"];
            self.refreshToken = responseDictionary[@"refresh_token"];
            NSInteger expiresIn = [responseDictionary[@"expires_in"] integerValue];
            self.accessTokenTimeout = [NSDate dateWithTimeIntervalSinceNow:expiresIn];
            self.refreshTokenTimeout = [NSDate dateWithTimeIntervalSinceNow:expiresIn * 2];
        }
    }
}

- (void)getAccessTokenWithRefreshToken
{
    if (self.refreshToken) {
        NSURL *requestURL = [NSURL URLWithString:kRDoubanAuthAccessTokenLink];
        NSDictionary *requestDictionary = @{
        @"client_id" : self.clientID,
        @"client_secret" : self.clientSecret,
        @"redirect_uri" : self.redirectURI,
        @"grant_type" : @"refresh_token",
        @"refresh_token" : self.refreshToken
        };
        NSDictionary *responseHeaders = nil;
        NSDictionary *responseDictionary = [RHTTPRequest sendSynchronousRequestForURL:requestURL
                                                                               method:HTTPMethodPOST
                                                                              headers:nil
                                                                          requestBody:requestDictionary
                                                                      responseHeaders:&responseHeaders];
        if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
            self.accessToken = responseDictionary[@"access_token"];
            self.refreshToken = responseDictionary[@"refresh_token"];
            NSInteger expiresIn = [responseDictionary[@"expires_in"] integerValue];
            self.accessTokenTimeout = [NSDate dateWithTimeIntervalSinceNow:expiresIn];
            self.refreshTokenTimeout = [NSDate dateWithTimeIntervalSinceNow:expiresIn * 2];
        }
    }
}

#pragma mark - Auth web view controller delegate

- (void)authWebViewControllerDidDismiss:(RSocialAuthWebViewController *)viewController
{
    dispatch_semaphore_signal(self.isAuthorizingViaWebViewSem);
}

- (void)authWebViewController:(RSocialAuthWebViewController *)viewController didSuccessWithResponseDictionary:(NSDictionary *)responseDictionary
{
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        self.code = responseDictionary[@"code"];
    }
}

@end
