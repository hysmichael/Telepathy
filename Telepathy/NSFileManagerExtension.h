//
//  NSFileManagerExtension.h
//  Telepathy
//
//  Created by Michael Hong on 4/22/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#ifndef Telepathy_NSFileManagerExtension_h
#define Telepathy_NSFileManagerExtension_h

// Catagory on NSFileManager

@interface NSFileManager (PathForSupportDirectory)

- (NSString *) findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                            inDomain:(NSSearchPathDomainMask)domainMask
                 appendPathComponent:(NSString *)appendComponent
                               error:(NSError **)errorOut;

- (NSString *) applicationSupportDirectory;

@end

@implementation NSFileManager (PathForSupportDirectory)

- (NSString *) findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                            inDomain:(NSSearchPathDomainMask)domainMask
                 appendPathComponent:(NSString *)appendComponent
                               error:(NSError **)errorOut {
    // Search for the path
    NSArray* paths = NSSearchPathForDirectoriesInDomains(searchPathDirectory, domainMask, YES);
    if ([paths count] == 0) { // *** creation and return of error object omitted for space
        return nil;
    }
    // Normally only need the first path
    NSString *resolvedPath = [paths objectAtIndex:0];
    if (appendComponent) {
        resolvedPath = [resolvedPath stringByAppendingPathComponent:appendComponent];
    }
    // Create the path if it doesn't exist
    NSError *error;
    BOOL success = [self createDirectoryAtPath:resolvedPath withIntermediateDirectories:YES
                                    attributes:nil error:&error];
    if (!success) {
        if (errorOut) *errorOut = error;
        return nil;
    }
    // If we've made it this far, we have a success
    if (errorOut) {
        *errorOut = nil;
    }
    return resolvedPath;
}

- (NSString *) applicationSupportDirectory {
    NSString *executableName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    NSError *error;
    NSString *result = [self findOrCreateDirectory:NSApplicationSupportDirectory
                                          inDomain:NSUserDomainMask
                               appendPathComponent:executableName
                                             error:&error];
    if (error) NSLog(@"Unable to find or create application support directory:\n%@", error);
    return result;
}

@end

#endif
