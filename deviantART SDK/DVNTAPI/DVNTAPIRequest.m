//
//  DVNTAPIRequest.m
//  Bootstrap
//
//  Created by Aaron Pearce on 15/11/13.
//  Copyright (c) 2013 deviantART. All rights reserved.
//

#import "DVNTAPIRequest.h"
#import "DVNTAPIClient.h"
@implementation DVNTAPIRequest


#pragma mark - Placebo

+ (NSURLSessionDataTask *)placeboWithSuccess:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [DVNTAPIClient GET:@"/api/oauth2/placebo" parameters:nil success:success failure:failure];
}


#pragma mark - User APIs
// user/whoami
+ (NSURLSessionDataTask *)whoAmIWithSuccess:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [DVNTAPIClient GET:@"/api/oauth2/user/whoami" parameters:nil success:success failure:failure];
}

+ (NSURLSessionDataTask *)damnTokenWithSuccess:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [DVNTAPIClient GET:@"/api/oauth2/user/damntoken" parameters:nil success:success failure:failure];
}


#pragma mark - Stash APIs

+ (NSURLSessionDataTask *)deltaWithCursor:(NSString *)cursor success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [self deltaWithCursor:cursor offset:0 extendedSubmissionMetadata:NO extendedCameraMetadata:NO extendedStatsMetadata:NO success:success failure:failure];
}

+ (NSURLSessionDataTask *)deltaWithCursor:(NSString *)cursor offset:(NSInteger)offset success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [self deltaWithCursor:cursor offset:offset extendedSubmissionMetadata:NO extendedCameraMetadata:NO extendedStatsMetadata:NO success:success failure:failure];
}

+ (NSURLSessionDataTask *)deltaWithCursor:(NSString *)cursor
                                                   offset:(NSInteger)offset
                               extendedSubmissionMetadata:(BOOL)extendedSubmissionMetadata
                                   extendedCameraMetadata:(BOOL)extendedCameraMetadata
                                    extendedStatsMetadata:(BOOL)extendedStatsMetadata
                                                  success:(void (^)(NSURLSessionDataTask *, id))success
                                                  failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // add parameters to call if set
    if(cursor) [parameters setObject:cursor forKey:@"cursor"];
    if(offset) [parameters setObject:@(offset) forKey:@"offset"];
    
    // if extended metadata wanted set up.
    if(extendedSubmissionMetadata) [parameters setObject:@"true" forKey:@"ext_submission"];
    if(extendedCameraMetadata) [parameters setObject:@"true" forKey:@"ext_camera"];
    if(extendedStatsMetadata) [parameters setObject:@"true" forKey:@"ext_stats"];
    
    return [DVNTAPIClient GET:@"/api/oauth2/stash/delta" parameters:parameters success:success failure:failure];
}

+ (NSURLSessionDataTask *)uploadDataFromFilePath:(NSString *)filePath parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    if([self checkPlaceboStatus]) {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];

        NSURLSessionDataTask *task = nil;
        
        if(error) {
            failure(nil, error);
            return task;
        } else {
            
            NSString *fileName = [NSString stringWithFormat:@"filename.%@",[filePath pathExtension]];
            
            task = [DVNTAPIClient POST:@"/api/oauth2/stash/submit" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:data name:fileName fileName:fileName mimeType:@"application/octet-stream"];
            } success:success failure:failure];
        }
        
        return task;
    }
    
    return nil;
}

+ (NSURLSessionDataTask *)uploadImageFromFilePath:(NSString *)filePath parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    if([self checkPlaceboStatus]) {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];
        
        NSURLSessionDataTask *task = nil;
        
        if(error) {
            failure(nil, error);
            return task;
        } else {
            NSString *fileName = [NSString stringWithFormat:@"filename.%@",[filePath pathExtension]];
            
            task = [DVNTAPIClient POST:@"/api/oauth2/stash/submit" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:data name:fileName fileName:fileName mimeType:@"application/octet-stream"];
            } success:success failure:failure];
        }
        
        return task;
    }
    
    return nil;
}

+ (NSURLSessionDataTask *)uploadText:(NSString *)text parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
  
    if([self checkPlaceboStatus]) {
        return [DVNTAPIClient POST:@"/api/oauth2/stash/submit" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            // Have to set the mimetype to text/html here to ensure writer will allow it to be editable
            [formData appendPartWithFileData:[text dataUsingEncoding:NSUTF8StringEncoding] name:@"filename.html" fileName:@"filename.html" mimeType:@"text/html"];
        } success:success failure:failure];
    }
    
    return nil;
}

+ (NSURLSessionDataTask *)uploadVideoFromFilePath:(NSString *)filePath parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    if([self checkPlaceboStatus]) {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];
        
        NSURLSessionDataTask *task = nil;
        
        if(error) {
            failure(nil, error);
            return task;
        } else {
            
            NSString *fileName = [NSString stringWithFormat:@"filename.%@",[filePath pathExtension]];
            
            task = [DVNTAPIClient POST:@"/api/oauth2/stash/submit" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:data name:fileName fileName:fileName mimeType:@"application/octet-stream"];
            } success:success failure:failure];
        }
        
        return task;
    }
    
    return nil;
}

// used solely internally for checking before upload. Creates a synchronous version of placeWithSuccess:failure:
+ (BOOL)checkPlaceboStatus {
    __block BOOL isValid = NO;
    
    // Using semaphores to lock up the system while we run this task. Should be a very fast call in all circumstances.
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self placeboWithSuccess:^(NSURLSessionDataTask *task, id JSON) {
        if([JSON[@"status"] isEqualToString:@"success"]) {
            isValid = YES;
        }
        
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop]
         runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    }
    
    return isValid;
}

