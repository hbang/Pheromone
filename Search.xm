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
	[searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:YES animated:YES];
	%orig;
}

%new - (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:YES animated:YES];

	if (!isResigning) {
		[self useSearch];
	}

	return YES;
}

- (void)searchBarButtonClicked:(UISearchBar *)searchBar {
	isResigning = YES;
	%orig;
	isResigning = NO;
}

%end
