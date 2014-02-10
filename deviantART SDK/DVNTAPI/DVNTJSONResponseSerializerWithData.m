//
//  DVNTJSONResponseSerializerWithData.m
//  Bootstrap
//
//  Created by Aaron Pearce on 13/11/13.
//  Copyright (c) 2013 deviantART. All rights reserved.
//

#import "DVNTJSONResponseSerializerWithData.h"

static NSString * const JSONResponseSerializerWithDataKey = @"responseData";

@implementation DVNTJSONResponseSerializerWithData

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (*error != nil) {
            NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
            userInfo[JSONResponseSerializerWithDataKey] = data;
            NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
            (*error) = newError;
        }
        
        return (nil);
    }
    
    return ([super responseObjectForResponse:response data:data error:error]);
}

@end
