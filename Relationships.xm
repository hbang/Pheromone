#import "HBPHRelationshipsViewController.h"
#import "Cydia/Database.h"
#import "Cydia/Package.h"
#import <WebKit/DOMDocument.h>
#import <WebKit/DOMHTMLElement.h>
#import <WebKit/DOMHTMLAnchorElement.h>
#import <WebKit/DOMHTMLImageElement.h>
#import <WebKit/WebFrame.h>

%hook CYPackageController

- (void)webView:(id)webView didFinishLoadForFrame:(WebFrame *)webFrame {
	%orig;

	if (webFrame.parentFrame) {
		return;
	}

	Package *package = MSHookIvar<Package *>(self, "package_");

	DOMDocument *document = webFrame.DOMDocument;
	DOMElement *actions = [document getElementById:@"actions"];

	if (!actions) {
		return;
	}

	DOMHTMLAnchorElement *link = (DOMHTMLAnchorElement *)[document createElement:@"a"];
	link.href = [NSURL URLWithString:[NSString stringWithFormat:@"cydia://package/%@/relationships", package.id]].absoluteString;

	DOMHTMLImageElement *icon = (DOMHTMLImageElement *)[document createElement:@"img"];
	icon.className = @"icon";
	icon.src = [bundle URLForResource:@"depends-icons" withExtension:@"png"].absoluteString;
	[link appendChild:icon];

	DOMElement *div1 = [document createElement:@"div"];
	[link appendChild:div1];

	DOMElement *div2 = [document createElement:@"div"];
	[div1 appendChild:div2];

	DOMElement *label = [document createElement:@"label"];
	[div2 appendChild:label];

	DOMElement *paragraph = [document createElement:@"p"];
	[paragraph appendChild:(DOMNode *)[document createTextNode:@"Relationships"]];
	[label appendChild:paragraph];

	[actions appendChild:link];
}

%end

%hook Cydia

- (CyteViewController *)pageForURL:(NSURL *)url forExternal:(BOOL)external withReferrer:(NSString *)referrer {
	if (url.pathComponents.count == 3 && [url.host isEqualToString:@"package"]) {
		Database *database = MSHookIvar<Database *>(self, "database_");
		Package *package = [database packageWithName:url.pathComponents[1]];

		if (!package) {
			return %orig;
		}

		if ([url.pathComponents[2] isEqualToString:@"relationships"]) {
			CyteViewController *viewController = [[[%c(HBPHRelationshipsViewController) alloc] initWithDatabase:database package:package] autorelease];
			viewController.delegate = self;
			return viewController;
		}
	}

	return %orig;
}

%end
