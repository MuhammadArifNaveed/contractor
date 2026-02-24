package com.thecontractor.VendorActivities;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.ForgotPassword;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Home;
import com.thecontractor.Login;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Model.VendorModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.UpdateProfile;
import com.thecontractor.VerifyNumber;

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

public class VendorLogin extends AppCompatActivity {
    private EditText emailET , passwordET;
    private String emailETStr , passwordETStr;
    TextView forgotPassword;
    Button loginBtn;
    TextView signUp , loginAsUser;
    VendorModel vendorModel;


    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    String fireBaseToken = "null";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_login);
        getSupportActionBar().setTitle(getResources().getString(R.string.login_as_a_vendor));
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        getTokenFromFireBase();
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





    public void initiate()
    {
        progressDialog = new ProgressDialog(VendorLogin.this);

        emailET = (EditText) findViewById(R.id.emailET);
        passwordET = (EditText) findViewById(R.id.passwordET);
        signUp = (TextView) findViewById(R.id.signUp);
        loginAsUser = (TextView) findViewById(R.id.loginAsUser);
        forgotPassword = (TextView) findViewById(R.id.forgotPassword);
        loginBtn = (Button) findViewById(R.id.loginBtn);


    }

    public void clickListener()
    {
        loginBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                emailETStr = emailET.getText().toString();
                passwordETStr = passwordET.getText().toString();


                if(emailETStr.equals(""))
                {
                    Toast.makeText(VendorLogin.this, getResources().getString(R.string.enter_email_address_error), Toast.LENGTH_SHORT).show();
                }else if(!isValidEmail(emailETStr))
                {
                    Toast.makeText(VendorLogin.this, getResources().getString(R.string.enter_valid_email_address), Toast.LENGTH_SHORT).show();
                }
                else if(passwordETStr.equals(""))
                {
                    Toast.makeText(VendorLogin.this, getResources().getString(R.string.password_error), Toast.LENGTH_SHORT).show();
                }
                else
                {



                    Log.e("tag" , "email is : "+emailETStr);
                    Log.e("tag" , "password is : "+passwordETStr);

                    login();
                }

            }
        });


        signUp.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(VendorLogin.this , VendorRegister.class);
                startActivity(intent);
            }
        });


        loginAsUser.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });

        forgotPassword.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(VendorLogin.this , VendorForgotPassword.class);
                startActivity(intent);
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



    private void login() {



        RequestBody email = RequestBody.create(emailETStr , MediaType.parse("text/plain"));
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
        call = retrofitApi.vendorLogin(email , password , device , token);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        vendorModel = response.body().getVendor();

                        VendorSharedPrefModel vendorSharedPrefModel = new VendorSharedPrefModel();
                        vendorSharedPrefModel.setId(vendorModel.getId());
                        vendorSharedPrefModel.setUuid(vendorModel.getUuid());
                        vendorSharedPrefModel.setCompany_serial_number(vendorModel.getCompany_serial_number());
                        vendorSharedPrefModel.setCompany_name(vendorModel.getCompany_name());
                        vendorSharedPrefModel.setLogin_email(vendorModel.getLogin_email());
                        vendorSharedPrefModel.setCompany_phone(vendorModel.getCompany_phone());
                        vendorSharedPrefModel.setCity_name(vendorModel.getCity_name());
                        vendorSharedPrefModel.setCompany_address(vendorModel.getCompany_address());
                        vendorSharedPrefModel.setUser_id(vendorModel.getUser_id());
                        vendorSharedPrefModel.setUser_type(vendorModel.getUser_type());

                        Gson gson = new Gson();
                        String vendorModelStr = gson.toJson(vendorSharedPrefModel);
                        SharedPrefManager.getInstance(VendorLogin.this).vendorLogin(vendorModelStr);


                        Intent intent = new Intent(VendorLogin.this, VendorHome.class);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                        startActivity(intent);
                        finish();




                    }
                    else
                    {
                        if(response.body().getIs_email_verified().equals("No"))
                        {
                            emailVerifyDialog(response.body().getMessage());
                        }else
                        {
                            Toast.makeText(VendorLogin.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                        }

                    }
                }
                else
                {
                    Toast.makeText(VendorLogin.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorLogin.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    public void emailVerifyDialog(String message)
    {
        Dialog dialog = new Dialog(VendorLogin.this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.verify_email_dialog);
        Window window = dialog.getWindow();
        window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        dialog.setCancelable(true);
        dialog.show();

        TextView emailError = dialog.findViewById(R.id.emailError);
        Button sendEmail = dialog.findViewById(R.id.sendEmail);

        emailError.setText(message);

        sendEmail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                dialog.dismiss();

                resendEmail();

            }
        });



    }

    private void resendEmail() {



        RequestBody email = RequestBody.create(emailETStr , MediaType.parse("text/plain"));



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
        call = retrofitApi.sendEmailVendor(email);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {
                        Toast.makeText(VendorLogin.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                    else
                    {
                        Toast.makeText(VendorLogin.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorLogin.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorLogin.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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