#import "Cydia/SourcesController.h"

BOOL allowContinuing = YES;

%hook SourcesController

%new - (NSURLRequest *) connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
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
