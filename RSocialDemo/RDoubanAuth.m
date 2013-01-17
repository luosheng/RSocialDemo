//
//  RDoubanAuth.m
//  RSocialDemo
//
//  Created by Alex Rezit on 16/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "RDoubanAuth.h"

#define kRDoubanAuthKeyAccessToken @"AccessToken"
#define kRDoubanAuthKeyRefreshToken @"RefreshToken"
#define kRDoubanAuthKeyAccessTokenTimeout @"AccessTokenTimeout"
#define kRDoubanAuthKeyRefreshTokenTimeout @"RefreshTokenTimeout"

NSString * const kRDoubanAuthPromptLink = @"https://www.douban.com/service/auth2/auth";
NSString * const kRDoubanAuthAccessTokenLink = @"https://www.douban.com/service/auth2/token";

@interface RDoubanAuth ()

@end

@implementation RDoubanAuth

#pragma mark - Auth flow

- (void)handleCodeAuthResponse:(NSDictionary *)responseDictionary
{
    [super handleCodeAuthResponse:responseDictionary];
    NSInteger expiresIn = [responseDictionary[@"expires_in"] integerValue];
    self.refreshTokenTimeout = [NSDate dateWithTimeIntervalSinceNow:expiresIn * 2];
}

- (void)handleRefreshTokenAuthResponse:(NSDictionary *)responseDictionary
{
    [super handleRefreshTokenAuthResponse:responseDictionary];
    NSInteger expiresIn = [responseDictionary[@"expires_in"] integerValue];
    self.refreshTokenTimeout = [NSDate dateWithTimeIntervalSinceNow:expiresIn * 2];
}

#pragma mark - Getters and setters

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

#pragma mark - Life cycle

- (void)configure
{
    self.clientID = @"0bdb1a1a76c3e40b23914e4f644bac21";
    self.clientSecret = @"c92655b1f2bea687";
    self.redirectURI = @"http://rsocial.seymourdev.com/";
    
    self.authorizeLink = kRDoubanAuthPromptLink;
    self.accessTokenLink = kRDoubanAuthAccessTokenLink;
}

@end
