//
//  DVNTJSONResponseSerializerWithData.h
//  Bootstrap
//
//  Created by Aaron Pearce on 13/11/13.
//  Copyright (c) 2013 deviantART. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

/** Provides an easy way to get hold of the real JSON in case of a failed request, not just the pointless error through NSError's userinfo as the key "responseData"
 */
@interface DVNTJSONResponseSerializerWithData : AFJSONResponseSerializer

@end
