package com.thecontractor;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.AvailableJobListingModel;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.VendorActivities.VendorJobDetail;

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

public class AvailableJobsDetails extends AppCompatActivity {
    AvailableJobListingModel availableJobListingModel;

    ImageView companyImage;
    TextView companyName , companyCategoriesName , companyCity ,jobTitle , jobLocation , jobCategory , jobType , jobSalary , deadline , description;
    Button applyJobBtn;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    String userId;
    String jobUUId;
    String selectedLanguage = "en";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_available_jobs_details);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.job_detail));

        getObjectFromAdapter();
        getLanguageFromSP();
        getDataFromSP();
        initiate();
        clickListener();
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

            availableJobListingModel = (AvailableJobListingModel) bundle.get("availableJobListingModel");
            jobUUId = availableJobListingModel.getJob_uuid();

            Log.e("tag" , "jobUUId is : "+jobUUId);


        }
    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(AvailableJobsDetails.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(AvailableJobsDetails.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(AvailableJobsDetails.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(AvailableJobsDetails.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();

            Log.e("tag" , "user id is : "+userId);

        }
    }

    public void initiate(){

        progressDialog = new ProgressDialog(AvailableJobsDetails.this);
        companyImage = (ImageView) findViewById(R.id.companyImage);
        companyName = (TextView) findViewById(R.id.companyName);
        companyCategoriesName = (TextView) findViewById(R.id.companyCategoriesName);
        companyCity = (TextView) findViewById(R.id.companyCity);
        jobTitle = (TextView) findViewById(R.id.jobTitle);
        jobLocation = (TextView) findViewById(R.id.jobLocation);
        jobCategory = (TextView) findViewById(R.id.jobCategory);
        jobType = (TextView) findViewById(R.id.jobType);
        jobSalary = (TextView) findViewById(R.id.jobSalary);
        deadline = (TextView) findViewById(R.id.deadline);
        description = (TextView) findViewById(R.id.description);
        applyJobBtn = (Button) findViewById(R.id.applyJobBtn);

    }

    public void clickListener(){
        applyJobBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!SharedPrefManager.getInstance(AvailableJobsDetails.this).getUserObject().equals("")) {
                    applyJobAPI();
                }else {
                    Intent intent = new Intent(AvailableJobsDetails.this, Login.class);
                    intent.putExtra("requestForLogin", "yes");
                    loginActivityResultLauncher.launch(intent);
                }

            }
        });
    }

    ActivityResultLauncher<Intent> loginActivityResultLauncher = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(),
            new ActivityResultCallback<ActivityResult>() {
                @Override
                public void onActivityResult(ActivityResult result) {
                    if (result.getResultCode() == Activity.RESULT_OK) {

                        Intent data = result.getData();

                        Log.e("tag" , "result back");

                        getDataFromSP();
                    }
                }
            });

    private void applyJobAPI() {


        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));
        RequestBody job_uuid = RequestBody.create(jobUUId , MediaType.parse("text/plain"));

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
        call = retrofitApi.applyJob(user_id , job_uuid);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        Toast.makeText(AvailableJobsDetails.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();

                        finish();
                    }
                    else
                    {
                        Toast.makeText(AvailableJobsDetails.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(AvailableJobsDetails.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(AvailableJobsDetails.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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

        Glide.with(AvailableJobsDetails.this)
                .load(ApiUrls.COMPANIES_IMAGE_URL+availableJobListingModel.getCompany_logo())
                .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                .into(companyImage);

        if(selectedLanguage.equals("en"))
        {
            companyName.setText(availableJobListingModel.getCompany_name());
            companyCategoriesName.setText(availableJobListingModel.getCategory_name());
            companyCity.setText(availableJobListingModel.getCity_name());
            jobTitle.setText(availableJobListingModel.getJob_title());
            jobLocation.setText(availableJobListingModel.getJob_location_name());
            jobCategory.setText(availableJobListingModel.getJob_category_title());
            jobType.setText(availableJobListingModel.getJob_type());
            description.setText(availableJobListingModel.getJob_description());

        }
        else
        {
            companyName.setText(availableJobListingModel.getCompany_arabic_name());
            companyCategoriesName.setText(availableJobListingModel.getCategory_name());
            companyCity.setText(availableJobListingModel.getCity_name());
            jobTitle.setText(availableJobListingModel.getArabic_title());
            jobLocation.setText(availableJobListingModel.getJob_location_name());
            jobCategory.setText(availableJobListingModel.getJob_category_title());
            jobType.setText(availableJobListingModel.getJob_type());
            description.setText(availableJobListingModel.getArabic_description());
        }


        jobSalary.setText(availableJobListingModel.getSalary());

        deadline.setText(parseDateToddMMyyyy(availableJobListingModel.getDeadline()));


    }

    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-MM-dd";
        String outputPattern = "dd-MMM-yyyy";
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