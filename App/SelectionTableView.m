//
//  SelectionTableView.m
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "SelectionTableView.h"

@implementation SelectionTableView

- (void)keyDown:(NSEvent *)theEvent {
	if ([[theEvent characters] characterAtIndex:0] == 'a')
		return;
	
	[super keyDown:theEvent];
}

- (void)keyUp:(NSEvent *)theEvent {
	if ([[theEvent characters] characterAtIndex:0] == 'a') {
		id < SelectionTableViewDelegate > delegate = (id < SelectionTableViewDelegate > ) [self delegate];
		
		if ([delegate respondsToSelector:@selector(tableViewDidSelectAll:)]) {
			[delegate tableViewDidSelectAll:self];
		}
		
		return;
	}
	
	[super keyUp:theEvent];
}

@end
