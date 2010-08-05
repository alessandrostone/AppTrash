//
//  DirectoryWatcher.h
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

/*	
 For reusability:
 
 TODO: watch subdirectories as well
 TODO: check modified date to see if files have changed
 */

@protocol DirectoryWatcherDelegate;

@interface DirectoryWatcher : NSObject {
  @private
	NSString *path;
	NSArray *currentSnapshot;
	FSEventStreamRef stream;
	
	id < DirectoryWatcherDelegate > delegate;
}

@property (nonatomic, assign) id < DirectoryWatcherDelegate > delegate;

- (id)initWithPath:(NSString *)aPath;

- (void)start;
- (void)stop;

@end


@protocol DirectoryWatcherDelegate < NSObject >

@optional

- (void)directoryWatcher:(DirectoryWatcher *)aWatcher itemsWereAdded:(NSArray *)items;
- (void)directoryWatcher:(DirectoryWatcher *)aWatcher itemsWereRemoved:(NSArray *)items;

@end
