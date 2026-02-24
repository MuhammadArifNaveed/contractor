package com.thecontractor.VendorActivities;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
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

import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.VendorStatusAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.VendorEnquiryDetailModel;
import com.thecontractor.Model.VendorRatingModel;
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

public class VendorEnquiryDetail extends AppCompatActivity implements VendorStatusAdapter.StatusIdInterface{
    VendorEnquiryDetailModel vendorEnquiryModel;
    String enquiryId;
    String vendorId;
    String statusId;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;


    LinearLayout enquiryDetail;
    TextView orderAt;
    TextView dateAndTime;
    TextView enquiryNumber;
    TextView location;
    TextView description;
    TextView status;
    TextView adminNote;
    LinearLayout adminNoteLayout;
    TextView userName , phoneNo , email;
    TextView updateStatusTV;

    RecyclerView statusRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<VendorRatingModel> list;

    String selectedLanguage = "en";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_enquiry_detail);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.enquiry_details));

        getLanguageFromSP();
        getDataFromSP();
        getObjectFromAdapter();
        initiate();
        enquiryDetailsAPI();
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

            enquiryId = (String) bundle.getString("id");

            Log.e("tag" , "enquiry id is : "+enquiryId);

        }
    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(VendorEnquiryDetail.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorEnquiryDetail.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }

    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorEnquiryDetail.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorEnquiryDetail.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();


            Log.e("tag" , "Vendor id is : "+vendorId);


        }
    }

    public void initiate()
    {

        progressDialog = new ProgressDialog(VendorEnquiryDetail.this);

        enquiryDetail = (LinearLayout) findViewById(R.id.enquiryDetail);
        enquiryDetail.setVisibility(View.GONE);
        orderAt = (TextView) findViewById(R.id.orderAt);
        enquiryNumber = (TextView) findViewById(R.id.enquiryNumber);
        dateAndTime = (TextView) findViewById(R.id.dateAndTime);
        location = (TextView) findViewById(R.id.location);
        description = (TextView) findViewById(R.id.description);
        status = (TextView) findViewById(R.id.status);
        adminNote = (TextView) findViewById(R.id.adminNote);
        adminNoteLayout = (LinearLayout) findViewById(R.id.adminNoteLayout);
        adminNoteLayout.setVisibility(View.GONE);

        userName = (TextView) findViewById(R.id.userName);
        phoneNo = (TextView) findViewById(R.id.phoneNo);
        email = (TextView) findViewById(R.id.email);
        updateStatusTV = (TextView) findViewById(R.id.updateStatusTV);
        updateStatusTV.setVisibility(View.GONE);

        list = new ArrayList<>();
        statusRV = (RecyclerView) findViewById(R.id.statusRV);
        linearLayoutManager = new LinearLayoutManager(VendorEnquiryDetail.this  ,  LinearLayoutManager.HORIZONTAL , false);
        statusRV.setLayoutManager(linearLayoutManager);

    }


    private void enquiryDetailsAPI() {

        RequestBody id = RequestBody.create(enquiryId, MediaType.parse("text/plain"));
        RequestBody vendor_id = RequestBody.create(vendorId, MediaType.parse("text/plain"));


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
        call = retrofitApi.vendorParticularEnquiryDetail(id , vendor_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : " + new Gson().toJson(response.body()));


                hideProgress();
                if (response.isSuccessful()) {
                    if (response.body().getError().equals("false")) {

                        enquiryDetail.setVisibility(View.VISIBLE);

                        vendorEnquiryModel = response.body().getVendor_enquiry();


                        setDataToWidget();


                    } else {
                        Toast.makeText(VendorEnquiryDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(VendorEnquiryDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if (call.isCanceled()) {
                    Log.e("tag", "request is cancelled");
                } else {
                    hideProgress();
                    Toast.makeText(VendorEnquiryDetail.this, getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    public void showProgress() {
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



        status.setText(vendorEnquiryModel.getS_name());
        orderAt.setText(parseDateToddMMyyyy(vendorEnquiryModel.getCreated_at()));
        enquiryNumber.setText(vendorEnquiryModel.getEnquiry_number());
        dateAndTime.setText(parseDateToddMMyyyy(vendorEnquiryModel.getDate_time()));
        location.setText(vendorEnquiryModel.getLocation());
        description.setText(vendorEnquiryModel.getDescription());

        if(vendorEnquiryModel.getStatus().size() > 0)
        {
            updateStatusTV.setVisibility(View.VISIBLE);
        }
        else
        {
            updateStatusTV.setVisibility(View.GONE);
        }
        VendorStatusAdapter vendorStatusAdapter = new VendorStatusAdapter(VendorEnquiryDetail.this , vendorEnquiryModel.getStatus() , selectedLanguage , VendorEnquiryDetail.this);
        statusRV.setAdapter(vendorStatusAdapter);

        ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                .toBuilder()
                .setAllCorners(CornerFamily.ROUNDED,5)
                .build();

        MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
        shapeDrawable.setPadding(10 , 5 , 10 , 5);

        shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(vendorEnquiryModel.getColor())));
        ViewCompat.setBackground(status,shapeDrawable);


        userName.setText(vendorEnquiryModel.getName() + " " + vendorEnquiryModel.getSurname());
        phoneNo.setText(vendorEnquiryModel.getPhone());
        email.setText(vendorEnquiryModel.getEmail());
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

    @Override
    public void selectedId(String statusId) {
        this.statusId = statusId;
        updateEnquiryStatusAPI();

    }

    private void updateEnquiryStatusAPI() {

        RequestBody id = RequestBody.create(enquiryId, MediaType.parse("text/plain"));
        RequestBody vendor_id = RequestBody.create(vendorId, MediaType.parse("text/plain"));
        RequestBody status_id = RequestBody.create(statusId, MediaType.parse("text/plain"));


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
        call = retrofitApi.updateEnquiryStatus(id , vendor_id , status_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : " + new Gson().toJson(response.body()));


                hideProgress();
                if (response.isSuccessful()) {

                    if (response.body().getError().equals("false")) {

                        if(response.body().getStatus().equals("reject"))
                        {
                            showDialog();
                        }else
                        {
                            enquiryDetailsAPI();
                        }



                    } else {
                        Toast.makeText(VendorEnquiryDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(VendorEnquiryDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if (call.isCanceled()) {
                    Log.e("tag", "request is cancelled");
                } else {
                    hideProgress();
                    Toast.makeText(VendorEnquiryDetail.this, getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }


    public void showDialog()
    {
        Dialog dialog = new Dialog(VendorEnquiryDetail.this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.rejection_dialog);
        Window window = dialog.getWindow();
        window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        dialog.setCancelable(true);
        dialog.show();

        EditText reasonOfRejection = dialog.findViewById(R.id.reasonOfRejection);
        Button submitBtn = dialog.findViewById(R.id.submitBtn);

        submitBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(reasonOfRejection.getText().toString().equals(""))
                {
                    Toast.makeText(VendorEnquiryDetail.this , "Enter your reason of rejection", Toast.LENGTH_SHORT).show();
                }
                else
                {
                    dialog.dismiss();
                    updateRejectStatusAPI(reasonOfRejection.getText().toString());
                }
            }
        });



    }


    private void updateRejectStatusAPI(String reason) {

        RequestBody id = RequestBody.create(enquiryId, MediaType.parse("text/plain"));
        RequestBody vendor_id = RequestBody.create(vendorId, MediaType.parse("text/plain"));
        RequestBody status_id = RequestBody.create(statusId, MediaType.parse("text/plain"));
        RequestBody reason_rejection = RequestBody.create(reason, MediaType.parse("text/plain"));


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
        call = retrofitApi.updateEnquiryRejectionStatus(id , vendor_id , status_id , reason_rejection);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : " + new Gson().toJson(response.body()));


                hideProgress();
                if (response.isSuccessful()) {

                    if (response.body().getError().equals("false")) {

                        enquiryDetailsAPI();

                    } else {
                        Toast.makeText(VendorEnquiryDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(VendorEnquiryDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if (call.isCanceled()) {
                    Log.e("tag", "request is cancelled");
                } else {
                    hideProgress();
                    Toast.makeText(VendorEnquiryDetail.this, getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }


}