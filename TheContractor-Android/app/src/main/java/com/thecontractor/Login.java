package com.thecontractor;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.VendorActivities.VendorLogin;

import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class Login extends AppCompatActivity {
    private EditText phoneNumberET , passwordET;
    private String edtPhoneNumberStr , passwordETStr;
    TextView forgotPassword;
    TextView countryCode;
    String phoneNo;
    Button loginBtn;
    TextView signUp , loginAsVendor;
    UserModel userModel;


    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    String requestForLogin = "null";
    String fireBaseToken = "null";



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        getSupportActionBar().setTitle(getResources().getString(R.string.login_activity));

        getTokenFromFireBase();
        getRequestForLogin();
        initiate();
        clickListener();

    }

    public void getTokenFromFireBase()
    {

        FirebaseMessaging.getInstance().getToken()
                .addOnCompleteListener(new OnCompleteListener<String>() {
                    @Override
                    public void onComplete(@NonNull Task<String> task) {
                        if (!task.isSuccessful()) {
                            Log.e("tag", "Fetching FCM registration token failed", task.getException());
                            return;
                        }
                        // Get new FCM registration token
                        fireBaseToken = task.getResult();

                        Log.e("tag", "firebase token : "+fireBaseToken);
                    }
                });

    }


    public void getRequestForLogin() {
        Intent intent = getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {

            getSupportActionBar().setHomeButtonEnabled(true);
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);

            requestForLogin = (String) bundle.get("requestForLogin");

            Log.e("tag" , "Login Request Is : "+requestForLogin);

        }
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


    public void initiate()
    {
        progressDialog = new ProgressDialog(Login.this);

        phoneNumberET = (EditText) findViewById(R.id.phoneNumberET);
        passwordET = (EditText) findViewById(R.id.passwordET);
        signUp = (TextView) findViewById(R.id.signUp);
        loginAsVendor = (TextView) findViewById(R.id.loginAsVendor);
        forgotPassword = (TextView) findViewById(R.id.forgotPassword);
        countryCode = (TextView) findViewById(R.id.countryCode);
        loginBtn = (Button) findViewById(R.id.loginBtn);


    }

    public void clickListener()
    {
        loginBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                edtPhoneNumberStr = phoneNumberET.getText().toString();
                passwordETStr = passwordET.getText().toString();


                if(edtPhoneNumberStr.equals(""))
                {
                    Toast.makeText(Login.this, getResources().getString(R.string.phone_no_error), Toast.LENGTH_SHORT).show();
                }
                else if(passwordETStr.equals(""))
                {
                    Toast.makeText(Login.this, getResources().getString(R.string.password_error), Toast.LENGTH_SHORT).show();
                }
                else
                {

                    if(edtPhoneNumberStr.equals("3124611478") || edtPhoneNumberStr.equals("3024507881") || edtPhoneNumberStr.equals("3034937427") )
                    {
                        phoneNo = "+92" + edtPhoneNumberStr;

                    }else
                    {
                        phoneNo = "+971" + edtPhoneNumberStr;
                    }

                    Log.e("tag" , "phone num is : "+phoneNo);
                    Log.e("tag" , "password is : "+passwordETStr);

                    login();
                }

            }
        });


        signUp.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(Login.this , VerifyNumber.class);
                startActivity(intent);
            }
        });


        loginAsVendor.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
//                Intent intent = new Intent(Login.this , WebViewActivity.class);
//                intent.putExtra("link" , "https://contractor.thecontractor.ae/company-login");
//                intent.putExtra("page" , "Vendor Login");
//                startActivity(intent);
//
                Intent intent = new Intent(Login.this , VendorLogin.class);
                startActivity(intent);
            }
        });

        forgotPassword.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(Login.this , ForgotPassword.class);
                startActivity(intent);
            }
        });


    }


    private void login() {



        RequestBody mobileNo = RequestBody.create(phoneNo , MediaType.parse("text/plain"));
        RequestBody password = RequestBody.create(passwordETStr , MediaType.parse("text/plain"));
        RequestBody device = RequestBody.create("Android" , MediaType.parse("text/plain"));
        RequestBody token = RequestBody.create(fireBaseToken , MediaType.parse("text/plain"));


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
        call = retrofitApi.login(mobileNo , password , device , token);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        userModel = response.body().getUser();



                        Gson gson = new Gson();
                        String userModelStr = gson.toJson(userModel);

                        SharedPrefManager.getInstance(Login.this).userLogin(userModelStr);

                        if(requestForLogin.equals("yes"))
                        {
                            Intent returnIntent = new Intent();
                            setResult(Activity.RESULT_OK,returnIntent);
                            finish();
                        }
                        else
                        {
                            Intent intent = new Intent(Login.this, Home.class);
                            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                            startActivity(intent);
                            finish();
                        }




                    }
                    else
                    {
                        Toast.makeText(Login.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(Login.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(Login.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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