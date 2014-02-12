//
//  DVNTAPIClient.m
//  Bootstrap
//
//  Created by Aaron Pearce on 13/11/13.
//  Copyright (c) 2013 deviantART. All rights reserved.
//

#import "DVNTAPIClient.h"

#import "DVNTJSONResponseSerializerWithData.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    #import "AFNetworkActivityIndicatorManager.h"
    #import "DVNTAPIAuthViewController.h"
#else
    #import <Cocoa/Cocoa.h>
    #import "DVNTAPIMacAuthViewController.h"
#endif

// set constant strings to use .lan if LAN & DEBUG are defined in the preprocessor macros.
#if (defined(LAN) && defined(DEBUG))

NSString * const DVNTClientBaseURLString = @"https://www.deviantart.lan";
NSString * const DVNTClientBaseServiceProviderString = @"www.deviantart.lan";
NSString * const DVNTClientRedirectURIString = @"https://www.deviantart.com/oauth2/redirect";

#else

NSString * const DVNTClientBaseURLString = @"https://www.deviantart.com";
NSString * const DVNTClientBaseServiceProviderString = @"www.deviantart.com";
NSString * const DVNTClientRedirectURIString = @"https://www.deviantart.com/oauth2/redirect";

#endif

@interface DVNTAPIClient () {
}

@property (nonatomic) AFHTTPResponseSerializer *responseSerializer;
@property (nonatomic) AFHTTPRequestSerializer *requestSerializer;
@property (nonatomic) AFHTTPSessionManager *authedDataSessionManager;
@property (nonatomic, readwrite) NSString *serviceProviderIdentifier;
@property (nonatomic, readwrite) NSString *clientID;
@property (nonatomic, readwrite) NSString *clientSecret;
@property (nonatomic) NSURL *baseURL;
@property (nonatomic) NSString *redirectURI;
@property (nonatomic) NSMutableArray *tasks;
@property (nonatomic) id authWindow;

@end

@implementation DVNTAPIClient

#pragma mark - Singleton

+ (DVNTAPIClient *)sharedClient {
    static DVNTAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:DVNTClientBaseURLString]];
        
        #if __IPHONE_OS_VERSION_MIN_REQUIRED
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        #endif
    });
    return _sharedClient;
}

#pragma mark - Initializers

- (id)initWithBaseURL:(NSURL *)url {
    // Make sure clientID is set
    self = [self init];
    if (!self) {
        return nil;
    }
    
    // Allowed to access instance variables directly here.
    // base url for all calls
    _baseURL = url;
    
    // default to our own redirect URI.
    _redirectURI = DVNTClientRedirectURIString;
    
    // serializers for requests and response, automatically serialize to right format.
    _requestSerializer = [AFHTTPRequestSerializer serializer];
    _responseSerializer = [DVNTJSONResponseSerializerWithData serializer];
    
    // basic session manager for all oAuth2 calls, use this by default.
    _authedDataSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    _authedDataSessionManager.requestSerializer = _requestSerializer;
    _authedDataSessionManager.responseSerializer = _responseSerializer;
    
    // set security policy to allow self-signed certificates if LAN & DEBUG are defined in the preprocessor macros.
    #if (defined(LAN) && defined(DEBUG))
    
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];

    [_authedDataSessionManager setSecurityPolicy:securityPolicy];
    
    #endif
    
    _tasks = [NSMutableArray array];
    
    return self;
}

+ (void)setClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret {
    [[self sharedClient] setClientID:clientID clientSecret:clientSecret];
}

- (void)setClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret {
    self.clientID = clientID;
    self.clientSecret = clientSecret;
    
    // for storing credentials
    self.serviceProviderIdentifier = [NSString stringWithFormat:@"%@-%@", DVNTClientBaseServiceProviderString, clientID];
}

// forward this call on to the client
+ (void)setRedirectURI:(NSString *)redirectURI {
    [[self sharedClient] setRedirectURI:redirectURI];
}

#pragma mark - API Method Calls

// Basic GET go to _dataSessionManager
+ (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSURLSessionDataTask *task = [[self sharedClient] GET:URLString parameters:parameters success:success failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(![self isExpired] && ![self hasQueuedTasks]) {
            if(failure) {
                failure(task, error);
            }
        }
    }];
    
    if([self isExpired]) {
        [task cancel];
        [[self sharedClient] addTaskToQueueWithURLString:URLString method:@"GET" parameters:parameters success:[success copy] failure:[failure copy]];
        
        if(![self hasQueuedTasks]) {
            [self refreshTokenIfExpiredWithSuccess:^(AFOAuthCredential *credential) {
                [self storeCredential:credential];
                [[self sharedClient] runQueuedTasks];
            } failure:^(NSError *error) {
                if(failure) {
                    failure(task, error);
                }
            }];
        }
    }
    
    return task;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [self.authedDataSessionManager GET:URLString parameters:parameters success:success failure:failure];
}

