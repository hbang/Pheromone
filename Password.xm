#import <Cydia/Database.h>
#import <Cydia/Package.h>
#import <Cydia/Cydia.h>

extern "C" NSString *HBOutputForShellCommand(NSString *command); // TODO: fix header…

%hook Cydia

- (void)loadData {
	%orig;

	Database *database = MSHookIvar<Database *>(self, "database_");
	Package *openssh = [database packageWithName:@"openssh"];

	if (openssh.installed) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSString *rootResult = HBOutputForShellCommand(@"/bin/echo alpine | /usr/bin/login -f root /bin/false");

			// TODO: get mobile check working
			NSString *mobileResult = @"Login incorrect";
			// NSString *mobileResult = HBOutputForShellCommand(@"/bin/echo alpine | /usr/bin/login -f nobody '/usr/bin/login -f mobile /bin/false'"); // wow hax

			if (![rootResult containsString:@"Login incorrect"] || ![mobileResult containsString:@"Login incorrect"]) {
				dispatch_async(dispatch_get_main_queue(), ^{
					UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Pheromone Warning:\nYour device is vulnerable to remote attacks." message:@"The OpenSSH package is installed on this device, but the root (administrator) user still has the default password, “alpine”. This allows an attacker or worm to connect to your device remotely and perform malicious actions.\n\nYou should change this password as soon as possible." preferredStyle:UIAlertControllerStyleAlert];

					[alertController addAction:[UIAlertAction actionWithTitle:@"Ignore" style:UIAlertActionStyleCancel handler:nil]];
					[alertController addAction:[UIAlertAction actionWithTitle:@"Change" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
						[self openCydiaURL:[NSURL URLWithString:@"cydia://url/https://cydia.saurik.com/password.html"] forExternal:YES];
					}]];

					UITabBarController *tabBarController = MSHookIvar<UITabBarController *>(self, "tabbar_");
					[tabBarController presentViewController:alertController animated:YES completion:nil];
				});
			}
		});
	}
}

%end
