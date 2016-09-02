v1.9 June 15th 2014

This plugin allows a user to either SMS or eMail their Geo Location 
(LAT/LNG) coordinates to another phone or email address. Results are provided in a simple
'Google Map' URL so recipients can just tap on the link.

******************************************************************
*   GPS *MUST* Be enabled in order for this to work correctly.   *
* Failure to utilize GPS will result in incorrect or no reading. *
******************************************************************

** It is REQUIRED that you Enable GPS (Start Tracking Location:Turn on GPS) 
via the 'Core' page of your BT App control panel. **

The SMS Compose Screen WILL NOT SHOW ON THE SIMULATOR. SMS IS ONLY AVAILABLE ON ACTUAL DEVICES.

If a network is available, it will display the user location in a Google Map Window.
If a network is not available, it will display a compass with coordinates, direction, and azimuth (iOS only for now).
Default graphics (compass background and compass arrow) are provided. Substitutions can be made via the control panel.
Graphics must be the same size "rectangle". Use transparency in your arrow graphic to emulate a smaller item.

(although the compass should still work regardless)

SMS/eMail your stranded car location to the Police or Towing Company
SMS/eMail your calmed Sailboat location to the Coast Guard
SMS/eMail your location to the Forestry service
SMS/eMail your location for pickup
SMS/eMail your location to yourself before leaving your vehicle in a large parking area.
SMS/eMail your location to your friends; have them join you for dinner.
SMS/eMail your location as part of a high-tech hide and seek game.
SMS/eMail your location for any reason your imagination can conjecture.

Android Specific Notes:
There is no Compass Function on Android at this time.
It uses a WebView, Not MapView; a Google API is NOT required.

iOS Specific Notes:
I'm afraid I had to use Apple Maps. Sorry, lol! But no Google API required.

v1.1 fixes a few errant issues such as:

1) default arrow image is correctly sized for the proper alignment with background.
2) test phone numbers removed.
3) sms dialog box can be cancelled out.

v1.2 adds and fixes a couple of things...

1) renamed files to match BT convention (sw_smugmsgloc)
2) added support for iAds, Search, and BG Sounds
3) cleaned up a bit of code to make it a little more efficient.

v1.3 basically preps for the new Market, as well as Xcode 5.

1) Cleaned it up for Xcode 5
2) Prepared for new Control Panel/Plugin Distribution Protocol
3) Cleaned up the images for better compatibility in alignment.
4) A recent update merely changed titles in the control panel.

v1.4 fixes a few things forgotten/not noticed before.

1) Fixed deprecated methods (Thanks for letting me know, fusionsch!)
2) Added iAds and Background Audio, just in case.

v1.5 fixes a glaring problem induced by the developer

1) Changed project to BT_appDelegate rather than my test project (thanks AussieRyan!)

v1.6 fixes a few iOS7 gotchas, and changes a bit of functionality

1) Segmented button/Send Button has been replaced by separate buttons for Email and SMS
2) Allows Email Msg without network (It queues)
3) Added Zoom In/Out capability (Still kinda centers on the user though…)
4) All of the above changes for BTv3 iOS 7 only.

v1.7 fixes a couple of iOS and Android issues that remain…

1) Changed GPS Alert to 'Toast' in Android v3
2) Changed iOS 'initial' location method.

v1.8 fixes a couple of iOS 'oops' and 'forgets' such as:

1) Setting it up to Zoom over the users region automatically before view
2) In accomplishing the above, it doesn't start out over the ocean. Oops.
3) Tries to obtain Device last known coordinates before jumping to conclusions.

v1.9 corrects a change in Googles query for web browsers…

1) change query string to http://maps.google.com/maps?q=[deviceLatitude],[deviceLongitude]
2) extended parameters to accept an 8 digit accuracy (xxx.xxxxxxxx)

iOS Project
------------------------
sw_smugmsgloc.h
sw_smugmsgloc.m
MKMapView+ZoomLevel.hMKMapView+ZoomLevel.m
sw_arrow.png
sw_compass.png

Android Project
------------------------
sw_smugmsgloc.java
sw_screen_smugmsgloc.xml


JSON Data
------------------------
{
"itemId":"SMUGWIMP_PMIWGUMS",
"itemType":"sw_smugmsgloc",
"itemNickname":"SmugMessageLocation",
"smugsubjdata":"Over Here!",
"smugmsgdata":"http://maps.google.com/maps?q=[deviceLatitude],[deviceLongitude]",
"navBarTitleText":"Over Here!",
"navBarBackgroundColor":"#333333", 
"navBarStyle":"solid", 
"backgroundColor":"#00FFFF", 
"backgroundImageNameSmallDevice":"mySmallImage.png", 
"backgroundImageNameLargeDevice":"myBigImage.jpg", 
"backgroundImageScale":"center",
"audioFileName":"audiofile.mp3", 
"audioNumberOfLoops":"1", 
"audioStopsOnScreenExit":"1",
"loginRequired":"0", 
"hideFromSearch":"0"
}