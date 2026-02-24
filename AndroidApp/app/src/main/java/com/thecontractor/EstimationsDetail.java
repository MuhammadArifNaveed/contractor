package com.thecontractor;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.ViewCompat;

import android.app.ProgressDialog;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.ComplaintModel;
import com.thecontractor.Model.EstimationModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class EstimationsDetail extends AppCompatActivity {
    LinearLayout estimationDetailLayout;
    String estimationId;
    String userId;
    EstimationModel estimationModel;
    TextView lookingFor , estimationCategory , totalSqft , SqftPrice , estimatedBudget;
    TextView estimationNo;
    TextView createdAt;
    TextView description;
    TextView status;
    TextView adminNote;
    LinearLayout adminNoteLayout , descriptionLayout;
    TextView userName , phoneNo , email;
    String selectedLanguage = "en";

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_estimations_detail);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.estimations_details));

        getDataFromSP();
        getLanguageFromSP();
        getObjectFromAdapter();
        initiate();
        estimationDetailAPI();
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
        if (!SharedPrefManager.getInstance(EstimationsDetail.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(EstimationsDetail.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();

            Log.e("tag" , "user id is : "+userId);

        }
    }


    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(EstimationsDetail.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(EstimationsDetail.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }

    public void getObjectFromAdapter() {
        Intent intent = getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {

            estimationId = (String) bundle.getString("id");

            Log.e("tag" , "estimation id is : "+estimationId);

        }
    }

    public void initiate()
    {
        progressDialog = new ProgressDialog(EstimationsDetail.this);

        estimationDetailLayout = (LinearLayout) findViewById(R.id.estimationDetailLayout);
        estimationDetailLayout.setVisibility(View.GONE);

        lookingFor = (TextView) findViewById(R.id.lookingFor);
        estimationCategory = (TextView) findViewById(R.id.estimationCategory);
        totalSqft = (TextView) findViewById(R.id.totalSqft);
        SqftPrice = (TextView) findViewById(R.id.SqftPrice);
        estimatedBudget = (TextView) findViewById(R.id.estimatedBudget);

        estimationNo = (TextView) findViewById(R.id.estimationNo);
        createdAt = (TextView) findViewById(R.id.createdAt);
        description = (TextView) findViewById(R.id.description);
        status = (TextView) findViewById(R.id.status);
        adminNote = (TextView) findViewById(R.id.adminNote);
        adminNoteLayout = (LinearLayout) findViewById(R.id.adminNoteLayout);
        adminNoteLayout.setVisibility(View.GONE);
        descriptionLayout = (LinearLayout) findViewById(R.id.descriptionLayout);
        descriptionLayout.setVisibility(View.GONE);


        userName = (TextView) findViewById(R.id.userName);
        phoneNo = (TextView) findViewById(R.id.phoneNo);
        email = (TextView) findViewById(R.id.email);
    }

    private void estimationDetailAPI() {

        RequestBody id = RequestBody.create(estimationId , MediaType.parse("text/plain"));
        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));


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
        call = retrofitApi.estimationDetail(id , user_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        estimationDetailLayout.setVisibility(View.VISIBLE);
                        estimationModel = response.body().getEstimation_request_detail();
                        setDataToWidget();


                    }
                    else
                    {
                        Toast.makeText(EstimationsDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(EstimationsDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(EstimationsDetail.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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

    public void hideProgress() {
        progressDialog.dismiss();
    }

    public void setDataToWidget()
    {
        if(selectedLanguage.equals("en"))
        {
            lookingFor.setText(estimationModel.getLooking_for());
            estimationCategory.setText(estimationModel.getCategory_name());
            totalSqft.setText(estimationModel.getEntered_sqft() + " Sqft");
            status.setText(estimationModel.getStatus_name());

        }else
        {
            lookingFor.setText(estimationModel.getLooking_for_arabic());
            estimationCategory.setText(estimationModel.getCategory_name_arabic());
            totalSqft.setText(estimationModel.getEntered_sqft() + " " + getResources().getString(R.string.sqft));
            status.setText(estimationModel.getStatus_arabic_name());
        }


        SqftPrice.setText(estimationModel.getSqft_price() + " " + getResources().getString(R.string.currency));
        estimatedBudget.setText(Integer.parseInt(estimationModel.getEntered_sqft()) * Integer.parseInt(estimationModel.getSqft_price()) + " " + getResources().getString(R.string.currency));

        estimationNo.setText(estimationModel.getEstimation_number());
        createdAt.setText(parseDateToddMMyyyy(estimationModel.getCreated_at()));

        if(!estimationModel.getNote().equals(""))
        {
            descriptionLayout.setVisibility(View.VISIBLE);
            description.setText(estimationModel.getNote());
        }

        if(!estimationModel.getReply().equals(""))
        {
            adminNoteLayout.setVisibility(View.VISIBLE);
            adminNote.setText(estimationModel.getReply());
        }



        ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                .toBuilder()
                .setAllCorners(CornerFamily.ROUNDED,5)
                .build();

        MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
        shapeDrawable.setPadding(10 , 5 , 10 , 5);

        shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(estimationModel.getStatus_color())));
        ViewCompat.setBackground(status,shapeDrawable);


        userName.setText(estimationModel.getAcc_name() + " " + estimationModel.getAcc_surname());
        phoneNo.setText(estimationModel.getPhone());
        email.setText(estimationModel.getEmail());
    }

    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-dd-MM HH:mm:ss";
        String outputPattern = "yyyy-dd-MM h:mm a";
        SimpleDateFormat inputFormat = new SimpleDateFormat(inputPattern);
        SimpleDateFormat outputFormat = new SimpleDateFormat(outputPattern);

        Date date = null;
        String str = null;

        try {
            date = inputFormat.parse(time);
            str = outputFormat.format(date);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return str;
    }
}