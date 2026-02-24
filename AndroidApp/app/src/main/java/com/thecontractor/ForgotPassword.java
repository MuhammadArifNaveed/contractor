package com.thecontractor;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.SearchView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseException;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthOptions;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

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

public class ForgotPassword extends AppCompatActivity {
    private Button btnSendCode, btnVerifyCode, btnResendCode;
    private TextView tvNumber;
    private EditText edtPhoneNumber, edtVerifyCode;
    private TextView tvCounter;
    private String mFullNumberWithCode, mVerificationId , country;
    private LinearLayout layoutPhoneNumber, layoutVerifyCode;
    private FirebaseAuth mAuth;
    private CountDownTimer mCountDownTimer;
    LinearLayout ccLayout;
    long remainingSecond;
    private PhoneAuthProvider.ForceResendingToken mResendToken;
    private PhoneAuthProvider.OnVerificationStateChangedCallbacks mCallbacks;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_forgot_password);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.forgot_password));


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


    public void initiate()
    {


        mAuth = FirebaseAuth.getInstance();

        progressDialog = new ProgressDialog(ForgotPassword.this);

        tvCounter=(TextView) findViewById(R.id.tvCounter);
        edtPhoneNumber = (EditText) findViewById(R.id.edtPhoneNumber);
        edtVerifyCode = (EditText) findViewById(R.id.edtVerifyCode);
        btnSendCode = (Button) findViewById(R.id.btnSendCode);
        btnVerifyCode = (Button) findViewById(R.id.btnVerifyCode);
        btnResendCode = (Button) findViewById(R.id.btnResendCode);
        btnResendCode.setVisibility(View.GONE);
        tvNumber=(TextView) findViewById(R.id.tvNumber);
        layoutPhoneNumber=(LinearLayout) findViewById(R.id.layoutPhoneNumber);
        layoutVerifyCode=(LinearLayout) findViewById(R.id.layoutVerifyCode);




    }

    public void clickListener()
    {
        btnSendCode.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view) {

                String phoneNumber = edtPhoneNumber.getText().toString();
                mFullNumberWithCode = "+971" + phoneNumber;
                //mFullNumberWithCode = "+92" + phoneNumber;


                if(phoneNumber.equals(""))
                {
                    Toast.makeText(ForgotPassword.this, getResources().getString(R.string.phone_no_error), Toast.LENGTH_SHORT).show();
                } else {

                    Log.e("tag" , "mFullNumberWithCode is : "+mFullNumberWithCode);

                    tvNumber.setText(mFullNumberWithCode);



                    checkPhone(mFullNumberWithCode);




                }

            }
        });
        //verify code
        btnVerifyCode.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                String verificationCode = edtVerifyCode.getText().toString();

                if (verificationCode.isEmpty())
                {

                    Toast.makeText(ForgotPassword.this, getResources().getString(R.string.enter_verification_code), Toast.LENGTH_SHORT).show();

                }
                else
                {
                    showProgress();

                    PhoneAuthCredential credential = PhoneAuthProvider.getCredential(mVerificationId, verificationCode);
                    signInWithPhoneAuthCredential(credential);
                }
            }
        });


        //resend code
        btnResendCode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                ResendCode();

            }
        });



        mCallbacks = new PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
            @Override
            public void onVerificationCompleted(PhoneAuthCredential phoneAuthCredential)
            {
                String code = phoneAuthCredential.getSmsCode();

                if (code != null) {
                    edtVerifyCode.setText(code);
                    //verifying the code

                    signInWithPhoneAuthCredential(phoneAuthCredential);


                }

            }

            @Override
            public void onVerificationFailed(FirebaseException e)
            {
                //Toast.makeText(VerifyNumber.this, e.toString(), Toast.LENGTH_SHORT).show();
                Log.e("tag", "onVerificationFailed : " + e.getMessage());

                hideProgress();

                alert(e.getMessage());


                layoutPhoneNumber.setVisibility(View.VISIBLE);
                layoutVerifyCode.setVisibility(View.GONE);
            }

            public void onCodeSent(String verificationId, PhoneAuthProvider.ForceResendingToken token)
            {


                hideProgress();

                btnResendCode.setVisibility(View.GONE);
                tvCounter.setVisibility(View.VISIBLE);

                StartCountDown();

                // Save verification ID and resending token so we can use them later
                mVerificationId = verificationId;
                mResendToken = token;


                Toast.makeText(ForgotPassword.this, getResources().getString(R.string.verification_code_sent) , Toast.LENGTH_SHORT).show();


                layoutPhoneNumber.setVisibility(View.GONE);
                layoutVerifyCode.setVisibility(View.VISIBLE);


            }
        };
    }

    public void alert(String message)
    {
        AlertDialog alertDialog = new AlertDialog.Builder(ForgotPassword.this).create();
        alertDialog.setCancelable(false);
        alertDialog.setTitle(getResources().getString(R.string.elert));
        alertDialog.setMessage(message);
        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, getResources().getString(R.string.ok),
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        finish();
                    }
                });
        alertDialog.show();
    }


    private void signInWithPhoneAuthCredential(PhoneAuthCredential credential)
    {
        mAuth.signInWithCredential(credential)
                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        if (task.isSuccessful())
                        {
                            hideProgress();


                            Intent intent = new Intent(ForgotPassword.this , NewPassword.class);
                            intent.putExtra("mobileNumber" , mFullNumberWithCode);
                            startActivity(intent);
                            finish();

                        }
                        else
                        {

                            hideProgress();

                            String message = task.getException().toString();


                            alert(message);

                        }
                    }
                });
    }



    public void StartCountDown() {
        mCountDownTimer = new CountDownTimer(1 * 60000, 1000) {
            public void onTick(long millisUntilFinished) {
                tvCounter.setText(getResources().getString(R.string.resend_in) + String.format("%d : %d ",
                        TimeUnit.MILLISECONDS.toMinutes(millisUntilFinished),
                        TimeUnit.MILLISECONDS.toSeconds(millisUntilFinished) -
                                TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millisUntilFinished))) +getResources().getString(R.string.seconds));

                remainingSecond = millisUntilFinished;

            }

            public void onFinish() {
                btnResendCode.setVisibility(View.VISIBLE);
                tvCounter.setVisibility(View.GONE);
            }
        }.start();
    }


    private void ResendCode()
    {

        showProgress();

        PhoneAuthOptions options =
                PhoneAuthOptions.newBuilder(mAuth)
                        .setPhoneNumber(mFullNumberWithCode)       // Phone number to verify
                        .setTimeout(60L, TimeUnit.SECONDS) // Timeout and unit
                        .setActivity(ForgotPassword.this)                 // Activity (for callback binding)
                        .setCallbacks(mCallbacks)          // OnVerificationStateChangedCallbacks
                        .build();
        PhoneAuthProvider.verifyPhoneNumber(options);

    }



    private void checkPhone(String phone) {


        RequestBody phoneNumber = RequestBody.create(phone , MediaType.parse("text/plain"));


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
        call = retrofitApi.otpLoginRegister(phoneNumber);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();

                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {
                        Toast.makeText(ForgotPassword.this, getResources().getString(R.string.phone_number_not_registered), Toast.LENGTH_SHORT).show();
                    }
                    else
                    {

                        showProgress();


                        PhoneAuthOptions options =
                                PhoneAuthOptions.newBuilder(mAuth)
                                        .setPhoneNumber(mFullNumberWithCode)       // Phone number to verify
                                        .setTimeout(60L, TimeUnit.SECONDS) // Timeout and unit
                                        .setActivity(ForgotPassword.this)                 // Activity (for callback binding)
                                        .setCallbacks(mCallbacks)          // OnVerificationStateChangedCallbacks
                                        .build();
                        PhoneAuthProvider.verifyPhoneNumber(options);

                    }
                }
                else
                {
                    Toast.makeText(ForgotPassword.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(ForgotPassword.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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