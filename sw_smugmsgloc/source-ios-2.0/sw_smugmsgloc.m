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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JSON.h"
#import "BT_application.h"
#import "BT_strings.h"
#import "BT_viewUtilities.h"
#import "BT_appDelegate.h"
#import "BT_item.h"
#import "BT_debugger.h"
#import "BT_viewControllerManager.h"
#import "sw_smugmsgloc.h"
//
@implementation sw_smugmsgloc
//
@synthesize smugUrlData, smugEmailSubject, smugLat, smugLng, canReachNetwork;
@synthesize smugDirection, smugCoordinates, smugDegrees, smugFormat;
//
@synthesize smugLeManager;
//
-(void)doUpdate {
   	BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
    smugLat = appDelegate.rootApp.rootDevice.deviceLatitude;
    smugLng = appDelegate.rootApp.rootDevice.deviceLongitude;
    self.objWidth = self.view.frame.size.width;
    self.objHeight = self.view.frame.size.height;
    smugCoordinates = [smugLat stringByAppendingString:@","];
    smugCoordinates = [smugCoordinates stringByAppendingString:smugLng];
    [btnSend setFrame:CGRectMake(5, 5, self.objWidth - 10, 40)];
	[smsOrEmail setFrame:CGRectMake(5, 50, self.objWidth - 10, 35)];
    [lblDirection setText:smugDirection];
    [lblCoordinates setText:smugCoordinates];
    NSString *tabCount = [NSString stringWithFormat:@"%d", [appDelegate.rootApp.tabs count]];
    [BT_debugger showIt:self theMessage:@"tabsCount"];
    [BT_debugger showIt:self theMessage:tabCount];
    //
    if([appDelegate.rootApp.tabs count] == 0){
    }else{
        self.mapHeight = (self.view.frame.size.height - 90);
    }
    [smugView setFrame:CGRectMake(5, 90, self.objWidth - 10, self.view.frame.size.height - 110)];
    MKCoordinateRegion region;
    region.center.latitude = [appDelegate.rootApp.rootDevice.deviceLatitude doubleValue];
    region.center.longitude = [appDelegate.rootApp.rootDevice.deviceLongitude doubleValue];
    region.span.latitudeDelta = 0.05;
    region.span.longitudeDelta = 0.05;
    region = [smugView regionThatFits:region];
    [smugView setRegion:region animated:TRUE];
    smsOrEmail.selectedSegmentIndex = 0;
	[lblDegrees setFrame:CGRectMake(0, 60, self.view.frame.size.width, 31)];
	[lblDirection setFrame:CGRectMake(0, 80, self.view.frame.size.width, 31)];
    [compassBg setFrame:CGRectMake((self.view.frame.size.width/2) - (compassBg.image.size.width / 2), 135, compassBg.image.size.width, compassBg.image.size.height)];
	[lblCoordinates setFrame:CGRectMake(0, (self.view.frame.size.height - 25), self.view.frame.size.width, 31)];
    if ( canReachNetwork == false) {
        smsOrEmail.selectedSegmentIndex = 0;
    }
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
    [self doUpdate];
}
//
-(void) layoutScreen {
    [self doUpdate];
}
//
-(void) canReach {
    Reachability *r = [Reachability reachabilityWithHostName:@"m.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachable){
        // no connection
        canReachNetwork = FALSE;
    }else{
        // connection
        canReachNetwork = TRUE;
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
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if(mailClass != nil){
		if([mailClass canSendMail]){
			BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
            smugLat = appDelegate.rootApp.rootDevice.deviceLatitude;
            smugLng = appDelegate.rootApp.rootDevice.deviceLongitude;
            BT_navigationController *theNavController = [appDelegate getNavigationController];
            BT_viewController *theViewController = [appDelegate getViewController];
			MFMailComposeViewController *picker = [[[MFMailComposeViewController alloc] init] autorelease];
			picker.mailComposeDelegate = theViewController;
			[picker setToRecipients:nil];
            NSString *tmpBody = self.smugUrlData;
            tmpBody = [tmpBody stringByReplacingOccurrencesOfString: @"[deviceLatitude]" withString:smugLat];
            tmpBody = [tmpBody stringByReplacingOccurrencesOfString: @"[deviceLongitude]" withString:smugLng];
			[picker setSubject: self.smugEmailSubject];
			NSString *emailBody = tmpBody;
			[picker setMessageBody:emailBody isHTML:NO];
            [theNavController presentViewController:picker animated:YES completion:nil];
            [picker.navigationBar setTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:screenData]];
		}//can send mail
	}else{
        
        [self showAlert:@"Email Not Available" theMessage:@"Your device cannot send Email Messages" alertTag:01];

        
    }
}
//
-(void) sendSmugMsg { // Bracket 1
   	BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
    smugLat = appDelegate.rootApp.rootDevice.deviceLatitude;
    smugLng = appDelegate.rootApp.rootDevice.deviceLongitude;
	if([appDelegate.rootApp.rootDevice canSendSMS]){
		Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));
		if(smsClass != nil && [MFMessageComposeViewController canSendText]){
            MFMessageComposeViewController *picker = [[[MFMessageComposeViewController alloc] init] autorelease];
			if([MFMessageComposeViewController canSendText]){
                 
                BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
                BT_navigationController *theNavController = [appDelegate getNavigationController];
                BT_viewController *theViewController = theViewController;
				
                picker.messageComposeDelegate = theViewController;
                picker.recipients = [NSArray arrayWithObjects: nil,  nil, nil];
                
                NSString *tmpBody = self.smugUrlData;
                tmpBody = [tmpBody stringByReplacingOccurrencesOfString: @"[deviceLatitude]" withString:smugLat];
                tmpBody = [tmpBody stringByReplacingOccurrencesOfString: @"[deviceLongitude]" withString:smugLng];
                picker.body = tmpBody;
                
				//show it
                [theNavController presentViewController:picker animated:YES completion:nil];
                [picker.navigationBar setTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:screenData]];
			
                 
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
    [self loadSegmentButton];
    [self loadMapView];
}
//
-(void) loadSegmentButton {
    smsOrEmail = [[UISegmentedControl alloc] init];
	[smsOrEmail setSegmentedControlStyle:UISegmentedControlStyleBar];
	[smsOrEmail insertSegmentWithTitle:@"eMail" atIndex:0 animated:NO];
	[smsOrEmail insertSegmentWithTitle:@"SMS" atIndex:0 animated:NO];
	[smsOrEmail setSelectedSegmentIndex:0];
    [smsOrEmail addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
	[smsOrEmail setFrame:CGRectMake(5, 50, self.objWidth - 10, 35)];
	[[self view] addSubview:smsOrEmail];
	[smsOrEmail release];
}
//
-(void) loadMapView {
   	BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
    smugView = [[MKMapView alloc] init];
    [smugView setShowsUserLocation:YES];
    [smugView setMapType:MKMapTypeHybrid];
    [smugView setFrame:CGRectMake(10, 90, 300, 300)];
    
    [smugView.layer setMasksToBounds:YES];
    [smugView.layer setCornerRadius:10.0];
    
    [[self view] addSubview:smugView];
    MKCoordinateRegion region;
    //
    region.center.latitude = [appDelegate.rootApp.rootDevice.deviceLatitude doubleValue];
    region.center.longitude = [appDelegate.rootApp.rootDevice.deviceLongitude doubleValue];
    region.span.latitudeDelta = 0.05;
    region.span.longitudeDelta = 0.05;
    region = [smugView regionThatFits:region];
    [smugView setRegion:region animated:TRUE];
    [smugView release];
}
//
-(void) loadBtnSend {
    btnSend = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnSend setTitle:@"Send SMS" forState:UIControlStateNormal];
	[btnSend setTitleColor:[UIColor colorWithRed:0.196078 green:0.309804 blue:0.521569 alpha:1.000000] forState:UIControlStateNormal];
	[btnSend.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
	[btnSend setBackgroundColor:[UIColor whiteColor]];
	[btnSend addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[btnSend setFrame:CGRectMake(10, 6, 300, 50)];
	[[self view] addSubview:btnSend];
}
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
	[lblDegrees release];
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
	[lblDirection release];
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
	[lblCoordinates release];
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
	[compassBg release];
}
//
-(void) loadcompassArrow {
	compassArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"compassArrowImgFilename" defaultValue:@"sw_arrow.png"]]];
    compassArrow.frame =  CGRectMake((self.view.frame.size.width/2) - (compassArrow.image.size.width /2), 135, compassArrow.image.size.width, compassArrow.image.size.height);
    compassArrow.backgroundColor = [UIColor clearColor];
    compassArrow.opaque = NO;
    [[self view] addSubview:compassArrow];
    [compassArrow release];
}
//
-(void) segmentedControlAction:(id)sender {
    
    switch (((UISegmentedControl *) sender).selectedSegmentIndex) {
        case 0:
            NSLog(@"Button_Pushed: seg0");
            [btnSend setTitle:@"Send SMS" forState:UIControlStateNormal];
            break;
        case 1:
            NSLog(@"Button_Pushed: seg1");
            [btnSend setTitle:@"Send Email" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}
//
-(void) buttonPressed:(UIButton *)button {
    if (button == btnSend) {
        if (smsOrEmail.selectedSegmentIndex == 0) {
            NSLog(@"Button_Pushed: SMS");
            [self sendSmugMsg];
        } else {
            NSLog(@"Button_Pushed: Email");
            [self sendSmugMail];
        }
    }
}

//
-(void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[BT_debugger showIt:self theMessage:@"viewWillAppear"];
	BT_appDelegate *appDelegate = (BT_appDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.rootApp.currentScreenData = self.screenData;
	[BT_viewUtilities configureBackgroundAndNavBar:self theScreenData:[self screenData]];
}

//
-(void) viewDidLoad{
	[BT_debugger showIt:self theMessage:@"viewDidLoad"];
	[super viewDidLoad];
	
    [self performSelector:(@selector(displayMap)) withObject:nil afterDelay:0.2];
    
    //create adView?
	if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"includeAds" defaultValue:@"0"] isEqualToString:@"1"]){
	   	[self createAdBannerView];
	}
}

