// v1.9 June 15th 2014

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


#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JSON.h"
#import "BT_application.h"
#import "BT_strings.h"
#import "BT_viewUtilities.h"
#import "BT_appDelegate.h"
#import "BT_item.h"
#import "BT_debugger.h"
#import "sw_smugmsgloc.h"
#import "BT_viewController.h"
#import "BT_background_view.h"
//
#import "MKMapView+ZoomLevel.h"

@implementation sw_smugmsgloc
//
@synthesize smugUrlData, smugEmailSubject, smugLat, smugLng, canReachNetwork;
@synthesize smugDirection, smugCoordinates, smugDegrees, smugFormat;
@synthesize swZoomLevel, swCurCoord;
//
@synthesize smugLeManager;
//
-(void) viewDidLoad{
	[BT_debugger showIt:self theMessage:@"viewDidLoad"];
	[super viewDidLoad];
    [self startUpdating];
    swZoomLevel = 10;
    BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
    smugLat = appDelegate.rootDevice.deviceLatitude;
    smugLng = appDelegate.rootDevice.deviceLongitude;
    swCurCoord.latitude = [appDelegate.rootDevice.deviceLatitude doubleValue];
    swCurCoord.longitude = [appDelegate.rootDevice.deviceLongitude doubleValue];
    [smugView setCenterCoordinate:swCurCoord zoomLevel:swZoomLevel animated:FALSE];
    [self.view setBackgroundColor:[BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundColor" defaultValue:@"#333333"]]];
    
    [self performSelector:(@selector(displayMap)) withObject:nil afterDelay:0.2];
	if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"includeAds" defaultValue:@"0"] isEqualToString:@"1"]){
	   	[self createAdBannerView];
	}
}
//
-(void) viewWillUnload {
    [self stopUpdating];
}
//

//
-(void)doUpdate {
   	BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
//    [BT_debugger showIt:self message:[NSString stringWithFormat:@"Latitude: %@", smugLat]];
//    [BT_debugger showIt:self message:[NSString stringWithFormat:@"Longitude: %@", smugLng]];
    self.objWidth = self.view.frame.size.width;
    self.objHeight = self.view.frame.size.height;
    smugCoordinates = [smugLat stringByAppendingString:@","];
    smugCoordinates = [smugCoordinates stringByAppendingString:smugLng];
//    [BT_debugger showIt:self message:[NSString stringWithFormat:@"Coordinates: %@", smugCoordinates]];
//    [btnSend setFrame:CGRectMake(5, 5, self.objWidth - 10, 40)];
    [btnSMS setFrame:CGRectMake(5,5, (self.objWidth /2) - 10,40)];
    [btnEmail setFrame:CGRectMake((self.objWidth /2) + 5, 5, (self.objWidth /2) - 10, 40)];
    [lblDirection setText:smugDirection];
    [lblCoordinates setText:smugCoordinates];
    swCurCoord = smugView.centerCoordinate;
    //
    if([appDelegate.rootApp.tabs count] == 0){
    }else{
        self.mapHeight = (self.view.frame.size.height - 50);
    }
    [smugView setFrame:CGRectMake(5, 50, self.objWidth - 10, self.view.frame.size.height - 70)];
    /*
    MKCoordinateRegion region;
    region.center.latitude = [smugLat doubleValue];
    region.center.longitude = [smugLng doubleValue];
    region.span.latitudeDelta = 0.05;
    region.span.longitudeDelta = 0.05;
    region = [smugView regionThatFits:region];
    [smugView setRegion:region animated:TRUE];
    */
	[lblDegrees setFrame:CGRectMake(0, 60, self.view.frame.size.width, 31)];
	[lblDirection setFrame:CGRectMake(0, 80, self.view.frame.size.width, 31)];
    [compassBg setFrame:CGRectMake((self.view.frame.size.width/2) - (compassBg.image.size.width / 2), 135, compassBg.image.size.width, compassBg.image.size.height)];
	[lblCoordinates setFrame:CGRectMake(0, (self.view.frame.size.height - 25), self.view.frame.size.width, 31)];
}
//
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    float mHeading = newHeading.trueHeading;
    if ((mHeading >= 339) || (mHeading <= 22)) {
        smugDirection = @"N";
    } else if ((mHeading > 23) && (mHeading <= 68)) {
        smugDirection = @"NE";
    } else if  ((mHeading > 69) && (mHeading <= 113)) {
        smugDirection = @"E";
    } else if ((mHeading > 114) && (mHeading <= 158)) {
        smugDirection = @"SE";
    } else if ((mHeading > 159) && (mHeading <= 203)) {
        smugDirection = @"S";
    } else if ((mHeading > 204) && (mHeading <= 248)) {
        smugDirection = @"SW";
    } else if ((mHeading > 249) && (mHeading <= 293)) {
        smugDirection = @"W";
    } else if ((mHeading > 294) && (mHeading <= 338)) {
        smugDirection = @"NW";
    }
    double radians = (newHeading.magneticHeading * M_PI) / 180;
    compassArrow.transform = CGAffineTransformMakeRotation(-radians);
    smugDegrees = [NSString stringWithFormat:@"%3.1f", manager.heading.trueHeading];
    smugDegrees = [smugDegrees stringByAppendingString:@"°"];
    [lblDegrees setText:smugDegrees];
    smugLat = [NSString stringWithFormat:@"%3.8f",manager.location.coordinate.latitude];
    smugLng = [NSString stringWithFormat:@"%3.8f",manager.location.coordinate.longitude];
    [self doUpdate];
}
//
-(void) layoutScreen {
    [self doUpdate];
}
//
-(void) canReach {
    
   	BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate.rootDevice isOnline]){
        canReachNetwork = TRUE;
    }else{
        canReachNetwork = FALSE;
    }
  
}

