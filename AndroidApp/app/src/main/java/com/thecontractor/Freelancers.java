package com.thecontractor;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.RelativeLayout;
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
import com.thecontractor.Adapter.FreelancerAdapter;
import com.thecontractor.Database.FreelancerDatabaseHelper;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SelectedFreelancerDatePicker;
import com.thecontractor.Global.PaginationScrollListener;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.FreelancerListModel;
import com.thecontractor.Model.SelectedFreelancersDatabaseModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.VendorActivities.VendorDashboardJobs;

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

public class Freelancers extends AppCompatActivity implements FreelancerAdapter.SelectFreelancer{
    String from;
    String userId = "";
    String vendorId = "";
    String userType = "";

    RelativeLayout freelancerLayout ;
    TextView noData;
    RecyclerView freelancerRV;
    Button selectedFreelancerList;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<FreelancerListModel> list;

    FreelancerAdapter freelancerAdapter;

    int currentPage = 1;
    int lastPage = 0;
    private boolean isLoading = false;
    private boolean isLastPage = false;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    String selectedLanguage = "en";
    String selectedSkills = "";
    String selectedRate = "";
    String selectedCategory = "";
    String selectedCity = "";
    String companyCommissionRate;
    SelectedFreelancerDatePicker selectedFreelancerDatePicker;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_freelancers);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.freelancers));

        getDataFromActivity();
        getLanguageFromSP();

        if(from.equals("user")){
            getUserDataFromSP();
        }else if(from.equals("vendor")){
            getVendorDataFromSP();
        }

        initiate();
        getAddedFreelancer();
        clickListener();
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

    public void getDataFromActivity(){
        Intent intent = getIntent();
        from = intent.getStringExtra("from");

        Log.e("tag" , "freelancer from is : "+from);
    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(Freelancers.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(Freelancers.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }


    public void getUserDataFromSP() {
        if (!SharedPrefManager.getInstance(Freelancers.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(Freelancers.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();

            Log.e("tag" , "user id is : "+userId);

        }
    }

    public void getVendorDataFromSP() {
        if (!SharedPrefManager.getInstance(Freelancers.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(Freelancers.this).getVendorObject();
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
        progressDialog = new ProgressDialog(Freelancers.this);

        list = new ArrayList<>();
        freelancerLayout = (RelativeLayout) findViewById(R.id.freelancerLayout);
        freelancerLayout.setVisibility(GONE);
        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(GONE);

        freelancerRV = (RecyclerView) findViewById(R.id.freelancerRV);
        linearLayoutManager = new LinearLayoutManager(Freelancers.this  , LinearLayoutManager.VERTICAL , false);
        freelancerRV.setLayoutManager(linearLayoutManager);
        freelancerAdapter = new FreelancerAdapter(Freelancers.this , list  ,selectedLanguage , userId, Freelancers.this);
        freelancerRV.setAdapter(freelancerAdapter);

        selectedFreelancerList = (Button) findViewById(R.id.selectedFreelancerList);
        selectedFreelancerList.setVisibility(GONE);

        selectedFreelancerDatePicker = new SelectedFreelancerDatePicker();

        selectedFreelancerDatePicker.setOnFreelancerSelectedListener(() -> {
           if(freelancerAdapter != null){
               freelancerAdapter.notifyDataSetChanged();
               getAddedFreelancer();
           }
        });

    }

    public void getAddedFreelancer(){
        if(userId == null || userId.isEmpty()){
            return;
        }
        FreelancerDatabaseHelper dbHelper = new FreelancerDatabaseHelper(Freelancers.this);
        ArrayList<SelectedFreelancersDatabaseModel> freelancers = dbHelper.getAllFreelancers();

        Log.e("tag" , "database freelancers is : " + new Gson().toJson(freelancers));

        if(!freelancers.isEmpty()){
            selectedFreelancerList.setVisibility(VISIBLE);
            selectedFreelancerList.setText("Selected Freelancer List (" + freelancers.size()+")");
        }else {
            selectedFreelancerList.setVisibility(GONE);
        }

    }

    public void clickListener(){
        selectedFreelancerList.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                selectedFreelancerList.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Intent intent = new Intent(Freelancers.this , FreelancerCheckout.class);
                        intent.putExtra("from" , from);
                        startActivity(intent);
                    }
                });
            }
        });
    }

    private void avaiableJobsAPI(final boolean firstTimeCall) {

        RequestBody page = RequestBody.create(String.valueOf(currentPage) , MediaType.parse("text/plain"));
        RequestBody selected_skills = RequestBody.create(selectedSkills , MediaType.parse("text/plain"));
        RequestBody selected_rate = RequestBody.create(selectedRate , MediaType.parse("text/plain"));
        RequestBody selected_category = RequestBody.create(selectedCategory , MediaType.parse("text/plain"));
        RequestBody selected_city = RequestBody.create(selectedCity , MediaType.parse("text/plain"));
        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));
        RequestBody user_type = RequestBody.create(userType , MediaType.parse("text/plain"));
        RequestBody vendor_id = RequestBody.create(vendorId , MediaType.parse("text/plain"));


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
        call = retrofitApi.freelancerApi(page , selected_skills , selected_rate , selected_category , selected_city , user_id , user_type , vendor_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    freelancerLayout.setVisibility(VISIBLE);
                    companyCommissionRate = response.body().getCompany_comission_rate();
                    freelancerAdapter.getCommissionRate(companyCommissionRate);

                    if(response.body().getError().equals("false")) {

                        noData.setVisibility(GONE);


                        list = response.body().getFreelancers_list();
                        lastPage = response.body().getTotal_page();

                        Log.e("tag" , "job list size is : "+list.size());
                        Log.e("tag" , "current page is : "+currentPage);
                        Log.e("tag" , "last page is : "+lastPage);
                        Log.e("tag"  ," firstTimeCall is : "+firstTimeCall);


                        if(!firstTimeCall)
                        {
                            freelancerAdapter.removeLoadingFooter();
                            isLoading = false;
                        }else
                        {
                            recyclerViewPaginationScroller();
                        }


                        freelancerAdapter.addAll(list);

                        if (lastPage != currentPage)
                        {
                            freelancerAdapter.addLoadingFooter();
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
                        freelancerAdapter = new FreelancerAdapter(Freelancers.this , list  ,selectedLanguage , userId , Freelancers.this);
                        freelancerRV.setAdapter(freelancerAdapter);
                        noData.setVisibility(VISIBLE);
                        //Toast.makeText(Companies.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(Freelancers.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(Freelancers.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    public void recyclerViewPaginationScroller()
    {

        freelancerRV.addOnScrollListener(new PaginationScrollListener(linearLayoutManager) {
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

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_search, menu);

        MenuItem action_search = (MenuItem) menu.findItem(R.id.action_search);

        action_search.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {

                Intent intent = new Intent(Freelancers.this  ,  SearchFreelancer.class);
                Bundle b = new Bundle();
                b.putString("from" , "job");
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

                        selectedSkills = data.getStringExtra("selectedSkills");
                        selectedRate = data.getStringExtra("selectedRate");
                        selectedCategory = data.getStringExtra("selectedCategory");
                        selectedCity = data.getStringExtra("selectedCity");


                        Log.e("tag", "selectedSkills is in result back : " + selectedSkills);
                        Log.e("tag", "selectedRate is in result back : " + selectedRate);
                        Log.e("tag", "selectedCategory is in result back  : " + selectedCategory);
                        Log.e("tag", "selectedCity is in result back  : " + selectedCity);

                        list = new ArrayList<>();
                        freelancerAdapter = new FreelancerAdapter(Freelancers.this , list  ,selectedLanguage , userId , Freelancers.this);
                        freelancerRV.setAdapter(freelancerAdapter);

                        currentPage = 1;
                        avaiableJobsAPI(true);


                    }
                }
            });

    @Override
    public void selectedFreelancer(FreelancerListModel freelancerListModel , String from) {
        if(from.equals("if")) {
            getAddedFreelancer();
        }else {
            selectedFreelancerDatePicker.showSelectFreelancerDialog(this , freelancerListModel , companyCommissionRate);
        }
    }

    @Override
    protected void onResume() {
        if(freelancerAdapter != null){
            freelancerAdapter.notifyDataSetChanged();
            getAddedFreelancer();
        }
        super.onResume();
    }
}