//
//  DirectoryWatcher.m
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "DirectoryWatcher.h"

@interface DirectoryWatcher ()

- (void)loadCurrentSnapshot;
- (void)createEventStream;

- (void)itemsWereRemoved:(NSArray *)items;
- (void)itemsWereAdded:(NSArray *)items;

- (void)directoryChanged;

@end


@implementation DirectoryWatcher

void StreamCallback (ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]);

@synthesize delegate;

- (id)initWithPath:(NSString *)aPath {
	NSParameterAssert(aPath != nil);
	
	self = [super init];
	if (self) {
		path = [aPath copy];
		
		[self loadCurrentSnapshot];
		[self createEventStream];
	}
	return self;
}

- (void)loadCurrentSnapshot {
	NSError *error = nil;
	
	currentSnapshot = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path
																		  error:&error];
	
	if (!currentSnapshot) {
		NSLog(@"Couldn't load initial snapshot of directory. Error: %@", error);
	}
}

- (void)createEventStream {
	FSEventStreamContext context = { 0, self, NULL, NULL, NULL };
	CFStringRef aPath = (CFStringRef) path;
	CFArrayRef paths = CFArrayCreate(NULL, (const void **) &aPath, 1, NULL);
	
	stream = FSEventStreamCreate(NULL, &StreamCallback, &context, paths, kFSEventStreamEventIdSinceNow, 1.0f, 0);
	CFRelease(paths);
}

- (void)itemsWereRemoved:(NSArray *)items {
	if ([delegate respondsToSelector:@selector(directoryWatcher:itemsWereRemoved:)]) {
		[delegate directoryWatcher:self itemsWereRemoved:items];
	}
}

- (void)itemsWereAdded:(NSArray *)items {
	if ([delegate respondsToSelector:@selector(directoryWatcher:itemsWereAdded:)]) {
		[delegate directoryWatcher:self itemsWereAdded:items];
	}
}

- (void)directoryChanged {
	NSError *error = nil;
	NSArray *snapshot = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path
																			error:&error];
	
	if (!snapshot) {
		NSLog(@"Couldn't load snapshot of directory. Error: %@", error);
		return;
	}
	
	NSUInteger leftIdx = 0;
	NSUInteger rightIdx = 0;
	
	NSMutableArray *addedItems = [NSMutableArray array];
	NSMutableArray *removedItems = [NSMutableArray array];
	
	while (true) {
		BOOL invalidLeft = leftIdx >= [currentSnapshot count];
		BOOL invalidRight = rightIdx >= [snapshot count];
		
		if (invalidLeft && invalidRight)
			break;
		
		NSString *leftPath = invalidLeft ? nil : [currentSnapshot objectAtIndex:leftIdx];
		NSString *rightPath = invalidRight ? nil : [snapshot objectAtIndex:rightIdx];
		
		NSComparisonResult result;
		
		if (!leftPath) {
			result = NSOrderedDescending;
		}
		else if (!rightPath) {
			result = NSOrderedAscending;
		}
		else {
			result = [leftPath compare:rightPath options:NSCaseInsensitiveSearch];
		}
		
		if (result == NSOrderedSame) {
			leftIdx++;
			rightIdx++;
		}
		else if (result == NSOrderedDescending) {
			rightIdx++;
			[addedItems addObject:[path stringByAppendingPathComponent:rightPath]];
		}
		else if (result == NSOrderedAscending) {
			leftIdx++;
			[removedItems addObject:[path stringByAppendingPathComponent:leftPath]];
		}
	}
	
	currentSnapshot = snapshot;
	
	if ([addedItems count] > 0) {
		[self itemsWereAdded:[addedItems copy]];
	}
	
	if ([removedItems count] > 0) {
		[self itemsWereRemoved:[removedItems copy]];
	}
}

void StreamCallback (ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]) {
	
	DirectoryWatcher *self = (DirectoryWatcher *) clientCallBackInfo;
	[self directoryChanged];
}

- (void)start {
	FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
	FSEventStreamStart(stream);
}

- (void)stop {
	FSEventStreamStop(stream);
	FSEventStreamUnscheduleFromRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
}

- (void)finalize {
	[self stop];
	
	FSEventStreamInvalidate(stream);
	FSEventStreamRelease(stream);
	
	[super finalize];
}

@end
