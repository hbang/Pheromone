#import "Cydia/SearchController.h"

BOOL isResigning = NO;

%hook SearchController

- (id)initWithDatabase:(id)database query:(NSString *)query {
	self = %orig;

	if (self) {
		UISearchBar *searchBar = MSHookIvar<UISearchBar *>(self, "search_");
		self.navigationItem.titleView = searchBar;

		UITableView *tableView = MSHookIvar<UITableView *>(self, "list_");
		tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
	}

	return self;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	searchBar.text = @"";
	[searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:YES animated:YES];
	%orig;
}

%new - (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:NO animated:YES];
	return YES;
}

%end