//
-(void) startUpdating {
    [self.smugLeManager startUpdatingHeading];
}
//
-(void) stopUpdating {
    [self.smugLeManager stopUpdatingHeading];
}
//
-(void) sendSmugMail { // Bracket 1
    if ( canReachNetwork == false) {
        [self showAlert:@"Network Not Available" theMessage:@"No Network. Email Messages will be queued." alertTag:01];
    }
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if(mailClass != nil){
		if([mailClass canSendMail]){
			BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
            BT_navController *theNavController = [appDelegate getNavigationController];
            BT_viewController *theViewController = [appDelegate getViewController];
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = theViewController;
			[picker setToRecipients:nil];
            NSString *tmpBody = self.smugUrlData;
            tmpBody = [tmpBody stringByReplacingOccurrencesOfString: @"[deviceLatitude]" withString:smugLat];
            tmpBody = [tmpBody stringByReplacingOccurrencesOfString: @"[deviceLongitude]" withString:smugLng];
			[picker setSubject: self.smugEmailSubject];
			NSString *emailBody = tmpBody;
			[picker setMessageBody:emailBody isHTML:NO];
            [theNavController presentViewController:picker animated:YES completion:nil];
            [picker.navigationBar setTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:self.screenData]];
		}//can send mail
	}else{
        [self showAlert:@"Email Not Available" theMessage:@"Your device cannot send Email Messages" alertTag:01];
    }
}
//
-(void) sendSmugMsg { // Bracket 1
   	BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
	if([appDelegate.rootDevice canSendSMS]){
		Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));
		if(smsClass != nil && [MFMessageComposeViewController canSendText]){
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
			if([MFMessageComposeViewController canSendText]){
                BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
                BT_navController *theNavController = [appDelegate getNavigationController];
                BT_viewController *theViewController = theViewController;
				picker.messageComposeDelegate = self;
                picker.recipients = [NSArray arrayWithObjects: nil,  nil, nil];
                NSString *tmpBody = self.smugUrlData;
                tmpBody = [tmpBody stringByReplacingOccurrencesOfString: @"[deviceLatitude]" withString:smugLat];
                tmpBody = [tmpBody stringByReplacingOccurrencesOfString: @"[deviceLongitude]" withString:smugLng];
                picker.body = tmpBody;
				//show it
                [theNavController presentViewController:picker animated:YES completion:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
		}
    }else{
        [self showAlert:@"SMS Not Available" theMessage:@"Your device cannot send SMS Messages" alertTag:01];
	}//device can send text
}
//
-(void) goCompass {
    [self loadlblDirection];
    [self loadlblDegrees];
    [self loadcompassBg];
    [self loadcompassArrow];
}
//
-(void) goMap {
//    [self loadSegmentButton];
    [self loadMapView];
    [self loadbtnZoomIn];
    [self loadbtnZoomOut];
    
}
//

