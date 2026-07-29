package com.thecontractor;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.ViewCompat;

import android.app.ProgressDialog;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
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
import com.thecontractor.Model.CategoriesModel;
import com.thecontractor.Model.ComplaintModel;
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

public class ComplaintDetail extends AppCompatActivity {
    LinearLayout complaintDetailLayout;
    String complaintId;
    String userId;
    ComplaintModel complaintModel;
    ImageView companyImage;
    TextView companyName;
    TextView companyCategory;
    TextView companyAddress;
    TextView complaintNo;
    TextView createdAt;
    TextView description;
    TextView status;
    TextView adminNote;
    LinearLayout adminNoteLayout;
    String selectedLanguage = "en";

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_complaint_detail);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.complaints_details));

        getDataFromSP();
        getLanguageFromSP();
        getObjectFromAdapter();
        initiate();
        complaintDetailAPI();

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

            complaintId = (String) bundle.getString("id");

            Log.e("tag" , "complaint id is : "+complaintId);

        }
    }

    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(ComplaintDetail.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(ComplaintDetail.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();

            Log.e("tag" , "user id is : "+userId);

        }
    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(ComplaintDetail.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(ComplaintDetail.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }

    public void initiate()
    {
        progressDialog = new ProgressDialog(ComplaintDetail.this);

        complaintDetailLayout = (LinearLayout) findViewById(R.id.complaintDetailLayout);
        complaintDetailLayout.setVisibility(View.GONE);
        companyImage = (ImageView) findViewById(R.id.companyImage);
        companyName = (TextView) findViewById(R.id.companyName);
        companyCategory = (TextView) findViewById(R.id.companyCategory);
        companyAddress = (TextView) findViewById(R.id.companyAddress);
        complaintNo = (TextView) findViewById(R.id.complaintNo);
        createdAt = (TextView) findViewById(R.id.createdAt);
        description = (TextView) findViewById(R.id.description);
        status = (TextView) findViewById(R.id.status);
        adminNote = (TextView) findViewById(R.id.adminNote);
        adminNoteLayout = (LinearLayout) findViewById(R.id.adminNoteLayout);
        adminNoteLayout.setVisibility(View.GONE);
    }

    private void complaintDetailAPI() {

        RequestBody id = RequestBody.create(complaintId , MediaType.parse("text/plain"));
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
        call = retrofitApi.complaintDetail(id , user_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        complaintDetailLayout.setVisibility(View.VISIBLE);
                        complaintModel = response.body().getComplaint_detail();
                        setDataToWidget();









                    }
                    else
                    {
                        Toast.makeText(ComplaintDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(ComplaintDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(ComplaintDetail.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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
        Glide.with(ComplaintDetail.this)
                .load(ApiUrls.COMPANIES_IMAGE_URL+complaintModel.getCompany_logo())
                .apply(new RequestOptions().placeholder(R.drawable.ic_user_profile).error(R.drawable.ic_user_profile))
                .into(companyImage);

        if(selectedLanguage.equals("en"))
        {
            companyName.setText(complaintModel.getCompany_name());
            companyCategory.setText(complaintModel.getCompany_category());
            companyAddress.setText(complaintModel.getCompany_address());
            status.setText(complaintModel.getStatus_name());

        }
        else
        {
            companyName.setText(complaintModel.getCompany_arabic_address());
            companyCategory.setText(complaintModel.getCategory_arabic_name());
            companyAddress.setText(complaintModel.getCompany_arabic_address());
            status.setText(complaintModel.getStatus_arabic_name());
        }


        complaintNo.setText(complaintModel.getComplaint_id());
        createdAt.setText(parseDateToddMMyyyy(complaintModel.getCreated_at()));
        description.setText(complaintModel.getComplaint());
        if(!complaintModel.getReply().equals(""))
        {
            adminNoteLayout.setVisibility(View.VISIBLE);
            adminNote.setText(complaintModel.getReply());
        }



        ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                .toBuilder()
                .setAllCorners(CornerFamily.ROUNDED,5)
                .build();

        MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
        shapeDrawable.setPadding(10 , 5 , 10 , 5);

        shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(complaintModel.getStatus_color())));
        ViewCompat.setBackground(status,shapeDrawable);
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