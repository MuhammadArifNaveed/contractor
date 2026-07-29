package com.thecontractor.VendorActivities;

import androidx.appcompat.app.AppCompatActivity;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.NewPassword;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class VendorForgotPasswordPin extends AppCompatActivity {
    private EditText pinET;
    private String pinETStr;
    private String email;
    Button btnSendEmail;



    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_forgot_passwoed_pin);
        getSupportActionBar().setTitle("Pin Code");
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        getDataFromPreviousActivity();
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

    public void getDataFromPreviousActivity()
    {
        Intent intent = getIntent();
        email = intent.getStringExtra("email");

        Log.e("tag" , "email is : "+email);
    }

    public void initiate()
    {
        progressDialog = new ProgressDialog(VendorForgotPasswordPin.this);

        pinET = (EditText) findViewById(R.id.pinET);
        btnSendEmail = (Button) findViewById(R.id.btnSendEmail);


    }

    public void clickListener()
    {
        btnSendEmail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                pinETStr = pinET.getText().toString();


                if(pinETStr.equals(""))
                {
                    Toast.makeText(VendorForgotPasswordPin.this, "Enter pin code", Toast.LENGTH_SHORT).show();
                }
                else
                {

                    Log.e("tag" , "pin is : "+pinETStr);

                    forgotPasswordCheckPin();
                }

            }
        });
    }




    private void forgotPasswordCheckPin() {


        RequestBody _email = RequestBody.create(email , MediaType.parse("text/plain"));
        RequestBody pin = RequestBody.create(pinETStr , MediaType.parse("text/plain"));



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
        call = retrofitApi.vendorForgotPasswordPin(_email , pin);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        Intent intent = new Intent(VendorForgotPasswordPin.this , VendorNewPassword.class);
                        intent.putExtra("email" , email);
                        startActivity(intent);
                        finish();




                    }
                    else
                    {
                        Toast.makeText(VendorForgotPasswordPin.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorForgotPasswordPin.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorForgotPasswordPin.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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