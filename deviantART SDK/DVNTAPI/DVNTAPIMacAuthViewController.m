//
//  DVNTAPIMacAuthViewController.m
//  deviantART SDK
//
//  Created by Aaron Pearce on 15/01/14.
//  Copyright (c) 2014 deviantART. All rights reserved.
//

#if !__IPHONE_OS_VERSION_MIN_REQUIRED
#import <Cocoa/Cocoa.h>
#import <Webkit/Webkit.h>
#import "DVNTAPIMacAuthViewController.h"
#import "DVNTAPIClient.h"

@interface DVNTAPIMacAuthViewController () {
    
}

@property (nonatomic) WebView *webView;
@property (nonatomic) WebFrame *webFrame;
@property (nonatomic, strong) void (^completionBlock)(NSError *);
@property (nonatomic) NSURL *authURL;
@end

@implementation DVNTAPIMacAuthViewController

- (id)initWithURL:(NSURL *)authURL completionHandler:(void (^)(NSError *))completionHandler {
    if ((self = [super initWithContentRect: NSMakeRect(100, 100, 700, 550)
                                 styleMask: NSTitledWindowMask backing: NSBackingStoreBuffered defer: YES])) {
        
        // clear cookies, need better way to do this?
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray* dAcookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://deviantart.com"]];
        for (NSHTTPCookie* cookie in dAcookies) {
            [cookies deleteCookie:cookie];
        }
        
        _authURL = authURL;
        
        _completionBlock = completionHandler;
        
        _webView  = [[WebView alloc] initWithFrame: NSMakeRect (0,0,700,550)];
        _webFrame = [_webView mainFrame];
        _webView.frameLoadDelegate = self;
        _webView.policyDelegate = self;
        
        [self setContentView:_webView];
        [self setTitle:@"Authorize this app"];
        [self setReleasedWhenClosed:NO];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:_authURL];
        
        [_webFrame loadRequest:request];
        
    }
    return self;
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
    NSString *URLString = [request.URL.absoluteString componentsSeparatedByString:@"?"][0];
    
    if([URLString isEqualToString:[DVNTAPIClient sharedClient].redirectURI]) {
        NSDictionary *parameters = [self queryParametersForURL:request.URL];
        
        NSString *code = parameters[@"code"];

        
        // now we have the code we can auth and dismiss this view
        [DVNTAPIClient authenticateUsingOAuthWithPath:@"/oauth2/token" code:code redirectURI:DVNTClientRedirectURIString success:^(AFOAuthCredential *credential) {
            [DVNTAPIClient storeCredential:credential];
            [self close];
            self.completionBlock(nil);
        } failure:^(NSError *error) {
            [self close];
            self.completionBlock(error);
        }];
    } else {
        [listener use];
    }
}

// gets query parameters from the URL
- (NSDictionary *)queryParametersForURL:(NSURL *)url {
    NSString *query = [url query];
    
    // Split into query params -> key/value
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];
    // each pair is separated by a & so we can loop them
    for (NSString *pairString in [query componentsSeparatedByString:@"&"]) {
        NSArray *pairArray = [pairString componentsSeparatedByString:@"="];
        
        // check for two values otherwise ignore it
        if(pairArray.count < 2) continue;
        
        [queryParams setObject:pairArray[1] forKey:pairArray[0]];
    }
    
    return queryParams;
}


@end

#endif
