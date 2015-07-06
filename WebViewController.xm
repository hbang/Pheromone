#import <UIKit/UIImage+Private.h>
#import "Cydia/CydiaWebViewController.h"

%hook CyteWebViewController

- (id)initWithWidth:(float)width ofClass:(Class)klass {
	self = %orig;

	if (self) {
		UIBarButtonItem *reloadItem = MSHookIvar<UIBarButtonItem *>(self, "reloaditem_");
		MSHookIvar<UIBarButtonItem *>(self, "reloaditem_") = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:reloadItem.target action:reloadItem.action];
		[self applyRightButton];
	}

	return self;
}

%end

%hook CydiaWebViewController

- (void)applyRightButton {
	UIBarButtonItem *reloadItem = MSHookIvar<UIBarButtonItem *>(self, "reloaditem_");

	if (self.class == %c(CydiaWebViewController) && self.rightButton == reloadItem && !self.isLoading) {
		self.navigationItem.rightBarButtonItems = @[
			reloadItem,
			[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"safari" inBundle:bundle] style:UIBarButtonItemStylePlain target:self action:@selector(_pheromone_openInSafari)] autorelease]
		];
	} else {
		%orig;
	}
}

%new - (void)_pheromone_openInSafari {
	[[UIApplication sharedApplication] openURL:self.webView.request.URL];
}

%end
