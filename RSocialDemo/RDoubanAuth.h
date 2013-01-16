//
//  RDoubanAuth.h
//  RSocialDemo
//
//  Created by Alex Rezit on 16/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

/*
 * Douban authorization flow
 *
 * if (access token is valid) {
 *     complete
 * } else if (refresh token is valid) {
 *     refresh token -> access token -> complete
 * } else {
 *     prompt web view -> auth code -> access token (& refresh token)
 * }
 *
 */

#import <Foundation/Foundation.h>
#import "RSocialAuthWebViewController.h"

extern NSString * const kRDoubanAuthPromptLink;
extern NSString * const kRDoubanAuthAccessTokenLink;

@interface RDoubanAuth : NSObject <RSocialAuthWebViewControllerDelegate>

// Config
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *redirectURI;
@property (nonatomic, strong) NSArray *scope;

// Property
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSDate *accessTokenTimeout;
@property (nonatomic, strong) NSDate *refreshTokenTimeout;

// Return YES if access token is currently valid.
- (BOOL)isAuthorized;

// If access token is currently valid, return YES. Or try use refresh token to fetch access token, then return YES if the process succeeded.
- (BOOL)checkAuthorizationUpdate;

// Try authorize using standard auth flow.
- (void)authorizeWithCompletionHandler:(void (^)(BOOL success))completion;

// Clears all the information stored.
- (void)logout;

@end
