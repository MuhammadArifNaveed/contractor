package com.thecontractor;

import androidx.annotation.NonNull;
import androidx.appcompat.content.res.AppCompatResources;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.FragmentActivity;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.libraries.places.api.Places;
import com.google.android.libraries.places.api.model.Place;
import com.google.android.libraries.places.api.net.PlacesClient;
import com.google.android.libraries.places.widget.Autocomplete;
import com.google.android.libraries.places.widget.model.AutocompleteActivityMode;
import com.thecontractor.Global.GpsUtils;

import java.text.DecimalFormat;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

public class MapsActivity extends FragmentActivity implements OnMapReadyCallback {

    private GoogleMap mMap;
    SupportMapFragment mapFragment;
    private PlacesClient placesClient;
    TextView currentAddress;
    TextView customLocationImg;
    Button selectLocationBtn;
    LatLng selectedLatLng;

    private FusedLocationProviderClient mFusedLocationClient;
    private LocationRequest locationRequest;
    private LocationCallback locationCallback;
    private boolean isGPS = false;
    private double wayLatitude = 0.0, wayLongitude = 0.0;
    Location mLastKnownLocation;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_maps);

        initiate();
        selectLocationBtnClickListener();
        gpsClickListener();
        currentAddressClickListener();
    }


    private void initiate() {


        mFusedLocationClient = LocationServices.getFusedLocationProviderClient(this);


        mapFragment = (SupportMapFragment) getSupportFragmentManager()
                .findFragmentById(R.id.map);
        mapFragment.getMapAsync(this);

        Places.initialize(getApplicationContext(), getResources().getString(R.string.map_key));
        placesClient = com.google.android.libraries.places.api.Places.createClient(this);

        currentAddress = (TextView) findViewById(R.id.currentAddress);
        currentAddress.setCompoundDrawablesWithIntrinsicBounds(AppCompatResources.getDrawable(MapsActivity.this,R.drawable.ic_search), null, null, null);
        selectLocationBtn = (Button) findViewById(R.id.selectLocationBtn);
        customLocationImg = (TextView) findViewById(R.id.customLocationImg);

    }

    public void checkGPSAndLocationPermission()
    {
        locationRequest = LocationRequest.create();
        locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
        locationRequest.setInterval(10 * 1000); // 10 seconds
        locationRequest.setFastestInterval(5 * 1000); // 5 seconds

        new GpsUtils(this).turnGPSOn(new GpsUtils.onGpsListener() {
            @Override
            public void gpsStatus(boolean isGPSEnable) {
                // turn on GPS
                isGPS = isGPSEnable;
                Log.e("tag" , "gps value is : "+isGPS);

                if(isGPS)
                {
                    getLocation();
                }
            }
        });

        locationCallback = new LocationCallback() {
            @Override
            public void onLocationResult(LocationResult locationResult) {
                if (locationResult == null) {
                    return;
                }
                for (Location location : locationResult.getLocations()) {
                    if (location != null) {

                        mLastKnownLocation = location;

                        wayLatitude = location.getLatitude();
                        wayLongitude = location.getLongitude();

                        selectedLatLng = new LatLng(mLastKnownLocation.getLatitude(),  mLastKnownLocation.getLongitude());


                        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(mLastKnownLocation.getLatitude(), mLastKnownLocation.getLongitude()) , 15));


                        Log.e("tag" , "lat is in call back: "+wayLatitude);
                        Log.e("tag" , "lng is in call back: "+wayLongitude);


                    }
                }
            }
        };

    }


    private void getLocation() {
        if (ActivityCompat.checkSelfPermission(MapsActivity.this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                && ActivityCompat.checkSelfPermission(MapsActivity.this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(MapsActivity.this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION},
                    1001);

        } else {

            mFusedLocationClient.getLastLocation().addOnSuccessListener(MapsActivity.this, location -> {
                if (location != null) {

                    mLastKnownLocation = location;


                    wayLatitude = location.getLatitude();
                    wayLongitude = location.getLongitude();

                    selectedLatLng = new LatLng(mLastKnownLocation.getLatitude(),  mLastKnownLocation.getLongitude());


                    mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(mLastKnownLocation.getLatitude(), mLastKnownLocation.getLongitude()) , 15));


                    Log.e("tag" , "lat is in addOnSuccessListener: "+wayLatitude);
                    Log.e("tag" , "lng is in addOnSuccessListener: "+wayLongitude);

                } else {
                    mFusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, null);
                }
            });

        }
    }

    @SuppressLint("MissingPermission")
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case 1000: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {


                    mFusedLocationClient.getLastLocation().addOnSuccessListener(MapsActivity.this, location -> {
                        if (location != null) {
                            wayLatitude = location.getLatitude();
                            wayLongitude = location.getLongitude();

                            mLastKnownLocation = location;

                            selectedLatLng = new LatLng(mLastKnownLocation.getLatitude(),  mLastKnownLocation.getLongitude());


                            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(mLastKnownLocation.getLatitude(), mLastKnownLocation.getLongitude()) , 15));



                            Log.e("tag" , "lat is in addOnSuccessListener: "+wayLatitude);
                            Log.e("tag" , "lng is in addOnSuccessListener: "+wayLongitude);

                        } else {
                            mFusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, null);
                        }
                    });

                } else {
                    Toast.makeText(this, "Permission denied", Toast.LENGTH_SHORT).show();
                }
                break;
            }
        }
    }



    public void selectLocationBtnClickListener()
    {
        selectLocationBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                if (selectedLatLng!=null) {

                    double lat = selectedLatLng.latitude;
                    double lang = selectedLatLng.longitude;

                    Log.e("tag" , "lat is select btn : "+lat);
                    Log.e("tag" , "lang is select btn : "+lang);


                    Intent intent = new Intent();
                    intent.putExtra("lat", lat);
                    intent.putExtra("lng", lang);
                    setResult(RESULT_OK, intent);
                    finish();

                }
                else
                {
                    Toast.makeText(MapsActivity.this, "Error! Please Specify your location again", Toast.LENGTH_SHORT).show();
                }
            }
        });
    }


    public void gpsClickListener()
    {
        customLocationImg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                checkGPSAndLocationPermission();
                if (mLastKnownLocation != null) {
                    LatLng currentLatLng = new LatLng(mLastKnownLocation.getLatitude(), mLastKnownLocation.getLongitude());
                    mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(currentLatLng, 15));
                }

            }
        });
    }

    public void currentAddressClickListener() {

        currentAddress.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startAutocompleteActivity();
            }
        });
    }



    private void startAutocompleteActivity() {

        // Set the fields to specify which types of place data to return.
        List<Place.Field> fields = Arrays.asList(Place.Field.ID, Place.Field.NAME, Place.Field.ADDRESS, Place.Field.LAT_LNG);
        // Start the autocomplete intent.
        Intent intent = new Autocomplete.IntentBuilder(
                AutocompleteActivityMode.FULLSCREEN, fields).setCountry("AE")
                .build(this);
        startActivityForResult(intent, 100);

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == 100) {

            if (resultCode == RESULT_OK) {

                Place place = Autocomplete.getPlaceFromIntent(data);
                selectedLatLng = place.getLatLng();
                String address = place.getAddress();


                Log.e("tag", "address is : " + address);

                mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(selectedLatLng, 15));
                mMap.animateCamera(CameraUpdateFactory.zoomTo(15), 2000, null);


                Log.e("tag", "Place: " + place.getName() + ", " + place.getId());

            }

        } else if (requestCode == 1000) {

            if (resultCode == RESULT_OK) {

                isGPS = true; // flag maintain before get location

                getLocation();

            }
            else
            {
                Log.e("tag" , "GPS not on");
                alert();
            }
        }

    }


    public void alert()
    {

        AlertDialog.Builder builder1 = new AlertDialog.Builder(MapsActivity.this);
        builder1.setCancelable(false);
        builder1.setTitle("Alert");
        builder1.setMessage("Turn on your GPS to use this App");

        builder1.setPositiveButton(
                "Yes",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        dialog.dismiss();
                        checkGPSAndLocationPermission();
                    }
                });

        builder1.setNegativeButton(
                "No",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        dialog.dismiss();
                        finish();

                    }
                });

        AlertDialog alert11 = builder1.create();
        alert11.show();

    }




    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;

        checkGPSAndLocationPermission();
        updateLocationUI();
        cameraIdleListener();
    }




    public void cameraIdleListener()
    {
        if (isGPS) {

            mMap.setOnCameraIdleListener(new GoogleMap.OnCameraIdleListener() {
                @Override
                public void onCameraIdle() {

                    double changePickUpLat = mMap.getCameraPosition().target.latitude;
                    double changePickUpLng = mMap.getCameraPosition().target.longitude;
                    Log.e("tag", "the current postion on marker lat is: " + changePickUpLat);
                    Log.e("tag", "the current postion on marker lng is: " + changePickUpLng);

                    selectedLatLng = new LatLng(changePickUpLat, changePickUpLng);


                    Location location = new Location("");

                    location.setLatitude(selectedLatLng.latitude);//your coords of course
                    location.setLongitude(selectedLatLng.longitude);


                    getAddress(selectedLatLng.latitude , selectedLatLng.longitude);

                }
            });

        }
    }


    private String getAddress(double LATITUDE, double LONGITUDE) {
        String address = "";
        Geocoder geocoder = new Geocoder(this, Locale.getDefault());
        try {
            List<android.location.Address> addressList = geocoder.getFromLocation(LATITUDE, LONGITUDE, 1);
            if (addressList != null) {
                Address returnedAddress = addressList.get(0);
                Log.e("tag", "My Current address returnedAddress : " + returnedAddress);

                address = addressList.get(0).getAddressLine(0);
                currentAddress.setText(address);


                Log.e("tag", "My Complete address is : " + address);

            } else {
                address = "unknown address";
                currentAddress.setText(address);

                Log.e("tag", "My Current address No Address returned!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            address = "unknown address";
            currentAddress.setText(address);
            Log.e("tag", "My Current address Cannnot get Address!");
        }
        return address;
    }


    private void getAddress(Location location) {
        if (location != null) {
            Geocoder geocoder;
            List<android.location.Address> addresses = null;
            geocoder = new Geocoder(MapsActivity.this, Locale.getDefault());
            DecimalFormat dFormat = new DecimalFormat("#.######");
            double latitude = Double.parseDouble(dFormat.format(location.getLatitude()));
            double longitude = Double.parseDouble(dFormat.format(location.getLongitude()));

            try {
                addresses = geocoder.getFromLocation(latitude, longitude, 1);
                if (!addresses.isEmpty()) {
                    Address returnedAddress = addresses.get(0);
                    StringBuilder strReturnedAddress = new StringBuilder("Address:\n");
                    for (int i = 0; i < returnedAddress.getMaxAddressLineIndex(); i++) {
                        strReturnedAddress.append(returnedAddress.getAddressLine(i)).append("\n");
                    }


                    currentAddress.setText(returnedAddress.getAddressLine(0));

                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }



    private void updateLocationUI() {
        if (mMap == null) return;
        try {
            if (isGPS) {
                mMap.setMyLocationEnabled(true);
                mMap.getUiSettings().setMyLocationButtonEnabled(false);
                mMap.getUiSettings().setCompassEnabled(false);

            } else {
                mMap.setMyLocationEnabled(false);
                mMap.getUiSettings().setMyLocationButtonEnabled(false);
                mMap.getUiSettings().setCompassEnabled(false);
                mLastKnownLocation = null;
            }

        } catch (SecurityException e) {
            Log.e("Exception: %s", e.getMessage());
        }

        Log.e("tag" , "update location ui");

    }
}