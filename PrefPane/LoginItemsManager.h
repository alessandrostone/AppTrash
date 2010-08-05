//
//  LoginItemsManager.h
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const LoginItemsChangedNotification;

@interface LoginItemsManager : NSObject {
  @private
	LSSharedFileListRef loginItems;
}

+ (id)sharedManager;

- (BOOL)containsItemAtPath:(NSString *)aPath item:(LSSharedFileListItemRef *)outItem;

- (void)addItemWithPath:(NSString *)aPath;
- (void)removeItemAtPath:(NSString *)aPath;

@end
