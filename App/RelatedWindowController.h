//
//  RelatedWindowController.h
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "SelectionTableView.h"

@interface RelatedWindowController : NSWindowController < SelectionTableViewDelegate > {
  @private
	NSArrayController *filesController;
	NSImageView *appIconView;
	NSString *applicationPath;
	BOOL checked;
}

@property (nonatomic, assign) IBOutlet NSArrayController *filesController;
@property (nonatomic, assign) IBOutlet NSImageView *appIconView;

@property (nonatomic, copy) NSString *applicationPath;

- (IBAction)leaveFiles:(id)sender;
- (IBAction)trashFiles:(id)sender;

@end
