//
//  DVNTAPIAuthViewController.h
//  Bootstrap
//
//  Created by Aaron Pearce on 14/11/13.
//  Copyright (c) 2013 deviantART. All rights reserved.
//

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>

/** This class is used to create the controller for authentication with deviantART.
 
 It is passed an authorization URL and a completion handler to call when authorization is completed.
 */
@interface DVNTAPIAuthViewController : UIViewController <UIWebViewDelegate>

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