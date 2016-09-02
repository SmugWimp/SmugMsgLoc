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
package com.buzzTouch;


import java.text.DecimalFormat;
import java.text.NumberFormat;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Toast;


@SuppressLint("SetJavaScriptEnabled")
public class sw_smugmsgloc extends BT_fragment{


	public boolean didCreate = false;
	// smug variables
	public String smugmsgdata = "";
	public String smugsubjdata = "";
	public String smuglat = "";
	public String smuglng = "";
	public double myLat;
	public double myLng;
	public String smuglocstring = "";
	boolean gpsQueried;
	boolean netOK;
	boolean gpsOK;
	//
	public RadioGroup radioTypeGroup;
	public RadioButton msgTypeBtn;
	public Button btnSend;
	public Button btnRefresh;
	public WebView myMap;
	
	
	public View screenView;

	//onCreateView...
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,  Bundle savedInstanceState){
	       
		/*
			Note: fragmentName property is already setup in the parent class (BT_fragment). This allows us 
			to add the 	name of this class file to the LogCat console using the BT_debugger.
		*/
		//show life-cycle event in LogCat console...
		BT_debugger.showIt(fragmentName + ":onCreateView JSON itemId: \"" + screenData.getItemId() + "\" itemType: \"" + screenData.getItemType() + "\" itemNickname: \"" + screenData.getItemNickname() + "\"");
		
		//inflate the layout file for this screen...
		View thisScreensView = inflater.inflate(R.layout.sw_smugmsgloc, container, false);
		screenView = thisScreensView;
		
		// End BT Stuff. It's time to Smug Out
		//
		((BT_activity_host)getActivity()).startListeningForLocationUpdate();
		((BT_activity_host)getActivity()).getLastGPSLocation();
		addSmugButtonEar();
		
		// End of Smug Routines...
        //flag as created..
        didCreate = true;
        
        //return...
        return thisScreensView;
        
	}//onCreateView...

	//onStart
	@Override 
	public void onStart() {
		BT_debugger.showIt(fragmentName + ":onStart");	
		super.onStart();
//		smugUpdate(); 
	}
	
    //onResume
    @Override
    public void onResume() {
       super.onResume();
       	BT_debugger.showIt(fragmentName + ":onResume");
		
       //verify onCreateView already ran...
       if(didCreate){
    	   smugUpdate(); 
       }
       
    }
    
    //onPause
    @Override
    public void onPause() {
        super.onPause();
        BT_debugger.showIt(fragmentName + ":onPause");	
        ((BT_activity_host)getActivity()).stopListeningForLocationUpdate();
    }
    
    //onStop
	@Override 
	public void onStop(){
		super.onStop();
        BT_debugger.showIt(fragmentName + ":onStop");	
        ((BT_activity_host)getActivity()).stopListeningForLocationUpdate();
	}	
	
	//onDestroy
    @Override
    public void onDestroy() {
    	((BT_activity_host)getActivity()).stopListeningForLocationUpdate();
        super.onDestroy();
        BT_debugger.showIt(fragmentName + ":onDestroy");	
    }
    
	//end activity life-cycle events
	//////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////
    // Smug Code
	//////////////////////////////////////////////////////////////////////////
    public void smugUpdate() {
    	BT_debugger.showIt(fragmentName + ":smugUpdate");
    	((BT_activity_host)getActivity()).getLastGPSLocation();
    	NumberFormat smugFormatter = new DecimalFormat("#0.00000");
   		smuglat = BT_appDelegate.rootApp.getRootDevice().getDeviceLatitude();
   		smuglng = BT_appDelegate.rootApp.getRootDevice().getDeviceLongitude();
   		if (smuglat != "") {
   			BT_debugger.showIt(fragmentName + ":smugUpdate - GPS OK");
            myLat = Double.parseDouble(smuglat);
            myLng = Double.parseDouble(smuglng);
        	smuglat = smugFormatter.format(myLat);
        	smuglng = smugFormatter.format(myLng);
        	BT_debugger.showIt(fragmentName + ":smugUpdateLoc formatted");	
   	   		smugsubjdata = BT_strings.getJsonPropertyValue(this.screenData.getJsonObject(), "smugsubjdata", "Over Here!");
   	   		smuglocstring = smuglat + "," + smuglng;
   	   		smugmsgdata = BT_strings.getJsonPropertyValue(this.screenData.getJsonObject(), "smugmsgdata", "http://maps.google.com/maps?hl=en&f=d&q=" + smuglocstring);
   			smugmsgdata = smugmsgdata.replace("[deviceLatitude]", smuglat);
   			smugmsgdata = smugmsgdata.replace("[deviceLongitude]", smuglng);
   	   		
   	   		BT_debugger.showIt(fragmentName + ":smugUpdate: " + smuglat + "," + smuglng);
   			netOK = isNetworkAvailable();
   			myMap = (WebView) screenView.findViewById(R.id.smugMapView);
   			myMap.getSettings().setJavaScriptEnabled(true);		
   		
   			//setup WebViewClient to device doesn't launch map url in Google Maps app...
   			myMap.setWebViewClient(new WebViewClient() {
   	            public void onReceivedError(WebView view, int errorCode, String description, String failingUrl){
   	                Toast.makeText(getActivity(), description, Toast.LENGTH_SHORT).show();
   	            }
   	        });   			
   			
   			if(netOK){
   				myMap.loadUrl(smugmsgdata);
   			}else{
   				myMap.loadData(getCoordURL(),"text/html", null);
   			}
   		
   		}else{
//   			showSettingsAlert();
            Toast.makeText(BT_appDelegate.getApplication(),
                           "No GPS Signal detected. Please check your settings!",
                           Toast.LENGTH_LONG).show();
   			BT_debugger.showIt(fragmentName + ":smugUpdate - showSettingsAlert should be shown");
   		}
    }
    
    /////////////////////////////////////////////////////
	private String getCoordURL() {
		String MyString = "";
		MyString = "<!DOCTYPE html><html><head>";
		MyString = MyString + "<title>No Data Connection</title>";
		MyString = MyString + "</head><body><center>";
		MyString = MyString + "<h3>No internet connection is available at the moment.<p />";
		MyString = MyString + "No Map will display, but you are currently ";
		MyString = MyString + "located at (Lat) " + smuglat + " and (Lng) " + smuglng;			
		MyString = MyString + ".<p />Please use SMS; Email transport is not currently available.</h3>";
		MyString = MyString + "</center></body></html>";
		return MyString;
	}
	//////////////////////////////////////////////////////

	
	/////////////////////////////////////////////////////
    private boolean isNetworkAvailable() {
        ConnectivityManager connectivityManager = (ConnectivityManager) this.getActivity().getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetworkInfo = connectivityManager.getActiveNetworkInfo();
        BT_debugger.showIt(fragmentName + ":isNetworkAvailable = " + activeNetworkInfo);
        return activeNetworkInfo != null;
    }
    /////////////////////////////////////////////////////
    public void showSettingsAlert(){
    	final AlertDialog.Builder builder = new AlertDialog.Builder(this.getActivity());
    	builder.setTitle("This Application Requires GPS");
    	builder.setMessage("Your GPS seems to be disabled, do you want to enable it?")
    	.setCancelable(false)
    	.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
    		public void onClick(final DialogInterface dialog, final int id) {
    			startActivity(new Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS));
    			dialog.cancel();
    			}
    	}
    	)
    	.setNegativeButton("No", new DialogInterface.OnClickListener() {
    		public void onClick(final DialogInterface dialog, final int id) {
    			dialog.cancel();
    			((BT_activity_host)getActivity()).onBackPressed();
    			}
    		}
    	);
    	final AlertDialog alert = builder.create();
    	alert.show();
    	gpsQueried = true;
    }
	//////////////////////////////////////////////////////////////////////////
    public void addSmugButtonEar(){

		radioTypeGroup = (RadioGroup) screenView.findViewById(R.id.radioMsgType);
    	btnSend = (Button) screenView.findViewById(R.id.btnSend);
    	btnRefresh = (Button) screenView.findViewById(R.id.btnRefresh);
    	btnSend.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				int selectedId = radioTypeGroup.getCheckedRadioButtonId();
				msgTypeBtn = (RadioButton) screenView.findViewById(selectedId);
				Toast.makeText(BT_appDelegate.getApplication(), msgTypeBtn.getText(), Toast.LENGTH_SHORT).show();
				if(msgTypeBtn.getText().equals("SMS")){
					try {
					     Intent sendIntent = new Intent(Intent.ACTION_VIEW);
					     sendIntent.putExtra("sms_body", (smugmsgdata + " ")); 
					     sendIntent.setType("vnd.android-dir/mms-sms");
					     startActivity(sendIntent);
					} catch (Exception e) {
						Toast.makeText(BT_appDelegate.getApplication(),
							"SMS failed, please try again later!",
							Toast.LENGTH_LONG).show();
						e.printStackTrace();
					}
				} else { 
					  Intent email = new Intent(Intent.ACTION_SEND);
					  email.putExtra(Intent.EXTRA_EMAIL, new String[]{ ""});
					  //email.putExtra(Intent.EXTRA_CC, new String[]{ to});
					  //email.putExtra(Intent.EXTRA_BCC, new String[]{to});
					  email.putExtra(Intent.EXTRA_SUBJECT, smugsubjdata);
					  email.putExtra(Intent.EXTRA_TEXT, smugmsgdata + " ");
					  //need this to prompts email client only
					  email.setType("message/rfc822");
					  startActivity(Intent.createChooser(email, "Choose an Email client :"));
				}
			}
    	});
    	
    	btnRefresh.setOnClickListener(new OnClickListener() {
			public void onClick(View v){
				((BT_activity_host)getActivity()).refreshAppData();
			}
    	});

    }


	
}


 
