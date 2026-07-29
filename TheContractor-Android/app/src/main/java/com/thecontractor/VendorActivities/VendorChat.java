package com.thecontractor.VendorActivities;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;

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
import com.google.gson.JsonArray;
import com.google.gson.JsonIOException;
import com.google.gson.JsonObject;
import com.thecontractor.Adapter.VendorChatAdapter;
import com.thecontractor.Complaints;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.ChatModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
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

public class VendorChat extends AppCompatActivity {
    String selectedLanguage = "en";
    String vendorId;
    String vendorSerialNo;
    String vendorName;
    String vendorUUID;
    String chatUUID;
    String documentID;
    String userId;
    String userName;
    String fullName;
    String userUUID;
    String countryDateTime;
    FirebaseFirestore db;
    Call<BasicResponseModel> call;
    ProgressDialog progressDialog;
    EditText messageEditText;
    ImageView sendBtn;
    RecyclerView chatRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<ChatModel> list;
    VendorChatAdapter chatAdapter;
    private boolean userConnection = false;
    String getTxtMessage;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_chat);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle("Chat");

        getLanguageFromSP();
        getDataFromSP();
        getUUID();
        getDataFromPreviousActivity();
        initiate();
        checkUserConnectionFromFireStore();
        clickListener();
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
        if (!SharedPrefManager.getInstance(VendorChat.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorChat.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);
        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorChat.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorChat.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();
            vendorSerialNo = vendorModel.getCompany_serial_number();
            vendorName = vendorModel.getCompany_name();
            vendorUUID = vendorModel.getUuid();


            Log.e("tag" , "Vendor id is : "+vendorId);
            Log.e("tag" , "Vendor name is : "+vendorName);
            Log.e("tag" , "Vendor uuid is : "+vendorUUID);



        }
    }

    public void getDataFromPreviousActivity()
    {
        Intent intent = getIntent();
        userId = intent.getStringExtra("userId");
        userName = intent.getStringExtra("userName");
        fullName = intent.getStringExtra("fullName");
        userUUID = intent.getStringExtra("userUUID");

        Log.e("tag" , "user id is :" +userId);
        Log.e("tag" , "user name is :" +userName);
        Log.e("tag" , "full name is :" +fullName);
        Log.e("tag" , "user uuid is :" +userUUID);
    }

    public void getUUID()
    {
        chatUUID = UUID.randomUUID().toString();

        Log.e("tag" , "chat uuid is : "+chatUUID);

    }

    public void initiate()
    {
        progressDialog = new ProgressDialog(VendorChat.this);

        db = FirebaseFirestore.getInstance();
        messageEditText = findViewById(R.id.messageEditTxt);
        sendBtn = findViewById(R.id.sendBtn);
        list = new ArrayList<>();
        chatRV = (RecyclerView) findViewById(R.id.chatRV);
        linearLayoutManager = new LinearLayoutManager(VendorChat.this  , LinearLayoutManager.VERTICAL , false);
        linearLayoutManager.setStackFromEnd(true);
        chatRV.setLayoutManager(linearLayoutManager);

        chatAdapter = new VendorChatAdapter(VendorChat.this , list , selectedLanguage , vendorUUID);
        chatRV.setAdapter(chatAdapter);

        Log.e("tag" , "current server time : "+ ServerValue.TIMESTAMP);

    }

    public void checkUserConnectionFromFireStore()
    {
        showProgress();
        db.collection("user_connections")
                .whereEqualTo("company_uuid", vendorUUID )
                .whereEqualTo("user_uuid" , userUUID)
                .get()
                .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<QuerySnapshot> task) {
                        if (task.isSuccessful()) {


                            boolean isEmpty = task.getResult().isEmpty();

                            if(isEmpty)
                            {
                                hideProgress();
                                userConnection = false;
                                Log.e("tag" , "connection not created");

                            }else
                            {
                                userConnection = true;
                                Log.e("tag" , "connection already created");
                                DocumentSnapshot documentSnapshot = task.getResult().getDocuments().get(0);
                                chatUUID = documentSnapshot.getString("chat_uuid");
                                documentID = documentSnapshot.getId();
                                Log.e("tag" , "chat uuid is : "+chatUUID);
                                getMessagesFromFireStore(chatUUID);
                            }
                        }
                    }
                });
    }

    public void createUserConnectionOnFireStore()
    {
        Map<String, Object> user = new HashMap<>();
        user.put("company_id", vendorId);
        user.put("company_uuid", vendorUUID);
        user.put("company_serial_no", vendorSerialNo);
        user.put("company_name", vendorName);
        user.put("company_is_active", "1");
        user.put("user_id", userId);
        user.put("user_uuid", userUUID);
        user.put("user_name", userName);
        user.put("full_name", fullName);
        user.put("user_is_active", "1");
        user.put("is_active", "1");
        user.put("chat_uuid", chatUUID);
        user.put("created_at", getCurrentDateTime());
        user.put("last_message", "");
        user.put("message_time", "");

        //Add a new document with a generated ID
        db.collection("user_connections")
                .add(user)
                .addOnSuccessListener(new OnSuccessListener<DocumentReference>() {
                    @Override
                    public void onSuccess(DocumentReference documentReference) {
                        Log.e("tag", "DocumentSnapshot added with ID: " + documentReference.getId());
                        documentID = documentReference.getId();

                        sendMessageFirebase(getTxtMessage);
                        getMessagesFromFireStore(chatUUID);

                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        Log.e("tag", "Error adding document", e);
                        Toast.makeText(VendorChat.this, "User not created on database", Toast.LENGTH_SHORT).show();
                    }
                });



    }

    public void getMessagesFromFireStore(String chatUUID)
    {

        db.collection("chat")
                .whereEqualTo("chat_uuid", chatUUID)
                .orderBy("country_time")
                .addSnapshotListener(new EventListener<QuerySnapshot>() {
                    @Override
                    public void onEvent(@Nullable QuerySnapshot snapshots, @Nullable FirebaseFirestoreException e) {
                        if (e != null) {
                            Log.e("tag", "listen:error", e);
                            return;
                        }

                        int count = list.size();
                        for (DocumentChange dc : snapshots.getDocumentChanges()) {
                            if (dc.getType() == DocumentChange.Type.ADDED) {
                                ChatModel chatModel = new ChatModel();
                                chatModel.setChat_uuid(dc.getDocument().getString("chat_uuid"));
                                chatModel.setCompany_is_view(dc.getDocument().getString("company_is_view"));
                                chatModel.setCompany_uuid(dc.getDocument().getString("company_uuid"));
                                chatModel.setMessage(dc.getDocument().getString("message"));
                                chatModel.setSent_by(dc.getDocument().getString("sent_by"));
                                chatModel.setTime(dc.getDocument().getString("time"));
                                chatModel.setCountry_time(dc.getDocument().getString("country_time"));
                                chatModel.setUser_is_view(dc.getDocument().getString("user_is_view"));
                                chatModel.setUser_uuid(dc.getDocument().getString("user_uuid"));
                                list.add(chatModel);
                            }
                        }
                        Log.e("tag" , "list size is  :"+list.size());
                        //Collections.sort(list, (o1, o2) -> o2.getCountry_time().compareTo(o1.getCountry_time()));
                        if(count == 0)
                        {
                            chatAdapter.notifyDataSetChanged();
                        }else
                        {
                            chatAdapter.notifyItemRangeInserted(list.size() , list.size());
                            chatRV.smoothScrollToPosition(list.size() - 1);
                        }

                    }
                });

        hideProgress();

    }

    public String getCurrentDateTime()
    {

        String formattedDate;
        Date date = Calendar.getInstance().getTime();
        SimpleDateFormat df = new SimpleDateFormat("yyyy-dd-MM HH:mm:ss", Locale.getDefault());
        formattedDate = df.format(date);
        Log.e("tag" , "get current time is : "+formattedDate);

        return formattedDate;
    }


    public String getCountryDateTime()
    {

        Date date = Calendar.getInstance().getTime();
        SimpleDateFormat df = new SimpleDateFormat("yyyy-dd-MM HH:mm:ss", Locale.getDefault());
        TimeZone tz = TimeZone.getTimeZone("Asia/Dubai");
        df.setTimeZone(tz);
        countryDateTime = df.format(date);
        Log.e("tag" , "get current time is : "+countryDateTime);

        return countryDateTime;
    }


    public void clickListener()
    {
        sendBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                getTxtMessage = messageEditText.getText().toString();

                if(getTxtMessage.equals(""))
                {
                    Toast.makeText(VendorChat.this, "Write message before send", Toast.LENGTH_SHORT).show();
                }else
                {
                    if(userConnection)
                    {
                        sendMessageFirebase(getTxtMessage);

                    }else
                    {
                        createUserConnectionOnFireStore();
                    }

                }

            }
        });

    }

    public void sendMessageFirebase(String message)
    {

        Map<String, Object> user = new HashMap<>();
        user.put("company_uuid", vendorUUID);
        user.put("user_uuid", userUUID);
        user.put("chat_uuid", chatUUID);
        user.put("time", getCurrentDateTime());
        user.put("country_time", getCountryDateTime());
        user.put("company_is_view", "0");
        user.put("user_is_view", "0");
        user.put("message", message);
        user.put("sent_by", "company");



        // Add a new document with a generated ID
        db.collection("chat")
                .add(user)
                .addOnSuccessListener(new OnSuccessListener<DocumentReference>() {
                    @Override
                    public void onSuccess(DocumentReference documentReference) {
                        Log.e("tag", "DocumentSnapshot added with ID: " + documentReference.getId());
                        updateLastMessage(message);
                        messageEditText.setText("");

                        sendNotification(message);


                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        Log.e("tag", "Error adding document", e);
                    }
                });



    }

    public void updateLastMessage(String message)
    {

        db.collection("user_connections").document(documentID)
                .update(
                "last_message", message,
                "message_time", countryDateTime);


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



    private void sendNotification(String message) {

        RequestBody msg = RequestBody.create(message , MediaType.parse("text/plain"));
        RequestBody user_name = RequestBody.create(userName , MediaType.parse("text/plain"));
        RequestBody chat_uuid = RequestBody.create(chatUUID , MediaType.parse("text/plain"));
        RequestBody vendor_serial_no = RequestBody.create(vendorSerialNo , MediaType.parse("text/plain"));

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

        //showProgress();


        RetrofitApi retrofitApi = retrofit.create(RetrofitApi.class);

        //creating a call and calling the upload image method
        call = retrofitApi.sendNotificationVendor(msg , user_name , chat_uuid , vendor_serial_no);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                //hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        Log.e("tag" , response.body().getMessage());

                        Log.e("tag" , response.body().getMessage());
                    }
                    else
                    {
                        Log.e("tag" , response.body().getMessage());
                    }
                }
                else
                {
                    Toast.makeText(VendorChat.this, "error : "+response.code(), Toast.LENGTH_SHORT).show();
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
                    //hideProgress();
                    Toast.makeText(VendorChat.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

}