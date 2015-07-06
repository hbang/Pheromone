#import "BOZPongRefreshControl.h"
#import "Cydia/CydiaDelegate.h"
#import "Cydia/ChangesController.h"
#import "Cydia/SourcesController.h"
#import "SourcesController+Pheromone.h"

UIBarButtonItem *refreshBarButtonItem;
UIActivityIndicatorView *activityIndicatorView;

%hook ChangesController

- (void)setLeftBarButtonItem {
	UIBarButtonItem *barButtonItem;
	id <CydiaDelegate> delegate = MSHookIvar<id>(self, "delegate_");

	if (delegate.updating) {
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			activityIndicatorView.frame = (CGRect){ { 7.f, 5.f }, activityIndicatorView.frame.size };

			refreshBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
		});

		barButtonItem = refreshBarButtonItem;

		[activityIndicatorView startAnimating];
	} else {
		barButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonClicked)] autorelease];

		[activityIndicatorView stopAnimating];
	}

	[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
}

- (void)refreshButtonClicked {
	self.tabBarController.selectedIndex = 1;

	UINavigationController *navigationController = self.tabBarController.selectedViewController;
	[(SourcesController *)navigationController.viewControllers[0] _pheromone_beginRefreshFromChanges];

	[self setLeftBarButtonItem];
}

%end
