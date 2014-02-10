//
//  DVNTAPIClient.h
//  Bootstrap
//
//  Created by Aaron Pearce on 13/11/13.
//  Copyright (c) 2013 deviantART. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFOAuthCredential.h"

/** DVNTAPIClient encapsulates the overall logic for interacting with the deviantART API.
 
 It requires that it is setup within your application delegate's application:didFinishLaunchingWithOptions: method by calling:
 
    [DVNTAPIClient setClientID: clientSecret:];
 
 This will initialize the singleton class with the correct client information.
 
 From here it is required that you call to authenticate with deviantART via the included webview:
        
    [DVNTAPIClient authenticateFromController: completionHandler:];
 
 After this calls it's completion handler you can place your API calls via the GET or POST methods, or use DVNTAPIRequest which is a wrapper for the API calls.
 */
@interface DVNTAPIClient : NSObject

/** BaseURL for the SDK, should always be "https://www.deviantart.com" */
extern NSString * const DVNTClientBaseURLString;

/** Redirect URI for the SDK, should be "https://www.deviantart.com/oauth2/redirect" */
extern NSString * const DVNTClientRedirectURIString;

// Properties
/**
 Whether the OAuth credentials exist.
 */
@property (readonly, nonatomic, assign) BOOL hasCredential;

/**
 Whether the OAuth credentials are expired.
 */
@property (readonly, nonatomic, assign, getter = isExpired) BOOL expired;

/**
 Whether the OAuth credentials exist and are valid and usable.
 */
@property (readonly, nonatomic, assign, getter = isAuthenticated) BOOL authenticated;

/**
 The Service Provider
 */
@property (nonatomic, readonly) NSString *serviceProviderIdentifier;

/**
 The client ID
 */
@property (nonatomic, readonly) NSString *clientID;

/**
 The client secret
 */
@property (nonatomic, readonly) NSString *clientSecret;

/**
 The redirect URI
 */
@property (nonatomic, readonly) NSString *redirectURI;


/**---------------------------------------------------------------------------------------
 * @name Initialization Methods
 *  ---------------------------------------------------------------------------------------
 */

/**
 Returns the singleton for DVNTAPIClient
 
 @return DVNTAPIClient The singleton instance of the client
 */
+ (DVNTAPIClient *)sharedClient;


/**
 Sets the client ID and secret to use in the SDK. 
 
 This must be the first call made to DVNTAPIClient. Should be called in your application delegate's application:didFinishLaunchingWithOptions:.
 
 @param clientID The application's client ID
 @param clientSecret The application's client secret
 */
+ (void)setClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret;


/**
 Sets a custom redirectURI if wanted.
 
 Must be called per session. Preferably directly after setClientID:clientSecret:.
 
 @param redirectURI The URI to use for redirecting
 */
+ (void)setRedirectURI:(NSString *)redirectURI;


/**---------------------------------------------------------------------------------------
 * @name Authentication Methods
 *  ---------------------------------------------------------------------------------------
 */

/**
 Used to authenticate your application with deviantART on iOS. Presents an instance of DAAPIAuthViewController that shows the correct authorization page.
 
 @param controller The controller to present from.
 @param scope The scope for the API.
 @param completionHandler The completion handler to be called when authentication is completed.
 */

#if __IPHONE_OS_VERSION_MIN_REQUIRED
+ (void)authenticateFromController:(UIViewController *)controller scope:(NSString *)scope completionHandler:(void (^)(NSError *))completionHandler;
#else
+ (void)authenticateWithScope:(NSString *)scope completionHandler:(void (^)(NSError *))completionHandler;
#endif

/**
 Unauthenticates the user's credentials from the app by deleting them.
 */
+ (void)unauthenticate;


/**
 Checks if the application has a fully authenticated user by checking for credentials and if they are expired or not.
 
 @return BOOL representing if the app is fully authenticated and ready to make calls to the API.
 */
+ (BOOL)isAuthenticated;


/**
 Checks if the current credentials are expired or not.
 
 @return BOOL representing if the current credentials in the app are expired.
 */
+ (BOOL)isExpired;


/**
 Refreshes the current credentials with the API to retrieve a current OAuth token.
 
 @param path The URL path to authenticate against. Relative to the base URL.
 @param refreshToken The refresh token to use to reauthenticate.
 @param success Success completion block to be called if authentication is successful, returns the new credential.
 @param failure Failure block to be called if authentication failed.
 */
+ (void)authenticateUsingOAuthWithPath:(NSString *)path refreshToken:(NSString *)refreshToken success:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure;


/**
 Authenticate with the API using a code to retrieve a current OAuth token.
 
 @param path The URL path to authenticate against. Relative to the base URL.
 @param code The code returned from /oauth2/authorize.
 @param scope The scope needed for the API.
 @param uri The redirect URI for your application.
 @param success Success completion block to be called if authentication is successful, returns the new credential.
 @param failure Failure block to be called if authentication failed.
 */
+ (void)authenticateUsingOAuthWithPath:(NSString *)path code:(NSString *)code redirectURI:(NSString *)uri success:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure;


/**
 Base authentication method, all other authentication methods use this internally.
 
 @param path The URL path to authenticate against. Relative to the base URL.
 @param parameters The parameters to be encoded and sent.
 @param success Success completion block to be called if authentication is successful, returns the new credential.
 @param failure Failure block to be called if authentication failed.
 */
- (void)authenticateUsingOAuthWithPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure;


/**---------------------------------------------------------------------------------------
 * @name Credential Methods
 *  ---------------------------------------------------------------------------------------
 */

/**
 Checks if the application currently has credentials for a user.
 
 @return BOOL representing if the application has credentials for a user.
 */
+ (BOOL)hasCredential;


/**
 Stores the given credential into the application's keychain.
 
 @param credential The credential to store.
 */
+ (void)storeCredential:(AFOAuthCredential *)credential;


/**---------------------------------------------------------------------------------------
 * @name HTTP Methods
 *  ---------------------------------------------------------------------------------------
 */


/**
 Creates and runs an NSURLSessionDataTask with a GET request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


/**
 Creates and runs an NSURLSessionDataTask with a POST request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


/**
 Creates and runs an NSURLSessionDataTask with a POST request with multipart form data.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer
 @param block A block that takes a single argument and appends data to the HTTP body. The block argument is an object adopting the AFMultipartFormData protocol.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void ( ^ ) ( id<AFMultipartFormData> formData ))block success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure;


/**---------------------------------------------------------------------------------------
 * @name Other Methods
 *  ---------------------------------------------------------------------------------------
 */

/**
 Returns the request serializer for use in creating tasks as needed.
 
 @return Returns the singleton's instance of AFHTTPRequestSerializer
 */
+ (AFHTTPRequestSerializer *)requestSerializer;

@end
