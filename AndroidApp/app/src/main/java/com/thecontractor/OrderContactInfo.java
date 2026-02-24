package com.thecontractor;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Database.DatabaseHandler;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.ImageComprasser;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

import static android.Manifest.permission.READ_EXTERNAL_STORAGE;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

public class OrderContactInfo extends AppCompatActivity {

    String selectedCompanies;

    EditText fistNameET , lastNameET   , mobileET , emailET;
    String fistNameETStr , lastNameETStr   , mobileETStr , emailETStr ;
    String userId;
    Button updateProfileBtn;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    DatabaseHandler databaseHandler;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_order_contact_info);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.contact_information));

        getDataFromSP();
        getDatFromPreviousActivity();
        initiate();
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

    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(OrderContactInfo.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(OrderContactInfo.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();

            Log.e("tag" , "user id is : "+userId);

            fistNameETStr = userModel.getName();
            lastNameETStr = userModel.getSurname();
            mobileETStr = userModel.getPhone();
            emailETStr = userModel.getEmail();


        }
    }


    public void getDatFromPreviousActivity()
    {
        Intent intent = getIntent();
        selectedCompanies = intent.getStringExtra("selectedCompanies");

        Log.e("tag" , "selected companies is : "+selectedCompanies);
    }



    public void initiate()
    {
        databaseHandler = new DatabaseHandler(OrderContactInfo.this);

        progressDialog = new ProgressDialog(OrderContactInfo.this);


        fistNameET = (EditText) findViewById(R.id.fistNameET);
        lastNameET = (EditText) findViewById(R.id.lastNameET);
        mobileET = (EditText) findViewById(R.id.mobileET);
        emailET = (EditText) findViewById(R.id.emailET);
        updateProfileBtn = (Button) findViewById(R.id.updateProfileBtn);


        fistNameET.setText(fistNameETStr);
        lastNameET.setText(lastNameETStr);
        emailET.setText(emailETStr);
        mobileET.setText(mobileETStr);


    }

    public void clickListener()
    {



        updateProfileBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                fistNameETStr = fistNameET.getText().toString();
                lastNameETStr = lastNameET.getText().toString();
                mobileETStr = mobileET.getText().toString();
                emailETStr = emailET.getText().toString();

                if(fistNameETStr.equals(""))
                {
                    Toast.makeText(OrderContactInfo.this, getResources().getString(R.string.enter_name_error), Toast.LENGTH_SHORT).show();
                }else if(lastNameETStr.equals(""))
                {
                    Toast.makeText(OrderContactInfo.this, getResources().getString(R.string.enter_sur_name_error), Toast.LENGTH_SHORT).show();
                }else if(mobileETStr.equals(""))
                {
                    Toast.makeText(OrderContactInfo.this, getResources().getString(R.string.phone_no_error), Toast.LENGTH_SHORT).show();
                } else if(emailETStr.equals(""))
                {
                    Toast.makeText(OrderContactInfo.this, getResources().getString(R.string.enter_email_address_error), Toast.LENGTH_SHORT).show();
                }else if(!isValidEmail(emailETStr))
                {
                    Toast.makeText(OrderContactInfo.this, getResources().getString(R.string.enter_valid_email_address), Toast.LENGTH_SHORT).show();
                }else
                {
                    updateProfile();
                }


            }
        });
    }


    public static boolean isValidEmail(final String emailAddress) {

        Pattern pattern;
        Matcher matcher;

        final String EMAIL_PATTERN = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@" + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";

        pattern = Pattern.compile(EMAIL_PATTERN);
        matcher = pattern.matcher(emailAddress);
        return matcher.matches();
    }


    private void updateProfile() {



        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));
        RequestBody firstName = RequestBody.create(fistNameETStr , MediaType.parse("text/plain"));
        RequestBody lastName = RequestBody.create(lastNameETStr , MediaType.parse("text/plain"));
        RequestBody phone = RequestBody.create(mobileETStr , MediaType.parse("text/plain"));
        RequestBody email = RequestBody.create(emailETStr , MediaType.parse("text/plain"));
        RequestBody companies = RequestBody.create(selectedCompanies , MediaType.parse("text/plain"));

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
        call = retrofitApi.submitEnquiry(user_id , firstName , lastName  , phone , email , companies);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        databaseHandler.clearCart();


                        AlertDialog alertDialog = new AlertDialog.Builder(OrderContactInfo.this).create();
                        alertDialog.setCancelable(false);
                        alertDialog.setTitle(getResources().getString(R.string.enquiries_submitted));
                        alertDialog.setMessage(response.body().getMessage());
                        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, getResources().getString(R.string.ok),
                                new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int which) {

                                        dialog.dismiss();

                                        Intent intent = new Intent(OrderContactInfo.this, Home.class);
                                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                                        startActivity(intent);
                                        finish();
                                    }
                                });
                        alertDialog.show();
                    }
                    else
                    {
                        Toast.makeText(OrderContactInfo.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(OrderContactInfo.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(OrderContactInfo.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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