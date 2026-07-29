package com.thecontractor;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;
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
import com.thecontractor.Adapter.VendorFreelancerDashboardAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.FreelancerListModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Model.VendorDashboardCountModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.VendorActivities.VendorAddFreelancer;
import com.thecontractor.VendorActivities.VendorDashboardFreelancer;
import com.thecontractor.VendorActivities.VendorFreelancersList;
import com.thecontractor.VendorActivities.VendorFreelancingOrders;
import com.thecontractor.VendorActivities.VendorFreelancingWallet;
import com.thecontractor.VendorActivities.VendorHiredFreelancersSummary;

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

public class UserDashboardFreelancer extends AppCompatActivity {
    String selectedLanguage = "en";
    String userId;
    String userType;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;


    HorizontalScrollView horizontalScrollview;
    TextView hiredFreelancers , freelancingOrders , freelancingWallet , noData;

    LinearLayout mainLayout;
    LinearLayout editFreelancerLayout;
    TextView freelancerStatus;
    RecyclerView freelancerDashboardRV;
    RecyclerView hiringDashboardRV;
    GridLayoutManager dashboardLayoutManager ;
    GridLayoutManager dashboardLayoutManager1 ;
    ArrayList<VendorDashboardCountModel> dashboardListFreelancer;
    ArrayList<VendorDashboardCountModel> dashboardListAsBoss;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_dashboard_freelancer);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(R.string.freelancer_dashboard);
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
        if (!SharedPrefManager.getInstance(UserDashboardFreelancer.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(UserDashboardFreelancer.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(UserDashboardFreelancer.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(UserDashboardFreelancer.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();
            userType = userModel.getUser_type();

            Log.e("tag" , "user id is : "+userId);
            Log.e("tag" , "user type is : "+userType);


        }
    }

    public void initiate() {
        progressDialog = new ProgressDialog(UserDashboardFreelancer.this);

        hiredFreelancers = (TextView) findViewById(R.id.hiredFreelancers);
        freelancingOrders = (TextView) findViewById(R.id.freelancingOrders);
        freelancingWallet = (TextView) findViewById(R.id.freelancingWallet);
        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(GONE);

        dashboardListFreelancer = new ArrayList<>();
        dashboardListAsBoss = new ArrayList<>();

        mainLayout = (LinearLayout) findViewById(R.id.mainLayout);
        mainLayout.setVisibility(GONE);
        editFreelancerLayout = (LinearLayout) findViewById(R.id.editFreelancerLayout);
        editFreelancerLayout.setVisibility(GONE);
        freelancerStatus = (TextView) findViewById(R.id.freelancerStatus);


        freelancerDashboardRV = (RecyclerView) findViewById(R.id.freelancerDashboardRV);
        dashboardLayoutManager = new GridLayoutManager(UserDashboardFreelancer.this, 3, LinearLayoutManager.VERTICAL, false);
        freelancerDashboardRV.setLayoutManager(dashboardLayoutManager);

        hiringDashboardRV = (RecyclerView) findViewById(R.id.hiringDashboardRV);
        dashboardLayoutManager1 = new GridLayoutManager(UserDashboardFreelancer.this, 3, LinearLayoutManager.VERTICAL, false);
        hiringDashboardRV.setLayoutManager(dashboardLayoutManager1);

        horizontalScrollview = (HorizontalScrollView) findViewById(R.id.horizontalScrollview);

    }

    public void clickListener(){

        hiredFreelancers.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(UserDashboardFreelancer.this , VendorHiredFreelancersSummary.class);
                intent.putExtra("from" , "user");
                startActivity(intent);

                horizontalScrollview.scrollTo(0, 0);

            }
        });

        freelancingOrders.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(UserDashboardFreelancer.this , VendorFreelancingOrders.class);
                intent.putExtra("from" , "user");
                startActivity(intent);

                horizontalScrollview.scrollTo(0, 0);

            }
        });

        freelancingWallet.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(UserDashboardFreelancer.this , VendorFreelancingWallet.class);
                intent.putExtra("from" , "user");
                startActivity(intent);

                horizontalScrollview.scrollTo(0, 0);

            }
        });

        editFreelancerLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                checkUserFreelancerDataAPI();


            }
        });
    }


    private void vendorJobsStatusAPI() {

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
        call = retrofitApi.userFreelancerStatus(user_id , user_id , user_type);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {
                        mainLayout.setVisibility(VISIBLE);

                        if(response.body().getUser_freelancing_dashboard().getIs_available_as_freelance().equals("1")){
                            freelancerStatus.setText("I am avaible as freelancer.");
                        }else {
                            freelancerStatus.setText("I am not avaible as freelancer.");
                        }

                        dashboardListFreelancer = response.body().getUser_freelancing_dashboard().getAs_freelancer();
                        dashboardListAsBoss = response.body().getUser_freelancing_dashboard().getAs_boss_details();

                        Log.e("tag" , "dashboard list freelancer size is : "+dashboardListFreelancer.size());
                        Log.e("tag" , "dashboard list as boss size is : "+dashboardListAsBoss.size());


                        VendorFreelancerDashboardAdapter vendorFreelancerDashboardAdapter = new VendorFreelancerDashboardAdapter(UserDashboardFreelancer.this , dashboardListFreelancer , selectedLanguage);
                        freelancerDashboardRV.setAdapter(vendorFreelancerDashboardAdapter);


                        VendorFreelancerDashboardAdapter vendorHiringDashboardAdapter = new VendorFreelancerDashboardAdapter(UserDashboardFreelancer.this , dashboardListAsBoss , selectedLanguage);
                        hiringDashboardRV.setAdapter(vendorHiringDashboardAdapter);



                    }
                    else
                    {
                        Toast.makeText(UserDashboardFreelancer.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(UserDashboardFreelancer.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(UserDashboardFreelancer.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    private void checkUserFreelancerDataAPI() {

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
        call = retrofitApi.userFreelancerData(user_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        if(response.body().getStatus().equals("false")){
                            Intent intent = new Intent(UserDashboardFreelancer.this , VendorAddFreelancer.class);
                            Bundle b = new Bundle();
                            intent.putExtra("from" , "user");
                            b.putString("type" , "add");
                            intent.putExtras(b);
                            startActivity(intent);
                        }else {

                            FreelancerListModel freelancerListModel = response.body().getUser_freelancer_details();

                            Intent intent = new Intent(UserDashboardFreelancer.this , VendorAddFreelancer.class);
                            Bundle b = new Bundle();
                            b.putParcelable("freelancerListModel", freelancerListModel);
                            intent.putExtra("from" , "user");
                            b.putString("type" , "update");
                            intent.putExtras(b);
                            startActivity(intent);
                        }






                    }
                    else
                    {
                        Toast.makeText(UserDashboardFreelancer.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(UserDashboardFreelancer.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(UserDashboardFreelancer.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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