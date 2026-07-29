package com.thecontractor.VendorActivities;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.firebase.database.ServerValue;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.pusher.client.Pusher;
import com.pusher.client.channel.Channel;
import com.pusher.client.channel.PusherEvent;
import com.pusher.client.channel.SubscriptionEventListener;
import com.thecontractor.Adapter.FreelancerChatAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.MyApp;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.FreelancerChatModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import org.json.JSONException;
import org.json.JSONObject;

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

public class VendorFreelancerChat extends AppCompatActivity {
    RelativeLayout chatLayout , bottomBar;
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
    private static final String CHANNEL_NAME = "freelancing-chats-";
    private static final String EVENT_NAME = "send-message";
    private Channel channel;

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

        implementPusher();
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

    public void implementPusher(){
        // 🔹 Ensure connected
        MyApp.connectPusher();

        // 🔹 Get Pusher
        Pusher pusher = MyApp.getPusher();

        // 🔹 Subscribe safely
        channel = MyApp.subscribeChannel(CHANNEL_NAME + orderId);

        // 🔹 Bind event
        if (channel != null) {
            channel.bind(EVENT_NAME, new SubscriptionEventListener() {
                @Override
                public void onEvent(PusherEvent event) {
                    Log.e("tag", "Pusher Data EVENT_CREATED : " + event.toString());
                    runOnUiThread(() -> {

                        if(freelancerChatAdapter == null){
                            getChat();
                        }else {

                            try {
                                JSONObject jsonObject = new JSONObject(event.getData());
                                FreelancerChatModel freelancerChatModel = new FreelancerChatModel();
                                freelancerChatModel.setMessage(jsonObject.getString("message"));
                                freelancerChatModel.setCreated_at(jsonObject.getString("created_at"));
                                freelancerChatModel.setSender_name(jsonObject.getString("sender_name"));
                                freelancerChatModel.setSender_id(jsonObject.getString("sender_id"));
                                freelancerChatModel.setOrder_id(jsonObject.getString("order_id"));
                                freelancerChatModel.setSender_type(jsonObject.getString("sender_type"));

                                Log.e("tag", "onEvent message is : "+jsonObject.getString("message"));
                               list.add(freelancerChatModel);

                                freelancerChatAdapter.notifyItemRangeInserted(list.size() , list.size());
                                chatRV.smoothScrollToPosition(list.size() - 1);

                            } catch (JSONException e) {
                                throw new RuntimeException(e);
                            }


                        }

                    });
                }
            });

        }
    }



    public void initiate()
    {
        progressDialog = new ProgressDialog(VendorFreelancerChat.this);

        chatLayout = (RelativeLayout) findViewById(R.id.chatLayout);
        bottomBar = (RelativeLayout) findViewById(R.id.bottomBar);
        bottomBar.setVisibility(GONE);
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
                    sendMessage(getTxtMessage);
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



                        if(response.body().getSending().equals("false")){
                            bottomBar.setVisibility(GONE);
                            noData.setVisibility(VISIBLE);
                            noData.setText("Order Expired / Rejected");
                        }else {
                            bottomBar.setVisibility(VISIBLE);
                            list = response.body().getChats();

                            Log.e("tag" , "list size is : "+list.size());

                            freelancerChatAdapter = new FreelancerChatAdapter(VendorFreelancerChat.this , list , userId , userType);
                            chatRV.setAdapter(freelancerChatAdapter);
                        }


                    }
                    else
                    {
                        bottomBar.setVisibility(VISIBLE);
                        noData.setVisibility(VISIBLE);
                        noData.setText(response.body().getMessage());

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



    private void sendMessage(String getTxtMessage) {

        RequestBody order_id = RequestBody.create(orderId , MediaType.parse("text/plain"));
        RequestBody message = RequestBody.create(getTxtMessage , MediaType.parse("text/plain"));
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
        call = retrofitApi.freelancerSendMessage(order_id , message , user_id , user_type);


        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {
                        messageEditText.setText("");
                        //Toast.makeText(VendorFreelancerChat.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                    else
                    {
                        Toast.makeText(VendorFreelancerChat.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
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
    protected void onDestroy() {
        super.onDestroy();
        if (channel != null) {
            MyApp.unsubscribeChannel(CHANNEL_NAME);
        }
    }
}