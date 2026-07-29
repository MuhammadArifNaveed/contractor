package com.thecontractor;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.view.ViewCompat;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.EnquiryModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class EnquiryDetail extends AppCompatActivity {
    LinearLayout enquiryDetailLayout;
    String enquiryId;
    String userId;
    EnquiryModel enquiryModel;
    ImageView companyImage;
    TextView companyName;
    TextView companyCategory;
    TextView companyAddress;
    TextView orderAt;
    TextView dateAndTime;
    TextView location;
    TextView description;
    TextView status;
    TextView adminNote;
    LinearLayout adminNoteLayout;
    String selectedLanguage = "en";

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    LinearLayout companyPhoneLayout , companyWhatsappLayout , companyEmailLayout;
    TextView companyPhone , companyWhatsapp , companyEmail;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_enquiry_detail);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.enquiry_details));

        getLanguageFromSP();
        getObjectFromAdapter();
        getDataFromSP();
        initiate();
        enquiryDetailAPI();
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

            enquiryId = (String) bundle.getString("id");

            Log.e("tag" , "enquiry id is : "+enquiryId);

        }
    }

    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(EnquiryDetail.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(EnquiryDetail.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();

            Log.e("tag" , "user id is : "+userId);

        }
    }


    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(EnquiryDetail.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(EnquiryDetail.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }

    public void initiate()
    {
        progressDialog = new ProgressDialog(EnquiryDetail.this);

        enquiryDetailLayout = (LinearLayout) findViewById(R.id.enquiryDetailLayout);
        enquiryDetailLayout.setVisibility(View.GONE);
        companyImage = (ImageView) findViewById(R.id.companyImage);
        companyName = (TextView) findViewById(R.id.companyName);
        companyCategory = (TextView) findViewById(R.id.companyCategory);
        companyAddress = (TextView) findViewById(R.id.companyAddress);
        orderAt = (TextView) findViewById(R.id.orderAt);
        dateAndTime = (TextView) findViewById(R.id.dateAndTime);
        location = (TextView) findViewById(R.id.location);
        description = (TextView) findViewById(R.id.description);
        status = (TextView) findViewById(R.id.status);
        adminNote = (TextView) findViewById(R.id.adminNote);
        adminNoteLayout = (LinearLayout) findViewById(R.id.adminNoteLayout);
        adminNoteLayout.setVisibility(View.GONE);
        companyPhoneLayout = (LinearLayout) findViewById(R.id.companyPhoneLayout);
        companyPhoneLayout.setVisibility(View.GONE);
        companyWhatsappLayout = (LinearLayout) findViewById(R.id.companyWhatsappLayout);
        companyWhatsappLayout.setVisibility(View.GONE);
        companyEmailLayout = (LinearLayout) findViewById(R.id.companyEmailLayout);
        companyEmailLayout.setVisibility(View.GONE);
        companyPhone = (TextView) findViewById(R.id.companyPhone);
        companyWhatsapp = (TextView) findViewById(R.id.companyWhatsapp);
        companyEmail = (TextView) findViewById(R.id.companyEmail);
    }

    private void enquiryDetailAPI() {

        RequestBody id = RequestBody.create(enquiryId , MediaType.parse("text/plain"));
        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));


        //The gson builder
        Gson gson = new GsonBuilder()
                .setLenient()
                .create();

        OkHttpClient okHttpClient = new OkHttpClient().newBuilder()
                .connectTimeout(120, TimeUnit.SECONDS)
                .readTimeout(120, TimeUnit.SECONDS)
                .writeTimeout(120, TimeUnit.SECONDS)
                .build();

        //creating retrofit object
        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(ApiUrls.API_URL)
                .client(SSSHandShake.getUnsafeOkHttpClient())
                .addConverterFactory(GsonConverterFactory.create(gson))
                .build();



        showProgress();
        RetrofitApi retrofitApi = retrofit.create(RetrofitApi.class);

        //creating a call and calling the upload image method
        call = retrofitApi.enquiryDetail(id , user_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        enquiryDetailLayout.setVisibility(View.VISIBLE);
                        enquiryModel = response.body().getEnquiry_detail();
                        setDataToWidget();









                    }
                    else
                    {
                        Toast.makeText(EnquiryDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(EnquiryDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if(call.isCanceled())
                {
                    Log.e("tag" , "request is cancelled");
                }
                else
                {
                    hideProgress();
                    Toast.makeText(EnquiryDetail.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }


    public void showProgress()
    {
        progressDialog.setCancelable(false);
        progressDialog.show();
        progressDialog.setContentView(R.layout.progress_dialog);
        progressDialog.getWindow().setBackgroundDrawable(null);
    }

    public void hideProgress()
    {
        progressDialog.dismiss();
    }

    public void setDataToWidget()
    {
        Glide.with(EnquiryDetail.this)
                .load(ApiUrls.COMPANIES_IMAGE_URL+enquiryModel.getCompany_logo())
                .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                .into(companyImage);

        if(selectedLanguage.equals("en"))
        {
            companyName.setText(enquiryModel.getCompany_name());
            companyCategory.setText(enquiryModel.getCategory_name());
            companyAddress.setText(enquiryModel.getCompany_address());
            status.setText(enquiryModel.getS_name());

        }
        else
        {
            companyName.setText(enquiryModel.getCompany_arabic_address());
            companyCategory.setText(enquiryModel.getCategory_arabic_name());
            companyAddress.setText(enquiryModel.getCompany_arabic_address());
            status.setText(enquiryModel.getS_arabic_name());
        }


        orderAt.setText(parseDateToddMMyyyy(enquiryModel.getCreated_at()));
        dateAndTime.setText(parseDateToddMMyyyy(enquiryModel.getDate_time()));
        location.setText(enquiryModel.getLocation());
        description.setText(enquiryModel.getDescription());

        if(enquiryModel.getReason() != null)
        {
            adminNoteLayout.setVisibility(View.VISIBLE);
            adminNote.setText(enquiryModel.getReason());
        }



        ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                .toBuilder()
                .setAllCorners(CornerFamily.ROUNDED,5)
                .build();

        MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
        shapeDrawable.setPadding(10 , 5 , 10 , 5);

        shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(enquiryModel.getS_color())));
        ViewCompat.setBackground(status,shapeDrawable);

        if(!enquiryModel.getCompany_phone().equals("") && enquiryModel.getCompany_phone() != null)
        {
            companyPhone.setText(enquiryModel.getCompany_phone());
            companyPhoneLayout.setVisibility(View.VISIBLE);
        }

        if(!enquiryModel.getCompany_whatsapp_phone().equals("") && enquiryModel.getCompany_whatsapp_phone() != null)
        {
            companyWhatsapp.setText(enquiryModel.getCompany_whatsapp_phone());
            companyWhatsappLayout.setVisibility(View.VISIBLE);
        }

        if(!enquiryModel.getCompany_email().equals("") && enquiryModel.getCompany_email() != null)
        {
            companyEmail.setText(enquiryModel.getCompany_email());
            companyEmailLayout.setVisibility(View.VISIBLE);
        }

        companyPhoneLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                onCallBtnClick();
            }
        });

        companyWhatsappLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String url = "https://api.whatsapp.com/send?phone="+enquiryModel.getCompany_whatsapp_phone();
                Intent i = new Intent(Intent.ACTION_VIEW);
                i.setData(Uri.parse(url));
                startActivity(i);
            }
        });

        companyEmailLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                Intent emailIntent = new Intent(Intent.ACTION_SENDTO);
                emailIntent.setData(Uri.parse("mailto:"+enquiryModel.getCompany_email()));
                startActivity(Intent.createChooser(emailIntent, "Send Email"));
            }
        });
    }

    private void onCallBtnClick(){
        if (Build.VERSION.SDK_INT < 23) {
            phoneCall();
        }else {

            if (ActivityCompat.checkSelfPermission(EnquiryDetail.this,
                    Manifest.permission.CALL_PHONE) == PackageManager.PERMISSION_GRANTED) {

                phoneCall();
            }else {
                final String[] PERMISSIONS_STORAGE = {Manifest.permission.CALL_PHONE};
                //Asking request Permissions
                ActivityCompat.requestPermissions(EnquiryDetail.this, PERMISSIONS_STORAGE, 9);
            }
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        boolean permissionGranted = false;
        switch (requestCode) {
            case 9:
                permissionGranted = grantResults[0] == PackageManager.PERMISSION_GRANTED;
                break;
        }
        if (permissionGranted) {
            phoneCall();
        } else {
            Toast.makeText(EnquiryDetail.this, "You don't permit permission.", Toast.LENGTH_SHORT).show();
        }
    }

    private void phoneCall() {
        if (ActivityCompat.checkSelfPermission(EnquiryDetail.this,
                Manifest.permission.CALL_PHONE) == PackageManager.PERMISSION_GRANTED) {
            Intent callIntent = new Intent(Intent.ACTION_CALL);
            callIntent.setData(Uri.parse("tel:"+enquiryModel.getCompany_phone()));
            startActivity(callIntent);
        } else {
            Toast.makeText(EnquiryDetail.this, "You don't permit permission.", Toast.LENGTH_SHORT).show();
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