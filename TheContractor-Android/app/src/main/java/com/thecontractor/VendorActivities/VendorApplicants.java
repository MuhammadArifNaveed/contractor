package com.thecontractor.VendorActivities;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.VendorApplicantAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.PaginationScrollListener;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.VendorApplicantListingModel;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.SearchJobsAndApplicant;

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

public class VendorApplicants extends AppCompatActivity {
    String userId;
    TextView noData;
    RecyclerView availableApplicantRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<VendorApplicantListingModel> list;

    VendorApplicantAdapter availableApplicantAdapter;

    int currentPage = 1;
    int lastPage = 0;
    private boolean isLoading = false;
    private boolean isLastPage = false;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    String selectedLanguage = "en";
    String selectedCategory = "";
    String selectedCity = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_applicants);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.available_applicant));

        getLanguageFromSP();
        getDataFromSP();
        initiate();
        availableApplicantAPI(true);
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
        if (!SharedPrefManager.getInstance(VendorApplicants.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorApplicants.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorApplicants.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorApplicants.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();

            Log.e("tag" , "user id is : "+userId);

        }
    }

    public void initiate()
    {
        progressDialog = new ProgressDialog(VendorApplicants.this);

        list = new ArrayList<>();
        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(View.GONE);

        availableApplicantRV = (RecyclerView) findViewById(R.id.availableApplicantRV);
        linearLayoutManager = new LinearLayoutManager(VendorApplicants.this  , LinearLayoutManager.VERTICAL , false);
        availableApplicantRV.setLayoutManager(linearLayoutManager);
        availableApplicantAdapter = new VendorApplicantAdapter(VendorApplicants.this , list  ,selectedLanguage);
        availableApplicantRV.setAdapter(availableApplicantAdapter);

    }

    private void availableApplicantAPI(final boolean firstTimeCall) {

        RequestBody page = RequestBody.create(String.valueOf(currentPage) , MediaType.parse("text/plain"));
        RequestBody selected_category = RequestBody.create(selectedCategory , MediaType.parse("text/plain"));
        RequestBody selected_city = RequestBody.create(selectedCity , MediaType.parse("text/plain"));

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
        call = retrofitApi.availableApplicantApi(page , selected_category , selected_city);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        noData.setVisibility(View.GONE);

                        list = response.body().getAvailable_users();
                        lastPage = response.body().getTotal_page();

                        Log.e("tag" , "enquiries list size is : "+list.size());
                        Log.e("tag" , "current page is : "+currentPage);
                        Log.e("tag" , "last page is : "+lastPage);
                        Log.e("tag"  ," firstTimeCall is : "+firstTimeCall);


                        if(!firstTimeCall)
                        {
                            availableApplicantAdapter.removeLoadingFooter();
                            isLoading = false;
                        }else
                        {
                            recyclerViewPaginationScroller();
                        }

                        availableApplicantAdapter.addAll(list);

                        if (lastPage != currentPage)
                        {
                            availableApplicantAdapter.addLoadingFooter();
                        }
                        else
                        {
                            isLastPage = true;
                        }

                        currentPage++;







                    }
                    else
                    {
                        list = new ArrayList<>();
                        availableApplicantAdapter = new VendorApplicantAdapter(VendorApplicants.this , list  ,selectedLanguage);
                        availableApplicantRV.setAdapter(availableApplicantAdapter);
                        noData.setVisibility(View.VISIBLE);
                        //Toast.makeText(Companies.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorApplicants.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorApplicants.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    public void recyclerViewPaginationScroller()
    {

        availableApplicantRV.addOnScrollListener(new PaginationScrollListener(linearLayoutManager) {
            @Override
            protected void loadMoreItems() {
                isLoading = true;

                // mocking network delay for API call
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        availableApplicantAPI(false);

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

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_search, menu);

        MenuItem action_search = (MenuItem) menu.findItem(R.id.action_search);

        action_search.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {

                Intent intent = new Intent(VendorApplicants.this  ,  SearchJobsAndApplicant.class);
                Bundle b = new Bundle();
                b.putString("from" , "applicant");
                intent.putExtras(b);
                searchResultLauncher.launch(intent);

                return false;
            }
        });

        return super.onCreateOptionsMenu(menu);
    }

    ActivityResultLauncher<Intent> searchResultLauncher = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(),
            new ActivityResultCallback<ActivityResult>() {
                @Override
                public void onActivityResult(ActivityResult result) {
                    if (result.getResultCode() == Activity.RESULT_OK) {

                        Intent data = result.getData();

                        selectedCategory = data.getStringExtra("selectedJobCategory");
                        selectedCity = data.getStringExtra("selectedJobCity");


                        Log.e("tag", "selectedCategory is in result back  : " + selectedCategory);
                        Log.e("tag", "selectedCity is in result back  : " + selectedCity);

                        list = new ArrayList<>();
                        availableApplicantAdapter = new VendorApplicantAdapter(VendorApplicants.this , list  ,selectedLanguage);
                        availableApplicantRV.setAdapter(availableApplicantAdapter);

                        currentPage = 1;
                        availableApplicantAPI(true);


                    }
                }
            });
}