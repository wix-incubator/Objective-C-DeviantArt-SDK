//
//  DVNTAPIRequest.h
//  Bootstrap
//
//  Created by Aaron Pearce on 15/11/13.
//  Copyright (c) 2013 deviantART. All rights reserved.
//

#import <Foundation/Foundation.h>

/** DAAPIRequest provides simple wrappers around each API call that the deviantART API provides. IDs for Sta.sh Folders and Items should be passed as strings as they do not fit within the bounds of a NSInteger. */
@interface DVNTAPIRequest : NSObject


#pragma mark - Placebo

/**---------------------------------------------------------------------------------------
 * @name General APIs
 *  ---------------------------------------------------------------------------------------
 */

/**
  Returns and runs a task to check /placebo from the API. Retrieves if the user's token are valid or not.

  @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
  @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.

  @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
*/
+ (NSURLSessionDataTask *)placeboWithSuccess:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


#pragma mark - User APIs

/**---------------------------------------------------------------------------------------
 * @name User APIs
 *  ---------------------------------------------------------------------------------------
 */

/** 
 Returns and runs a task to get /user/whoami from the API. Retrieves user information such as username, ident, usericonurl
 
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
*/
+ (NSURLSessionDataTask *)whoAmIWithSuccess:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**
 Returns and runs a task to get /user/damntoken from the API. Retrieves the user's damntoken for authenticating with the Chat server
 
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)damnTokenWithSuccess:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


#pragma mark - Stash APIs

/**---------------------------------------------------------------------------------------
 * @name Stash APIs
 *  ---------------------------------------------------------------------------------------
 */

