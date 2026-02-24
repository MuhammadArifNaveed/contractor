package com.thecontractor.VendorActivities;

import static android.view.View.GONE;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.database.ServerValue;
import com.google.firebase.database.annotations.Nullable;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.FreelancerChatAdapter;
import com.thecontractor.Adapter.FreelancersChatConnectionAdapter;
import com.thecontractor.Adapter.VendorChatAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.ChatModel;
import com.thecontractor.Model.FreelancerChatModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class VendorFreelancerChat extends AppCompatActivity {
    String selectedLanguage = "en";
    String orderId;
    String from;
    String userId;
    String vendorId;
    String userType;
    Call<BasicResponseModel> call;
    ProgressDialog progressDialog;
    TextView noData;
    EditText messageEditText;
    ImageView sendBtn;
    RecyclerView chatRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<FreelancerChatModel> list;
    FreelancerChatAdapter freelancerChatAdapter;
    private boolean userConnection = false;
    String getTxtMessage;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_freelancer_chat);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle("Chat");

        getLanguageFromSP();
        getDataFromPreviousActivity();

        if(from.equals("user")){
            getUserDataFromSP();
        }else if(from.equals("vendor")){
            getVendorDataFromSP();
        }

        initiate();
        clickListener();
        getChat();

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
        if (!SharedPrefManager.getInstance(VendorFreelancerChat.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorFreelancerChat.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);
        }
    }

    public void getDataFromPreviousActivity()
    {
        Intent intent = getIntent();
        orderId = intent.getStringExtra("orderId");
        from = intent.getStringExtra("from");

        Log.e("tag" , "orderId is :" +orderId);
        Log.e("tag" , "from is :" +from);
    }

    public void getUserDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorFreelancerChat.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorFreelancerChat.this).getUserObject();
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
        if (!SharedPrefManager.getInstance(VendorFreelancerChat.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorFreelancerChat.this).getVendorObject();
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
        progressDialog = new ProgressDialog(VendorFreelancerChat.this);

        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(GONE);
        messageEditText = findViewById(R.id.messageEditTxt);
        sendBtn = findViewById(R.id.sendBtn);
        list = new ArrayList<>();
        chatRV = (RecyclerView) findViewById(R.id.chatRV);
        linearLayoutManager = new LinearLayoutManager(VendorFreelancerChat.this  , LinearLayoutManager.VERTICAL , false);
        linearLayoutManager.setStackFromEnd(true);
        chatRV.setLayoutManager(linearLayoutManager);



        Log.e("tag" , "current server time : "+ ServerValue.TIMESTAMP);

    }



    public void clickListener()
    {
        sendBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                getTxtMessage = messageEditText.getText().toString();

                if(getTxtMessage.equals(""))
                {
                    Toast.makeText(VendorFreelancerChat.this, "Write message before send", Toast.LENGTH_SHORT).show();
                }else
                {
                    //sendNotification(getTxtMessage);
                }

            }
        });

    }


    private void getChat() {

        RequestBody order_id = RequestBody.create(orderId , MediaType.parse("text/plain"));



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
        call = retrofitApi.freelancerOrderChat(order_id);


        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        list = response.body().getChats();

                        Log.e("tag" , "list size is : "+list.size());

                        freelancerChatAdapter = new FreelancerChatAdapter(VendorFreelancerChat.this , list , selectedLanguage , userId);
                        chatRV.setAdapter(freelancerChatAdapter);

                    }
                    else
                    {
                        noData.setVisibility(View.VISIBLE);
                        //Toast.makeText(Companies.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorFreelancerChat.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorFreelancerChat.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }



//    private void sendNotification(String message) {
//
//        RequestBody msg = RequestBody.create(message , MediaType.parse("text/plain"));
//        RequestBody user_name = RequestBody.create(userName , MediaType.parse("text/plain"));
//        RequestBody chat_uuid = RequestBody.create(chatUUID , MediaType.parse("text/plain"));
//        RequestBody vendor_serial_no = RequestBody.create(vendorSerialNo , MediaType.parse("text/plain"));
//
//        //The gson builder
//        Gson gson = new GsonBuilder()
//                .setLenient()
//                .create();
//
//        OkHttpClient okHttpClient = new OkHttpClient().newBuilder()
//                .connectTimeout(120, TimeUnit.SECONDS)
//                .readTimeout(120, TimeUnit.SECONDS)
//                .writeTimeout(120, TimeUnit.SECONDS)
//                .build();
//
//        //creating retrofit object
//        Retrofit retrofit = new Retrofit.Builder()
//                .baseUrl(ApiUrls.API_URL)
//                .client(SSSHandShake.getUnsafeOkHttpClient())
//                .addConverterFactory(GsonConverterFactory.create(gson))
//                .build();
//
//        showProgress();
//
//
//        RetrofitApi retrofitApi = retrofit.create(RetrofitApi.class);
//
//        //creating a call and calling the upload image method
//        call = retrofitApi.sendNotificationVendor(msg , user_name , chat_uuid , vendor_serial_no);
//
//        //finally performing the call
//        call.enqueue(new Callback<BasicResponseModel>() {
//            @Override
//            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {
//
//
//                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );
//
//
//                hideProgress();
//                if(response.isSuccessful())
//                {
//                    if(response.body().getError().equals("false")) {
//
//                        Log.e("tag" , response.body().getMessage());
//
//                    }
//                    else
//                    {
//                        Log.e("tag" , response.body().getMessage());
//                    }
//                }
//                else
//                {
//                    Toast.makeText(VendorFreelancerChat.this, "error : "+response.code(), Toast.LENGTH_SHORT).show();
//                }
//
//            }
//
//            @Override
//            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
//                if(call.isCanceled())
//                {
//                    Log.e("tag" , "request is cancelled");
//                }
//                else
//                {
//                    hideProgress();
//                    Toast.makeText(VendorFreelancerChat.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
//                    Log.e("tag", "on failure error : " + t.getMessage());
//
//                }
//            }
//        });
//    }



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