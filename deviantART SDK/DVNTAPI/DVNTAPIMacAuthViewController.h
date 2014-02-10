//
//  DVNTAPIMacAuthViewController.h
//  deviantART SDK
//
//  Created by Aaron Pearce on 15/01/14.
//  Copyright (c) 2014 deviantART. All rights reserved.
//

#if !__IPHONE_OS_VERSION_MIN_REQUIRED
@interface DVNTAPIMacAuthViewController : NSWindow

/**
 Initializes the controller with the authorization URL and a completion handler to call when authentication completed.
 
 @param authURL The authorization URL to use when authenticating.
 @param scope Scope for the API
 @param completionHandler The completion handler to call when authentication is completed.
 @return The controller that was initialized
 */
- (id)initWithURL:(NSURL *)authURL completionHandler:(void (^)(NSError *))completionHandler;

@end

#endif