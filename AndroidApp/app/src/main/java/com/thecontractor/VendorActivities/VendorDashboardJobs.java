package com.thecontractor.VendorActivities;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.VendorEnquiriesDashboardAdapter;
import com.thecontractor.Adapter.VendorJobsDashboardAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.VendorDashboardCountModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.util.ArrayList;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class VendorDashboardJobs extends AppCompatActivity {
    String selectedLanguage = "en";
    String vendorId;
    String userId;
    String userType;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;


    TextView postJob , directHiring , noData;

    RecyclerView jobDashboardRV;
    GridLayoutManager dashboardLayoutManager ;
    ArrayList<VendorDashboardCountModel> dashboardList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_dashboard_jobs);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.jobs_portal));
        getSupportActionBar().setElevation(0);

        getLanguageFromSP();
        getDataFromSP();
        initiate();
        clickListener();
        vendorJobsStatusAPI();
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

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(VendorDashboardJobs.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorDashboardJobs.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorDashboardJobs.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorDashboardJobs.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();
            userId = vendorModel.getUser_id();
            userType = vendorModel.getUser_type();


            Log.e("tag" , "Vendor id is : "+vendorId);
            Log.e("tag" , "user id is : "+userId);
            Log.e("tag" , "user type is : "+userType);


        }
    }

    public void initiate()
    {
        progressDialog = new ProgressDialog(VendorDashboardJobs.this);

        postJob = (TextView) findViewById(R.id.postJob);
        directHiring = (TextView) findViewById(R.id.directHiring);
        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(View.GONE);

        dashboardList = new ArrayList<>();
        jobDashboardRV = (RecyclerView) findViewById(R.id.jobDashboardRV);
        dashboardLayoutManager = new GridLayoutManager(VendorDashboardJobs.this  ,  3 , LinearLayoutManager.VERTICAL , false);
        jobDashboardRV.setLayoutManager(dashboardLayoutManager);


    }

    public void clickListener(){
        postJob.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(VendorDashboardJobs.this , VendorPostJob.class);
                Bundle b = new Bundle();
                b.putString("from" , "add");
                intent.putExtras(b);
                startActivity(intent);
            }
        });

        directHiring.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(VendorDashboardJobs.this , VendorDirectHiring.class);
                startActivity(intent);
            }
        });
    }

    private void vendorJobsStatusAPI() {

        RequestBody id = RequestBody.create(vendorId , MediaType.parse("text/plain"));
        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));
        RequestBody user_type = RequestBody.create(userType , MediaType.parse("text/plain"));


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
        call = retrofitApi.vendorJobsStatus(id , user_id , user_type);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        dashboardList = response.body().getVendor_dashboard_counts();


                        Log.e("tag" , "dashboard list size is : "+dashboardList.size());

                        VendorJobsDashboardAdapter vendorJobsDashboardAdapter = new VendorJobsDashboardAdapter(VendorDashboardJobs.this , dashboardList , selectedLanguage);
                        jobDashboardRV.setAdapter(vendorJobsDashboardAdapter);



                    }
                    else
                    {
                        Toast.makeText(VendorDashboardJobs.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorDashboardJobs.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorDashboardJobs.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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
}