// POST go to _dataSessionManager
+ (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSURLSessionDataTask *task = [[self sharedClient] POST:URLString parameters:parameters success:success failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(![self isExpired] && ![self hasQueuedTasks]) {
            if(failure) {
                failure(task, error);
            }
        }
    }];
    
    if([self isExpired]) {
        [task cancel];
        [[self sharedClient] addTaskToQueueWithURLString:URLString method:@"POST" parameters:parameters success:[success copy] failure:[failure copy]];
        
        if(![self hasQueuedTasks]) {
            [self refreshTokenIfExpiredWithSuccess:^(AFOAuthCredential *credential) {
                [self storeCredential:credential];
                [[self sharedClient] runQueuedTasks];
            } failure:^(NSError *error) {
                if(failure) {
                    failure(task, error);
                }
            }];
        }
    }
    
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [self.authedDataSessionManager POST:URLString parameters:parameters success:success failure:failure];
}

// POST multipart
+ (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void ( ^ ) ( id<AFMultipartFormData> formData ))block success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    NSURLSessionDataTask *task = [[self sharedClient] POST:URLString parameters:parameters constructingBodyWithBlock:block success:success failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(![self isExpired] && ![self hasQueuedTasks]) {
            if(failure) {
                failure(task, error);
            }
        }
    }];
    
    if([self isExpired]) {
        [task cancel];
        NSMutableDictionary *mutableParameters  = [NSMutableDictionary dictionaryWithDictionary:parameters];
        [mutableParameters setObject:[block copy] forKey:@"dataBlock"];
        
        [[self sharedClient] addTaskToQueueWithURLString:URLString method:@"POST-Data" parameters:mutableParameters success:[success copy] failure:[failure copy]];
        
        if(![self hasQueuedTasks]) {
            [self refreshTokenIfExpiredWithSuccess:^(AFOAuthCredential *credential) {
                [self storeCredential:credential];
                [[self sharedClient] runQueuedTasks];
            } failure:^(NSError *error) {
                if(failure) {
                    failure(task, error);
                }
            }];
        }
    }
    
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void ( ^ ) ( id<AFMultipartFormData> formData ))block success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure {
    return [self.authedDataSessionManager POST:URLString parameters:parameters constructingBodyWithBlock:block success:success failure:failure];
}

- (void)runQueuedTasks {
    NSArray *tasksLocal = [self.tasks copy];
    for (NSDictionary *task in tasksLocal) {
        
        [self.tasks removeObject:task];
        [self rebuildTask:task];
    }
}

- (void)rebuildTask:(NSDictionary *)task {
    NSString *method = task[@"method"];
    NSString *URLString = task[@"URLString"];
    NSMutableDictionary *parameters = task[@"parameters"];
    id successBlock = task[@"success"];
    id failureBlock = task[@"failure"];
    
    if([method isEqualToString:@"GET"]) {
        [self GET:URLString parameters:parameters success:successBlock failure:failureBlock];
    } else if([method isEqualToString:@"POST"])  {
        [self POST:URLString parameters:parameters success:successBlock failure:failureBlock];
    } else if([method isEqualToString:@"POST-Data"]) {
        id block = parameters[@"dataBlock"];
        [parameters removeObjectForKey:@"dataBlock"];
        [self POST:URLString parameters:parameters constructingBodyWithBlock:block success:successBlock failure:failureBlock];
    }
}

+ (BOOL)hasQueuedTasks {
    return [[self sharedClient] hasQueuedTasks];
}

- (BOOL)hasQueuedTasks {
    if(self.tasks.count > 1) return YES;
    return NO;
}

- (void)addTaskToQueueWithURLString:(NSString *)URLString method:(NSString *)method parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:@{@"URLString": URLString, @"method": method, @"success": success, @"failure": failure}];
    if(parameters) [mutableParameters setObject:parameters forKey:@"parameters"];
    [self.tasks addObject:mutableParameters];
}

#pragma mark - Authorization Headers

