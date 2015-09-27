#import "Cydia/Cydia.h"

@interface Cydia ()

@property (nonatomic, retain) NSDictionary *_pheromone_appDates;

- (void)_pheromone_getAppModificationDates;
- (BOOL)_pheromone_needsUicacheReload;

@end

%hook Cydia

%property (nonatomic, retain) NSDictionary *_pheromone_appDates;

%new - (void)_pheromone_getAppModificationDates {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *prefix = @"/Applications";

	NSError *error = nil;
	NSArray *files = [fileManager contentsOfDirectoryAtPath:prefix error:&error];

	if (error) {
		HBLogError(@"error getting list of %@: %@", prefix, files);
		return;
	}

	NSMutableDictionary *appDates = [NSMutableDictionary dictionary];

	for (NSString *item in files) {
		NSString *path = [prefix stringByAppendingPathComponent:item];

		NSError *error = nil;
		NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:&error];

		if (error) {
			HBLogError(@"error getting attributes of %@: %@", path, error);
			continue;
		}

		appDates[path] = attributes[NSFileModificationDate];
	}

	self._pheromone_appDates = [appDates copy];
}

%new - (BOOL)_pheromone_needsUicacheReload {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *prefix = @"/Applications";

	NSError *error = nil;
	NSArray *files = [fileManager contentsOfDirectoryAtPath:prefix error:&error];

	NSDictionary *appDates = self._pheromone_appDates;

	if (error) {
		HBLogError(@"error getting list of %@: %@", prefix, files);

		// reload to be sure
		goto reload;
	}

	if (!appDates) {
		// no dates were collected before, reload to be sure
		goto reload;
	}

	for (NSString *item in appDates.allKeys) {
		if (![files containsObject:item.lastPathComponent]) {
			// directory was removed, reload needed
			goto reload;
		}
	}

	for (NSString *item in files) {
		NSString *path = [prefix stringByAppendingPathComponent:item];

		if (![appDates.allKeys containsObject:path]) {
			// directory was added, reload needed
			goto reload;
		}

		NSError *error = nil;
		NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:&error];

		if (error) {
			HBLogError(@"error getting attributes of %@: %@", path, error);

			// reload to be sure
			goto reload;
		} else if (![attributes[NSFileModificationDate] isEqual:appDates[path]]) {
			// mod date changed, reload needed
			goto reload;
		}
	}

	return NO;

reload: // zomg a label
	// release and nil the dictionary
	[appDates release];
	self._pheromone_appDates = nil;

	return YES;
}

- (void)perform_ {
	// get the before install file mod dates
	[self _pheromone_getAppModificationDates];
	%orig;
}

- (void)uicache {
	// don't call uicache if nothing changed
	if (!self._pheromone_needsUicacheReload) {
		return;
	}

	%orig;
}

%end
