#import "BOZPongRefreshControl.h"
#import "Cydia/SourcesController.h"
#import "Cydia/CydiaDelegate.h"
#import <UIKit/UIAlertView+Private.h>

BOZPongRefreshControl *refreshControl;
BOOL refreshWillAppear = NO;
BOOL hasAppeared = NO;

%hook SourcesController

#pragma mark - Refresh control

- (void)viewDidLayoutSubviews {
	%orig;

	UITableView *tableView = MSHookIvar<UITableView *>(self, "list_");
	refreshControl = [[BOZPongRefreshControl attachToTableView:tableView withRefreshTarget:self andRefreshAction:@selector(refreshButtonClicked)] retain];
}

- (void)viewDidAppear:(BOOL)animated {
	%orig;

	hasAppeared = YES;

	if (refreshWillAppear) {
		refreshWillAppear = NO;
		[refreshControl beginLoadingAnimated:NO];
		[self refreshButtonClicked];
	}
}

%new - (void)_pheromone_beginRefreshFromChanges {
	refreshWillAppear = YES;
}

- (void)refreshButtonClicked {
	%orig;
	[refreshControl beginLoadingAnimated:YES];
	UITableView *tableView = MSHookIvar<UITableView *>(self, "list_");
	tableView.contentOffset = CGPointMake(0, -tableView.contentInset.top - refreshControl.frame.size.height);
}

- (void)updateButtonsForEditingStatusAnimated:(BOOL)animated {
	UITableView *tableView = MSHookIvar<UITableView *>(self, "list_");
	id <CydiaDelegate> delegate = MSHookIvar<id>(self, "delegate_");

	if (tableView.isEditing) {
		[self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClicked)] autorelease] animated:animated];
	} else if (delegate.updating) {
		[self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelButtonClicked)] autorelease] animated:animated];

		if (!hasAppeared) {
			refreshWillAppear = YES;
		}
	} else {
		[self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonClicked)] autorelease] animated:animated];
		[refreshControl finishedLoading];
	}

	[self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:tableView.isEditing ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked)] autorelease] animated:animated];
}

%new - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[refreshControl scrollViewDidScroll];
}

%new - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[refreshControl scrollViewDidEndDragging];
}

- (void)dealloc {
	[refreshControl release];
	%orig;
}

#pragma mark - Add source

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([alertView.context isEqualToString:@"source"]) {
		NSURL *url = [NSURL URLWithString:alertView.textField.text];

		if (url && [url.host hasSuffix:@".github.io"] && [url.scheme isEqualToString:@"http"]) {
			alertView.textField.text = [@"https" stringByAppendingString:[url.absoluteString substringFromIndex:4]];
		}
	}

	%orig;
}

%new - (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
	NSString *href = MSHookIvar<NSString *>(self, "href_");

	if ([request.URL.scheme isEqualToString:@"https"] && [href hasPrefix:@"http://"]) {
		MSHookIvar<NSString *>(self, "href_") = [[@"https" stringByAppendingString:[href substringFromIndex:4]] retain];
	}

	return request;
}

- (void)complete {
	NSString *href = MSHookIvar<NSString *>(self, "href_");

	if ([[NSURL URLWithString:href].scheme isEqualToString:@"http"]) {
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Pheromone Warning:\nYou are adding a repository that is not secure." message:@"Data downloaded from this repository will not be encrypted in transit, allowing packages to be modified by a man in the middle (MITM) in order to perform malicious actions on your device.\n\nDo you want to continue?" preferredStyle:UIAlertControllerStyleAlert];

		[alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
		[alertController addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			%orig;
		}]];

		[self.navigationController presentViewController:alertController animated:YES completion:nil];
	} else {
		%orig;
	}
}

%end