- (void)setAuthorizationHeaderWithCredential:(AFOAuthCredential *)credential {
    [self setAuthorizationHeaderWithToken:[credential accessToken] ofType:[credential tokenType]];
}

- (void)setAuthorizationHeaderWithToken:(NSString *)token
                                 ofType:(NSString *)type {
    // See http://tools.ietf.org/html/rfc6749#section-7.1
    if ([[type lowercaseString] isEqualToString:@"bearer"]) {
        // Set both session managers to have the same token as their Bearer HTTP header field.
        [self.authedDataSessionManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    }
}

#pragma mark - Authentication

+ (void)refreshTokenIfExpiredWithSuccess:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure {
    [[self sharedClient] refreshTokenIfExpiredWithSuccess:success failure:failure];
}

- (void)refreshTokenIfExpiredWithSuccess:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure {
    // if app has credentials, just refresh
    if(self.hasCredential && self.isExpired) {
        AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
        [self authenticateUsingOAuthWithPath:@"oauth2/token" refreshToken:credential.refreshToken success:success failure:failure];
    } else {
        [self setCredential];
        success(nil);
    }
}


// Class Methods
+ (void)authenticateUsingOAuthWithPath:(NSString *)path refreshToken:(NSString *)refreshToken success:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure {
    [[self sharedClient] authenticateUsingOAuthWithPath:path refreshToken:refreshToken success:success failure:failure];
}

+ (void)authenticateUsingOAuthWithPath:(NSString *)path code:(NSString *)code redirectURI:(NSString *)uri success:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure {
    [[self sharedClient] authenticateUsingOAuthWithPath:path code:code redirectURI:uri success:success failure:failure];
}

// Implementation Methods
- (void)authenticateUsingOAuthWithPath:(NSString *)path refreshToken:(NSString *)refreshToken success:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setObject:@"refresh_token" forKey:@"grant_type"];
    [mutableParameters setValue:refreshToken forKey:@"refresh_token"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    [self authenticateUsingOAuthWithPath:path parameters:parameters success:success failure:failure];
}

- (void)authenticateUsingOAuthWithPath:(NSString *)path code:(NSString *)code redirectURI:(NSString *)uri success:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setObject:@"authorization_code" forKey:@"grant_type"];
    [mutableParameters setValue:code forKey:@"code"];
    [mutableParameters setValue:uri forKey:@"redirect_uri"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    [self authenticateUsingOAuthWithPath:path parameters:parameters success:success failure:failure];
}

- (void)authenticateUsingOAuthWithPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [mutableParameters setObject:self.clientID forKey:@"client_id"];
    [mutableParameters setValue:self.clientSecret forKey:@"client_secret"];
    
    parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    NSString *urlString = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
    
    NSMutableURLRequest *mutableRequest = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:mutableRequest];
    
    // set security policy to allow self-signed certificates if LAN & DEBUG are defined in the preprocessor macros.
    #if (defined(LAN) && defined(DEBUG))
    
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    
    [requestOperation setSecurityPolicy:securityPolicy];
    
    #endif
    
    [requestOperation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject valueForKey:@"error"]) {
            if (failure) {
                // TODO: Resolve the `error` field into a proper NSError object
                // http://tools.ietf.org/html/rfc6749#section-5.2
                failure(nil);
            }
            
            return;
        }
        
        NSString *refreshToken = [responseObject valueForKey:@"refresh_token"];
        if (refreshToken == nil || [refreshToken isEqual:[NSNull null]]) {
            refreshToken = [parameters valueForKey:@"refresh_token"];
        }
        
        AFOAuthCredential *credential = [AFOAuthCredential credentialWithOAuthToken:[responseObject valueForKey:@"access_token"] tokenType:[responseObject valueForKey:@"token_type"]];
        
        NSDate *expireDate = nil;
        id expiresIn = [responseObject valueForKey:@"expires_in"];
        if (expiresIn != nil && ![expiresIn isEqual:[NSNull null]]) {
            expireDate = [NSDate dateWithTimeIntervalSinceNow:[expiresIn doubleValue]];
        }
        
        [credential setRefreshToken:refreshToken expiration:expireDate];
        
        [self setAuthorizationHeaderWithCredential:credential];
        
        if (success) {
            success(credential);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
            [userInfo setObject:operation.responseObject forKey:@"responseJSON"];
            
            NSError *errorChanged = [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:userInfo];
            
            failure(errorChanged);
        }
    }];
    
    [requestOperation start];
}

#pragma mark - Setup 

