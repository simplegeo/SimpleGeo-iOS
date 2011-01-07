//
//  MapViewController.m
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

#import "PlacesMapViewController.h"


@implementation PlacesMapViewController

@synthesize locationController;
@synthesize simpleGeoController;
@synthesize mapView;
@synthesize placeData;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    CLLocationCoordinate2D lastLocation = [[self.locationController lastLocation] coordinate];

    [self.simpleGeoController setDelegate:self];
    [self.simpleGeoController.client getPlacesNear:[SGPoint pointWithLatitude:lastLocation.latitude
                                                                    longitude:lastLocation.longitude]];

    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(lastLocation, 1000.0, 1000.0);
    [self.mapView setRegion:region];
}

- (void)dealloc
{
    [placeData release];
    [super dealloc];
}

#pragma mark SimpleGeoDelegate methods

- (void)requestDidFail:(ASIHTTPRequest *)request
{
    NSLog(@"Request failed: %@: %i", [request responseStatusMessage], [request responseStatusCode]);
}

- (void)requestDidFinish:(ASIHTTPRequest *)request
{
    // NSLog(@"Request finished: %@", [request responseString]);
}

- (void)didLoadPlaces:(SGFeatureCollection *)places
             forQuery:(NSDictionary *)query
{
    self.placeData = places;

    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[places count]];

    for (SGFeature *place in [places features]) {
        SGPoint *point = (SGPoint *)[place geometry];
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

        MKPointAnnotation *annotation = [[[MKPointAnnotation alloc] init] autorelease];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = point.latitude;
        coordinate.longitude = point.longitude;

        annotation.coordinate = coordinate;
        annotation.title = name;
        annotation.subtitle = category;

        [annotations addObject:annotation];
    }

    [self.mapView addAnnotations:annotations];
}

#pragma mark MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)aMapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *AnnotationIdentifier = @"annotation";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];

    if (annotationView == nil) {
        annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] autorelease];
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
    }

    annotationView.annotation = annotation;
    return annotationView;
}

@end
