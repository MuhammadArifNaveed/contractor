package com.thecontractor;

import androidx.appcompat.app.AppCompatActivity;

import android.app.ProgressDialog;
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
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.UserModel;
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

public class ChangePassword extends AppCompatActivity {
    EditText oldPasswordET , passwordET , confirmPasswordET;
    String oldPasswordETStr , passwordETStr , confirmPasswordETStr;
    Button changePasswordBtn;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    String userId;
    String userEmail;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_change_password);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.change_password));

        getDataFromSP();
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
        if (!SharedPrefManager.getInstance(ChangePassword.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(ChangePassword.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);
            userId = userModel.getId();
            userEmail = userModel.getEmail();

            Log.e("tag" , "user id is : "+userId);
            Log.e("tag" , "user email is : "+userEmail);


        }
    }

    public void initiate()
    {
        progressDialog = new ProgressDialog(ChangePassword.this);


        oldPasswordET = (EditText) findViewById(R.id.oldPasswordET);
        passwordET = (EditText) findViewById(R.id.passwordET);
        confirmPasswordET = (EditText) findViewById(R.id.confirmPasswordET);
        changePasswordBtn = (Button) findViewById(R.id.changePasswordBtn);


    }

    public void clickListener()
    {
        changePasswordBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                oldPasswordETStr = oldPasswordET.getText().toString();
                passwordETStr = passwordET.getText().toString();
                confirmPasswordETStr = confirmPasswordET.getText().toString();


                if(oldPasswordETStr.equals(""))
                {
                    Toast.makeText(ChangePassword.this, getResources().getString(R.string.enter_old_4_digit_pin), Toast.LENGTH_SHORT).show();
                }
                else if(passwordETStr.equals(""))
                {
                    Toast.makeText(ChangePassword.this, getResources().getString(R.string.enter_new_4_digit_pin), Toast.LENGTH_SHORT).show();
                }else if(passwordETStr.trim().length() <= 3)
                {
                    Toast.makeText(ChangePassword.this, getResources().getString(R.string.enter_at_least_4_digit_pin), Toast.LENGTH_SHORT).show();
                }
                else if(confirmPasswordETStr.equals(""))
                {
                    Toast.makeText(ChangePassword.this, getResources().getString(R.string.enter_confirm_4_digit_pin), Toast.LENGTH_SHORT).show();
                }
                else if(!passwordETStr.equals(confirmPasswordETStr))
                {
                    Toast.makeText(ChangePassword.this, getResources().getString(R.string.pin_not_matched), Toast.LENGTH_SHORT).show();
                }
                else
                {
                    updatePaasword();
                }


            }
        });
    }




    private void updatePaasword() {


        RequestBody user_email = RequestBody.create(userEmail , MediaType.parse("text/plain"));
        RequestBody oldPassword = RequestBody.create(oldPasswordETStr , MediaType.parse("text/plain"));
        RequestBody newPassword = RequestBody.create(passwordETStr , MediaType.parse("text/plain"));


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
        call = retrofitApi.changePassword(user_email , oldPassword , newPassword);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {
                        Toast.makeText(ChangePassword.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                        finish();
                    }
                    else
                    {
                        Toast.makeText(ChangePassword.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(ChangePassword.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(ChangePassword.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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