//
-(void)displayMap{
    //put code here that adds UI controls to the screen.
    self.smugUrlData = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"smugmsgdata" defaultValue:@"http://maps.google.com/maps?hl=en&f=d&q=[deviceLatitude],[deviceLongitude]"];
    self.smugEmailSubject = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"smugsubjdata" defaultValue:@"Over Here!"];
    smugLeManager=[[CLLocationManager alloc] init];
    smugLeManager.desiredAccuracy = kCLLocationAccuracyBest;
    smugLeManager.headingFilter = 0.5;
    smugLeManager.delegate=self;
    [smugLeManager startUpdatingHeading];
    smugFormat = [[NSNumberFormatter alloc]init];
    [smugFormat setPositiveFormat:@"##0.######"];
    smugDirection = @"";
    //    [self loadBackground];
    [self loadBtnSend];
    [self loadlblCoordinates];
    [self canReach];
    if (canReachNetwork) {
        [self goMap];
    } else {
        [self goCompass];
    }
    [self doUpdate];
}


//
-(void) dealloc {
    [super dealloc];
    [smsOrEmail dealloc];
    [btnSend dealloc];
    [smugView dealloc];
    [lblDegrees dealloc];
    [lblDirection dealloc];
    [lblCoordinates dealloc];
    [compassArrow dealloc];
    [compassBg dealloc];
    [compassContainer dealloc];
    [smugFormat dealloc];
    [smugUrlData dealloc];
    [smugEmailSubject dealloc];
    [smugLocation dealloc];
    [smugDegrees dealloc];
    [smugDirection dealloc];
    [smugCoordinates dealloc];
    [smugLeManager dealloc];
    canReachNetwork = nil;
}
//
@end





