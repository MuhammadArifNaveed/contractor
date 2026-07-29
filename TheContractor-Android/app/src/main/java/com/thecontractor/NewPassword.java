package com.thecontractor;

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
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class NewPassword extends AppCompatActivity {
    EditText passwordET , confirmPasswordET;
    String passwordETStr , confirmPasswordETStr , mobileNumber;
    Button updatePasswordBtn;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_new_password);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.new_password));

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
        mobileNumber = intent.getStringExtra("mobileNumber");

        Log.e("tag" , "mobile number is : "+mobileNumber);
    }


    public void initiate()
    {
        progressDialog = new ProgressDialog(NewPassword.this);


        passwordET = (EditText) findViewById(R.id.passwordET);
        confirmPasswordET = (EditText) findViewById(R.id.confirmPasswordET);
        updatePasswordBtn = (Button) findViewById(R.id.updatePasswordBtn);


    }

    public void clickListener()
    {
        updatePasswordBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                passwordETStr = passwordET.getText().toString();
                confirmPasswordETStr = confirmPasswordET.getText().toString();


                if(passwordETStr.equals(""))
                {
                    Toast.makeText(NewPassword.this, getResources().getString(R.string.enter_new_4_digit_pin), Toast.LENGTH_SHORT).show();
                }else if(passwordETStr.trim().length() <= 3)
                {
                    Toast.makeText(NewPassword.this, getResources().getString(R.string.enter_at_least_4_digit_pin), Toast.LENGTH_SHORT).show();
                }
                else if(confirmPasswordETStr.equals(""))
                {
                    Toast.makeText(NewPassword.this, getResources().getString(R.string.enter_confirm_4_digit_pin), Toast.LENGTH_SHORT).show();
                }
                else if(!passwordETStr.equals(confirmPasswordETStr))
                {
                    Toast.makeText(NewPassword.this, getResources().getString(R.string.pin_not_matched), Toast.LENGTH_SHORT).show();
                }
                else
                {
                    newPassword();
                }


            }
        });
    }





    private void newPassword() {


        RequestBody password = RequestBody.create(passwordETStr , MediaType.parse("text/plain"));
        RequestBody mobile = RequestBody.create(mobileNumber , MediaType.parse("text/plain"));


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
        call = retrofitApi.newPassword(password , mobile);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {
                        Toast.makeText(NewPassword.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();

                        Intent intent = new Intent(NewPassword.this , Login.class);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                        startActivity(intent);
                        finish();

                    }
                    else
                    {
                        Toast.makeText(NewPassword.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(NewPassword.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(NewPassword.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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