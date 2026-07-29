package com.thecontractor.VendorActivities;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;

import com.google.android.material.navigation.NavigationView;

import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.content.ContextCompat;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.os.Handler;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.VendorEnquiriesDashboardAdapter;
import com.thecontractor.Adapter.VendorEnquiriesAdapter;
import com.thecontractor.Freelancers;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Home;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.VendorDashboardCountModel;
import com.thecontractor.Model.VendorEnquiryModel;
import com.thecontractor.Model.VendorSharedPrefModel;
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

public class VendorHome extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener{
    DrawerLayout drawerLayout;
    NavigationView navigationView;

    TextView userName, viewProfile;
    LinearLayout headerLayout;

    boolean doubleBackToExitPressedOnce = false;

    LinearLayout vendorHomeLayout;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    TextView noData;


    RecyclerView dashboardRV;
    GridLayoutManager dashboardLayoutManager ;
    ArrayList<VendorDashboardCountModel> dashboardList;

    LinearLayout pendingEnquiriesLayout;
    RecyclerView pendingEnquiriesRV;
    LinearLayoutManager pendingEnquiriesLinearLayoutManager ;
    ArrayList<VendorEnquiryModel> pendingEnquiriesList;

    LinearLayout acceptedEnquiriesLayout;
    RecyclerView acceptedEnquiriesRV;
    LinearLayoutManager acceptedEnquiriesLinearLayoutManager ;
    ArrayList<VendorEnquiryModel> acceptedEnquiriesList;

    LinearLayout todayEnquiriesLayout;
    RecyclerView todayEnquiriesRV;
    LinearLayoutManager todayEnquiriesLinearLayoutManager ;
    ArrayList<VendorEnquiryModel> todayEnquiriesList;

