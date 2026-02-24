package com.thecontractor;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

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

import com.foloosi.core.FPayListener;
import com.foloosi.core.FoloosiLog;
import com.foloosi.core.FoloosiPay;
import com.foloosi.models.Customer;
import com.foloosi.models.OrderData;
import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.QuotationImagesAdapter;
import com.thecontractor.Adapter.QuotationsCompaniesAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Global.downloadFile;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.QuotationModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Random;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

//public class QuotationsDetails extends AppCompatActivity implements QuotationsCompaniesAdapter.QuotationIdInterface , FPayListener {
public class QuotationsDetails extends AppCompatActivity implements QuotationsCompaniesAdapter.QuotationIdInterface {
    String transactionId;
    String userId;
    String companyQuotationId;
    String fistNameStr , lastNameStr  , addressStr  , mobileStr , emailStr;
    String quotationId;
    String quotationPrice;

    LinearLayout quotationDetailsLayout;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    QuotationModel quotationModel;

    TextView category;
    TextView subCategory;
    TextView quotationNo;
    TextView status;
    TextView createdAt;
    TextView description;
    TextView adminNote;
    TextView userName;
    TextView phoneNo;
    TextView email;

    LinearLayout adminNoteLayout , descriptionLayout , imagesLayout , assignedCompaniesLayout;

    RecyclerView quotationImagesRecyclerView;
    GridLayoutManager gridLayoutManager ;
    QuotationImagesAdapter quotationImagesAdapter;


