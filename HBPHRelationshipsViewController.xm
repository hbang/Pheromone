#import "HBPHRelationshipsViewController.h"
#import "Cydia/CydiaClause.h"
#import "Cydia/CydiaOperation.h"
#import "Cydia/CydiaRelation.h"
#import "Cydia/CYPackageController.h"
#import "Cydia/Database.h"
#import "Cydia/Package.h"

@interface HBPHRelationshipsViewController ()

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, retain) Database *database;
@property (nonatomic, retain) Package *package;

@property (nonatomic, retain) NSDictionary *relations;
@property (nonatomic, retain) NSArray *sortedRelations;

- (void)_updateRelations;

@end

%subclass HBPHRelationshipsViewController : CyteViewController

%property (nonatomic, retain) UITableView *tableView;

%property (nonatomic, retain) Database *database;
%property (nonatomic, retain) Package *package;

%property (nonatomic, retain) NSDictionary *relations;
%property (nonatomic, retain) NSArray *sortedRelations;

%new - (id)initWithDatabase:(Database *)database package:(Package *)package {
	self = [self init];

	if (self) {
		self.database = database;
		self.package = package;
	}

	return self;
}

#pragma mark - UIViewController

- (void)loadView {
	%orig;

	UITableView *tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStyleGrouped];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tableView.dataSource = self;
	tableView.delegate = self;
	self.view = tableView;
	self.tableView = tableView;
}

- (void)viewDidLoad {
	%orig;
	self.title = @"Relationships";
}

#pragma mark - CyteViewController

- (NSURL *)navigationURL {
	return [NSURL URLWithString:[NSString stringWithFormat:@"cydia://package/%@/relationships", self.package.id]];
}

- (void)reloadData {
	%orig;
	[self _updateRelations];
}

#pragma mark - Calculating

%new - (void)_updateRelations {
	NSMutableDictionary *relations = [NSMutableDictionary dictionary];

	for (CydiaRelation *relation in self.package.relations) {
		NSString *relationship = relation.relationship;

		if (!relations[relationship]) {
			relations[relationship] = [NSMutableArray array];
		}

		BOOL first = YES;

		for (CydiaClause *clause in relation.clauses) {
			if (!first) {
				[relations[relationship] addObject:@"– or –"];
			}

			first = NO;

			[relations[relationship] addObject:clause];
		}
	}

	if (relations.allKeys.count == 0) {
		relations[@""] = @[ @"No Relationships" ];
	}

	[self.relations release];
	self.relations = relations;

	[self.sortedRelations release];
	self.sortedRelations = [relations.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

#pragma mark - Table view

%new - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.relations.count;
}

%new - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *type = self.sortedRelations[section];
	NSArray *relations = self.relations[type];
	return relations.count;
}

%new - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
	}

	NSString *type = self.sortedRelations[indexPath.section];
	id value = self.relations[type][indexPath.row];

	if ([value isKindOfClass:%c(CydiaClause)]) {
		CydiaClause *clause = value;
		Package *package = [self.database packageWithName:clause.package];

		cell.textLabel.text = package ? package.name : clause.package;
		cell.detailTextLabel.text = [clause.version isKindOfClass:NSNull.class] ? @"" : [NSString stringWithFormat:@"%@ %@", [clause.version operator], clause.version.value];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	} else {
		cell.textLabel.text = value;
		cell.detailTextLabel.text = @"";
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	return cell;
}

%new - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	NSString *type = self.sortedRelations[indexPath.section];
	CydiaClause *clause = self.relations[type][indexPath.row];

	if ([clause isKindOfClass:%c(CydiaClause)]) {
		CYPackageController *viewController = [[%c(CYPackageController) alloc] initWithDatabase:self.database forPackage:clause.package withReferrer:self.navigationURL.absoluteString];
		viewController.delegate = self.delegate;
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

%new - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.sortedRelations[section];
}

%new - (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	/*
	 all types known to apt as of basically forever ago:

	 Depends, PreDepends, Suggests, Recommends, Conflicts, Replaces, Obsoletes,
	 Breaks, Enhances
	*/

	NSString *type = self.sortedRelations[section];

	if ([type isEqualToString:@"Depends"]) {
		return @"These packages are required for the package to function.";
	} else if ([type isEqualToString:@"PreDepends"]) {
		return @"These packages are required for the package to install.";
	} else if ([type isEqualToString:@"Suggests"]) {
		return @"These packages add features to the package and are suggested, but are not required.";
	} else if ([type isEqualToString:@"Recommends"]) {
		return @"These packages add features to the package and are recommended, but are not required.";
	} else if ([type isEqualToString:@"Conflicts"]) {
		return @"These packages have an issue with the package and can not be installed at the same time.";
	} else if ([type isEqualToString:@"Replaces"]) {
		return @"This package supersedes these packages.";
	} else if ([type isEqualToString:@"Obsoletes"]) {
		return @"This package makes these packages redundant.";
	} else if ([type isEqualToString:@"Breaks"]) {
		return @"This package breaks these packages and can not be installed at the same time.";
	} else if ([type isEqualToString:@"Enhances"]) {
		return @"This package enhances the features of these packages.";
	} else {
		return nil;
	}
}

#pragma mark - Weird CyteKit memory management

- (void)releaseSubviews {
	[self.tableView release];
	[self.database release];
	[self.package release];
	[self.relations release];
	[self.sortedRelations release];
	%orig;
}

%end
