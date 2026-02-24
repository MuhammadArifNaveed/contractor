package com.thecontractor;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.WorkshopAdImagesAdapter;
import com.thecontractor.Adapter.WorkshopAdQuotationAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Model.WorkshopAdImagesModel;
import com.thecontractor.Model.WorkshopAdModel;
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

public class WorkshopAdDetail extends AppCompatActivity implements WorkshopAdQuotationAdapter.QuotationLockInterface {
    String userId;
    String workshopAdId;
    String paidStatusId;


    LinearLayout workshopAdDetailsLayout;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    WorkshopAdModel workshopAdModel;

    TextView bidType;
    TextView workSector;
    TextView workCity;
    TextView paidStatus;
    TextView createdAt;
    TextView workshopStatus;
    TextView title;
    TextView description;
    LinearLayout imagesLayout , quotationsLayout;
    RecyclerView quotationImagesRecyclerView;
    GridLayoutManager gridLayoutManager ;
    RecyclerView quotationRecyclerView;
    LinearLayoutManager linearLayoutManager ;
    WorkshopAdImagesAdapter workshopAdImagesAdapter;
    WorkshopAdQuotationAdapter workshopAdQuotationAdapter;
    String selectedLanguage = "en";
    ArrayList<WorkshopAdImagesModel> imagesArray;
    ArrayList<WorkshopAdModel.QuotationsModel> quotationArray;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_workshop_ad_detail);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(R.string.workshop_ad_detail);

        getLanguageFromSP();
        getDataFromSP();
        getObjectFromAdapter();
        initiate();
        clickListener();
        workshopAdDetailsAPI();
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

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(WorkshopAdDetail.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(WorkshopAdDetail.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }

    public void getObjectFromAdapter() {
        Intent intent = getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {

            workshopAdId = (String) bundle.getString("id");

            Log.e("tag", "workshop ad id is : " + workshopAdId);
        }
    }

    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(WorkshopAdDetail.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(WorkshopAdDetail.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);

            userId = userModel.getId();

            Log.e("tag", "user id is : " + userId);

        }
    }

    public void initiate() {
        imagesArray = new ArrayList<>();
        quotationArray = new ArrayList<>();

        progressDialog = new ProgressDialog(WorkshopAdDetail.this);

        workshopAdDetailsLayout = (LinearLayout) findViewById(R.id.workshopAdDetailsLayout);
        workshopAdDetailsLayout.setVisibility(View.GONE);



        bidType = (TextView) findViewById(R.id.bidType);
        workSector = (TextView) findViewById(R.id.workSector);
        workCity = (TextView) findViewById(R.id.workCity);
        paidStatus = (TextView) findViewById(R.id.paidStatus);
        createdAt = (TextView) findViewById(R.id.createdAt);
        workshopStatus = (TextView) findViewById(R.id.workshopStatus);
        title = (TextView) findViewById(R.id.title);
        description = (TextView) findViewById(R.id.description);
        imagesLayout = (LinearLayout) findViewById(R.id.imagesLayout);
        imagesLayout.setVisibility(View.GONE);
        quotationsLayout = (LinearLayout) findViewById(R.id.quotationsLayout);
        quotationsLayout.setVisibility(View.GONE);

        workshopAdImagesAdapter = new WorkshopAdImagesAdapter(WorkshopAdDetail.this);

        quotationImagesRecyclerView = findViewById(R.id.quotationImagesRecyclerView);
        gridLayoutManager = new GridLayoutManager(WorkshopAdDetail.this , 3 ,  GridLayoutManager.VERTICAL , false);
        quotationImagesRecyclerView.setLayoutManager(gridLayoutManager);
        quotationImagesRecyclerView.setAdapter(workshopAdImagesAdapter);



        quotationRecyclerView = findViewById(R.id.quotationRecyclerView);
        linearLayoutManager = new LinearLayoutManager(WorkshopAdDetail.this ,  LinearLayoutManager.VERTICAL , false);
        quotationRecyclerView.setLayoutManager(linearLayoutManager);

    }

    public void clickListener(){
        workshopStatus.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateWorkshopStatus();
            }
        });
    }

    private void workshopAdDetailsAPI() {

        RequestBody id = RequestBody.create(workshopAdId, MediaType.parse("text/plain"));


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
        call = retrofitApi.workshopAdDetails(id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : " + new Gson().toJson(response.body()));


                hideProgress();
                if (response.isSuccessful()) {
                    if (response.body().getError().equals("false")) {

                        workshopAdDetailsLayout.setVisibility(View.VISIBLE);
                        workshopAdModel = response.body().getWorkshop_details();

                        setDataToWidget();


                    } else {
                        Toast.makeText(WorkshopAdDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(WorkshopAdDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if (call.isCanceled()) {
                    Log.e("tag", "request is cancelled");
                } else {
                    hideProgress();
                    Toast.makeText(WorkshopAdDetail.this, getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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

        bidType.setText(workshopAdModel.getBid_type());
        workSector.setText(workshopAdModel.getWork_sector());

        if(workshopAdModel.getIs_paid().equals("0")){
            paidStatus.setText("Unpaid");
        }else{
            paidStatus.setText("Paid");
        }

        if(workshopAdModel.getIs_active().equals("1")){
            workshopStatus.setText("(Enabled) Make Disable");
            workshopStatus.setTextColor(ContextCompat.getColor(WorkshopAdDetail.this, R.color.green));
        }else{
            workshopStatus.setText("(Disabled) Make Enable");
            workshopStatus.setTextColor(ContextCompat.getColor(WorkshopAdDetail.this, R.color.red));
        }

        workCity.setText(workshopAdModel.getCity_name());
        //viewCount.setText(workshopAdModel.getView_count());
        createdAt.setText(parseDateToddMMyyyy(workshopAdModel.getCreated_at()));

        title.setText(workshopAdModel.getTitle());
        description.setText(workshopAdModel.getDescription());
        imagesArray = workshopAdModel.getImages();

        Log.e("tag" , "imagesArray size is  : "+imagesArray.size());

        if(imagesArray.size() > 0)
        {
            imagesLayout.setVisibility(View.VISIBLE);
            workshopAdImagesAdapter.setData(imagesArray);

        }

        quotationArray = workshopAdModel.getQuotations();

        Log.e("tag" , "quotationArray size is  : "+quotationArray.size());


        if(quotationArray.size() > 0)
        {
            quotationsLayout.setVisibility(View.VISIBLE);
            workshopAdQuotationAdapter = new WorkshopAdQuotationAdapter(WorkshopAdDetail.this , quotationArray , selectedLanguage , WorkshopAdDetail.this);
            quotationRecyclerView.setAdapter(workshopAdQuotationAdapter);

        }

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

    private void updateLockAPI(int pos, WorkshopAdModel.QuotationsModel quotationsModel) {
        String status;
        String statusId;
        if(quotationsModel.getLocked().equals("1"))
        {
            statusId = "0";
            status = "unlock";
        }else {
            statusId = "1";
            status = "lock";
        }


        RequestBody quotation_id = RequestBody.create(quotationsModel.getId(), MediaType.parse("text/plain"));
        RequestBody lock = RequestBody.create(status, MediaType.parse("text/plain"));


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
        call = retrofitApi.updateWorkshopQuotationLock(quotation_id , lock);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : " + new Gson().toJson(response.body()));


                hideProgress();
                if (response.isSuccessful()) {

                    if (response.body().getError().equals("false")) {

                        quotationsModel.setLocked(statusId);
                        workshopAdQuotationAdapter.notifyItemChanged(pos);

                    } else {
                        Toast.makeText(WorkshopAdDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(WorkshopAdDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if (call.isCanceled()) {
                    Log.e("tag", "request is cancelled");
                } else {
                    hideProgress();
                    Toast.makeText(WorkshopAdDetail.this, getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    private void updateWorkshopStatus() {

        RequestBody workshop_id = RequestBody.create(workshopAdId, MediaType.parse("text/plain"));


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
        call = retrofitApi.updateWorkshopStatus(workshop_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : " + new Gson().toJson(response.body()));


                hideProgress();
                if (response.isSuccessful()) {

                    if (response.body().getError().equals("false")) {

                        if(response.body().getCurrent_status().equals("true")){
                            workshopStatus.setText("(Enabled) Make Disable");
                            workshopStatus.setTextColor(ContextCompat.getColor(WorkshopAdDetail.this, R.color.green));
                        }else{
                            workshopStatus.setText("(Disabled) Make Enable");
                            workshopStatus.setTextColor(ContextCompat.getColor(WorkshopAdDetail.this, R.color.red));
                        }

                    } else {
                        Toast.makeText(WorkshopAdDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(WorkshopAdDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if (call.isCanceled()) {
                    Log.e("tag", "request is cancelled");
                } else {
                    hideProgress();
                    Toast.makeText(WorkshopAdDetail.this, getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }


    @Override
    public void selectedQuotation(int pos, WorkshopAdModel.QuotationsModel quotationsModel) {

        updateLockAPI(pos , quotationsModel);
    }
}