//
//  SGViewController.m
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

#import "SGViewController.h"

@implementation SGViewController

#pragma -
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [panGesture setDelegate:self];
    [mapView addGestureRecognizer:panGesture];
    [panGesture release];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // If the view loaded for the first time, set the map region
    if (lastLocation.latitude == 0) [mapView setRegion:locationController.savedRegion animated:NO];
    
    // Otherwise, just set the map center
    else [mapView setCenterCoordinate:locationController.savedRegion.center];
    
    // Then, get info about the location
    [self getInfoForLocation:mapView.centerCoordinate zoom:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Before the view dissapears, save the current map region
    locationController.savedRegion = MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(0, mapView.region.span.longitudeDelta));
}

#pragma -
#pragma mark Request

- (IBAction)getInfoForCurrentLocation:(id)sender
{
    // If the current location is a new location, change the map region
    if (![SGViewController coordinate:locationController.lastLocation.coordinate matches:lastLocation])
        [mapView setRegion:MKCoordinateRegionMake(locationController.lastLocation.coordinate, SGDefaultSpan) animated:YES];
    
    // Otherwise, just change the coordinate
    else [mapView setCenterCoordinate:locationController.lastLocation.coordinate animated:YES];
    
    // Get info about the current location
    [self getInfoForLocation:locationController.lastLocation.coordinate zoom:YES];
}

- (void)getInfoForLocation:(CLLocationCoordinate2D)location zoom:(BOOL)zoom
{
    // Determine if we should actually make a new request
    BOOL sameLocation = [SGViewController coordinate:location matches:lastLocation];
    BOOL zoomedOut = mapView.region.span.longitudeDelta > 1.0;
    if (sameLocation || zoomedOut) return;
    
    // Make the request
    NSLog(@"updating last location");
    lastLocation = location;
    [self loadInfoForLocation:location zoom:zoom];
}

- (void)loadInfoForLocation:(CLLocationCoordinate2D)location
                       zoom:(BOOL)zoom
{
    // Subclasses should call the appropriate request methods
}

#pragma -
#pragma MapView

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
        [self getInfoForLocation:mapView.centerCoordinate zoom:NO];
}

- (void)zoomMap:(NSArray *)objects
{
    // Zoom the map to fit all objects
    SGGeoObject *lastObject = [objects lastObject];
    if (lastObject) {
        double span = [lastObject.distance doubleValue] * 2.0 ;
        if ([lastObject isKindOfClass:[SGPlace class]]) span *= 1000.0;
        [mapView setRegion:MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, span, span) animated:YES];
    }
}

#pragma -
#pragma mark Convenience

+ (BOOL)coordinate:(CLLocationCoordinate2D)c1
           matches:(CLLocationCoordinate2D)c2
{
    double latDelta = c1.latitude - c2.latitude;
    double lonDelta = c1.longitude - c2.longitude;
    double distance = sqrt(latDelta*latDelta + lonDelta*lonDelta);
    return (distance < SGMapDelta);
}

#pragma -
#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma -
#pragma mark Memory

- (void)viewDidUnload
{
    mapView = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    [super dealloc];
}

@end
