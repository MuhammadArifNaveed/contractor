package com.thecontractor.VendorActivities;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.VendorEnquiriesAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.VendorDashboardCountModel;
import com.thecontractor.Model.VendorEnquiryModel;
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

public class

VendorParticularEnquiries extends AppCompatActivity {
    VendorDashboardCountModel vendorDashboardCountModel;
    String selectedLanguage = "en";
    String statusId;
    String vendorId;


    RecyclerView particularEnquiriesRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<VendorEnquiryModel> list;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    TextView noData;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_particular_enquiries);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        getLanguageFromSP();
        getDataFromSP();
        getObjectFromAdapter();
        initiate();
        vendorParticularEnquiriesAPI();
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

            vendorDashboardCountModel = (VendorDashboardCountModel) bundle.getParcelable("vendorDashboardCountModel");

            statusId = vendorDashboardCountModel.getId();
            Log.e("tag" , "enquiry status id is : "+statusId);
            getSupportActionBar().setTitle(vendorDashboardCountModel.getName());


        }
    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(VendorParticularEnquiries.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorParticularEnquiries.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorParticularEnquiries.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorParticularEnquiries.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();


            Log.e("tag" , "Vendor id is : "+vendorId);


        }
    }

    public void initiate()
    {

        progressDialog = new ProgressDialog(VendorParticularEnquiries.this);

        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(View.GONE);

        list = new ArrayList<>();
        particularEnquiriesRV = (RecyclerView) findViewById(R.id.particularEnquiriesRV);
        linearLayoutManager = new LinearLayoutManager(VendorParticularEnquiries.this  ,  LinearLayoutManager.VERTICAL , false);
        particularEnquiriesRV.setLayoutManager(linearLayoutManager);

    }


    private void vendorParticularEnquiriesAPI() {

        RequestBody status_id = RequestBody.create(statusId , MediaType.parse("text/plain"));
        RequestBody id = RequestBody.create(vendorId , MediaType.parse("text/plain"));


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
        call = retrofitApi.vendorParticularEnquiries(status_id , id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        list = response.body().getVendor_enquiries();

                        Log.e("tag" , "list size is : "+list.size());


                        VendorEnquiriesAdapter vendorEnquiriesAdapter = new VendorEnquiriesAdapter(VendorParticularEnquiries.this , list , selectedLanguage , "today");
                        particularEnquiriesRV.setAdapter(vendorEnquiriesAdapter);


                    }
                    else
                    {
                        noData.setVisibility(View.VISIBLE);
                        //Toast.makeText(VendorParticularEnquiries.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorParticularEnquiries.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorParticularEnquiries.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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