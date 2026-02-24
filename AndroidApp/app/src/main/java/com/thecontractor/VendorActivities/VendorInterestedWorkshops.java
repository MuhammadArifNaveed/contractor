package com.thecontractor.VendorActivities;

import static android.view.View.GONE;

import android.app.ProgressDialog;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.VendorInterestedWorkshopAdAdapter;
import com.thecontractor.Adapter.WorkshopAdAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.PaginationScrollListener;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.Model.WorkshopAdModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.WorkShopAds;

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

public class VendorInterestedWorkshops extends AppCompatActivity {

    String vendorId;
    String userId;
    String userType;
    TextView noData;
    RecyclerView workshopRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<WorkshopAdModel> list;

    VendorInterestedWorkshopAdAdapter vendorInterestedWorkshopAdAdapter;
    int currentPage = 1;
    int lastPage = 0;
    private boolean isLoading = false;
    private boolean isLastPage = false;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    String selectedLanguage = "en";

    Button openBid , closeBid;
    String from = "open";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_intrested_workshops);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.interested_workshops));

        getLanguageFromSP();
        getVendorDataFromSP();
        initiate();
        clickListener();
        workshopAdAPI(true);
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
        if (!SharedPrefManager.getInstance(VendorInterestedWorkshops.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorInterestedWorkshops.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }



    public void getVendorDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorInterestedWorkshops.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorInterestedWorkshops.this).getVendorObject();
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
        progressDialog = new ProgressDialog(VendorInterestedWorkshops.this);

        list = new ArrayList<>();
        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(GONE);

        openBid = (Button) findViewById(R.id.openBid);
        closeBid = (Button) findViewById(R.id.closeBid);

        workshopRV = (RecyclerView) findViewById(R.id.workshopRV);
        linearLayoutManager = new LinearLayoutManager(VendorInterestedWorkshops.this  , LinearLayoutManager.VERTICAL , false);
        workshopRV.setLayoutManager(linearLayoutManager);
        vendorInterestedWorkshopAdAdapter = new VendorInterestedWorkshopAdAdapter(VendorInterestedWorkshops.this , list , selectedLanguage);
        workshopRV.setAdapter(vendorInterestedWorkshopAdAdapter);
    }


    public void clickListener(){
        openBid.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openBid.setBackground(ContextCompat.getDrawable(VendorInterestedWorkshops.this, R.drawable.button_bacground));
                closeBid.setBackground(ContextCompat.getDrawable(VendorInterestedWorkshops.this, R.drawable.outline_black_button_bacground));
                noData.setVisibility(GONE);
                from = "open";
                currentPage = 1;
                lastPage = 0;
                list = new ArrayList<>();
                vendorInterestedWorkshopAdAdapter = new VendorInterestedWorkshopAdAdapter(VendorInterestedWorkshops.this , list , selectedLanguage);
                workshopRV.setAdapter(vendorInterestedWorkshopAdAdapter);
                workshopAdAPI(true);

            }
        });

        closeBid.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                closeBid.setBackground(ContextCompat.getDrawable(VendorInterestedWorkshops.this, R.drawable.button_bacground));
                openBid.setBackground(ContextCompat.getDrawable(VendorInterestedWorkshops.this, R.drawable.outline_black_button_bacground));
                noData.setVisibility(GONE);
                from = "close";
                currentPage = 1;
                lastPage = 0;
                list = new ArrayList<>();
                vendorInterestedWorkshopAdAdapter = new VendorInterestedWorkshopAdAdapter(VendorInterestedWorkshops.this , list , selectedLanguage);
                workshopRV.setAdapter(vendorInterestedWorkshopAdAdapter);
                workshopAdAPI(true);

            }
        });
    }

    private void workshopAdAPI(final boolean firstTimeCall) {

        RequestBody vendor_id = RequestBody.create(vendorId , MediaType.parse("text/plain"));
        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));
        RequestBody user_type = RequestBody.create(userType , MediaType.parse("text/plain"));
        RequestBody bid_type = RequestBody.create(from , MediaType.parse("text/plain"));
        RequestBody page = RequestBody.create(String.valueOf(currentPage) , MediaType.parse("text/plain"));


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

        if(firstTimeCall)
        {
            showProgress();
        }

        RetrofitApi retrofitApi = retrofit.create(RetrofitApi.class);

        //creating a call and calling the upload image method
        call = retrofitApi.interestedWorkshops(vendor_id , user_id , user_type , bid_type , page);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        list = response.body().getWorkshops();
                        lastPage = response.body().getTotal_page();

                        Log.e("tag" , "workshop list size is : "+list.size());
                        Log.e("tag" , "current page is : "+currentPage);
                        Log.e("tag" , "last page is : "+lastPage);
                        Log.e("tag"  ," firstTimeCall is : "+firstTimeCall);


                        if(!firstTimeCall)
                        {
                            vendorInterestedWorkshopAdAdapter.removeLoadingFooter();
                            isLoading = false;
                        }else
                        {
                            recyclerViewPaginationScroller();
                        }

                        vendorInterestedWorkshopAdAdapter.addAll(list);

                        if (lastPage != currentPage)
                        {
                            vendorInterestedWorkshopAdAdapter.addLoadingFooter();
                        }
                        else
                        {
                            isLastPage = true;
                        }

                        currentPage++;


                    }
                    else
                    {
                        noData.setVisibility(View.VISIBLE);
                        //Toast.makeText(Companies.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorInterestedWorkshops.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorInterestedWorkshops.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    public void recyclerViewPaginationScroller()
    {

        workshopRV.addOnScrollListener(new PaginationScrollListener(linearLayoutManager) {
            @Override
            protected void loadMoreItems() {
                isLoading = true;

                // mocking network delay for API call
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        workshopAdAPI(false);

                    }
                }, 100);
            }

            @Override
            public int getTotalPageCount() {
                return lastPage;
            }

            @Override
            public boolean isLastPage() {
                return isLastPage;
            }

            @Override
            public boolean isLoading() {
                return isLoading;
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