//
//  PolygonViewController.m
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

#import "PolygonViewController.h"
#import "SGController.h"

@implementation PolygonViewController

@synthesize feature;

#pragma -
#pragma mark Instantiation

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
           controller:(SGController *)controller
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        simpleGeoController = [controller retain];
    }
    return self;
}

#pragma -
#pragma mark View

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navBar.topItem setTitle:feature.name];
    [mapView removeOverlays:mapView.overlays];
    [self loadFeaturePolygon];
    [mapView setVisibleMapRect:[(SGEnvelope *)feature.geometry mapRect]
                   edgePadding:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
                      animated:NO];
}

- (void)done:(id)sender
{
    // Dismiss the view
    [self dismissModalViewControllerAnimated:YES];
}

#pragma -
#pragma mark Request

- (void)loadFeaturePolygon
{
    [simpleGeoController.client getFeatureWithHandle:feature.identifier
                                                zoom:nil
                                            callback:[SGCallback callbackWithSuccessBlock:
                                                      ^(id response) {
                                                          SGFeature *fullFeature = [SGFeature featureWithGeoJSON:response];
                                                          [mapView addOverlays:[fullFeature.geometry overlays]];
                                                      } failureBlock:^(NSError *error) {
                                                          //
                                                      }]];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    // Style the polygon overlay
    MKPolygonView *overlayView = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay] autorelease];
    overlayView.fillColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    return overlayView;
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
    navBar = nil;
    mapView = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [simpleGeoController release];
    [feature release];
    [super dealloc];
}

@end
