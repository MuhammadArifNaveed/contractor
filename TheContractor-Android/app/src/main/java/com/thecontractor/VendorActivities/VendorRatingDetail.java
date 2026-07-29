package com.thecontractor.VendorActivities;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.ViewCompat;

import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RatingBar;
import android.widget.TextView;

import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.VendorEnquiryModel;
import com.thecontractor.Model.VendorRatingModel;
import com.thecontractor.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class VendorRatingDetail extends AppCompatActivity {
    VendorRatingModel vendorRatingModel;
    String selectedLanguage = "en";

    TextView orderAt;
    TextView dateAndTime;
    TextView location;
    TextView description;
    TextView status;
    TextView userName , phoneNo , email;
    RatingBar reviewRate;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_rating_detail);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle("Rating Detail");

        getLanguageFromSP();
        getObjectFromAdapter();
        initiate();
        setDataToWidget();
    }


    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        switch (menuItem.getItemId()) {
            case android.R.id.home:
                this.finish();
                return true;
            default:
                return super.onOptionsItemSelected(menuItem);
        }

    }




    public void getObjectFromAdapter() {
        Intent intent = getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {

            vendorRatingModel = (VendorRatingModel) bundle.getParcelable("vendorRatingModel");

            Log.e("tag" , "enquiry id is : "+vendorRatingModel.getId());

        }
    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(VendorRatingDetail.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorRatingDetail.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }

    public void initiate()
    {

        orderAt = (TextView) findViewById(R.id.orderAt);
        dateAndTime = (TextView) findViewById(R.id.dateAndTime);
        location = (TextView) findViewById(R.id.location);
        description = (TextView) findViewById(R.id.description);
        status = (TextView) findViewById(R.id.status);


        userName = (TextView) findViewById(R.id.userName);
        phoneNo = (TextView) findViewById(R.id.phoneNo);
        email = (TextView) findViewById(R.id.email);
        reviewRate = (RatingBar) findViewById(R.id.reviewRate);

    }

    public void setDataToWidget()
    {



        status.setText(vendorRatingModel.getS_name());
        orderAt.setText(parseDateToddMMyyyy(vendorRatingModel.getCreated_at()));
        dateAndTime.setText(parseDateToddMMyyyy(vendorRatingModel.getApp_date_time()));
        location.setText(vendorRatingModel.getLocation());
        description.setText(vendorRatingModel.getReview());





        ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                .toBuilder()
                .setAllCorners(CornerFamily.ROUNDED,5)
                .build();

        MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
        shapeDrawable.setPadding(10 , 5 , 10 , 5);

        shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(vendorRatingModel.getColor())));
        ViewCompat.setBackground(status,shapeDrawable);


        userName.setText(vendorRatingModel.getName() + " " + vendorRatingModel.getSurname());
        phoneNo.setText(vendorRatingModel.getPhone());
        email.setText(vendorRatingModel.getEmail());


        if(vendorRatingModel.getRating() != null)
        {
            reviewRate.setRating(Float.parseFloat(vendorRatingModel.getRating()));
        }
        else
        {
            reviewRate.setRating(0);
        }

    }

    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-dd-MM HH:mm:ss";
        String outputPattern = "yyyy-dd-MM h:mm a";
        SimpleDateFormat inputFormat = new SimpleDateFormat(inputPattern);
        SimpleDateFormat outputFormat = new SimpleDateFormat(outputPattern);

        Date date = null;
        String str = null;

        try {
            date = inputFormat.parse(time);
            str = outputFormat.format(date);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return str;
    }

}