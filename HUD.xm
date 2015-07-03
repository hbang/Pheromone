#import <UIKit/_UIBackdropView.h>
#import <UIKit/_UIBackdropViewSettings.h>
#import <UIKit/_UIBackdropViewSettingsLight.h>
#import <UIKit/_UIBackdropViewSettingsUltraDark.h>
#import <UIKit/UIProgressHUD.h>
#import <UIKit/UIProgressIndicator.h>

typedef NS_ENUM(NSInteger, HBCDHUDStyle) {
	HBCDHUDStyleDark,
	HBCDHUDStyleLight
};

BOOL enabled = YES;
HBCDHUDStyle hudStyle = HBCDHUDStyleDark;

%hook UIProgressHUD

- (id)initWithFrame:(CGRect)frame {
	self = %orig;

	if (self) {
		if (!enabled) {
			return self;
		}

		self.layer.cornerRadius = 16.f;
		self.clipsToBounds = YES;

		BOOL isLight = hudStyle == HBCDHUDStyleLight;
		Class settingsClass = isLight ? %c(_UIBackdropViewSettingsLight) : %c(_UIBackdropViewSettingsUltraDark);

		_UIBackdropView *backdropView = [[%c(_UIBackdropView) alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:[[settingsClass alloc] initWithDefaultValues]];
		[self insertSubview:backdropView atIndex:0];

		if (isLight) {
			// the following are for black text on the light blur

			UILabel *progressMessage = MSHookIvar<UILabel *>(self, "_progressMessage");
			progressMessage.textColor = [UIColor colorWithWhite:0 alpha:0.65f];

			UIProgressIndicator *progressIndicator = MSHookIvar<UIProgressIndicator *>(self, "_progressIndicator");
			progressIndicator.activityIndicatorViewStyle = 10;
		}
	}

	return self;
}

- (void)drawRect:(CGRect)rect {
	if (enabled) {
		// prevents the solid black background from being drawn
		objc_super super = { self, self.superclass };
		objc_msgSendSuper(&super, _cmd, rect);
	} else {
		%orig;
	}
}

%end
