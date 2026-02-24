package com.thecontractor;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.thecontractor.Global.LocaleHelper;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.VendorActivities.VendorHome;

public class Splash extends AppCompatActivity {
    ImageView splashImage;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);
        getSupportActionBar().hide();

        initiate();
        getDataFromSP();
        splashThread();
    }

    public void initiate()
    {
        splashImage = (ImageView) findViewById(R.id.splashImage);


        Glide.with(Splash.this).asGif().load(R.drawable.splash).into(splashImage);

    }

    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(Splash.this).getUserLanguage().equals("")) {
            String language = SharedPrefManager.getInstance(Splash.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+language);

            LocaleHelper.setLocale(Splash.this , language);

        }
    }



    public void splashThread()
    {
        Thread background = new Thread() {
            public void run() {
                try {
                    sleep(1600);

                    if (!SharedPrefManager.getInstance(Splash.this).getVendorObject().equals("")){

                        //Intent i=new Intent(Splash.this, VendorChat.class);
                        Intent i=new Intent(Splash.this, VendorHome.class);
                        startActivity(i);
                        finish();
                    }
                    else
                    {

                        Intent i=new Intent(Splash.this,Home.class);
                        startActivity(i);
                        finish();
                    }


                } catch (Exception e) {
                }
            }
        };
        background.start();
    }
}