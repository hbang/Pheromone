NSBundle *bundle;

%ctor {
	bundle = [[NSBundle bundleWithPath:@"/Library/Application Support/Pheromone.bundle"] retain];
}
