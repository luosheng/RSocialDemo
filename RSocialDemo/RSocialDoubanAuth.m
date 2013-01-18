//
//  RSocialDoubanAuth.m
//  RSocialDemo
//
//  Created by Alex Rezit on 16/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "RSocialDoubanAuth.h"

#define kRSocialDoubanAuthKeyAccessToken @"DoubanAccessToken"
#define kRSocialDoubanAuthKeyRefreshToken @"DoubanRefreshToken"
#define kRSocialDoubanAuthKeyAccessTokenTimeout @"DoubanAccessTokenTimeout"
#define kRSocialDoubanAuthKeyRefreshTokenTimeout @"DoubanRefreshTokenTimeout"

NSString * const kRSocialDoubanAuthPromptLink = @"https://www.douban.com/service/auth2/auth";
NSString * const kRSocialDoubanAuthAccessTokenLink = @"https://www.douban.com/service/auth2/token";

@interface RSocialDoubanAuth ()

@end

@implementation RSocialDoubanAuth

#pragma mark - Auth flow

- (void)handleCodeAuthResponse:(NSDictionary *)responseDictionary
{
    [super handleCodeAuthResponse:responseDictionary];
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        NSInteger expiresIn = [responseDictionary[@"expires_in"] integerValue];
        self.refreshTokenTimeout = [NSDate dateWithTimeIntervalSinceNow:expiresIn * 2];
    }
}

- (void)handleRefreshTokenAuthResponse:(NSDictionary *)responseDictionary
{
    [super handleRefreshTokenAuthResponse:responseDictionary];
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        NSInteger expiresIn = [responseDictionary[@"expires_in"] integerValue];
        self.refreshTokenTimeout = [NSDate dateWithTimeIntervalSinceNow:expiresIn * 2];
    }
}

#pragma mark - Getters and setters

#warning ATTENTION!!!
#warning STORE TOKENS IN PLAIN TEXT IS NOT SAFE!!!
#warning PLEASE MODIFY THIS PART WHEN YOU USE MY CODE!!!

- (NSString *)accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialDoubanAuthKeyAccessToken];
}

- (NSString *)refreshToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialDoubanAuthKeyRefreshToken];
}

- (NSDate *)accessTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialDoubanAuthKeyAccessTokenTimeout];
}

- (NSDate *)refreshTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialDoubanAuthKeyRefreshTokenTimeout];
}

- (void)setAccessToken:(NSString *)accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:accessToken forKey:kRSocialDoubanAuthKeyAccessToken];
    [userDefaults synchronize];
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:refreshToken forKey:kRSocialDoubanAuthKeyRefreshToken];
    [userDefaults synchronize];
}

- (void)setAccessTokenTimeout:(NSDate *)accessTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:accessTokenTimeout forKey:kRSocialDoubanAuthKeyAccessTokenTimeout];
    [userDefaults synchronize];
}

- (void)setRefreshTokenTimeout:(NSDate *)refreshTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:refreshTokenTimeout forKey:kRSocialDoubanAuthKeyRefreshTokenTimeout];
    [userDefaults synchronize];
}

#pragma mark - Life cycle

- (void)configure
{
    self.clientID = @"0bdb1a1a76c3e40b23914e4f644bac21";
    self.clientSecret = @"c92655b1f2bea687";
    self.redirectURI = @"http://rsocial.seymourdev.com/";
    
    self.authorizeLink = kRSocialDoubanAuthPromptLink;
    self.accessTokenLink = kRSocialDoubanAuthAccessTokenLink;
}

@end