+ (NSURLSessionDataTask *)updateItem:(NSString *)stashID parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [mutableParameters setObject:stashID forKey:@"stashid"];
    
    return [DVNTAPIClient POST:@"/api/oauth2/stash/submit" parameters:mutableParameters success:success failure:failure];
}

// Retrieves folder metadata
+ (NSURLSessionDataTask *)folderMetadata:(NSString *)folderID success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [DVNTAPIClient GET:@"/api/oauth2/stash/metadata" parameters:@{@"folderid": folderID} success:success failure:failure];
}

// Retrieves item metadata
+ (NSURLSessionDataTask *)itemMetadata:(NSString *)stashID success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [self itemMetadata:stashID extendedSubmissionMetadata:NO extendedCameraMetadata:NO extendedStatsMetadata:NO success:success failure:failure];
}

// Retrieves extended item metadata
+ (NSURLSessionDataTask *)itemMetadata:(NSString *)stashID
                  extendedSubmissionMetadata:(BOOL)extendedSubmissionMetadata
                      extendedCameraMetadata:(BOOL)extendedCameraMetadata
                       extendedStatsMetadata:(BOOL)extendedStatsMetadata
                                     success:(void (^)(NSURLSessionDataTask *, id))success
                                     failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"stashid": stashID}];
    
    // if extended metadata wanted set up.
    if(extendedSubmissionMetadata) [parameters setObject:@"true" forKey:@"ext_submission"];
    if(extendedCameraMetadata) [parameters setObject:@"true" forKey:@"ext_camera"];
    if(extendedStatsMetadata) [parameters setObject:@"true" forKey:@"ext_stats"];
                                                            
    return [DVNTAPIClient GET:@"/api/oauth2/stash/metadata" parameters:parameters success:success failure:failure];
}

+ (NSURLSessionDataTask *)itemMedia:(NSString *)stashID success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [DVNTAPIClient GET:@"/api/oauth2/stash/media" parameters:@{@"stashid": stashID} success:success failure:failure];
}

// deletes an item
+ (NSURLSessionDataTask *)deleteItem:(NSString *)stashID success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [DVNTAPIClient POST:@"/api/oauth2/stash/delete" parameters:@{@"stashid": stashID} success:success failure:failure];
}

// renames a folder
+ (NSURLSessionDataTask *)renameFolder:(NSString *)folderID folderName:(NSString *)folderName success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [DVNTAPIClient POST:@"/api/oauth2/stash/folder" parameters:@{@"folderid": folderID, @"folder": folderName} success:success failure:failure];
}

// Retrieves user's available and total Sta.sh space
+ (NSURLSessionDataTask *)spaceWithSuccess:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    // Should be GET, not POST but it will not matter to the end user of this SDK
    return [DVNTAPIClient POST:@"/api/oauth2/stash/space" parameters:nil success:success failure:failure];
}

// move folder to position
+ (NSURLSessionDataTask *)moveFolder:(NSString *)folderID toPosition:(NSInteger)position success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [DVNTAPIClient POST:@"/api/oauth2/stash/move/folder" parameters:@{@"folderid": folderID, @"position": @(position)} success:success failure:failure];
}

// move folder into new folder at position 0
+ (NSURLSessionDataTask *)moveFolder:(NSString *)folderID intoParentFolder:(NSInteger)parentFolderID success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [self moveFolder:folderID intoParentFolder:parentFolderID atPosition:0 success:success failure:failure];
}

// move folder into folder at set position
+ (NSURLSessionDataTask *)moveFolder:(NSString *)folderID intoParentFolder:(NSInteger)parentFolderID atPosition:(NSInteger)position success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [DVNTAPIClient POST:@"/api/oauth2/stash/move/folder" parameters:@{@"folderid": folderID, @"targetid": @(parentFolderID), @"position": @(position)} success:success failure:failure];
}

// move file in folder to position
+ (NSURLSessionDataTask *)moveItem:(NSString *)stashID inFolder:(NSString *)folderID toPosition:(NSInteger)position success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [DVNTAPIClient POST:@"/api/oauth2/stash/move/file" parameters:@{@"folderid": folderID, @"stashid": stashID, @"position": @(position)} success:success failure:failure];
}

// move file into new folder at position 0
+ (NSURLSessionDataTask *)moveItem:(NSString *)stashID intoNewFolderWithName:(NSString *)folderName success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [self moveItem:stashID intoNewFolderWithName:folderName atPosition:0 success:success failure:failure];
}

// move file into new folder at position
+ (NSURLSessionDataTask *)moveItem:(NSString *)stashID intoNewFolderWithName:(NSString *)folderName atPosition:(NSInteger)position success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [DVNTAPIClient POST:@"/api/oauth2/stash/move/file" parameters:@{@"folder": folderName, @"stashid": stashID, @"position": @(position)} success:success failure:failure];
}

// move file into folder
+ (NSURLSessionDataTask *)moveItem:(NSString *)stashID intoFolder:(NSString *)folderID success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [self moveItem:stashID intoFolder:folderID atPosition:0 success:success failure:failure];
}

// move file into folder at position
+ (NSURLSessionDataTask *)moveItem:(NSString *)stashID intoFolder:(NSString *)folderID atPosition:(NSInteger)position success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [DVNTAPIClient POST:@"/api/oauth2/stash/move/file" parameters:@{@"folderid": folderID, @"stashid": stashID, @"position": @(position)} success:success failure:failure];
}

#pragma mark - Other APIs

// Unauthorized API calls
+ (NSURLSessionDataTask *)OEmbedWithQuery:(NSString *)query success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [DVNTAPIClient GET:[NSString stringWithFormat:@"http://backend.deviantart.com/oembed?%@", query] parameters:nil success:success failure:failure];
}

@end
