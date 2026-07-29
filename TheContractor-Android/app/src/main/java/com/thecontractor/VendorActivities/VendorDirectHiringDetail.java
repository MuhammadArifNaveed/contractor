package com.thecontractor.VendorActivities;

import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.JobTypeSpinnerAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.VendorDirectHiringModel;
import com.thecontractor.Model.VendorJobTypeModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
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

public class VendorDirectHiringDetail extends AppCompatActivity {
    VendorDirectHiringModel vendorDirectHiringModel;

    ImageView applicantImage;
    TextView applicantName , categoriesName , dateTime ,viewCV , phone , email , address , status;
    Button updateHireBtn;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    String selectedLanguage = "en";
    String hiringId;
    String vendorId;
    String userId;
    String userType;
    String selectedHireStatus;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_direct_hiring_detail);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.applicant_detail));

        getObjectFromAdapter();
        getLanguageFromSP();
        getDataFromSP();
        initiate();
        clickListener();
        setDataToWidget();
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


    public void getObjectFromAdapter() {
        Intent intent = getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {

            vendorDirectHiringModel = (VendorDirectHiringModel) bundle.get("vendorDirectHiringModel");
            hiringId = vendorDirectHiringModel.getHiring_id();

            Log.e("tag" , "hiringId is : "+hiringId);


        }
    }


    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(VendorDirectHiringDetail.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorDirectHiringDetail.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorDirectHiringDetail.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorDirectHiringDetail.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();
            userId = vendorModel.getUser_id();
            userType = vendorModel.getUser_type();


            Log.e("tag" , "Vendor id is : "+vendorId);
            Log.e("tag" , "user id is : "+userId);
            Log.e("tag" , "user type is : "+userType);


        }
    }

    public void initiate(){

        progressDialog = new ProgressDialog(VendorDirectHiringDetail.this);
        applicantImage = (ImageView) findViewById(R.id.applicantImage);
        applicantName = (TextView) findViewById(R.id.applicantName);
        categoriesName = (TextView) findViewById(R.id.categoriesName);
        dateTime = (TextView) findViewById(R.id.dateTime);
        viewCV = (TextView) findViewById(R.id.viewCV);
        phone = (TextView) findViewById(R.id.phone);
        email = (TextView) findViewById(R.id.email);
        address = (TextView) findViewById(R.id.address);
        status = (TextView) findViewById(R.id.status);
        updateHireBtn = (Button) findViewById(R.id.updateHireBtn);

    }

    public void clickListener(){
        updateHireBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                hireDialog();
            }
        });
    }

    public void hireDialog()
    {
        Dialog dialog = new Dialog(VendorDirectHiringDetail.this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.hire_status_dialog);
        Window window = dialog.getWindow();
        window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        dialog.setCancelable(true);
        dialog.show();

        ArrayList<VendorJobTypeModel> hireStatusList = new ArrayList<>();
        hireStatusList.add(new VendorJobTypeModel("Submitted"));
        hireStatusList.add(new VendorJobTypeModel("Viewed"));
        hireStatusList.add(new VendorJobTypeModel("Shortlisted"));
        hireStatusList.add(new VendorJobTypeModel("interviewed"));
        hireStatusList.add(new VendorJobTypeModel("Selected"));



        Spinner hireSpinner = dialog.findViewById(R.id.hireStatusSpinner);
        Button proceedBtn = dialog.findViewById(R.id.proceedBtn);

        JobTypeSpinnerAdapter jobTypeSpinnerAdapter = new JobTypeSpinnerAdapter(VendorDirectHiringDetail.this , hireStatusList , selectedLanguage);
        hireSpinner.setAdapter(jobTypeSpinnerAdapter);

        hireSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {


                selectedHireStatus = hireStatusList.get(i).getType();


                Log.e("tag" , "selectedHireStatus is : "+selectedHireStatus);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });


        proceedBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
                updateHireStatusAPI();
            }
        });
    }

    private void updateHireStatusAPI() {

        RequestBody id = RequestBody.create(vendorId , MediaType.parse("text/plain"));
        RequestBody hiring_id = RequestBody.create(hiringId , MediaType.parse("text/plain"));
        RequestBody status = RequestBody.create(selectedHireStatus , MediaType.parse("text/plain"));

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
        call = retrofitApi.updateDirectHireStatusApi(id , hiring_id , status);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        Toast.makeText(VendorDirectHiringDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();

                        finish();
                    }
                    else
                    {
                        Toast.makeText(VendorDirectHiringDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorDirectHiringDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorDirectHiringDetail.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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

    public void setDataToWidget()
    {

        Glide.with(VendorDirectHiringDetail.this)
                .load(ApiUrls.PROFILE_IMAGE_URL+vendorDirectHiringModel.getImage())
                .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                .into(applicantImage);

        if(selectedLanguage.equals("en"))
        {
            applicantName.setText(vendorDirectHiringModel.getName() + " " + vendorDirectHiringModel.getSurname());
            categoriesName.setText(vendorDirectHiringModel.getCategory_title());
            phone.setText(vendorDirectHiringModel.getPhone());
            email.setText(vendorDirectHiringModel.getEmail());
            address.setText(vendorDirectHiringModel.getAddress());
            status.setText(vendorDirectHiringModel.getHiring_status());


        }
        else
        {
            applicantName.setText(vendorDirectHiringModel.getName() + " " + vendorDirectHiringModel.getSurname());
            categoriesName.setText(vendorDirectHiringModel.getCategory_arabic_title());
            phone.setText(vendorDirectHiringModel.getPhone());
            email.setText(vendorDirectHiringModel.getEmail());
            address.setText(vendorDirectHiringModel.getAddress());
            status.setText(vendorDirectHiringModel.getHiring_status());

        }


        dateTime.setText(parseDateToddMMyyyy(vendorDirectHiringModel.getCreated_at()));



    }

    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-dd-MM HH:mm:ss";
        String outputPattern = "dd-MMM-yyyy";
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