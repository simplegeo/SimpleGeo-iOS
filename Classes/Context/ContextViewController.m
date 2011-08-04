//
//  ContextViewController.m
//  SimpleGeo
//
//  Copyright (c) 2010-2011, SimpleGeo Inc.
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

#import "ContextViewController.h"
#import "PolygonViewController.h"

typedef enum {
    ContextSectionAddress = 0,
    ContextSectionFeatures = 1,
    ContextSectionIntersections = 2,
    ContextSectionDemographics = 3,
    ContextSectionCoordinate = 4,
} ContextSection;

@interface ContextViewController ()
@property (nonatomic, retain) SGContext *context;
@property (nonatomic, retain) PolygonViewController *polygonViewController;
@end

@implementation ContextViewController

@synthesize context, polygonViewController;

#pragma mark Instantiation

- (PolygonViewController *)polygonViewController
{
    if (!polygonViewController) {
        polygonViewController = [[PolygonViewController alloc] initWithNibName:@"PolygonView"
                                                                        bundle:nil
                                                                    controller:simpleGeoController];
    }
    return polygonViewController;
}

#pragma -
#pragma mark View

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [tableView reloadData];
}

#pragma -
#pragma mark Request

- (void)loadInfoForLocation:(CLLocationCoordinate2D)location
                       zoom:(BOOL)zoom
{
    SGContextQuery *query = [SGContextQuery queryWithPoint:[SGPoint pointWithLat:location.latitude
                                                                             lon:location.longitude]];
    [simpleGeoController.client getContextForQuery:query
                                          callback:[SGCallback callbackWithSuccessBlock:
                                                    ^(id response) {
                                                        self.context = [SGContext contextWithDictionary:response];
                                                        [tableView reloadData];
                                                    } failureBlock:^(NSError *error) {
                                                        // handle failures
                                                    }]];
}

#pragma -
#pragma mark TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case ContextSectionAddress: return @"Nearest Address";
        case ContextSectionFeatures: return @"Features";
        case ContextSectionIntersections: return @"Nearest Intersections";
        case ContextSectionDemographics: return @"Demographics";
        case ContextSectionCoordinate: return @"Coordinate";
        default: return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.context) {
        if (section == ContextSectionAddress && self.context.address) return 1;
        else if (section == ContextSectionFeatures && self.context.features) return [self.context.features count];
        else if (section == ContextSectionDemographics && self.context.demographics) return 1;
        else if (section == ContextSectionIntersections && self.context.intersections) return [self.context.intersections count];
        else if (section == ContextSectionCoordinate) return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Initialize the celll
    static NSString *reuseIdentifier = @"contextCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                    reuseIdentifier:reuseIdentifier] autorelease];
    
    // If this is a feature cell, set accessory icon & selection style
    if (indexPath.section == ContextSectionFeatures) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    // Otherwise remove them (since cells are reused)
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    // Format address cell
    if (indexPath.section == ContextSectionAddress) {
        NSString *textLabel = context.address.street;
        NSString *detailTextLabel = [context.address formattedAddress:SGAddressFormatUSNormal withStreet:NO];
        if (!textLabel) {
            textLabel = detailTextLabel;
            detailTextLabel = nil;
        }
        [[cell textLabel] setText:textLabel];
        [[cell detailTextLabel] setText:detailTextLabel];        
        
    // Format feature cell
    } else if (indexPath.section == ContextSectionFeatures) {
        SGFeature *feature = [self.context.features objectAtIndex:indexPath.row];
        [[cell textLabel] setText:feature.name];
        NSDictionary *classifier = [feature.classifiers objectAtIndex:0];
        NSMutableString *featureKind = [NSMutableString string];
        if ([classifier classifierCategory]) [featureKind appendString:[classifier classifierCategory]];
        if ([classifier classifierSubcategory]) [featureKind appendFormat:@" - %@", [classifier classifierSubcategory]];
        [[cell detailTextLabel] setText:featureKind];       
        
    // Format demographic cell
    } else if (indexPath.section == ContextSectionDemographics) {
        [[cell textLabel] setText:[NSString stringWithFormat:@"%d people/km\u00b2",
                                   [[self.context.demographics objectForKey:@"population_density"] intValue]]];
        [[cell detailTextLabel] setText:@"Population Density"];
        
    // Format intersection cell
    } else if (indexPath.section == ContextSectionIntersections) {
        SGGeoObject *intersection = [self.context.intersections objectAtIndex:indexPath.row];
        NSString *road1 = [[[intersection.properties objectForKey:@"highways"] objectAtIndex:0] objectForKey:@"name"];
        NSString *road2 = [[[intersection.properties objectForKey:@"highways"] objectAtIndex:1] objectForKey:@"name"];
        [[cell textLabel] setText:[NSString stringWithFormat:@"%@ & %@",road1,road2]];
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%dm away", [intersection.distance intValue]]];
        
    // Format coordinate cell
    } else if (indexPath.section == ContextSectionCoordinate) {
        [[cell textLabel] setText:[NSString stringWithFormat:@"%@, %@",
                                   [self.context.query objectForKey:@"latitude"],
                                   [self.context.query objectForKey:@"longitude"]]];
        [[cell detailTextLabel] setText:nil];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == ContextSectionFeatures) {
        // Show the polygon view for the feature
        [self.polygonViewController setFeature:[self.context.features objectAtIndex:indexPath.row]];
        [self presentModalViewController:polygonViewController animated:YES];
    }
}

#pragma -
#pragma mark Memory

- (void)viewDidUnload
{
    tableView = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    [context release];
    [polygonViewController release];
    [super dealloc];
}

@end
