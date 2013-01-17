//
//  RSocialRenrenAuth.m
//  RSocialDemo
//
//  Created by Alex Rezit on 17/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "RSocialRenrenAuth.h"

#define kRSocialRenrenAuthKeyAccessToken @"RenrenAccessToken"
#define kRSocialRenrenAuthKeyRefreshToken @"RenrenRefreshToken"
#define kRSocialRenrenAuthKeyAccessTokenTimeout @"RenrenAccessTokenTimeout"
#define kRSocialRenrenAuthKeyRefreshTokenTimeout @"RenrenRefreshTokenTimeout"

NSString * const kRSocialRenrenAuthPromptLink = @"https://graph.renren.com/oauth/authorize";
NSString * const kRSocialRenrenAuthAccessTokenLink = @"https://graph.renren.com/oauth/token";

@interface RSocialRenrenAuth ()

@end

@implementation RSocialRenrenAuth

#pragma mark - Getters and setters

#warning ATTENTION!!!
#warning STORE TOKENS IN PLAIN TEXT IS NOT SAFE!!!
#warning PLEASE MODIFY THIS PART WHEN YOU USE MY CODE!!!

- (NSString *)accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialRenrenAuthKeyAccessToken];
}

- (NSString *)refreshToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialRenrenAuthKeyRefreshToken];
}

- (NSDate *)accessTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialRenrenAuthKeyAccessTokenTimeout];
}

- (NSDate *)refreshTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialRenrenAuthKeyRefreshTokenTimeout];
}

- (void)setAccessToken:(NSString *)accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:accessToken forKey:kRSocialRenrenAuthKeyAccessToken];
    [userDefaults synchronize];
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:refreshToken forKey:kRSocialRenrenAuthKeyRefreshToken];
    [userDefaults synchronize];
}

- (void)setAccessTokenTimeout:(NSDate *)accessTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:accessTokenTimeout forKey:kRSocialRenrenAuthKeyAccessTokenTimeout];
    [userDefaults synchronize];
}

- (void)setRefreshTokenTimeout:(NSDate *)refreshTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:refreshTokenTimeout forKey:kRSocialRenrenAuthKeyRefreshTokenTimeout];
    [userDefaults synchronize];
}

#pragma mark - Life cycle

- (void)configure
{
    self.clientID = @"46e83f7e948142b49a482ace4feb621b";
    self.clientSecret = @"9284b023da3b490984fd995819cf602b";
    self.redirectURI = @"http://graph.renren.com/oauth/login_success.html";
    
    self.authorizeLink = kRSocialRenrenAuthPromptLink;
    self.accessTokenLink = kRSocialRenrenAuthAccessTokenLink;
}


@end
