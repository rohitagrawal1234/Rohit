//
//  NSFileManager+TCBlobDownload.m
//  TCBlobDownload
//
//  Created by Thibault Charbonnier on 03/05/14.
//  Copyright (c) 2014 thibaultCha. All rights reserved.
//

#import "NSFileManager+TCBlobDownload.h"

@implementation NSFileManager (TCBlobDownload)

+ (BOOL)createDirFromPath:(NSString *)path error:(NSError *__autoreleasing *)error
{
    if (path == nil || [path isEqualToString:@""]) {
        return NO;
    }
    
    return [[NSFileManager defaultManager] createDirectoryAtPath:path
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:error];
}


+ (BOOL)createFolderWithPath:(NSString *)folderPath
{
    NSError *error = nil;
    BOOL isFolderCreatred = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
    {
        isFolderCreatred = [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    }
    return isFolderCreatred;
}

+ (NSString *)getMeetingFolderPathForFolder:(NSString *)folder
{
    NSString *meetingName = @"/MetingFolder";
    NSString *documentsDirectory = [self applicationDocumentsDirectory];
    NSString *meetingFolderPath = [documentsDirectory stringByAppendingPathComponent:meetingName];
    return meetingFolderPath;
}

+ (NSString *)getLocalPathForFile:(NSString *)fileName inMeetingFolder:(NSString *)folderName
{
    NSString *meetingFolder = [self getMeetingFolderPathForFolder:folderName];
    return [meetingFolder stringByAppendingPathComponent:fileName];
}


+ (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


@end