/**
 Returns and runs a task to retrieve a user's Sta.sh delta.
 
 @param cursor The cursor hash provided to your app in the last delta call, if nil, this is the start of a new delta, will return all items.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)deltaWithCursor:(NSString *)cursor success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**
 Returns and runs a task to retrieve a user's Sta.sh delta.
 
 @param cursor The cursor hash provided to your app in the last delta call, if nil, this is the start of a new delta, will return all items.
 @param offset The offset provided to your app if the last delta call returned too many results
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)deltaWithCursor:(NSString *)cursor offset:(NSInteger)offset success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


/**
 Returns and runs a task to retrieve a user's Sta.sh delta.
 
 @param cursor The cursor hash provided to your app in the last delta call, if nil, this is the start of a new delta, will return all items.
 @param offset The offset provided to your app if the last delta call returned too many results
 @param extendedSubmissionMetadata Boolean signifying if you wish to retrieve extended submission metadata for items/folders in this call.
 @param extendedCameraMetadata Boolean signifying if you wish to retrieve extended camera metadata for items/folders in this call.
 @param extendedStatsMetadata Boolean signifying if you wish to retrieve extended statistics metadata for items/folders in this call.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)deltaWithCursor:(NSString *)cursor
                                                   offset:(NSInteger)offset
                               extendedSubmissionMetadata:(BOOL)extendedSubmissionMetadata
                                   extendedCameraMetadata:(BOOL)extendedCameraMetadata
                                    extendedStatsMetadata:(BOOL)extendedStatsMetadata
                                                  success:(void (^)(NSURLSessionDataTask *, id))success
                                                  failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

+ (NSURLSessionDataTask *)uploadDataFromFilePath:(NSString *)filePath parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**
 Returns and runs a task to upload an image to Sta.sh via the API.
 
 @param filePath The filepath to the image to upload.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)uploadImageFromFilePath:(NSString *)filePath parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


/**
 Returns and runs a task to upload text to Sta.sh via the API.
 
 @param text The text to upload
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)uploadText:(NSString *)text parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**
 Returns and runs a task to upload a video to Sta.sh via the API.
 
 @param filePath The filepath to the video to upload.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)uploadVideoFromFilePath:(NSString *)filePath parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**
 Returns and runs a task to update an item's details via the API.
 
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)updateItem:(NSString *)stashID parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**
 Returns and runs a task for retrieving the metadata of a folder from Sta.sh using /stash/metadata.
 
 @param folderID The internal folderid of the Folder you wish to retrieve metadata for.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)folderMetadata:(NSString *)folderID success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


/**
 Returns and runs a task for retrieving the metadata of an item from Sta.sh using /stash/metadata.
 
 @param stashID The internal stashid of the Item you wish to retrieve metadata for.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)itemMetadata:(NSString *)stashID success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


/**
 Returns and runs a task for retrieving the metadata and extended metadata if wanted of an item from Sta.sh using /stash/metadata.
 
 @param stashID The internal stashid of the Item you wish to retrieve metadata for.
 @param extendedSubmissionMetadata Boolean signifying if you wish to retrieve extended submission metadata for items/folders in this call.
 @param extendedCameraMetadata Boolean signifying if you wish to retrieve extended camera metadata for items/folders in this call.
 @param extendedStatsMetadata Boolean signifying if you wish to retrieve extended statistics metadata for items/folders in this call.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)itemMetadata:(NSString *)stashID
                  extendedSubmissionMetadata:(BOOL)extendedSubmissionMetadata
                      extendedCameraMetadata:(BOOL)extendedCameraMetadata
                       extendedStatsMetadata:(BOOL)extendedStatsMetadata
                                     success:(void (^)(NSURLSessionDataTask *, id))success
                                     failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


/**
 Returns and runs a task for retrieving the media of an item from Sta.sh using /stash/media.
 
 @param stashID The internal stashid of the Item you wish to retrieve media for.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)itemMedia:(NSString *)stashID success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


/**
 Returns and runs a task for deleting an item from Sta.sh using /stash/delete.
 
 @param stashID The internal stashid of the Item you wish to delete
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)deleteItem:(NSString *)stashID success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


/**
 Returns and runs a task for renaming a folder in Sta.sh using /stash/folder.
 
 @param folderID The internal folder of the folder you wish to rename
 @param folderName The new name for the folder
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)renameFolder:(NSString *)folderID folderName:(NSString *)folderName success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


/**
 Returns and runs a task for retrieving the amount of total space and the amount of available space in the user's Sta.sh using /stash/space.
 
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)spaceWithSuccess:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


/**
 Returns and runs a task for moving a folder's position in Sta.sh using /stash/move/folder.
 
 @param folderID The folderID of the folder to move.
 @param position The position (zero-indexed) to move to.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)moveFolder:(NSString *)folderID toPosition:(NSInteger)position success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**
 Returns and runs a task for moving a folder into a parent folder in Sta.sh using /stash/move/folder.
 
 @param folderID The folderID of the folder to move.
 @param parentFolderID The folder ID of the folder to move the folder into.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)moveFolder:(NSString *)folderID intoParentFolder:(NSInteger)parentFolderID success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**
 Returns and runs a task for moving a folder into a parent folder with a position in Sta.sh using /stash/move/folder.
 
 @param folderID The folderID of the folder to move.
 @param position The position (zero-indexed) to set the moved folder to.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)moveFolder:(NSString *)folderID intoParentFolder:(NSInteger)parentFolderID atPosition:(NSInteger)position success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**
 Returns and runs a task for moving a file in a folder to a position in Sta.sh using /stash/move/file.
 
 @param stashID The stashID of the file to move.
 @param folderID The folder ID of the folder to move the file within.
 @param position The position (zero-indexed) to set the moved file to.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)moveItem:(NSString *)stashID inFolder:(NSString *)folderID toPosition:(NSInteger)position success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**
 Returns and runs a task for moving a file into a new folder in Sta.sh using /stash/move/file.
 
 @param stashID The stashID of the file to move.
 @param folderName The name for the new folder.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)moveItem:(NSString *)stashID intoNewFolderWithName:(NSString *)folderName success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**
 Returns and runs a task for moving a file into a new folder at a position in Sta.sh using /stash/move/file.
 
 @param stashID The stashID of the file to move.
 @param folderName The name for the new folder.
 @param position The position (zero-indexed) to set the moved file to.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)moveItem:(NSString *)stashID intoNewFolderWithName:(NSString *)folderName atPosition:(NSInteger)position success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**
 Returns and runs a task for moving a file into an existing folder in Sta.sh using /stash/move/file.
 
 @param stashID The stashID of the file to move.
 @param folderID The name for the new folder
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)moveItem:(NSString *)stashID intoFolder:(NSString *)folderID success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


/**
 Returns and runs a task for moving a file into an existing folder in Sta.sh using /stash/move/file.

 @param stashID The stashID of the file to move.
 @param folderID The name for the new folder
 @param position The position (zero-indexed) to set the moved file to.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response  data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.

 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)moveItem:(NSString *)stashID intoFolder:(NSString *)folderID atPosition:(NSInteger)position success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

#pragma mark - Other APIs

/**---------------------------------------------------------------------------------------
 * @name Other APIs
 *  ---------------------------------------------------------------------------------------
 */

/**
 Returns and runs a task for an oEmbed query. Just needs the key and value for the search.
 
 @param query strong of the query e.g. url=http://fav.me/d2enxz7
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @return NSURLSessionDataTask - Task for the call, can be paused if needed for later use.
 */
+ (NSURLSessionDataTask *)OEmbedWithQuery:(NSString *)query success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

@end
