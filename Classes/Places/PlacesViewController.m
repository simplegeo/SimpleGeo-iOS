//
//  PlacesViewController.m
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

#import "PlacesViewController.h"

@interface PlacesViewController ()
@property (nonatomic, retain) NSArray *fetchedPlaces;
@end

@implementation PlacesViewController

@synthesize fetchedPlaces;

# pragma mark Request

- (void)loadInfoForLocation:(CLLocationCoordinate2D)location
                       zoom:(BOOL)zoom
{
    SGPlacesQuery *query = [SGPlacesQuery queryWithPoint:[SGPoint pointWithLat:location.latitude lon:location.longitude]];
    [query setSearchString:searchBar.text];
    [simpleGeoController.client getPlacesForQuery:query
                                         callback:[SGCallback callbackWithSuccessBlock:
                                                   ^(id response) {
                                                       NSArray *places = [NSArray arrayWithSGCollection:response type:SGCollectionTypePlaces];
                                                       self.fetchedPlaces = places;
                                                       [mapView removeAnnotations:mapView.annotations];
                                                       [self showPlacesAndZoom:zoom];
                                                   } failureBlock:^(NSError *error) {
                                                       // handle failures
                                                   }]];
}

- (void)showPlacesAndZoom:(BOOL)zoom
{
    // Create the map annotations
    for (SGPlace *place in fetchedPlaces) {
        MKPointAnnotation *annotation = [[[MKPointAnnotation alloc] init] autorelease];
        [annotation setCoordinate:place.point.coordinate];
        [annotation setTitle:place.name];
        if (place.classifiers)
            [annotation setSubtitle:[[place.classifiers objectAtIndex:0] classifierCategory]];
        [mapView addAnnotation:annotation];
    }
    if (zoom) [self zoomMap:fetchedPlaces];
}

#pragma -
#pragma mark MapView

- (MKAnnotationView *)mapView:(MKMapView*)aMapView
            viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation && [[annotation title] isEqual:@"Current Location"]) return nil;
    
    static NSString *annotationIdentifier = @"placeAnnotation";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    if (annotationView == nil) {
        annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
        [annotationView setCanShowCallout:YES];
        [annotationView setAnimatesDrop:YES];
        /* If you'd like to show detailed information about a place...
        UIButton *showPlace = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [annotationView setRightCalloutAccessoryView:showPlace];
         */
    }
    
    [annotationView setAnnotation:annotation];
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // This is where you'd show detailed information about a place
}

#pragma -
#pragma mark Seach Bar

- (void)mapView:(MKMapView *)aMapView regionWillChangeAnimated:(BOOL)animated
{
    // Dismiss the keyboard if the map is moved
    if (searchBar.isFirstResponder)
        [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    // Load new info if the search term has changed
    [self loadInfoForLocation:mapView.centerCoordinate zoom:YES];
    [aSearchBar resignFirstResponder];
}

#pragma -
#pragma mark Memory

- (void)viewDidUnload
{
    searchBar = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    [fetchedPlaces release];
    [super dealloc];
}

@end
