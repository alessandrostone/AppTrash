//
//  AppTrashAppDelegate.h
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "DirectoryWatcher.h"
#import "RelatedWindowController.h"

@interface AppDelegate : NSObject < NSApplicationDelegate, DirectoryWatcherDelegate > {
  @private
	DirectoryWatcher *watcher;
	RelatedWindowController *relatedWC;
}

@end
