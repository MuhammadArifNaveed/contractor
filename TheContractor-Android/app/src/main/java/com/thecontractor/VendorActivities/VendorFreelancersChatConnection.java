package com.thecontractor.VendorActivities;

import static android.view.View.GONE;

import android.app.ProgressDialog;
import android.content.Intent;
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
import com.thecontractor.Adapter.FreelancersChatConnectionAdapter;
import com.thecontractor.Adapter.VendorInterestedWorkshopAdAdapter;
import com.thecontractor.Freelancers;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.PaginationScrollListener;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.FreelancersChatConnectionModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.Model.WorkshopAdModel;
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

public class VendorFreelancersChatConnection extends AppCompatActivity {
    String from;
    String userId;
    String vendorId;
    String userType;

    TextView noData;
    RecyclerView workshopRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<FreelancersChatConnectionModel> list;

    FreelancersChatConnectionAdapter freelancersChatConnectionAdapter;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    String selectedLanguage = "en";

    Button placedChat , receivedChat;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_freelancer_chat_connection);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle("Chat");

        getDataFromActivity();
        getLanguageFromSP();

        if(from.equals("user")){
            getUserDataFromSP();
        }else if(from.equals("vendor")){
            getVendorDataFromSP();
        }

        initiate();
        clickListener();
        workshopAdAPI("received");


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
        if (!SharedPrefManager.getInstance(VendorFreelancersChatConnection.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorFreelancersChatConnection.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }



    public void getUserDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorFreelancersChatConnection.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorFreelancersChatConnection.this).getUserObject();
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
        if (!SharedPrefManager.getInstance(VendorFreelancersChatConnection.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorFreelancersChatConnection.this).getVendorObject();
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
        progressDialog = new ProgressDialog(VendorFreelancersChatConnection.this);

        list = new ArrayList<>();
        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(GONE);

        placedChat = (Button) findViewById(R.id.placedChat);
        receivedChat = (Button) findViewById(R.id.receivedChat);

        workshopRV = (RecyclerView) findViewById(R.id.workshopRV);
        linearLayoutManager = new LinearLayoutManager(VendorFreelancersChatConnection.this  , LinearLayoutManager.VERTICAL , false);
        workshopRV.setLayoutManager(linearLayoutManager);

    }


    public void clickListener(){
        placedChat.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                placedChat.setBackground(ContextCompat.getDrawable(VendorFreelancersChatConnection.this, R.drawable.button_bacground));
                receivedChat.setBackground(ContextCompat.getDrawable(VendorFreelancersChatConnection.this, R.drawable.outline_black_button_bacground));
                noData.setVisibility(GONE);
                list = new ArrayList<>();
                freelancersChatConnectionAdapter = new FreelancersChatConnectionAdapter(VendorFreelancersChatConnection.this , list , from);
                workshopRV.setAdapter(freelancersChatConnectionAdapter);
                workshopAdAPI("placed");

            }
        });

        receivedChat.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                receivedChat.setBackground(ContextCompat.getDrawable(VendorFreelancersChatConnection.this, R.drawable.button_bacground));
                placedChat.setBackground(ContextCompat.getDrawable(VendorFreelancersChatConnection.this, R.drawable.outline_black_button_bacground));
                noData.setVisibility(GONE);
                list = new ArrayList<>();
                freelancersChatConnectionAdapter = new FreelancersChatConnectionAdapter(VendorFreelancersChatConnection.this , list , from);
                workshopRV.setAdapter(freelancersChatConnectionAdapter);
                workshopAdAPI("received");

            }
        });
    }

    private void workshopAdAPI(String type) {

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
        if (type.equals("placed")){
            call = retrofitApi.freelancersPlacedChatConnection(vendor_id , user_id , user_type);
        }else{
            call = retrofitApi.freelancersReceivedChatConnection(vendor_id , user_id , user_type);
        }

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        list = response.body().getOrder_chats();

                        Log.e("tag" , "workshop list size is : "+list.size());

                        freelancersChatConnectionAdapter = new FreelancersChatConnectionAdapter(VendorFreelancersChatConnection.this , list , from);
                        workshopRV.setAdapter(freelancersChatConnectionAdapter);

                    }
                    else
                    {
                        noData.setVisibility(View.VISIBLE);
                        //Toast.makeText(Companies.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorFreelancersChatConnection.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorFreelancersChatConnection.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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