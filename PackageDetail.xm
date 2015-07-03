#import "Cydia/CYPackageController.h"
#import "Cydia/MIMEAddress.h"
#import "Cydia/Package.h"

%hook CYPackageController

- (void)applyRightButton {
	%orig;

	if (self.rightButton && !self.isLoading) {
		Package *package = MSHookIvar<Package *>(self, "package_");

		if (package.source) {
			[self.navigationItem setRightBarButtonItems:@[
				self.rightButton,
				[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(_pheromone_share)] autorelease]
			] animated:YES];
		}
	}
}

%new - (void)_pheromone_share {
	Package *package = MSHookIvar<Package *>(self, "package_");

	NSString *message = [NSString stringWithFormat:@"Check out %@ by %@ on Cydia:", package.name, package.author.name];
	NSURL *cydiaURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://cydia.saurik.com/package/%@/", package.id]];

	UIActivityViewController *viewController = [[[UIActivityViewController alloc] initWithActivityItems:@[ message, cydiaURL ] applicationActivities:nil] autorelease];
	[self.navigationController presentViewController:viewController animated:YES completion:nil];
}

%end
