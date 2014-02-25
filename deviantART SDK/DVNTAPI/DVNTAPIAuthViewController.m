//
//  DVNTAPIAuthViewController.m
//  Bootstrap
//
//  Created by Aaron Pearce on 14/11/13.
//  Copyright (c) 2013 deviantART. All rights reserved.
//

#import "DVNTAPIAuthViewController.h"
#import "DVNTAPIClient.h"

// set NSURLRequest to allow self-signed certificates if LAN & DEBUG are defined in the preprocessor macros.
#if (defined(LAN) && defined(DEBUG))
@implementation NSURLRequest (NSURLRequestWithIgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return YES;
}

@end

#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED

@interface DVNTAPIAuthViewController () {
}

@property (nonatomic) UIWebView *webView;
@property (nonatomic, strong) void (^completionBlock)(NSError *);
@property (nonatomic) NSURL *authURL;

@end

@implementation DVNTAPIAuthViewController

- (id)initWithURL:(NSURL *)authURL completionHandler:(void (^)(NSError *))completionHandler {
    if ((self = [super init])) {
        _authURL = authURL;

        _completionBlock = completionHandler;
        self.title = @"deviantART";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // clear cookies, need better way to do this?
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* dAcookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://deviantart.com"]];
    for (NSHTTPCookie* cookie in dAcookies) {
        [cookies deleteCookie:cookie];
    }
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.scalesPageToFit = YES;
    
    [self.view addSubview:self.webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.authURL];
    [self.webView loadRequest:request];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:^{
        // code 100 for user canceled
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"User canceled authorization" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"deviantART SDK" code:100 userInfo:errorDetail];
        
        self.completionBlock(error);
    }];
}

#pragma mark - Webview Delegates
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

// This is where we grab the authorization code
- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *URLString = [request.URL.absoluteString componentsSeparatedByString:@"?"][0];
    
    if([URLString isEqualToString:[DVNTAPIClient sharedClient].redirectURI]) {
        
        NSDictionary *parameters = [self queryParametersForURL:request.URL];
        
        NSString *code = parameters[@"code"];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        // now we have the code we can auth and dismiss this view
                    [DVNTAPIClient authenticateUsingOAuthWithPath:@"/oauth2/token" code:code redirectURI:DVNTClientRedirectURIString success:^(AFOAuthCredential *credential) {
                [DVNTAPIClient storeCredential:credential];
                [self dismissViewControllerAnimated:YES completion:^{
                    self.completionBlock(nil);
                }];
            } failure:^(NSError *error) {
                [self dismissViewControllerAnimated:YES completion:^{
                    self.completionBlock(error);
                }];
            }];
    }
    
    return YES;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

#endif