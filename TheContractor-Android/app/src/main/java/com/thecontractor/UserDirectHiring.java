package com.thecontractor;

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

import androidx.activity.EdgeToEdge;
import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.AvailableJobAdapter;
import com.thecontractor.Adapter.UserDirectHiringAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.PaginationScrollListener;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.AvailableJobListingModel;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.UserDirectHiringModel;
import com.thecontractor.Model.UserModel;
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

public class UserDirectHiring extends AppCompatActivity {
    String userId;
    TextView noData;
    RecyclerView userDirectHiringRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<UserDirectHiringModel> list;

    UserDirectHiringAdapter userDirectHiringAdapter;

    int currentPage = 1;
    int lastPage = 0;
    private boolean isLoading = false;
    private boolean isLastPage = false;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    String selectedLanguage = "en";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_direct_hiring);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle("Direct Hiring");

        getLanguageFromSP();
        getDataFromSP();
        initiate();
        avaiableJobsAPI(true);
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
        if (!SharedPrefManager.getInstance(UserDirectHiring.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(UserDirectHiring.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(UserDirectHiring.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(UserDirectHiring.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();

            Log.e("tag" , "user id is : "+userId);

        }
    }

    public void initiate()
    {
        progressDialog = new ProgressDialog(UserDirectHiring.this);

        list = new ArrayList<>();
        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(View.GONE);

        userDirectHiringRV = (RecyclerView) findViewById(R.id.userDirectHiringRV);
        linearLayoutManager = new LinearLayoutManager(UserDirectHiring.this  , LinearLayoutManager.VERTICAL , false);
        userDirectHiringRV.setLayoutManager(linearLayoutManager);
        userDirectHiringAdapter = new UserDirectHiringAdapter(UserDirectHiring.this , list  ,selectedLanguage);
        userDirectHiringRV.setAdapter(userDirectHiringAdapter);

    }

    private void avaiableJobsAPI(final boolean firstTimeCall) {

        RequestBody page = RequestBody.create(String.valueOf(currentPage) , MediaType.parse("text/plain"));
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

        if(firstTimeCall)
        {
            showProgress();
        }

        RetrofitApi retrofitApi = retrofit.create(RetrofitApi.class);

        //creating a call and calling the upload image method
        call = retrofitApi.userDirectHiringApi(page , user_id);

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


                        list = response.body().getUser_direct_selections();
                        lastPage = response.body().getTotal_page();

                        Log.e("tag" , "list size is : "+list.size());
                        Log.e("tag" , "current page is : "+currentPage);
                        Log.e("tag" , "last page is : "+lastPage);
                        Log.e("tag"  ," firstTimeCall is : "+firstTimeCall);


//                        if(!firstTimeCall)
//                        {
//                            userDirectHiringAdapter.removeLoadingFooter();
//                            isLoading = false;
//                        }else
//                        {
//                            recyclerViewPaginationScroller();
//                        }

                        userDirectHiringAdapter.addAll(list);

//                        if (lastPage != currentPage)
//                        {
//                            userDirectHiringAdapter.addLoadingFooter();
//                        }
//                        else
//                        {
//                            isLastPage = true;
//                        }
//
//                        currentPage++;







                    }
                    else
                    {
                        noData.setVisibility(View.VISIBLE);
                        //Toast.makeText(Companies.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(UserDirectHiring.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(UserDirectHiring.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    public void recyclerViewPaginationScroller()
    {

        userDirectHiringRV.addOnScrollListener(new PaginationScrollListener(linearLayoutManager) {
            @Override
            protected void loadMoreItems() {
                isLoading = true;

                // mocking network delay for API call
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        avaiableJobsAPI(false);

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