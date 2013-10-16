//
//  SearchDelegate.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/16/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "SearchDelegate.h"

#import "ShowViewController.h"
#import "TourViewController.h"
#import "SongInstancesViewController.h"
#import "VenueViewController.h"

@interface SearchDelegate ()

@property (nonatomic) NSString *searchString;

@end

@implementation SearchDelegate

- (instancetype)initWithTableView:(UITableView *)tableView
		  andNavigationController:(UINavigationController *)nav {
    self = [super init];
    if (self) {
        self.tableView = tableView;
		self.navigationController = nav;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(self.results.allowedKeys.count == 0) {
		return 1;
	}

	return self.results.allowedKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(self.results.allowedKeys.count == 0) {
		return 1;
	}

	return [[self.results valueForKey:self.results.allowedKeys[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	
	if(!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									  reuseIdentifier:@"Cell"];
	}

	if(self.results.allowedKeys.count == 0) {
		cell.textLabel.text = @"No results";
		cell.detailTextLabel.text = @"";
		return cell;
	}

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	NSString *resultType = self.results.allowedKeys[indexPath.section];
	id result = [self.results valueForKey:resultType][indexPath.row];
	
	if([resultType isEqualToString:@"show"]) {
		PhishinShow *show = (PhishinShow*)result;
		cell.textLabel.text = show.date;
		cell.detailTextLabel.text = show.fullLocation;
	}
	else if([resultType isEqualToString:@"other_shows"]) {
		PhishinShow *show = (PhishinShow*)result;
		cell.textLabel.text = show.date;
		cell.detailTextLabel.text = show.fullLocation;
	}
	else if([resultType isEqualToString:@"songs"]) {
		PhishinSong *song = (PhishinSong*)result;
		cell.textLabel.text = song.title;
		cell.detailTextLabel.text = @"";
	}
	else if([resultType isEqualToString:@"venues"]) {
		PhishinVenue *venue = (PhishinVenue*)result;
		cell.textLabel.text = venue.name;
		cell.detailTextLabel.text = venue.location;
	}
	else if([resultType isEqualToString:@"tours"]) {
		PhishinTour *tour = (PhishinTour*)result;
		cell.textLabel.text = tour.name;
		cell.detailTextLabel.text = tour.prettyDuration;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	NSString *resultType = self.results.allowedKeys[indexPath.section];
	id result = [self.results valueForKey:resultType][indexPath.row];
	
	if([resultType isEqualToString:@"show"]) {
		ShowViewController *vc = [[ShowViewController alloc] initWithShow:(PhishinShow*)result];
		[self.navigationController pushViewController:vc
											 animated:YES];
	}
	else if([resultType isEqualToString:@"other_shows"]) {
		PhishinShow *show = (PhishinShow*)result;
		ShowViewController *vc = [[ShowViewController alloc] initWithShow:show];
		[self.navigationController pushViewController:vc
											 animated:YES];
	}
	else if([resultType isEqualToString:@"songs"]) {
		PhishinSong *song = (PhishinSong*)result;
		SongInstancesViewController *vc = [[SongInstancesViewController alloc] initWithSong:song];
		[self.navigationController pushViewController:vc
											 animated:YES];
	}
	else if([resultType isEqualToString:@"venues"]) {
		PhishinVenue *venue = (PhishinVenue*)result;
		VenueViewController *vc = [[VenueViewController alloc] initWithVenue:venue];
		[self.navigationController pushViewController:vc
											 animated:YES];
	}
	else if([resultType isEqualToString:@"tours"]) {
		PhishinTour *tour = (PhishinTour*)result;
		TourViewController *vc = [[TourViewController alloc] initWithTour:tour];
		[self.navigationController pushViewController:vc
											 animated:YES];
	}
}

- (void)updateFilteredContentForProductName {
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(guardedSearch)
											   object:nil];
	
	[self performSelector:@selector(guardedSearch)
			   withObject:nil
			   afterDelay:0.3];
	
}

- (void)guardedSearch {
	[[PhishinAPI sharedAPI] search:self.searchString
						   success:^(PhishinSearchResults *results) {
							   self.results = results;
							   
							   [self.tableView reloadData];
						   }
						   failure:REQUEST_FAILED(self.tableView)];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString {
	self.searchString = searchString;
    [self updateFilteredContentForProductName];
    return NO;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self updateFilteredContentForProductName];
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(section >= self.results.allowedKeys.count) {
		return nil;
	}
	
	NSString *resultType = self.results.allowedKeys[section];
	
	if([resultType isEqualToString:@"show"]) {
		return @"Exact Show Match";
	}
	else if([resultType isEqualToString:@"other_shows"]) {
		return @"Shows";
	}
	else if([resultType isEqualToString:@"songs"]) {
		return @"Songs";
	}
	else if([resultType isEqualToString:@"venues"]) {
		return @"Venues";
	}
	else if([resultType isEqualToString:@"tours"]) {
		return @"Tours";
	}
	
	return nil;
}



@end