    RecyclerView assignedCompaniesRecyclerView;
    LinearLayoutManager linearLayoutManager ;
    String selectedLanguage = "en";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_quotations_details);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(R.string.quotation_details);

        getLanguageFromSP();
        getDataFromSP();
        getObjectFromAdapter();
        initiate();
        quotationDetailsAPI();
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
        if (!SharedPrefManager.getInstance(QuotationsDetails.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(QuotationsDetails.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }

    public void getObjectFromAdapter() {
        Intent intent = getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {

            quotationId = (String) bundle.getString("id");

            Log.e("tag", "quotation id is : " + quotationId);
        }
    }

    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(QuotationsDetails.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(QuotationsDetails.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();
            fistNameStr = userModel.getName();
            lastNameStr = userModel.getSurname();
            addressStr = userModel.getAddress();
            mobileStr = userModel.getPhone();
            emailStr = userModel.getEmail();

            Log.e("tag", "user id is : " + userId);

        }
    }

    public void initiate() {
        progressDialog = new ProgressDialog(QuotationsDetails.this);

        quotationDetailsLayout = (LinearLayout) findViewById(R.id.quotationDetailsLayout);
        quotationDetailsLayout.setVisibility(View.GONE);



        category = (TextView) findViewById(R.id.category);
        subCategory = (TextView) findViewById(R.id.subCategory);
        quotationNo = (TextView) findViewById(R.id.quotationNo);
        status = (TextView) findViewById(R.id.status);
        createdAt = (TextView) findViewById(R.id.createdAt);
        description = (TextView) findViewById(R.id.description);
        adminNote = (TextView) findViewById(R.id.adminNote);

        userName = (TextView) findViewById(R.id.userName);
        phoneNo = (TextView) findViewById(R.id.phoneNo);
        email = (TextView) findViewById(R.id.email);

        adminNoteLayout = (LinearLayout) findViewById(R.id.adminNoteLayout);
        adminNoteLayout.setVisibility(View.GONE);
        descriptionLayout = (LinearLayout) findViewById(R.id.descriptionLayout);
        descriptionLayout.setVisibility(View.GONE);
        imagesLayout = (LinearLayout) findViewById(R.id.imagesLayout);
        imagesLayout.setVisibility(View.GONE);
        assignedCompaniesLayout = (LinearLayout) findViewById(R.id.assignedCompaniesLayout);
        assignedCompaniesLayout.setVisibility(View.GONE);

        quotationImagesAdapter = new QuotationImagesAdapter(QuotationsDetails.this);

        quotationImagesRecyclerView = findViewById(R.id.quotationImagesRecyclerView);
        quotationImagesRecyclerView.setHasFixedSize(true);
        gridLayoutManager = new GridLayoutManager(QuotationsDetails.this , 3 ,  GridLayoutManager.VERTICAL , false);
        quotationImagesRecyclerView.setLayoutManager(gridLayoutManager);
        quotationImagesRecyclerView.setAdapter(quotationImagesAdapter);


        assignedCompaniesRecyclerView = findViewById(R.id.assignedCompaniesRecyclerView);
        linearLayoutManager = new LinearLayoutManager(QuotationsDetails.this  ,  LinearLayoutManager.VERTICAL , false);
        assignedCompaniesRecyclerView.setLayoutManager(linearLayoutManager);
    }

    private void quotationDetailsAPI() {

        RequestBody id = RequestBody.create(quotationId, MediaType.parse("text/plain"));
        RequestBody user_id = RequestBody.create(userId, MediaType.parse("text/plain"));


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
        call = retrofitApi.quotationsDetails(id, user_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : " + new Gson().toJson(response.body()));


                hideProgress();
                if (response.isSuccessful()) {
                    if (response.body().getError().equals("false")) {

                        quotationDetailsLayout.setVisibility(View.VISIBLE);
                        quotationPrice = response.body().getQuotation_price();
                        quotationModel = response.body().getQuotation();

                        Log.e("tag", "message is : " + quotationModel.getMessage());

                        setDataToWidget();


                    } else {
                        Toast.makeText(QuotationsDetails.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(QuotationsDetails.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if (call.isCanceled()) {
                    Log.e("tag", "request is cancelled");
                } else {
                    hideProgress();
                    Toast.makeText(QuotationsDetails.this, getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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
        if(selectedLanguage.equals("en"))
        {
            category.setText(quotationModel.getCate_name());
            subCategory.setText(quotationModel.getSub_cat_name());
            status.setText(quotationModel.getStatus_name());

        }else
        {
            category.setText(quotationModel.getCategory_arabic_name());
            subCategory.setText(quotationModel.getSub_category_arabic_name());
            status.setText(quotationModel.getStatus_arabic_name());
        }


        quotationNo.setText(quotationModel.getQuotation_number());
        createdAt.setText(parseDateToddMMyyyy(quotationModel.getCreated_at()));
        userName.setText(quotationModel.getName() + " " + quotationModel.getSurname());
        phoneNo.setText(quotationModel.getPhone());
        email.setText(quotationModel.getEmail());


        if(!quotationModel.getMessage().equals(""))
        {
            descriptionLayout.setVisibility(View.VISIBLE);
            description.setText(quotationModel.getMessage());
        }

        if(!quotationModel.getReply().equals(""))
        {
            adminNoteLayout.setVisibility(View.VISIBLE);
            adminNote.setText(quotationModel.getReply());
        }

        if(quotationModel.getImages().size() > 0)
        {
            imagesLayout.setVisibility(View.VISIBLE);
            quotationImagesAdapter.setData(quotationModel.getImages());

        }else
        {
            imagesLayout.setVisibility(View.GONE);
        }

        if(quotationModel.getCompanies().size() > 0)
        {
            assignedCompaniesLayout.setVisibility(View.VISIBLE);
            QuotationsCompaniesAdapter quotationsCompaniesAdapter = new QuotationsCompaniesAdapter(QuotationsDetails.this , quotationModel.getCompanies() , selectedLanguage , QuotationsDetails.this);
            assignedCompaniesRecyclerView.setAdapter(quotationsCompaniesAdapter);

        }else
        {
            assignedCompaniesLayout.setVisibility(View.GONE);
        }






        ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                .toBuilder()
                .setAllCorners(CornerFamily.ROUNDED,5)
                .build();

        MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
        shapeDrawable.setPadding(10 , 5 , 10 , 5);

        shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(quotationModel.getColor())));
        ViewCompat.setBackground(status,shapeDrawable);
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
    public void selectedQuotationId(String id , String text , String path) {
        this.companyQuotationId = id;
        if(text.equals("Pay to Download"))
        {
            //makePayment();
        }else
        {
            downloadFile.DownloadingInsta(QuotationsDetails.this , ApiUrls.DOWNLOAD_QUOTATIONS_IMAGE_URL + path , path , ".png");
        }
    }

//    public void makePayment()
//    {
//        Log.e("tag" , "make payment function : ");
//
//        FoloosiLog.setLogVisible(true);
//        FoloosiPay.init(this, getResources().getString(R.string.foloosi_key));
//
//        OrderData orderData = new OrderData();
//        orderData.setOrderAmount(Double.parseDouble(quotationPrice));
//        Random rand = new Random();
//        int orderId = rand.nextInt(100000);
//        orderData.setCustomColor("#ab34fd");
//        orderData.setOrderId(String.valueOf(orderId));
//        orderData.setCurrencyCode(getResources().getString(R.string.currency));
//        Customer customer = new Customer();
//        customer.setName(fistNameStr + " " +lastNameStr);
//        customer.setEmail(emailStr);
//        customer.setMobile(mobileStr);
//
//
//        orderData.setCustomer(customer);
//        FoloosiPay.setPaymentListener(this);
//        FoloosiPay.makePayment(orderData);
//    }
//
//    @Override
//    public void onTransactionSuccess(String transactionId) {
//        this.transactionId = transactionId;
//        //showToast("isSuccess::" + transactionId);
//        paymentAPI();
//    }
//
//    @Override
//    public void onTransactionFailure(String error) {
//        showToast(error);
//    }
//
//    @Override
//    public void onTransactionCancelled() {
//        // Cancelled by User
//        Log.e("Cancel::", "Cancelled");
//    }

    private void showToast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_LONG).show();
    }

    private void paymentAPI() {

        RequestBody id = RequestBody.create(companyQuotationId, MediaType.parse("text/plain"));
        RequestBody user_id = RequestBody.create(userId, MediaType.parse("text/plain"));
        RequestBody transaction_id = RequestBody.create(transactionId, MediaType.parse("text/plain"));


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
        call = retrofitApi.quotationPayment(id, user_id , transaction_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : " + new Gson().toJson(response.body()));


                hideProgress();
                if (response.isSuccessful()) {
                    if (response.body().getError().equals("false")) {

                       quotationDetailsAPI();

                    } else {
                        Toast.makeText(QuotationsDetails.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(QuotationsDetails.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onFailure(Call<BasicResponseModel> call, Throwable t) {
                if (call.isCanceled()) {
                    Log.e("tag", "request is cancelled");
                } else {
                    hideProgress();
                    Toast.makeText(QuotationsDetails.this, getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

}

