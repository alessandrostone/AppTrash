//
//  Item.h
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@interface Item : NSObject {
  @private
	BOOL checked;
	NSString *path;
	NSImage *icon;
	NSAttributedString *displayName;
}

- (id)initWithPath:(NSString *)aPath;

@property (nonatomic, assign) BOOL checked;
@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSImage *icon;
@property (nonatomic, readonly) NSAttributedString *displayName;

@end
