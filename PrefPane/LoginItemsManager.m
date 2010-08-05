//
//  LoginItemsManager.m
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "LoginItemsManager.h"

NSString *const LoginItemsChangedNotification = @"MRLoginItemsChanged";


@interface LoginItemsManager ()

- (void)postNotification;

@end


@implementation LoginItemsManager

void ItemsChanged (LSSharedFileListRef inList, void *context);

+ (id)sharedManager {
	static LoginItemsManager *sharedManager = nil;
	
	if (!sharedManager) {
		sharedManager = [[[self class] alloc] init];
	}
	
	return sharedManager;
}

- (id)init {
	self = [super init];
	if (self) {
		loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
		
		LSSharedFileListAddObserver(loginItems, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, &ItemsChanged, self);
	}
	return self;
}

- (BOOL)containsItemAtPath:(NSString *)aPath item:(LSSharedFileListItemRef *)outItem {
	NSParameterAssert(aPath != nil);
	
	UInt32 seed = 0;
	CFArrayRef snapshot = LSSharedFileListCopySnapshot(loginItems, &seed);
	
	for (NSUInteger n = 0; n < CFArrayGetCount(snapshot); n++) {
		LSSharedFileListItemRef item = (LSSharedFileListItemRef) CFArrayGetValueAtIndex(snapshot, n);
		
		CFURLRef url = NULL;
		LSSharedFileListItemResolve(item, 0, &url, NULL);
		
		NSURL *cURL = (NSURL *) url;
		
		if ([[cURL path] isEqualToString:aPath]) {
			if (outItem) {
				*outItem = item;
			}
			
			CFRelease(snapshot);
			return YES;
		}
	}
	
	CFRelease(snapshot);
	return NO;
}

- (void)addItemWithPath:(NSString *)aPath {
	NSParameterAssert(aPath != nil);
	
	NSURL *url = [NSURL fileURLWithPath:aPath];
	LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, NULL, NULL, (CFURLRef) url, NULL, NULL);
}

- (void)removeItemAtPath:(NSString *)aPath {
	NSParameterAssert(aPath != nil);
	
	LSSharedFileListItemRef item = NULL;
	
	if ([self containsItemAtPath:aPath item:&item]) {
		LSSharedFileListItemRemove(loginItems, item);
	}
}

- (void)postNotification {
	[[NSNotificationCenter defaultCenter] postNotificationName:LoginItemsChangedNotification
														object:self];
}

void ItemsChanged (LSSharedFileListRef inList, void *context) {
	LoginItemsManager *self = (LoginItemsManager *) context;
	[self postNotification];
}

- (void)finalize {
	CFRelease(loginItems);
	[super finalize];
}

- (void)dealloc {
	CFRelease(loginItems);
	[super dealloc];
}

@end
