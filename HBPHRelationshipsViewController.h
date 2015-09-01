#import "Cydia/PackageListController.h"

@class Database, Package;

@interface HBPHRelationshipsViewController : PackageListController <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithDatabase:(Database *)database package:(Package *)package;

@end