+ (void)unauthenticate {
    [[self sharedClient] deleteCredential];
    [[self sharedClient] setAuthorizationHeaderWithCredential:nil];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED
+ (void)authenticateFromController:(UIViewController *)controller scope:(NSString *)scope completionHandler:(void (^)(NSError *))completionHandler {
    [[self sharedClient] authenticateFromController:controller scope:scope completionHandler:completionHandler];
}

- (void)authenticateFromController:(UIViewController *)controller scope:(NSString *)scope completionHandler:(void (^)(NSError *))completionHandler {
    if(self.hasCredential) {
        // if app has credentials, just refresh
        if(self.isExpired) {
            AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
            [self authenticateUsingOAuthWithPath:@"oauth2/token" refreshToken:credential.refreshToken success:^(AFOAuthCredential *credential) {
                [self storeCredential:credential];
                completionHandler(nil);
            } failure:^(NSError *error) {
                completionHandler(error);
            }];
        } else {
            [self setCredential];
            completionHandler(nil);
        }
    } else {
        // if no credentials, show view
        scope = [scope stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *urlString = [NSString stringWithFormat:@"%@/oauth2/authorize?response_type=code&client_id=%@&redirect_uri=%@&scope=%@", DVNTClientBaseURLString, self.clientID, self.redirectURI, scope];
        NSURL *authURL = [NSURL URLWithString:urlString];

        UIViewController *authController = [[DVNTAPIAuthViewController alloc] initWithURL:authURL completionHandler:completionHandler];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:authController];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            authController.modalPresentationStyle = UIModalPresentationFormSheet;
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [controller presentViewController:navController animated:YES completion:nil];
    }
}

#else

+ (void)authenticateWithScope:(NSString *)scope completionHandler:(void (^)(NSError *))completionHandler {
    [[self sharedClient] authenticateWithScope:scope completionHandler:completionHandler];
}

- (void)authenticateWithScope:(NSString *)scope completionHandler:(void (^)(NSError *))completionHandler {
    if(self.hasCredential) {
        // if app has credentials, just refresh
        if(self.isExpired) {
            AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
            [self authenticateUsingOAuthWithPath:@"oauth2/token" refreshToken:credential.refreshToken success:^(AFOAuthCredential *credential) {
                [self storeCredential:credential];
                completionHandler(nil);
            } failure:^(NSError *error) {
                completionHandler(error);
            }];
        } else {
            [self setCredential];
            completionHandler(nil);
        }
    } else {
        // if no credentials, show view
        scope = [scope stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *urlString = [NSString stringWithFormat:@"%@/oauth2/authorize?response_type=code&client_id=%@&redirect_uri=%@&scope=%@", DVNTClientBaseURLString, self.clientID, self.redirectURI, scope];
        NSURL *authURL = [NSURL URLWithString:urlString];
        
        self.authWindow = [[DVNTAPIMacAuthViewController alloc] initWithURL:authURL completionHandler:completionHandler];
        [self.authWindow makeKeyAndOrderFront:self];
        [self.authWindow center];
    }
}

#endif 

+ (void)storeCredential:(AFOAuthCredential *)credential {
    [[self sharedClient] storeCredential:credential];
}

- (void)storeCredential:(AFOAuthCredential *)credential {
    [AFOAuthCredential storeCredential:credential withIdentifier:self.serviceProviderIdentifier];
    [self setAuthorizationHeaderWithCredential:credential];
}

- (void)setCredential {
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
    [self setAuthorizationHeaderWithCredential:credential];
}

- (void)deleteCredential {
    [AFOAuthCredential deleteCredentialWithIdentifier:self.serviceProviderIdentifier];
}

#pragma mark - Credential Checks

+ (BOOL)isAuthenticated {
    return [self sharedClient].isAuthenticated;
}

- (BOOL)isAuthenticated {
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
    BOOL isAuthed = NO;
    if (credential) {
        isAuthed = !credential.isExpired;
        if(isAuthed) [self setAuthorizationHeaderWithCredential:credential];
    }
    
    return isAuthed;
}

+ (BOOL)isExpired {
    return [self sharedClient].isExpired;
}

- (BOOL)isExpired {
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
    
    if (credential)
        return credential.isExpired;
    else
        return YES;
}

+ (BOOL)hasCredential {
    return [self sharedClient].hasCredential;
}

- (BOOL)hasCredential {
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
    if (credential) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Class Variables

+ (AFHTTPRequestSerializer *)requestSerializer {
    return [[self sharedClient] requestSerializer];
}

@end
