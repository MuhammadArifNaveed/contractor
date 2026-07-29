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
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.VendorMyMembershipAdapter;
import com.thecontractor.Adapter.VendorRatingAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.VendorMyMembershipModel;
import com.thecontractor.Model.VendorRatingModel;
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

public class VendorMyMembership extends AppCompatActivity {
    String selectedLanguage = "en";
    String vendorId;


    RecyclerView myMembershipRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<VendorMyMembershipModel> list;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    Button buyMembership;
    TextView noData;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_my_membership);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle("My Membership");

        getLanguageFromSP();
        getDataFromSP();
        initiate();
        clickListener();
        vendorRatingAPI();
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
        if (!SharedPrefManager.getInstance(VendorMyMembership.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorMyMembership.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorMyMembership.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorMyMembership.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();


            Log.e("tag" , "Vendor id is : "+vendorId);


        }
    }

    public void initiate()
    {

        progressDialog = new ProgressDialog(VendorMyMembership.this);

        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(View.GONE);

        buyMembership = (Button) findViewById(R.id.buyMembership);
        buyMembership.setVisibility(View.GONE);

        list = new ArrayList<>();
        myMembershipRV = (RecyclerView) findViewById(R.id.myMembershipRV);
        linearLayoutManager = new LinearLayoutManager(VendorMyMembership.this  ,  LinearLayoutManager.VERTICAL , false);
        myMembershipRV.setLayoutManager(linearLayoutManager);

    }

    public void clickListener()
    {
        buyMembership.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(VendorMyMembership.this , VendorMembership.class);
                startActivity(intent);
                finish();
            }
        });
    }


    private void vendorRatingAPI() {

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
        call = retrofitApi.myMembership(id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        list = response.body().getMy_memberships();

                        Log.e("tag" , "list size is : "+list.size());


                        if(list.size() > 0)
                        {
                            VendorMyMembershipAdapter vendorMyMembershipAdapter = new VendorMyMembershipAdapter(VendorMyMembership.this , list , selectedLanguage);
                            myMembershipRV.setAdapter(vendorMyMembershipAdapter);
                        }else
                        {
                            buyMembership.setVisibility(View.VISIBLE);
                            noData.setVisibility(View.VISIBLE);
                        }



                    }
                    else
                    {
                        buyMembership.setVisibility(View.VISIBLE);
                        noData.setVisibility(View.VISIBLE);
                        //Toast.makeText(VendorMyMembership.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorMyMembership.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorMyMembership.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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