    String selectedLanguage = "en";
    String vendorId;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_home);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setTitle("");


        initiate(toolbar);
        clickListener();
        getDataFromSP();
        getLanguageFromSP();
        vendorDashBoardAPI();

    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(VendorHome.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorHome.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorHome.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorHome.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();

            userName.setText(vendorModel.getCompany_name());

            Log.e("tag" , "Vendor id is : "+vendorId + " company name : "+vendorModel.getCompany_name());


        }
    }

    public void initiate(Toolbar toolbar)
    {

        progressDialog = new ProgressDialog(VendorHome.this);

        vendorHomeLayout = (LinearLayout) findViewById(R.id.vendorHomeLayout);
        vendorHomeLayout.setVisibility(View.GONE);



        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(View.GONE);

        dashboardList = new ArrayList<>();
        dashboardRV = (RecyclerView) findViewById(R.id.dashboardRV);
        dashboardLayoutManager = new GridLayoutManager(VendorHome.this  ,  3 , LinearLayoutManager.VERTICAL , false);
        dashboardRV.setLayoutManager(dashboardLayoutManager);
       



        pendingEnquiriesLayout = (LinearLayout) findViewById(R.id.pendingEnquiriesLayout);
        pendingEnquiriesLayout.setVisibility(View.GONE);
        pendingEnquiriesList = new ArrayList<>();
        pendingEnquiriesRV = (RecyclerView) findViewById(R.id.pendingEnquiriesRV);
        pendingEnquiriesLinearLayoutManager = new LinearLayoutManager(VendorHome.this  ,  LinearLayoutManager.HORIZONTAL , false);
        pendingEnquiriesRV.setLayoutManager(pendingEnquiriesLinearLayoutManager);


        acceptedEnquiriesLayout = (LinearLayout) findViewById(R.id.acceptedEnquiriesLayout);
        acceptedEnquiriesLayout.setVisibility(View.GONE);
        acceptedEnquiriesList = new ArrayList<>();
        acceptedEnquiriesRV = (RecyclerView) findViewById(R.id.acceptedEnquiriesRV);
        acceptedEnquiriesLinearLayoutManager = new LinearLayoutManager(VendorHome.this  ,  LinearLayoutManager.HORIZONTAL , false);
        acceptedEnquiriesRV.setLayoutManager(acceptedEnquiriesLinearLayoutManager);


        todayEnquiriesLayout = (LinearLayout) findViewById(R.id.todayEnquiriesLayout);
        todayEnquiriesLayout.setVisibility(View.GONE);
        todayEnquiriesList = new ArrayList<>();
        todayEnquiriesRV = (RecyclerView) findViewById(R.id.todayEnquiriesRV);
        todayEnquiriesLinearLayoutManager = new LinearLayoutManager(VendorHome.this  ,  LinearLayoutManager.VERTICAL , false);
        todayEnquiriesRV.setLayoutManager(todayEnquiriesLinearLayoutManager);


        drawerLayout = findViewById(R.id.drawer_layout_vendor);
        drawerLayout.closeDrawer(GravityCompat.START);
        drawerLayout.setStatusBarBackgroundColor(ContextCompat.getColor(this, R.color.white));

        navigationView = findViewById(R.id.nav_view);

        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawerLayout, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close) {
            @Override
            public void onDrawerClosed(View drawerView) {
                super.onDrawerClosed(drawerView);
            }

            @Override
            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);

                InputMethodManager inputMethodManager = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);

                if (inputMethodManager.isAcceptingText()) {
                    inputMethodManager.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
                }
            }

            @Override
            public void onDrawerSlide(View drawerView, float slideOffset) {
                super.onDrawerSlide(drawerView, slideOffset);


                InputMethodManager inputMethodManager = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);

                if (inputMethodManager.isAcceptingText()) {
                    inputMethodManager.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
                }
            }
        };
        drawerLayout.addDrawerListener(toggle);
        toggle.syncState();

        navigationView.setNavigationItemSelectedListener(this);

        View view = navigationView.getHeaderView(0);
        userName = (TextView) view.findViewById(R.id.userName);
        viewProfile = (TextView) view.findViewById(R.id.viewProfile);
        headerLayout = (LinearLayout) view.findViewById(R.id.headerLayout);

    }

    public void clickListener()
    {
        headerLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(VendorHome.this , VendorProfile.class);
                startActivity(intent);
            }
        });

        viewProfile.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(VendorHome.this , VendorProfile.class);
                startActivity(intent);
            }
        });
    }

    private void vendorDashBoardAPI() {

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
        call = retrofitApi.vendorDashboard(id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        vendorHomeLayout.setVisibility(View.VISIBLE);

                        dashboardList = response.body().getVendor_dashboard_counts();
                        acceptedEnquiriesList = response.body().getAccepted_enquiries();
                        todayEnquiriesList = response.body().getToday_enquiries();
                        pendingEnquiriesList = response.body().getPending_enquiries();

                        Log.e("tag" , "dashboard list size is : "+dashboardList.size());
                        Log.e("tag" , "accepted enquiries list size is : "+acceptedEnquiriesList.size());
                        Log.e("tag" , "today enquiriesList list size is : "+todayEnquiriesList.size());
                        Log.e("tag" , "pending enquiriesList list size is : "+pendingEnquiriesList.size());


                        VendorEnquiriesDashboardAdapter vendorDashboardAdapter = new VendorEnquiriesDashboardAdapter(VendorHome.this , dashboardList , selectedLanguage);
                        dashboardRV.setAdapter(vendorDashboardAdapter);

                        if(pendingEnquiriesList.size() > 0)
                        {
                            pendingEnquiriesLayout.setVisibility(View.VISIBLE);

                            VendorEnquiriesAdapter vendorEnquiriesAdapter = new VendorEnquiriesAdapter(VendorHome.this , pendingEnquiriesList , selectedLanguage , "pending");
                            pendingEnquiriesRV.setAdapter(vendorEnquiriesAdapter);

                        }else
                        {
                            pendingEnquiriesLayout.setVisibility(View.GONE);
                        }


                        if(acceptedEnquiriesList.size() > 0)
                        {
                            acceptedEnquiriesLayout.setVisibility(View.VISIBLE);

                            VendorEnquiriesAdapter vendorEnquiriesAdapter = new VendorEnquiriesAdapter(VendorHome.this , acceptedEnquiriesList , selectedLanguage , "accepted");
                            acceptedEnquiriesRV.setAdapter(vendorEnquiriesAdapter);


                        }else
                        {
                            acceptedEnquiriesLayout.setVisibility(View.GONE);

                        }

                        if(todayEnquiriesList.size() > 0)
                        {
                            todayEnquiriesLayout.setVisibility(View.VISIBLE);

                            VendorEnquiriesAdapter vendorEnquiriesAdapter = new VendorEnquiriesAdapter(VendorHome.this , todayEnquiriesList , selectedLanguage , "today");
                            todayEnquiriesRV.setAdapter(vendorEnquiriesAdapter);

                        }else
                        {
                            todayEnquiriesLayout.setVisibility(View.GONE);
                        }




                    }
                    else
                    {
                        noData.setVisibility(View.VISIBLE);
                        Toast.makeText(VendorHome.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorHome.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorHome.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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


    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        int id = item.getItemId();

        if (id == R.id.nav_home) {
            Intent intent = new Intent(VendorHome.this , VendorHome.class);
            startActivity(intent);
            finish();
        }else if (id == R.id.nav_inbox) {
            Intent intent = new Intent(VendorHome.this , VendorChatConnection.class);
            startActivity(intent);
        }else if (id == R.id.nav_vendor_rating) {
            Intent intent = new Intent(VendorHome.this , VendorRating.class);
            startActivity(intent);
        }else if (id == R.id.nav_vendor_enquiries) {
            Intent intent = new Intent(VendorHome.this , VendorDashboardEnquiries.class);
            startActivity(intent);
        }else if (id == R.id.nav_vendor_quotations) {
            Intent intent = new Intent(VendorHome.this , VendorDashboardQuotations.class);
            startActivity(intent);
        }else if (id == R.id.nav_vendor_post_workshop) {
            Intent intent = new Intent(VendorHome.this , VendorPostWorkshop.class);
            startActivity(intent);
        }else if (id == R.id.nav_vendor_workshop) {
            Intent intent = new Intent(VendorHome.this , WorkShopAds.class);
            intent.putExtra("type" , "vendor");
            startActivity(intent);
        }else if (id == R.id.nav_vendor_all_workshop) {
            Intent intent = new Intent(VendorHome.this , VendorAllWorkshopsAds.class);
            startActivity(intent);
        }else if (id == R.id.nav_vendor_interested_workshop) {
            Intent intent = new Intent(VendorHome.this , VendorInterestedWorkshops.class);
            startActivity(intent);
        }else if (id == R.id.nav_vendor_jobs) {
            Intent intent = new Intent(VendorHome.this , VendorDashboardJobs.class);
            startActivity(intent);
        }else if (id == R.id.nav_vendor_applicants) {
            Intent intent = new Intent(VendorHome.this , VendorApplicants.class);
            startActivity(intent);
        }else if (id == R.id.nav_vendor_freelancer) {
            Intent intent = new Intent(VendorHome.this, Freelancers.class);
            intent.putExtra("from" , "vendor");
            startActivity(intent);
        }else if (id == R.id.nav_vendor_freelancer_dashboard) {
            Intent intent = new Intent(VendorHome.this, VendorDashboardFreelancer.class);
            startActivity(intent);
        }else if (id == R.id.nav_vendor_membership) {
            Intent intent = new Intent(VendorHome.this , VendorMembership.class);
            startActivity(intent);
        }else if (id == R.id.nav_vendor_my_membership) {
            Intent intent = new Intent(VendorHome.this , VendorMyMembership.class);
            startActivity(intent);
        }else if (id == R.id.nav_vendor_logout) {
            AlertDialog alertDialog = AlertDialog();
            alertDialog.show();
        }

        DrawerLayout drawer = findViewById(R.id.drawer_layout_vendor);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }

    private AlertDialog AlertDialog() {
        AlertDialog myDialogBox = new AlertDialog.Builder(VendorHome.this)
                // set message, title, and icon
                .setTitle(getResources().getString(R.string.logout))
                .setMessage(getResources().getString(R.string.want_to_logout))

                .setPositiveButton(getResources().getString(R.string.yes), new DialogInterface.OnClickListener() {

                    public void onClick(DialogInterface dialog, int whichButton) {
                        //your deleting code
                        dialog.dismiss();

                        logout();
                    }

                })
                .setNegativeButton(getResources().getString(R.string.no), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {

                        dialog.dismiss();

                    }
                })
                .create();

        return myDialogBox;
    }


    public void logout() {

        SharedPrefManager.getInstance(VendorHome.this).userLogout();

        Intent intent = new Intent(VendorHome.this, Home.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        finish();

    }

    @Override
    public void onBackPressed() {
        if (drawerLayout.isDrawerOpen(GravityCompat.START)) {
            drawerLayout.closeDrawer(GravityCompat.START);
        } else {


            if (doubleBackToExitPressedOnce) {
                super.onBackPressed();
                return;
            }

            this.doubleBackToExitPressedOnce = true;
            Toast.makeText(this, getResources().getString(R.string.press_again_to_exit), Toast.LENGTH_SHORT).show();

            new Handler().postDelayed(new Runnable() {

                @Override
                public void run() {
                    doubleBackToExitPressedOnce = false;
                }
            }, 2000);



        }
    }


}