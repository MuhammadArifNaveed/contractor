package com.thecontractor.VendorActivities;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.app.ProgressDialog;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.VendorJobListingAdapter;
import com.thecontractor.ComplaintDetail;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.VendorDashboardCountModel;
import com.thecontractor.Model.VendorJobListingModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.R;
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

public class VendorJobDetail extends AppCompatActivity {


    String selectedLanguage = "en";
    String vendorId;
    String userId;
    String userType;
    VendorJobListingModel vendorJobListingModel;
    String jobUUID;
    String jobId;

    LinearLayout jobDetailLayout;
    TextView jobTitle , jobLocation , jobCategory , jobType , jobVacancies , jobSalary , createdAt , deadline , description , candidates ,
            status , payment , viewApplies;
    CheckBox jobPublishCB;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_job_detail);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(R.string.job_detail);

        getObjectFromAdapter();
        getLanguageFromSP();
        getDataFromSP();
        initiate();
        getJobDetailAPI();
        clickListener();
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

            jobUUID = (String) bundle.get("jodUUId");
            jobId = (String) bundle.get("jodId");


            Log.e("tag" , "job UUID is : "+jobUUID);
            Log.e("tag" , "job id is : "+jobId);


        }
    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(VendorJobDetail.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorJobDetail.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorJobDetail.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorJobDetail.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();
            userId = vendorModel.getUser_id();
            userType = vendorModel.getUser_type();


            Log.e("tag" , "Vendor id is : "+vendorId);
            Log.e("tag" , "user id is : "+userId);
            Log.e("tag" , "user type is : "+userType);


        }
    }


    public void initiate(){

        progressDialog = new ProgressDialog(VendorJobDetail.this);


        jobDetailLayout = (LinearLayout) findViewById(R.id.jobDetailLayout);
        jobDetailLayout.setVisibility(GONE);
        jobTitle = (TextView) findViewById(R.id.jobTitle);
        jobLocation = (TextView) findViewById(R.id.jobLocation);
        jobCategory = (TextView) findViewById(R.id.jobCategory);
        jobType = (TextView) findViewById(R.id.jobType);
        jobVacancies = (TextView) findViewById(R.id.jobVacancies);
        jobSalary = (TextView) findViewById(R.id.jobSalary);
        createdAt = (TextView) findViewById(R.id.createdAt);
        deadline = (TextView) findViewById(R.id.deadline);
        description = (TextView) findViewById(R.id.description);
        candidates = (TextView) findViewById(R.id.candidates);
        status = (TextView) findViewById(R.id.status);
        payment = (TextView) findViewById(R.id.payment);
        viewApplies = (TextView) findViewById(R.id.viewApplies);
        viewApplies.setVisibility(GONE);
        jobPublishCB = (CheckBox) findViewById(R.id.jobPublishCB);
    }

    public void clickListener(){
        viewApplies.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(VendorJobDetail.this , VendorApplies.class);
                Bundle b = new Bundle();
                b.putString("jodUUId" , jobUUID);
                intent.putExtras(b);
                startActivity(intent);
            }
        });

        jobPublishCB.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(@NonNull CompoundButton buttonView, boolean isChecked) {

                if (buttonView.isPressed()) {

                    if (isChecked) {
                        updatePublishStatus("1");
                    } else {
                        updatePublishStatus("0");
                    }
                }

            }
        });
    }

    private void getJobDetailAPI() {


        RequestBody job_uuid = RequestBody.create(jobUUID , MediaType.parse("text/plain"));

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
        call = retrofitApi.vendorJobDetail(job_uuid);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        jobDetailLayout.setVisibility(VISIBLE);
                        vendorJobListingModel = response.body().getJob_details();

                        setDataToWidget();


                    }
                    else
                    {
                        Toast.makeText(VendorJobDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorJobDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorJobDetail.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    private void updatePublishStatus(String status) {


        RequestBody job_id = RequestBody.create(jobId , MediaType.parse("text/plain"));
        RequestBody checkStatus = RequestBody.create(status , MediaType.parse("text/plain"));

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
        call = retrofitApi.vendorUpdateJobPublishStatus(job_id , checkStatus);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        Toast.makeText(VendorJobDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();

                        if(status.equals("0"))
                        {
                            jobPublishCB.setChecked(false);
                            jobPublishCB.setText("Not Published");
                        }else {
                            jobPublishCB.setChecked(true);
                            jobPublishCB.setText("Published");
                        }

                    }
                    else
                    {
                        Toast.makeText(VendorJobDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorJobDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorJobDetail.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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

        if(selectedLanguage.equals("en"))
        {
            jobTitle.setText(vendorJobListingModel.getTitle());
            jobLocation.setText(vendorJobListingModel.getLoaction_name());
            jobCategory.setText(vendorJobListingModel.getJob_category_name());
            jobType.setText(vendorJobListingModel.getJob_type());
            description.setText(vendorJobListingModel.getDescription());

        }
        else
        {
            jobTitle.setText(vendorJobListingModel.getArabic_title());
            jobLocation.setText(vendorJobListingModel.getLoaction_arabic_name());
            jobCategory.setText(vendorJobListingModel.getJob_category_arabic_name());
            jobType.setText(vendorJobListingModel.getJob_type());
            description.setText(vendorJobListingModel.getArabic_description());
        }


        jobVacancies.setText(vendorJobListingModel.getVaccancies());
        jobSalary.setText(vendorJobListingModel.getSalary());

        if(vendorJobListingModel.getApplication_count() != null && !vendorJobListingModel.getApplication_count().equals("0")){
            viewApplies.setVisibility(VISIBLE);

        }

        candidates.setText(vendorJobListingModel.getApplication_count() + " candidates have applied for this job    ");

        createdAt.setText(parseDateToddMMyyyy(vendorJobListingModel.getCreated_at()));
        deadline.setText(parseDateToddMMyyyy(vendorJobListingModel.getCreated_at()));

        if(vendorJobListingModel.getApproved().equals("0")){
            status.setText("Pending");

        }else {
            status.setText("Approved");
        }


        if(vendorJobListingModel.getAmount() != null && !vendorJobListingModel.getAmount().equals("0")){
            payment.setText("Sponsored " +vendorJobListingModel.getAmount() + " " + getResources().getString(R.string.currency));

        }else {
            payment.setText("Normal");
        }

        if(vendorJobListingModel.getStatus().equals("0"))
        {
            jobPublishCB.setChecked(false);
            jobPublishCB.setText("Not Published");
        }else {
            jobPublishCB.setChecked(true);
            jobPublishCB.setText("Published");
        }

    }

    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-dd-MM HH:mm:ss";
        String outputPattern = "yyyy-dd-MM";
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