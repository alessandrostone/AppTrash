//
//  SelectionTableView.h
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@interface SelectionTableView : NSTableView {

}

@end


@protocol SelectionTableViewDelegate < NSTabViewDelegate >

- (void)tableViewDidSelectAll:(NSTableView *)aTableView;

@end
