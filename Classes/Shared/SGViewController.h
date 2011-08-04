//
//  SGViewController.h
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

#import "SGController.h"
#import "LocationController.h"

/*!
 * Base SimpleGeo View Controller
 */
@interface SGViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet MKMapView *mapView;
    IBOutlet LocationController *locationController;
    IBOutlet SGController *simpleGeoController;
    CLLocationCoordinate2D lastLocation;
}

#pragma -
#pragma mark Request

/*!
 * Show SG info for the current location
 * @param sender    Sender
 */
- (IBAction)getInfoForCurrentLocation:(id)sender;

/*!
 * Show SG info for a specified point location
 * @param location  Point location
 * @param zoom      Map should zoom when info loads
 */
- (void)getInfoForLocation:(CLLocationCoordinate2D)location
                      zoom:(BOOL)zoom;

/*!
 * Request SG info for a specified point location
 * @param location  Point location
 * @param zoom      Map should zoom when info loads
 */
- (void)loadInfoForLocation:(CLLocationCoordinate2D)location
                       zoom:(BOOL)zoom;

#pragma -
#pragma mark MapView

/*!
 * Zoom the map to include all response objects
 * @param objects   SG Response objects
 */
- (void)zoomMap:(NSArray *)objects;

#pragma -
#pragma mark Convenience

/*!
 * Determine if two coordinates are "close enough"
 * @param coordinate1   First coordinate
 * @param coordinate2   Second coordinate
 */
+ (BOOL)coordinate:(CLLocationCoordinate2D)coordinate1
           matches:(CLLocationCoordinate2D)coordinate2;

@end
