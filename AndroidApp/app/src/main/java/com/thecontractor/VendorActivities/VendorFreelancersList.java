package com.thecontractor.VendorActivities;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.MenuItem;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.VendorFreelancerAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.PaginationScrollListener;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.FreelancerListModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.UpdateProfile;

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

public class VendorFreelancersList extends AppCompatActivity implements VendorFreelancerAdapter.FreelancerCheckBoxClickListener{
    String userId = "";
    String vendorId = "";
    String userType = "";

    TextView noData;
    RecyclerView vendorFreelancerRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<FreelancerListModel> list;

    VendorFreelancerAdapter vendorFreelancerAdapter;

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
        setContentView(R.layout.activity_vendor_freelancers_list);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.freelancers));

        getLanguageFromSP();
        getVendorDataFromSP();
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
        if (!SharedPrefManager.getInstance(VendorFreelancersList.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorFreelancersList.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }


    public void getVendorDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorFreelancersList.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorFreelancersList.this).getVendorObject();
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
        progressDialog = new ProgressDialog(VendorFreelancersList.this);

        list = new ArrayList<>();
        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(GONE);

        vendorFreelancerRV = (RecyclerView) findViewById(R.id.vendorFreelancerRV);
        linearLayoutManager = new LinearLayoutManager(VendorFreelancersList.this  , LinearLayoutManager.VERTICAL , false);
        vendorFreelancerRV.setLayoutManager(linearLayoutManager);
        vendorFreelancerAdapter = new VendorFreelancerAdapter(VendorFreelancersList.this , list  ,selectedLanguage , VendorFreelancersList.this);
        vendorFreelancerRV.setAdapter(vendorFreelancerAdapter);


    }



    private void avaiableJobsAPI(final boolean firstTimeCall) {

        RequestBody page = RequestBody.create(String.valueOf(currentPage) , MediaType.parse("text/plain"));
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
        call = retrofitApi.vendorFreelancerApi(page , user_id , user_type , vendor_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {


                    if(response.body().getError().equals("false")) {

                        noData.setVisibility(GONE);


                        list = response.body().getCompany_freelancers_list();
                        lastPage = response.body().getTotal_page();

                        Log.e("tag" , "freelancer list size is : "+list.size());
                        Log.e("tag" , "current page is : "+currentPage);
                        Log.e("tag" , "last page is : "+lastPage);
                        Log.e("tag"  ," firstTimeCall is : "+firstTimeCall);


                        if(!firstTimeCall)
                        {
                            vendorFreelancerAdapter.removeLoadingFooter();
                            isLoading = false;
                        }else
                        {
                            recyclerViewPaginationScroller();
                        }


                        vendorFreelancerAdapter.addAll(list);

                        if (lastPage != currentPage)
                        {
                            vendorFreelancerAdapter.addLoadingFooter();
                        }
                        else
                        {
                            isLastPage = true;
                        }

                        currentPage++;







                    }
                    else
                    {
                        noData.setVisibility(VISIBLE);
                        //Toast.makeText(Companies.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorFreelancersList.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorFreelancersList.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    public void recyclerViewPaginationScroller()
    {

        vendorFreelancerRV.addOnScrollListener(new PaginationScrollListener(linearLayoutManager) {
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

    private void updateVendorFreelancerStatusAPI(FreelancerListModel freelancer, String status, int position) {

        RequestBody freelancer_id = RequestBody.create(freelancer.getId() , MediaType.parse("text/plain"));
        RequestBody user_type = RequestBody.create(userType , MediaType.parse("text/plain"));
        RequestBody vendor_id = RequestBody.create(vendorId , MediaType.parse("text/plain"));
        RequestBody mStatus = RequestBody.create(status , MediaType.parse("text/plain"));

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
        call = retrofitApi.updateVendorFreelanceStatus(freelancer_id , user_type , vendor_id , mStatus);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );

                if(response.body().isAvailable()){
                    freelancer.setIs_available_as_freelancer("1");
                }else {
                    freelancer.setIs_available_as_freelancer("0");
                }
                vendorFreelancerAdapter.notifyItemChanged(position);



                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        if(response.body().getAction().equals("incomplete") || response.body().getAction().equals("open_modal")){
                            AlertDialog alertDialog = AlertDialog(freelancer , response.body().getMessage() , response.body().getAction());
                            alertDialog.show();
                        }else if(response.body().getAction().equals("expired")){
                            AlertDialog alertDialog = AlertDialog(freelancer , response.body().getMessage() , response.body().getAction());
                            alertDialog.show();
                        }else if(response.body().getAction().equals("exists") || response.body().getAction().equals("unavailable")){

                        }



                    }
                    else
                    {
                        Toast.makeText(VendorFreelancersList.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorFreelancersList.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if(status.equals("1")){
                    freelancer.setIs_available_as_freelancer("0");
                }else {
                    freelancer.setIs_available_as_freelancer("1");
                }
                vendorFreelancerAdapter.notifyItemChanged(position);


                if(call.isCanceled())
                {
                    Log.e("tag" , "request is cancelled");
                }
                else
                {
                    hideProgress();
                    Toast.makeText(VendorFreelancersList.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }


    private AlertDialog AlertDialog(FreelancerListModel freelancer, String message , String type)
    {
        AlertDialog myDialogBox = new AlertDialog.Builder(VendorFreelancersList.this)
                // set message, title, and icon
                .setTitle("Alert")
                .setMessage(message)
                .setPositiveButton("Update", new DialogInterface.OnClickListener() {

                    public void onClick(DialogInterface dialog, int whichButton) {
                        //your deleting code
                        dialog.dismiss();
                        if(type.equals("incomplete") || type.equals("open_modal")){

                            Intent intent = new Intent(VendorFreelancersList.this , VendorAddFreelancer.class);
                            Bundle b = new Bundle();
                            b.putParcelable("freelancerListModel", freelancer);
                            intent.putExtra("from" , "vendor");
                            b.putString("type" , "update");
                            intent.putExtras(b);
                            startActivity(intent);

                        }else if(type.equals("expired")){

                        }
                    }
                })
                .setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                })
                .create();

        return myDialogBox;
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
    public void onCheckboxClicked(FreelancerListModel freelancer, String status, int position) {

        updateVendorFreelancerStatusAPI(freelancer , status , position);
    }
}