package com.thecontractor;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

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

import java.util.ArrayList;
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

public class Register extends AppCompatActivity {
    EditText usernameET , fistNameET , lastNameET  , mobileET , emailET , passwordET , confirmPasswordET;
    String usernameETStr , fistNameETStr , lastNameETStr  , mobileETStr , emailETStr , passwordETStr , confirmPasswordETStr;
    Button registerBtn;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    UserModel userModel;
    String fireBaseToken = "null";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.register));

        getTokenFromFireBase();
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

    public void getDataFromPreviousActivity() {

        Intent intent = getIntent();
        mobileETStr = intent.getStringExtra("phoneNumber");

        Log.e("tag" , "mobile no is : "+mobileETStr);

    }


    public void initiate()
    {
        progressDialog = new ProgressDialog(Register.this);


        usernameET = (EditText) findViewById(R.id.usernameET);
        fistNameET = (EditText) findViewById(R.id.fistNameET);
        lastNameET = (EditText) findViewById(R.id.lastNameET);
        mobileET = (EditText) findViewById(R.id.mobileET);
        emailET = (EditText) findViewById(R.id.emailET);
        passwordET = (EditText) findViewById(R.id.passwordET);
        confirmPasswordET = (EditText) findViewById(R.id.confirmPasswordET);
        registerBtn = (Button) findViewById(R.id.registerBtn);

        mobileET.setText(mobileETStr);


    }

    public void clickListener()
    {
        registerBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                usernameETStr = usernameET.getText().toString();
                fistNameETStr = fistNameET.getText().toString();
                lastNameETStr = lastNameET.getText().toString();
                mobileETStr = mobileET.getText().toString();
                emailETStr = emailET.getText().toString();
                passwordETStr = passwordET.getText().toString();
                confirmPasswordETStr = confirmPasswordET.getText().toString();


                if(usernameETStr.equals(""))
                {
                    Toast.makeText(Register.this, getResources().getString(R.string.enter_user_name_error), Toast.LENGTH_SHORT).show();
                } else if(!isValidUsername(usernameETStr) && !usernameETStr.equals(""))
                {
                    Toast.makeText(Register.this, getResources().getString(R.string.enter_valid_user_name_error), Toast.LENGTH_SHORT).show();
                }else if(fistNameETStr.equals(""))
                {
                    Toast.makeText(Register.this, getResources().getString(R.string.enter_name_error), Toast.LENGTH_SHORT).show();
                }else if(lastNameETStr.equals(""))
                {
                    Toast.makeText(Register.this, getResources().getString(R.string.enter_sur_name_error), Toast.LENGTH_SHORT).show();
                }else if(mobileETStr.equals(""))
                {
                    Toast.makeText(Register.this, getResources().getString(R.string.phone_no_error), Toast.LENGTH_SHORT).show();
                }
                else if(emailETStr.equals(""))
                {
                    Toast.makeText(Register.this, getResources().getString(R.string.enter_email_address_error), Toast.LENGTH_SHORT).show();
                }
                else if(!isValidEmail(emailETStr) && !emailETStr.equals(""))
                {
                    Toast.makeText(Register.this, getResources().getString(R.string.enter_valid_email_address), Toast.LENGTH_SHORT).show();
                }else if(passwordETStr.equals(""))
                {
                    Toast.makeText(Register.this, getResources().getString(R.string.password_error), Toast.LENGTH_SHORT).show();
                }else if(passwordETStr.trim().length() <= 3)
                {
                    Toast.makeText(Register.this, getResources().getString(R.string.enter_at_least_4_digit_pin), Toast.LENGTH_SHORT).show();
                }
                else if(confirmPasswordETStr.equals(""))
                {
                    Toast.makeText(Register.this, getResources().getString(R.string.enter_confirm_4_digit_pin), Toast.LENGTH_SHORT).show();
                }
                else if(!passwordETStr.equals(confirmPasswordETStr))
                {
                    Toast.makeText(Register.this,  getResources().getString(R.string.pin_not_matched), Toast.LENGTH_SHORT).show();
                }
                else
                {
                    register();
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


    public static boolean isValidUsername(final String username) {

        final String USERNAME_PATTERN = "^[a-zA-Z0-9]([._-](?![._-])|[a-zA-Z0-9]){3,18}[a-zA-Z0-9]$";
        final Pattern pattern = Pattern.compile(USERNAME_PATTERN);

        Matcher matcher = pattern.matcher(username);
        return matcher.matches();
    }


    private void register() {


        RequestBody username = RequestBody.create(usernameETStr , MediaType.parse("text/plain"));
        RequestBody firstName = RequestBody.create(fistNameETStr , MediaType.parse("text/plain"));
        RequestBody lastName = RequestBody.create(lastNameETStr , MediaType.parse("text/plain"));
        RequestBody mobileNo = RequestBody.create(mobileETStr , MediaType.parse("text/plain"));
        RequestBody email = RequestBody.create(emailETStr , MediaType.parse("text/plain"));
        RequestBody password = RequestBody.create(passwordETStr , MediaType.parse("text/plain"));
        RequestBody countryId = RequestBody.create("1" , MediaType.parse("text/plain"));
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
        call = retrofitApi. register(username , firstName , lastName , mobileNo  , email , password , countryId , device , token);

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
                        SharedPrefManager.getInstance(Register.this).userLogin(userModelStr);


                        Intent intent = new Intent(Register.this, Home.class);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                        startActivity(intent);
                        finish();




                    }
                    else
                    {
                        Toast.makeText(Register.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(Register.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(Register.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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