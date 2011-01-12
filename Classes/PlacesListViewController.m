//
//  PlacesViewController.m
//  SimpleGeo
//
//  Copyright (c) 2010, SimpleGeo Inc.
//  All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the <organization> nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "PlacesListViewController.h"


@implementation PlacesListViewController

@synthesize tableView;
@synthesize tvCell;

#pragma mark SimpleGeoDelegate methods

- (void)didLoadPlaces:(SGFeatureCollection *)places
             forQuery:(NSDictionary *)query
{
    [super didLoadPlaces:places
                forQuery:query];

    [tableView reloadData];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView
 numberOfRowsInSection:(NSInteger)section
{
    if (placeData) {
        return [self.placeData count];
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *PlacesIdentifier = @"PlacesTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlacesIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"PlacesTVCell"
                                      owner:self
                                    options:nil];
        cell = tvCell;
        self.tvCell = nil;
    }

    SGFeature *place = [[self.placeData features] objectAtIndex:indexPath.row];
    NSString *name = [[place properties] objectForKey:@"name"];
    NSString *category = @"";

    if ([[[place properties] objectForKey:@"classifiers"] count] > 0) {
        NSDictionary *classifiers = [[[place properties] objectForKey:@"classifiers"] objectAtIndex:0];

        category = [classifiers objectForKey:@"category"];

        NSString *subcategory = (NSString *)[classifiers objectForKey:@"subcategory"];
        if (subcategory && ! ([subcategory isEqual:@""] ||
                              [subcategory isEqual:[NSNull null]])) {
            category = [NSString stringWithFormat:@"%@ : %@", category, subcategory];
        }
    }

    // TODO add distance to category

    UILabel *label;
    label = (UILabel *)[cell viewWithTag:1];
    label.text = category;

    label = (UILabel *)[cell viewWithTag:2];
    label.text = name;

    return cell;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)aTableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.placeData count] - 1) {
        return 73.0;
    }

    return 60.0;
}

@end
