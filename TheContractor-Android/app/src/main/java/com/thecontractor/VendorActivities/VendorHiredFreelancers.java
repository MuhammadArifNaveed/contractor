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
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.VendorHiredFreelancerAdapter;
import com.thecontractor.Adapter.VendorHiredFreelancerSummaryAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Model.VendorHiredFreelancersModel;
import com.thecontractor.Model.VendorHiredFreelancersSummaryModel;
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

public class VendorHiredFreelancers extends AppCompatActivity {
    String from;
    String selectedLanguage = "en";
    String vendorId;
    String userId;
    String userType;
    String batchId;


    RecyclerView hiredFreelancersListingRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<VendorHiredFreelancersModel> list;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    VendorHiredFreelancerAdapter vendorHiredFreelancerAdapter;
    TextView noData;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_hired_freelancers);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle("Hired Freelancer");

        getObjectFromAdapter();
        getLanguageFromSP();

        if(from.equals("user")){
            getUserDataFromSP();
        }else if(from.equals("vendor")){
            getVendorDataFromSP();
        }

        initiate();
        vendorHiredFreelancerSummaryAPI();

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

            from = bundle.getString("from");
            batchId = (String) bundle.getString("batchId");

            Log.e("tag", "batchId is : " + batchId);
            Log.e("tag" , "freelancer from is : "+from);
        }
    }



    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(VendorHiredFreelancers.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorHiredFreelancers.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }


    public void getUserDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorHiredFreelancers.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorHiredFreelancers.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);

            userId = userModel.getId();
            userType = userModel.getUser_type();
            vendorId = userId;

            Log.e("tag" , "user id is : "+userId);
            Log.e("tag" , "user type is : "+userType);
            Log.e("tag" , "vendor id is : "+vendorId);

        }
    }

    public void getVendorDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorHiredFreelancers.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorHiredFreelancers.this).getVendorObject();
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

        progressDialog = new ProgressDialog(VendorHiredFreelancers.this);

        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(View.GONE);

        list = new ArrayList<>();
        hiredFreelancersListingRV = (RecyclerView) findViewById(R.id.hiredFreelancersListingRV);
        linearLayoutManager = new LinearLayoutManager(VendorHiredFreelancers.this  ,  LinearLayoutManager.VERTICAL , false);
        hiredFreelancersListingRV.setLayoutManager(linearLayoutManager);

    }


    private void vendorHiredFreelancerSummaryAPI() {

        RequestBody batch_id = RequestBody.create(batchId , MediaType.parse("text/plain"));
        RequestBody vendor_id = RequestBody.create(vendorId , MediaType.parse("text/plain"));
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
        call = retrofitApi.vendorHiredFreelancerApi(batch_id , user_id , user_type , vendor_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        list = response.body().getHired_freelancers();

                        Log.e("tag" , "list size is : "+list.size());

                        vendorHiredFreelancerAdapter = new VendorHiredFreelancerAdapter(VendorHiredFreelancers.this , list , selectedLanguage);
                        hiredFreelancersListingRV.setAdapter(vendorHiredFreelancerAdapter);



                    }
                    else
                    {
                        noData.setVisibility(View.VISIBLE);
                        //Toast.makeText(VendorParticularQuotations.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorHiredFreelancers.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorHiredFreelancers.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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