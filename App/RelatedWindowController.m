//
//  RelatedWindowController.m
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "RelatedWindowController.h"

#import "Item.h"
#import "NSFileManager+Trash.h"
#import "RelatedAppFilesScanner.h"

@interface RelatedWindowController ()

- (void)setAppIcon;
- (void)findRelatedFiles;

@end


@implementation RelatedWindowController

@synthesize filesController, appIconView, applicationPath;

- (id)init {
	return [self initWithWindowNibName:@"RelatedWindow"];
}

- (void)setApplicationPath:(NSString *)aPath {
	checked = YES;
	
	if (applicationPath != aPath) {
		applicationPath = [aPath copy];
		
		[self setAppIcon];
		[self findRelatedFiles];
	}
}

- (void)setAppIcon {
	NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:applicationPath];
	[appIconView setImage:icon];
}

- (void)findRelatedFiles {
	[filesController removeObjects:[filesController arrangedObjects]];
	
	NSArray *paths = [RelatedAppFilesScanner relatedFilesToApplicationAtPath:applicationPath];
	[filesController addObjects:paths];
}

- (BOOL)tableView:(NSTableView *)tableView
  shouldTrackCell:(NSCell *)cell
   forTableColumn:(NSTableColumn *)tableColumn
			  row:(NSInteger)row {
	
	if ([[tableColumn identifier] isEqualToString:@"mark"])
		return YES;
	
	return NO;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
	return NO;
}

- (void)tableViewDidSelectAll:(NSTableView *)aTableView {
	for (Item *item in [filesController arrangedObjects]) {
		item.checked = !checked;
	}
	
	checked = !checked;
}

- (IBAction)leaveFiles:(id)sender {
	[NSApp stopModal];
}

- (IBAction)trashFiles:(id)sender {
	NSFileManager *manager = [NSFileManager defaultManager];
	
	for (Item *item in [filesController arrangedObjects]) {
		if (item.checked) {
			NSError *error = nil;
			
			if (![manager mr_moveFileAtPathToTrash:item.path error:&error]) {
				NSLog(@"Cannot trash file at path: %@ Error: %@", item.path, error);
			}
		}
	}
	
	[NSApp stopModal];
}

@end
