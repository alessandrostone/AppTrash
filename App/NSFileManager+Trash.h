//
//  NSFileManager+Trash.h
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@interface NSFileManager (Trash)

- (NSString *)mr_uniqueFileNameWithPath:(NSString *)aPath;
- (BOOL)mr_moveFileAtPathToTrash:(NSString *)aPath error:(NSError **)outError;

@end
