//
//  VCenterTextCell.m
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "VCenterTextCell.h"

@implementation VCenterTextCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	
	cellFrame.origin.y += 5.0f;
	cellFrame.size.height -= 5.0f;
	
	[super drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
