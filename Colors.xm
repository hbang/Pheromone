#import "Cydia/Cydia.h"
#import "Cydia/ProgressController.h"

%hook Cydia

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	UIColor *tintColor = [UIColor colorWithRed:109.f / 255.f green:76.f / 255.f blue:65.f / 255.f alpha:1];
	UIColor *barTintColor = [UIColor colorWithWhite:243.f / 255.f alpha:1];

	((UIView *)[%c(_UIAlertControllerView) appearance]).tintColor = tintColor;

	[UINavigationBar appearance].barTintColor = barTintColor;
	[UISearchBar appearance].barTintColor = barTintColor;
	[UITabBar appearance].barTintColor = barTintColor;

	%orig;

	UIWindow *window = MSHookIvar<UIWindow *>(self, "window_");
	window.tintColor = tintColor;
}

%end

%hook ProgressController

- (void)loadView {
	%orig;
	self.navigationController.navigationBar.barTintColor = nil;
}

%end
