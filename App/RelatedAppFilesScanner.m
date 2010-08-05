//
//  RelatedAppFilesScanner.m
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "RelatedAppFilesScanner.h"

#import "Item.h"

@implementation RelatedAppFilesScanner

#define MASK (NSUserDomainMask+NSLocalDomainMask)

void GetCachePaths (NSMutableArray *array, NSString *basename, NSString *identifier);
void GetAppSupportPaths (NSMutableArray *array, NSString *basename, NSString *identifier);
void GetGrowlPaths (NSMutableArray *array, NSString *basename);
void GetPreferencePaths (NSMutableArray *array, NSString *identifier);

+ (NSArray *)relatedFilesToApplicationAtPath:(NSString *)aPath {
	NSBundle *bundle = [NSBundle bundleWithPath:aPath];
	NSString *basename = [[bundle infoDictionary] objectForKey:@"CFBundleName"];
	
	if ([basename length] <= 0) {
		basename = [[bundle infoDictionary] objectForKey:@"CFBundleExecutable"];
		
		if ([basename length] <= 0) {
			return [NSArray array];
		}
	}
	
	NSString *identifier = [bundle bundleIdentifier];
	
	NSMutableArray *paths = [NSMutableArray array];
	
	GetAppSupportPaths(paths, basename, identifier);
	GetPreferencePaths(paths, identifier);
	GetGrowlPaths(paths, basename);
	GetCachePaths(paths, basename, identifier);
	
	return paths;
}

void AddPathIfExists (NSMutableArray *array, NSString *path) {
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		Item *item = [[Item alloc] initWithPath:path];
		[array addObject:item];
	}
}

void GetCachePaths (NSMutableArray *array, NSString *basename, NSString *identifier) {
	for (NSString *p in NSSearchPathForDirectoriesInDomains(NSCachesDirectory, MASK, YES)) {
		NSString *metadataPath = [p stringByAppendingPathComponent:@"Metadata"];
		
		AddPathIfExists(array, [p stringByAppendingPathComponent:basename]);
		AddPathIfExists(array, [p stringByAppendingPathComponent:identifier]);
		
		AddPathIfExists(array, [metadataPath stringByAppendingPathComponent:basename]);
		AddPathIfExists(array, [metadataPath stringByAppendingPathComponent:identifier]);
	}
}

void GetAppSupportPaths (NSMutableArray *array, NSString *basename, NSString *identifier) {
	for (NSString *p in NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, MASK, YES)) {
		AddPathIfExists(array, [p stringByAppendingPathComponent:basename]);
		AddPathIfExists(array, [p stringByAppendingPathComponent:identifier]);
	}
}

void GetGrowlPaths (NSMutableArray *array, NSString *basename) {
	for (NSString *p in NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)) {
		NSString *p2 = [p stringByAppendingPathComponent:@"Growl/Tickets"];
		NSString *name = [NSString stringWithFormat:@"%@.growlTicket", basename];
		
		AddPathIfExists(array, [p2 stringByAppendingPathComponent:name]);
	}
}

void GetPreferencePaths (NSMutableArray *array, NSString *identifier) {
	for (NSString *p in NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, MASK, YES)) {
		NSString *p2 = [p stringByAppendingPathComponent:@"Preferences"];
		
		NSString *name = [NSString stringWithFormat:@"%@.plist", identifier];
		NSString *name2 = [NSString stringWithFormat:@"%@.LSSharedFileList.plist", identifier];
		
		AddPathIfExists(array, [p2 stringByAppendingPathComponent:name]);
		AddPathIfExists(array, [p2 stringByAppendingPathComponent:name2]);
	}
}

@end
