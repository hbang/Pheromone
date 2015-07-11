#import "Cydia/ProgressController.h"
#import <WebKit/WebFrame.h>
#import <WebKit/DOMDocument.h>
#import <WebKit/DOMHTMLElement.h>
#import <WebKit/DOMCSSStyleDeclaration.h>


UIImage *backgroundImage;

%hook ProgressController

- (void)viewDidAppear:(BOOL)animated {
	%orig;

	UIView *darkeningView = [[[UIView alloc] initWithFrame:self.view.superview.bounds] autorelease];
	darkeningView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	darkeningView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
	[self.view.superview insertSubview:darkeningView atIndex:0];

	UIVisualEffectView *visualEffectView = [[[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]] autorelease];
	visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	visualEffectView.frame = darkeningView.frame;
	[self.view.superview insertSubview:visualEffectView atIndex:0];

	UIImageView *imageView = [[[UIImageView alloc] init] autorelease];

	if (backgroundImage) {

		[imageView setImage:backgroundImage];
	}

	else {

		[imageView setImage:[UIImage imageWithContentsOfFile:@"/var/mobile/Library/SpringBoard/HomeBackgroundThumbnail.jpg"]];
	}
	
	imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	imageView.frame = darkeningView.frame;
	[self.view.superview insertSubview:imageView atIndex:0];
}

- (void)webView:(id)webView didFinishLoadForFrame:(WebFrame *)webFrame {
	%orig;

	self.webView.opaque = NO;
	self.webView.backgroundColor = [UIColor clearColor];
	self.webView.scrollView.backgroundColor = nil;

	[webFrame.DOMDocument.body.style setProperty:@"background-color" value:@"transparent" priority:@""];
	[webFrame.DOMDocument.body.style setProperty:@"border-color" value:@"transparent" priority:@""];
}

- (void)dealloc {
	[backgroundImage release];
	%orig;
}

%end

%hook Cydia

- (void)perform {
	UIWindow *window = MSHookIvar<UIWindow *>(self, "window_");

	//if wallpaper image is present, use it as blur background
	if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/SpringBoard/HomeBackgroundThumbnail.jpg"]) {
		
		UIGraphicsBeginImageContextWithOptions(window.bounds.size, YES, 0);
		[window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
		backgroundImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
		UIGraphicsEndImageContext();
	}

	%orig;
}

%end

%ctor {
	if (!IS_IPAD) {
		%init;
	}
}
