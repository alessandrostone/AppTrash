//
//  AppTrashAppDelegate.m
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (DirectoryWatcher *)trashWatcher {
	if (!watcher) {
		NSString *trashPath = [@"~/.Trash" stringByExpandingTildeInPath];
		
		watcher = [[DirectoryWatcher alloc] initWithPath:trashPath];
		watcher.delegate = self;
	}
	
	return watcher;
}

- (RelatedWindowController *)relatedWC {
	if (!relatedWC) {
		relatedWC = [[RelatedWindowController alloc] init];
	}
	
	return relatedWC;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[[self trashWatcher] start];
}

- (void)processItems:(NSArray *)items {
	for (NSString *path in items) {
		if (![[path pathExtension] isEqualToString:@"app"])
			continue;
		
		NSRunningApplication *app = [NSRunningApplication currentApplication];
		[app activateWithOptions:NSApplicationActivateIgnoringOtherApps];
		
		RelatedWindowController *wc = [self relatedWC];
		NSWindow *window = [wc window];
		wc.applicationPath = path;
		
		[NSApp runModalForWindow:window];
	}
	
	[[relatedWC window] orderOut:self];
}

- (void)directoryWatcher:(DirectoryWatcher *)aWatcher itemsWereAdded:(NSArray *)items {
	[self performSelector:@selector(processItems:) withObject:items afterDelay:0.0f];
}

@end
