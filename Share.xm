#import "Cydia/CYPackageController.h"
#import "Cydia/MIMEAddress.h"
#import "Cydia/Package.h"
#import "Cydia/Source.h"

%hook CYPackageController

- (void)applyRightButton {
	%orig;

	if (self.rightButton && !self.isLoading) {
		Package *package = MSHookIvar<Package *>(self, "package_");

		if (package.source) {
			self.navigationItem.rightBarButtonItems = @[
				self.rightButton,
				[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(_pheromone_share:)] autorelease]
			];
		}
	}
}

%new - (void)_pheromone_share:(UIBarButtonItem *)sender {
	static NSArray *BuiltInRepositories;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		BuiltInRepositories = [@[
			@"http://apt.saurik.com/",
			@"http://apt.thebigboss.org/repofiles/cydia/",
			@"http://apt.modmyi.com/",
			@"http://cydia.zodttd.com/repo/cydia/"
		] retain];
	});

	Package *package = MSHookIvar<Package *>(self, "package_");

	NSString *message = [NSString stringWithFormat:@"Check out %@ by %@ on Cydia:", package.name, package.author.name];
	NSURL *url;

	if ([BuiltInRepositories containsObject:package.source.rooturi]) {
		url = [NSURL URLWithString:[NSString stringWithFormat:@"http://cydia.saurik.com/package/%@/", package.id]];
	} else if (package.homepage && ![package.homepage isEqualToString:@"http://myrepospace.com/"]) {
		url = [NSURL URLWithString:package.homepage];
	} else {
		url = [NSURL URLWithString:package.source.rooturi];
	}

	// That looks fine. _UICreateScreenUIImage does an extra copy
	UIGraphicsBeginImageContextWithOptions(self.view.window.bounds.size, YES, 0);
	[self.view.window drawViewHierarchyInRect:self.view.window.bounds afterScreenUpdates:YES];
	UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	UIActivityViewController *viewController = [[[UIActivityViewController alloc] initWithActivityItems:@[ message, url, screenshot ] applicationActivities:nil] autorelease];
	viewController.popoverPresentationController.barButtonItem = sender;
	[self.navigationController presentViewController:viewController animated:YES completion:nil];
}

%end