//
-(void) loadMapView {
//   	BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
    smugView = [[MKMapView alloc] init];
    [smugView setShowsUserLocation:YES];
    [smugView setMapType:MKMapTypeHybrid];
    [smugView setFrame:CGRectMake(10, 50, 300, 300)];
    
    [smugView.layer setMasksToBounds:YES];
    [smugView.layer setCornerRadius:10.0];
    
    [[self view] addSubview:smugView];
//    MKCoordinateRegion region;
    //
    /*
    region.center.latitude = [smugLat doubleValue]; //[appDelegate.rootDevice.deviceLatitude doubleValue];
    region.center.longitude = [smugLng doubleValue]; //[appDelegate.rootDevice.deviceLongitude doubleValue];
    region.span.latitudeDelta = 0.05;
    region.span.longitudeDelta = 0.05;
    region = [smugView regionThatFits:region];
    */
//    [smugView setRegion:region animated:TRUE];
    [smugView setCenterCoordinate:swCurCoord zoomLevel:swZoomLevel animated:TRUE];

}
//
- (void)loadbtnSMS {
	btnSMS = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnSMS setTitle:@"SMS" forState:UIControlStateNormal];
	[btnSMS setTitleColor:[UIColor colorWithRed:0.196078 green:0.309804 blue:0.521569 alpha:1.000000] forState:UIControlStateNormal];
	[btnSMS.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
	[btnSMS setBackgroundColor:[UIColor whiteColor]];
    [btnSMS setFrame:CGRectMake(5, 5, 120, 40)];
    [btnSMS addTarget:self action:@selector(sendSmugMsg) forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:btnSMS];

}


- (void)loadbtnEmail {
	btnEmail = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnEmail setTitle:@"Email" forState:UIControlStateNormal];
	[btnEmail setTitleColor:[UIColor colorWithRed:0.196078 green:0.309804 blue:0.521569 alpha:1.000000] forState:UIControlStateNormal];
	[btnEmail.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
	[btnEmail setBackgroundColor:[UIColor whiteColor]];
    [btnEmail setFrame:CGRectMake(140, 5, 120, 40)];
    [btnEmail addTarget:self action:@selector(sendSmugMail) forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:btnEmail];
}
//
- (void)loadbtnZoomIn {
	btnZoomIn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnZoomIn setTitle:@"+" forState:UIControlStateNormal];
	[btnZoomIn setTitleColor:[UIColor colorWithRed:0.196078 green:0.309804 blue:0.521569 alpha:1.000000] forState:UIControlStateNormal];
	[btnZoomIn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:24]];
	[btnZoomIn setBackgroundColor:[UIColor clearColor]];
    [btnZoomIn setFrame:CGRectMake(270, 50, 40, 40)];
    [btnZoomIn addTarget:self action:@selector(zoomIn) forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:btnZoomIn];
    
}
//
- (void)loadbtnZoomOut {
	btnZoomOut = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnZoomOut setTitle:@"-" forState:UIControlStateNormal];
	[btnZoomOut setTitleColor:[UIColor colorWithRed:0.196078 green:0.309804 blue:0.521569 alpha:1.000000] forState:UIControlStateNormal];
	[btnZoomOut.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:24]];
	[btnZoomOut setBackgroundColor:[UIColor clearColor]];
    [btnZoomOut setFrame:CGRectMake(10, 50, 40, 40)];
    [btnZoomOut addTarget:self action:@selector(zoomOut) forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:btnZoomOut];
    
}
////////////////////////////////////////////////////////////////////
-(void)zoomIn {
    [BT_debugger showIt:self theMessage:@"Zoom In..."];
    if (swZoomLevel < 18) {
        swZoomLevel = swZoomLevel + 1;
    }
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"Zoom In Level: %d", swZoomLevel]];
    [smugView setCenterCoordinate:swCurCoord zoomLevel:swZoomLevel animated:NO];
}
-(void)zoomOut {
    [BT_debugger showIt:self theMessage:@"Zoom Out..."];
    if (swZoomLevel > 5) {
        swZoomLevel = swZoomLevel - 1;
    }
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"Zoom Out Level: %d", swZoomLevel]];
    [smugView setCenterCoordinate:swCurCoord zoomLevel:swZoomLevel animated:NO];
}
////////////////////////////////////////////////////////////////////


