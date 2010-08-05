//
//  Item.m
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "Item.h"

@implementation Item

@synthesize checked, path;
@dynamic icon, displayName;

- (id)initWithPath:(NSString *)aPath {
	self = [super init];
	if (self) {
		path = [aPath copy];
		self.checked = YES;
	}
	return self;
}

- (NSImage *)icon {
	if (!icon) {
		icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
	}
	
	return icon;
}

- (NSAttributedString *)displayName {
	if (!displayName) {
		NSString *filename = [path lastPathComponent];
		NSString *directory = [path stringByDeletingLastPathComponent];
		
		NSString *string = [NSString stringWithFormat:@"%@\n%@", filename, directory];
		NSMutableAttributedString *displayString = [[NSMutableAttributedString alloc] initWithString:string];
		
		NSFont *subFont = [NSFont systemFontOfSize:11.0f];
		NSColor *subColor = [NSColor grayColor];
		
		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
									subFont, NSFontAttributeName, 
									subColor, NSForegroundColorAttributeName, nil];
		
		[displayString addAttributes:attributes
							 range:NSMakeRange([filename length] + 1, [directory length])];
		
		displayName = [displayString copy];
	}
	
	return displayName;
}

@end
