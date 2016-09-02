/*
 *	Copyright 2013, SmugWimp
 *
 *	All rights reserved.
 *
 *	Redistribution and use in source and binary forms, with or without modification, are 
 *	permitted provided that the following conditions are met:
 *
 *	Redistributions of source code must retain the above copyright notice which includes the
 *	name(s) of the copyright holders. It must also retain this list of conditions and the 
 *	following disclaimer. 
 *
 *	Redistributions in binary form must reproduce the above copyright notice, this list 
 *	of conditions and the following disclaimer in the documentation and/or other materials 
 *	provided with the distribution. 
 *
 *	Neither the name of David Book, or buzztouch.com nor the names of its contributors 
 *	may be used to endorse or promote products derived from this software without specific 
 *	prior written permission.
 *
 *	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 *	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 *	IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 *	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
 *	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
 *	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 *	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 *	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
 *	OF SUCH DAMAGE. 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BT_viewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface sw_smugmsgloc : BT_viewController <CLLocationManagerDelegate>{
    
//    UISegmentedControl *smsOrEmail;
//    UIButton *btnSend;
    UIButton  *btnSMS;
    UIButton *btnEmail;
    UIButton *btnZoomIn;
    UIButton *btnZoomOut;
    MKMapView *smugView;
    UILabel *lblDegrees;
    UILabel *lblDirection;
    UILabel *lblCoordinates;
    UIImageView *compassBg;
    UIImageView *compassArrow;
    UIView *compassContainer;
    NSNumberFormatter *smugFormat;
    // variables
    
    NSString *smugUrlData;
    NSString *smugEmailSubject;
    NSString *smugLocation;
    NSString *smugDegrees;
    NSString *smugDirection;
    NSString *smugCoordinates;
    BOOL canReachNetwork;
    
    // Location Manager
    
    CLLocationManager *smugLeManager;
    
}

@property (nonatomic, retain) CLLocationManager	*smugLeManager;
@property (nonatomic, retain) NSNumberFormatter *smugFormat;
@property (nonatomic, retain) NSString *smugLat;
@property (nonatomic, retain) NSString *smugLng;
@property (nonatomic, retain) NSString *smugEmailSubject;
@property (nonatomic, retain) NSString *smugUrlData;
@property (nonatomic, retain) NSString *smugDegrees;
@property (nonatomic, retain) NSString *smugDirection;
@property (nonatomic, retain) NSString *smugCoordinates;
@property (nonatomic) CLLocationCoordinate2D swCurCoord;
@property (nonatomic) BOOL canReachNetwork;
@property (nonatomic)  int swZoomLevel;
@property (nonatomic)  CGFloat objWidth;
@property (nonatomic)  CGFloat objHeight;
@property (nonatomic)  CGFloat mapHeight;

-(void)viewDidLoad;
-(void)canReach;
-(void)sendSmugMail;
-(void)sendSmugMsg;
-(void)zoomIn;
-(void)zoomOut;
// -(void)loadSegmentButton;
// -(void)segmentedControlAction:(id)sender;
-(void)buttonPressed:(UIButton *)button;
-(void)layoutScreen;
-(void)loadMapView;
-(void)loadlblDegrees;
-(void)loadlblDirection;
-(void)loadcompassBg;
-(void)loadcompassArrow;
// -(void)loadBtnSend;
-(void)doUpdate;

-(void)displayMap;



@end