//
-(void) loadlblDegrees {
	lblDegrees = [[UILabel alloc] init];
	[lblDegrees setFont:[UIFont fontWithName:@"Arial-BoldMT" size:32]];
	[lblDegrees setText:@""];
	[lblDegrees setTextColor:[UIColor redColor]];
	[lblDegrees setBackgroundColor:[UIColor clearColor]];
	[lblDegrees setTextAlignment:NSTextAlignmentCenter];
	[lblDegrees setLineBreakMode:NSLineBreakByTruncatingTail];
	[lblDegrees setNumberOfLines:1];
	[lblDegrees setFrame:CGRectMake(0, 55, self.view.frame.size.width, 31)];
	[[self view] addSubview:lblDegrees];
}
//
-(void) loadlblDirection {
	lblDirection = [[UILabel alloc] init];
	[lblDirection setFont:[UIFont fontWithName:@"Arial-BoldMT" size:14]];
	[lblDirection setText:@"N"];
	[lblDirection setTextColor:[UIColor blueColor]];
	[lblDirection setBackgroundColor:[UIColor clearColor]];
	[lblDirection setTextAlignment:NSTextAlignmentCenter];
	[lblDirection setLineBreakMode:NSLineBreakByTruncatingTail];
	[lblDirection setNumberOfLines:1];
	[lblDirection setFrame:CGRectMake(0, 90, self.view.frame.size.width, 31)];
	[[self view] addSubview:lblDirection];
}
//
-(void) loadlblCoordinates {
	lblCoordinates = [[UILabel alloc] init];
	[lblCoordinates setFont:[UIFont fontWithName:@"Arial-BoldMT" size:14]];
	[lblCoordinates setText:@""];
	[lblCoordinates setTextColor:[UIColor greenColor]];
	[lblCoordinates setBackgroundColor:[UIColor clearColor]];
	[lblCoordinates setTextAlignment:NSTextAlignmentCenter];
	[lblCoordinates setLineBreakMode:NSLineBreakByTruncatingTail];
	[lblCoordinates setNumberOfLines:1];
	[lblCoordinates setFrame:CGRectMake(0, 105, self.view.frame.size.width, 31)];
	[[self view] addSubview:lblCoordinates];
}
//
-(void) loadcompassBg {
	compassBg = [[UIImageView alloc] init];
	// Please ensure this image is added to the project, a random name has been used to prevent conflicts
    //	[compassBg setImage:[UIImage imageNamed:@"bkg_compass.png"]];
	[compassBg setImage:[UIImage imageNamed:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"compassBGImgFilename" defaultValue:@"sw_compass.png"]]];
	[compassBg setContentMode:UIViewContentModeCenter];
	[compassBg setFrame:CGRectMake((self.view.frame.size.width/2) - (compassBg.image.size.width / 2), 125, compassBg.image.size.width, compassBg.image.size.height)];
	[[self view] addSubview:compassBg];
}
//
-(void) loadcompassArrow {
	compassArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"compassArrowImgFilename" defaultValue:@"sw_arrow.png"]]];
    compassArrow.frame =  CGRectMake((self.view.frame.size.width/2) - (compassArrow.image.size.width /2), 135, compassArrow.image.size.width, compassArrow.image.size.height);
    compassArrow.backgroundColor = [UIColor clearColor];
    compassArrow.opaque = NO;
    [[self view] addSubview:compassArrow];
}
//
-(void) buttonPressed:(UIButton *)button {
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"Button Pressed: %@", button.titleLabel.text]];
    if (button == btnSMS) {
        [self sendSmugMsg];
    } else {
        [self sendSmugMail];
    }
}


//
-(void)displayMap{
    //put code here that adds UI controls to the screen.
    self.smugUrlData = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"smugmsgdata" defaultValue:@"http://maps.google.com/maps?q=[deviceLatitude],[deviceLongitude]"];
    self.smugEmailSubject = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"smugsubjdata" defaultValue:@"Over Here!"];
    smugLeManager=[[CLLocationManager alloc] init];
    smugLeManager.desiredAccuracy = kCLLocationAccuracyBest;
    smugLeManager.headingFilter = 0.5;
    smugLeManager.delegate=self;
    [smugLeManager startUpdatingHeading];
    smugFormat = [[NSNumberFormatter alloc]init];
    [smugFormat setPositiveFormat:@"##0.########"];
    smugDirection = @"";
    //    [self loadBackground];
    [self loadlblCoordinates];
    [self canReach];
    [self loadbtnSMS];
    [self loadbtnEmail];
    if (canReachNetwork) {
        [self goMap];
    } else {
        [self goCompass];
    }
    [self doUpdate];
}
//////
@end





