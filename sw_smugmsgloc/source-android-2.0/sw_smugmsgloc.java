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


import java.util.ArrayList;

import java.text.DecimalFormat;
import java.text.NumberFormat;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.Toast;
//smug imports
import android.annotation.SuppressLint;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.content.Intent;
import android.webkit.WebView;


@SuppressLint("SetJavaScriptEnabled")
public class sw_smugmsgloc extends BT_activity_base{


	private boolean didCreate = false;
	// smug variables
	private String smugmsgdata = "";
	private String smugsubjdata = "";
	private String smuglat = "";
	private String smuglng = "";
	private double myLat;
	private double myLng;
	private String smuglocstring = "";
	boolean gpsQueried;
	boolean netOK;
	boolean gpsOK;
	//
	private RadioGroup radioTypeGroup;
	private RadioButton msgTypeBtn;
	private Button btnSend;
	private Button btnRefresh;
	private WebView myMap;

	//////////////////////////////////////////////////////////////////////////
	//activity life-cycle events.

	//onCreate
	@Override
    public void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);
        this.activityName = "sw_smugmsgloc";
		BT_debugger.showIt(activityName + ":onCreate");	
		LinearLayout baseView = (LinearLayout)findViewById(R.id.baseView);
		BT_viewUtilities.updateBackgroundColorsForScreen(this, this.screenData);
		if(backgroundImageWorkerThread == null){
			backgroundImageWorkerThread = new BackgroundImageWorkerThread();
			backgroundImageWorkerThread.start();
		}			
		LinearLayout navBar = BT_viewUtilities.getNavBarForScreen(this, this.screenData);
		if(navBar != null){
			baseView.addView(navBar);
		}
		LayoutInflater vi = (LayoutInflater)thisActivity.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View thisScreensView = vi.inflate(R.layout.screen_sw_smugmsgloc, null);
		baseView.addView(thisScreensView);
		// End BT Stuff. It's time to Smug Out
		//
		startListening();
		getLastLocation();
		addSmugButtonEar();
		// End of Smug Routines...
        //flag as created..
        didCreate = true;
	}//onCreate

	//onStart
	@Override 
	protected void onStart() {
		BT_debugger.showIt(activityName + ":onStart");	
		super.onStart();
//		smugUpdate(); 
	}
	
    //onResume
    @Override
    public void onResume() {
       super.onResume();
       	BT_debugger.showIt(activityName + ":onResume");
		
       //verify onCreate already ran...
       if(didCreate){
    	   smugUpdate(); 
       }
       
    }
    
    //onPause
    @Override
    public void onPause() {
        super.onPause();
        BT_debugger.showIt(activityName + ":onPause");	
        stopListening();
    }
    
    //onStop
	@Override 
	protected void onStop(){
		super.onStop();
        BT_debugger.showIt(activityName + ":onStop");	
        stopListening();
	}	
	
	//onDestroy
    @Override
    public void onDestroy() {
    	stopListening();
        super.onDestroy();
        BT_debugger.showIt(activityName + ":onDestroy");	
    }
    
	//end activity life-cycle events
	//////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////
    // Smug Code
	//////////////////////////////////////////////////////////////////////////
    public void smugUpdate() {
    	BT_debugger.showIt(activityName + ":smugUpdate");
    	getLastLocation();
    	NumberFormat smugFormatter = new DecimalFormat("#0.00000");
   		smuglat = BT_appDelegate.rootApp.getRootDevice().getDeviceLatitude();
   		smuglng = BT_appDelegate.rootApp.getRootDevice().getDeviceLongitude();
   		if (smuglat != "") {
   			BT_debugger.showIt(activityName + ":smugUpdate - GPS OK");
            myLat = Double.parseDouble(smuglat);
            myLng = Double.parseDouble(smuglng);
        	smuglat = smugFormatter.format(myLat);
        	smuglng = smugFormatter.format(myLng);
        	BT_debugger.showIt(activityName + ":smugUpdateLoc formatted");	
   	   		smugsubjdata = BT_strings.getJsonPropertyValue(this.screenData.getJsonObject(), "smugsubjdata", "Over Here!");
   	   		smuglocstring = smuglat + "," + smuglng;
   	   		smugmsgdata = BT_strings.getJsonPropertyValue(this.screenData.getJsonObject(), "smugmsgdata", "http://maps.google.com/maps?hl=en&f=d&q=" + smuglocstring);
   			BT_debugger.showIt(activityName + ":smugUpdate: " + smuglat + "," + smuglng);
   			netOK = isNetworkAvailable();
   			myMap = (WebView) findViewById(R.id.smugMapView);
   			myMap.getSettings().setJavaScriptEnabled(true);		
   			smugmsgdata = smugmsgdata.replace("[deviceLatitude]", smuglat);
   			smugmsgdata = smugmsgdata.replace("[deviceLongitude]", smuglng);
   			if (netOK){
   				myMap.loadUrl(smugmsgdata);
   			}else{
   				myMap.loadData(getCoordURL(),"text/html", null);
   			}
   		}else{
   			showSettingsAlert();
   			BT_debugger.showIt(activityName + ":smugUpdate - showSettingsAlert should be shown");
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
/*	private boolean isGPSAvailable() {
		 final LocationManager manager = (LocationManager) getSystemService( Context.LOCATION_SERVICE );
		    if ( !manager.isProviderEnabled( LocationManager.GPS_PROVIDER ) ) {
		        return false;
		    } else {
		    	return true;
		    }
	} */
    /////////////////////////////////////////////////////
    private boolean isNetworkAvailable() {
        ConnectivityManager connectivityManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetworkInfo = connectivityManager.getActiveNetworkInfo();
        BT_debugger.showIt(activityName + ":isNetworkAvailable = " + activeNetworkInfo);
        return activeNetworkInfo != null;
    }
    /////////////////////////////////////////////////////
    public void showSettingsAlert(){
    	final AlertDialog.Builder builder = new AlertDialog.Builder(this);
    	builder.setTitle("This Application Requires GPS");
    	builder.setMessage("Your GPS seems to be disabled, do you want to enable it?")
    	.setCancelable(false)
    	.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
    	@Override
    		public void onClick(final DialogInterface dialog, final int id) {
    			startActivity(new Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS));
    			dialog.cancel();
    			}
    	}
    	)
    	.setNegativeButton("No", new DialogInterface.OnClickListener() {
    		public void onClick(final DialogInterface dialog, final int id) {
    			dialog.cancel();
    			finish();
    			}
    		}
    	);
    	final AlertDialog alert = builder.create();
    	alert.show();
    	gpsQueried = true;
    }
	//////////////////////////////////////////////////////////////////////////
    public void addSmugButtonEar(){
    	radioTypeGroup = (RadioGroup) findViewById(R.id.radioMsgType);
    	btnSend = (Button) findViewById(R.id.btnSend);
    	btnRefresh = (Button) findViewById(R.id.btnRefresh);
    	btnSend.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				int selectedId = radioTypeGroup.getCheckedRadioButtonId();
				msgTypeBtn = (RadioButton) findViewById(selectedId);
				Toast.makeText(thisActivity, msgTypeBtn.getText(), Toast.LENGTH_SHORT).show();
				if(msgTypeBtn.getText().equals("SMS")){
					try {
					     Intent sendIntent = new Intent(Intent.ACTION_VIEW);
					     sendIntent.putExtra("sms_body", (smugmsgdata + " ")); 
					     sendIntent.setType("vnd.android-dir/mms-sms");
					     startActivity(sendIntent);
					} catch (Exception e) {
						Toast.makeText(getApplicationContext(),
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
			@Override
			public void onClick(View v) {
				refreshAppData();
			}
    	});

    }
	// End of Smug Code
	/////////////////////////////////////////////////////
	/////////////////////////////////////////////////////
	//options menu (hardware menu-button)
	@Override 
	public boolean onPrepareOptionsMenu(Menu menu) { 
		super.onPrepareOptionsMenu(menu); 
		
		 //set up dialog
        final Dialog dialog = new Dialog(this);
        
		//linear layout holds all the options...
		LinearLayout optionsView = new LinearLayout(this);
		optionsView.setLayoutParams(new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));
		optionsView.setOrientation(LinearLayout.VERTICAL);
		optionsView.setGravity(Gravity.CENTER_VERTICAL | Gravity.CENTER_HORIZONTAL);
		optionsView.setPadding(20, 0, 20, 20); //left, top, right, bottom
		
		//options have individual layout params
		LinearLayout.LayoutParams btnLayoutParams = new LinearLayout.LayoutParams(400, LayoutParams.WRAP_CONTENT);
		btnLayoutParams.setMargins(10, 10, 10, 10);
		btnLayoutParams.leftMargin = 10;
		btnLayoutParams.rightMargin = 10;
		btnLayoutParams.topMargin = 0;
		btnLayoutParams.bottomMargin = 10;
		
		//holds all the options 
		ArrayList<Button> options = new ArrayList<Button>();

		//cancel...
		final Button btnCancel = new Button(this);
		btnCancel.setText(getString(R.string.okClose));
		
		btnCancel.setOnClickListener(new OnClickListener(){
            public void onClick(View v){
                dialog.cancel();
            }
        });
		options.add(btnCancel);

		//refreshAppData (if we are on home screen)
		if(this.screenData.isHomeScreen() && BT_appDelegate.rootApp.getDataURL().length() > 1){
			
			final Button btnRefreshAppData = new Button(this);
			btnRefreshAppData.setText(getString(R.string.refreshAppData));
			btnRefreshAppData.setOnClickListener(new OnClickListener(){
	            public void onClick(View v){
	                dialog.cancel();
	                refreshAppData();
	            }
	        });
			options.add(btnRefreshAppData);			
		}		
		
		//add each option to layout, set layoutParams as we go...
		for(int x = 0; x < options.size(); x++){
			options.get(x).setLayoutParams(btnLayoutParams);
			options.get(x).setPadding(5, 5, 5, 5);
			optionsView.addView(options.get(x));
		}
		
		//set content view..        
        dialog.setContentView(optionsView);
        if(options.size() > 1){
        	dialog.setTitle(getString(R.string.menuOptions));
        }else{
        	dialog.setTitle(getString(R.string.menuNoOptions));
        }
        
        //show
        dialog.show();
		return true;
		
	} 
	//end options menu
	/////////////////////////////////////////////////////	
	
}


 
