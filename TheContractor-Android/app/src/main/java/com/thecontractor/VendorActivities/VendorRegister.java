package com.thecontractor.VendorActivities;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
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
import com.thecontractor.Home;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.R;
import com.thecontractor.Register;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.WebViewActivity;

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

public class VendorRegister extends AppCompatActivity {
    EditText companyNameET , companyNameArabicET  , companyEmailET , companyMobileET , companyAddressET , ownerNameET , ownerPhoneNumberET , agentReferralET ,  loginEmailET , passwordET , confirmPasswordET;
    String companyNameETStr , companyNameArabicETStr  , companyEmailETStr , companyMobileETStr  , companyAddressETStr , ownerNameETStr , ownerPhoneNumberETStr , agentReferralETStr ,  loginEmailETStr , passwordETStr , confirmPasswordETStr;
    CheckBox termsConditionCB;
    TextView termsTV;
    Button registerBtn;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    UserModel userModel;
    String fireBaseToken = "null";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_register);
        getSupportActionBar().setTitle(getResources().getString(R.string.vendor_registration));
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        getTokenFromFireBase();
        initiate();
        clickListener();
        setTextAndClickOnTermsCondition();
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
        progressDialog = new ProgressDialog(VendorRegister.this);


        companyNameET = (EditText) findViewById(R.id.companyNameET);
        companyNameArabicET = (EditText) findViewById(R.id.companyNameArabicET);
        companyEmailET = (EditText) findViewById(R.id.companyEmailET);
        companyMobileET = (EditText) findViewById(R.id.companyMobileET);
        companyAddressET = (EditText) findViewById(R.id.companyAddressET);
        ownerNameET = (EditText) findViewById(R.id.ownerNameET);
        ownerPhoneNumberET = (EditText) findViewById(R.id.ownerPhoneNumberET);
        agentReferralET = (EditText) findViewById(R.id.agentReferralET);
        loginEmailET = (EditText) findViewById(R.id.loginEmailET);
        passwordET = (EditText) findViewById(R.id.passwordET);
        confirmPasswordET = (EditText) findViewById(R.id.confirmPasswordET);
        termsConditionCB = (CheckBox) findViewById(R.id.termsConditionCB);
        termsTV = (TextView) findViewById(R.id.termsTV);
        registerBtn = (Button) findViewById(R.id.registerBtn);

    }


    public void setTextAndClickOnTermsCondition()
    {
        String text = "I agree with Terms & Condition and Company Agreement";

        SpannableString ss = new SpannableString(text);

        ClickableSpan clickableSpan = new ClickableSpan() {
            @Override
            public void onClick(View widget) {

                Intent intent = new Intent(VendorRegister.this , WebViewActivity.class);
                intent.putExtra("link" , ApiUrls.BASE_URL + "terms-and-conditions-app");
                intent.putExtra("page" , getResources().getString(R.string.terms_and_conditions));
                startActivity(intent);
            }

            @Override
            public void updateDrawState(TextPaint ds) {
                super.updateDrawState(ds);
                ds.setColor(getResources().getColor(R.color.appColor));
                ds.setUnderlineText(false);
            }
        };


        ClickableSpan clickableSpan1 = new ClickableSpan() {
            @Override
            public void onClick(View widget) {

                Intent intent = new Intent(VendorRegister.this , WebViewActivity.class);
                intent.putExtra("link" , ApiUrls.BASE_URL + "company-agreement-app");
                intent.putExtra("page" , "Company Agreement");
                startActivity(intent);

            }

            @Override
            public void updateDrawState(TextPaint ds) {
                super.updateDrawState(ds);
                ds.setColor(getResources().getColor(R.color.appColor));
                ds.setUnderlineText(false);
            }
        };


        ss.setSpan(clickableSpan, 13, 30, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        ss.setSpan(clickableSpan1, 35, 52, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

        termsTV.setText(ss);
        termsTV.setMovementMethod(LinkMovementMethod.getInstance());

    }


    public void clickListener()
    {
        registerBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                companyNameETStr = companyNameET.getText().toString();
                companyNameArabicETStr = companyNameArabicET.getText().toString();
                companyEmailETStr = companyEmailET.getText().toString();
                companyMobileETStr = companyMobileET.getText().toString();
                companyAddressETStr = companyAddressET.getText().toString();
                ownerNameETStr = ownerNameET.getText().toString();
                ownerPhoneNumberETStr = ownerPhoneNumberET.getText().toString();
                agentReferralETStr = agentReferralET.getText().toString();
                loginEmailETStr = loginEmailET.getText().toString();
                passwordETStr = passwordET.getText().toString();
                confirmPasswordETStr = confirmPasswordET.getText().toString();


                if(companyNameETStr.equals(""))
                {
                    Toast.makeText(VendorRegister.this, getResources().getString(R.string.enter_company_name_in_english), Toast.LENGTH_SHORT).show();
                }else if(companyNameArabicETStr.equals(""))
                {
                    Toast.makeText(VendorRegister.this, getResources().getString(R.string.enter_company_name_in_arabic), Toast.LENGTH_SHORT).show();
                }else if(companyEmailETStr.equals(""))
                {
                    Toast.makeText(VendorRegister.this, getResources().getString(R.string.enter_company_email_address), Toast.LENGTH_SHORT).show();
                }
                else if(!isValidEmail(companyEmailETStr) && !companyEmailETStr.equals(""))
                {
                    Toast.makeText(VendorRegister.this, getResources().getString(R.string.enter_company_valid_email_address), Toast.LENGTH_SHORT).show();
                }else if(companyMobileETStr.equals(""))
                {
                    Toast.makeText(VendorRegister.this, getResources().getString(R.string.enter_company_phone_number), Toast.LENGTH_SHORT).show();
                }else if(companyAddressETStr.equals(""))
                {
                    Toast.makeText(VendorRegister.this, getResources().getString(R.string.enter_company_address), Toast.LENGTH_SHORT).show();
                }else if(ownerNameETStr.equals(""))
                {
                    Toast.makeText(VendorRegister.this, getResources().getString(R.string.enter_company_owner_name), Toast.LENGTH_SHORT).show();
                }else if(ownerPhoneNumberETStr.equals(""))
                {
                    Toast.makeText(VendorRegister.this, getResources().getString(R.string.enter_company_owner_phone_number), Toast.LENGTH_SHORT).show();
                } else if(loginEmailETStr.equals(""))
                {
                    Toast.makeText(VendorRegister.this, getResources().getString(R.string.enter_company_login_email_address), Toast.LENGTH_SHORT).show();
                }
                else if(!isValidEmail(loginEmailETStr) && !loginEmailETStr.equals(""))
                {
                    Toast.makeText(VendorRegister.this, getResources().getString(R.string.enter_company_login_valid_email_address), Toast.LENGTH_SHORT).show();
                }else if(passwordETStr.equals(""))
                {
                    Toast.makeText(VendorRegister.this, getResources().getString(R.string.password_error), Toast.LENGTH_SHORT).show();
                }else if(passwordETStr.trim().length() <= 3)
                {
                    Toast.makeText(VendorRegister.this, getResources().getString(R.string.enter_at_least_4_digit_pin), Toast.LENGTH_SHORT).show();
                }
                else if(confirmPasswordETStr.equals(""))
                {
                    Toast.makeText(VendorRegister.this, getResources().getString(R.string.enter_confirm_4_digit_pin), Toast.LENGTH_SHORT).show();
                }
                else if(!passwordETStr.equals(confirmPasswordETStr))
                {
                    Toast.makeText(VendorRegister.this,  getResources().getString(R.string.pin_not_matched), Toast.LENGTH_SHORT).show();
                }
                else
                {
                    vendorRegistration();
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



    private void vendorRegistration() {


        RequestBody companyName = RequestBody.create(companyNameETStr , MediaType.parse("text/plain"));
        RequestBody companyArabicName = RequestBody.create(companyNameArabicETStr , MediaType.parse("text/plain"));
        RequestBody companyEmail = RequestBody.create(companyEmailETStr , MediaType.parse("text/plain"));
        RequestBody companyPhoneNo = RequestBody.create(companyMobileETStr , MediaType.parse("text/plain"));
        RequestBody companyAddress = RequestBody.create(companyAddressETStr , MediaType.parse("text/plain"));
        RequestBody companyOwnerName = RequestBody.create(ownerNameETStr , MediaType.parse("text/plain"));
        RequestBody companyOwnerPhoneNo = RequestBody.create(ownerPhoneNumberETStr , MediaType.parse("text/plain"));
        RequestBody agentReferral = RequestBody.create(agentReferralETStr , MediaType.parse("text/plain"));
        RequestBody companyLoginEmail = RequestBody.create(loginEmailETStr , MediaType.parse("text/plain"));
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
        call = retrofitApi.vendorRegistration(companyName , companyArabicName , companyEmail  , companyPhoneNo  , companyAddress , companyOwnerName , companyOwnerPhoneNo ,
                agentReferral , companyLoginEmail , password , device , token);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        AlertDialog alertDialog = new AlertDialog.Builder(VendorRegister.this).create();
                        alertDialog.setTitle(getResources().getString(R.string.registration_submitted));
                        alertDialog.setMessage(response.body().getMessage());
                        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, getResources().getString(R.string.ok),
                                new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int which) {

                                        dialog.dismiss();

                                        finish();
                                    }
                                });
                        alertDialog.show();







                    }
                    else
                    {
                        Toast.makeText(VendorRegister.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorRegister.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorRegister.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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