package com.thecontractor.VendorActivities;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.GridLayoutManager;
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
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RatingBar;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
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
import com.thecontractor.Adapter.CompanyDetailSubCategoriesAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.EstimationModel;
import com.thecontractor.Model.VendorMyMembershipModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
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

//public class VendorMyMembershipDetail extends AppCompatActivity implements FPayListener {
public class VendorMyMembershipDetail extends AppCompatActivity {
    VendorMyMembershipModel vendorMyMembershipModel;
    String selectedLanguage = "en";

    LinearLayout muMemberShipLayout , buyWorkshopLayout , workshopDetailsLayout;

    TextView membershipNoTV , membershipTitleTV , membershipPriceTV  , leadCapacityTV , quotationCapacityTV , membershipBuyThroughTV ,
            paymentIdTV , membershipBuyDateTimeTV , topTenDaysStartDateTV , topTenDaysEndDate , topTwentyDaysStartDateTV , topTwentyDaysEndDateTV,
            topTenDaysTV , topTwentyDaysTV , membershipStatusTV , buyWorkshopTV , workshopNoTV , workshopPriceTV , workshopBuyThroughTV , workShopPaymentIdTV,
            workShopCouponCodeTV , workshopStartDateTV , workshopEndDateTV , workshopStatusTV;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    String membershipId;
    String transactionId;
    String vendorId;
    String vendorName;
    String vendorEmail;
    String vendorCity;
    String vendorAddress;
    String vendorPhone;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_my_membership_detail);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle("Membership Detail");

        getObjectFromAdapter();
        getLanguageFromSP();
        getDataFromSP();
        initiate();
        clickListener();
        membershipDetail();
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

            membershipId = (String) bundle.getString("id");

            Log.e("tag" , "membership id is : "+membershipId);

        }
    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(VendorMyMembershipDetail.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorMyMembershipDetail.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }

    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorMyMembershipDetail.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorMyMembershipDetail.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();
            vendorName = vendorModel.getCompany_name();
            vendorEmail = vendorModel.getLogin_email();
            vendorPhone = vendorModel.getCompany_phone();
            vendorCity = vendorModel.getCity_name();
            vendorAddress = vendorModel.getCompany_address();


            Log.e("tag" , "vendorId is : "+vendorId + "vendorName is : "+vendorName + "vendorEmail is : "+vendorEmail + "vendorPhone is : "+vendorPhone + "vendorCity is : "+vendorCity+ "vendorAddress is : "+vendorAddress);


        }
    }

    public void initiate()
    {
        progressDialog = new ProgressDialog(VendorMyMembershipDetail.this);


        membershipNoTV = (TextView) findViewById(R.id.membershipNoTV);
        membershipTitleTV = (TextView) findViewById(R.id.membershipTitleTV);
        membershipPriceTV = (TextView) findViewById(R.id.membershipPriceTV);
        leadCapacityTV = (TextView) findViewById(R.id.leadCapacityTV);
        quotationCapacityTV = (TextView) findViewById(R.id.quotationCapacityTV);
        membershipBuyThroughTV = (TextView) findViewById(R.id.membershipBuyThroughTV);
        paymentIdTV = (TextView) findViewById(R.id.paymentIdTV);
        membershipBuyDateTimeTV = (TextView) findViewById(R.id.membershipBuyDateTimeTV);
        topTenDaysStartDateTV = (TextView) findViewById(R.id.topTenDaysStartDateTV);
        topTenDaysEndDate = (TextView) findViewById(R.id.topTenDaysEndDate);
        topTwentyDaysStartDateTV = (TextView) findViewById(R.id.topTwentyDaysStartDateTV);
        topTwentyDaysEndDateTV = (TextView) findViewById(R.id.topTwentyDaysEndDateTV);
        topTenDaysTV = (TextView) findViewById(R.id.topTenDaysTV);
        topTwentyDaysTV = (TextView) findViewById(R.id.topTwentyDaysTV);
        membershipStatusTV = (TextView) findViewById(R.id.membershipStatusTV);
        buyWorkshopTV = (TextView) findViewById(R.id.buyWorkshopTV);

        muMemberShipLayout = (LinearLayout) findViewById(R.id.muMemberShipLayout);
        muMemberShipLayout.setVisibility(View.GONE);
        buyWorkshopLayout = (LinearLayout) findViewById(R.id.buyWorkshopLayout);
        buyWorkshopLayout.setVisibility(View.GONE);
        workshopDetailsLayout = (LinearLayout) findViewById(R.id.workshopDetailsLayout);
        workshopDetailsLayout.setVisibility(View.GONE);

        workshopNoTV = (TextView) findViewById(R.id.workshopNoTV);
        workshopPriceTV = (TextView) findViewById(R.id.workshopPriceTV);
        workshopBuyThroughTV = (TextView) findViewById(R.id.workshopBuyThroughTV);
        workShopPaymentIdTV = (TextView) findViewById(R.id.workShopPaymentIdTV);
        workShopCouponCodeTV = (TextView) findViewById(R.id.workShopCouponCodeTV);
        workshopStartDateTV = (TextView) findViewById(R.id.workshopStartDateTV);
        workshopEndDateTV = (TextView) findViewById(R.id.workshopEndDateTV);
        workshopStatusTV = (TextView) findViewById(R.id.workshopStatusTV);





    }

    private void membershipDetail() {



        RequestBody vendor_id = RequestBody.create(vendorId , MediaType.parse("text/plain"));
        RequestBody membership_id = RequestBody.create(membershipId , MediaType.parse("text/plain"));


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
        call = retrofitApi.membershipDetail(vendor_id , membership_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {
                        //Toast.makeText(VendorMyMembershipDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                        muMemberShipLayout.setVisibility(View.VISIBLE);
                        vendorMyMembershipModel = response.body().getMembership_detail();

                        setDataToWidget();

                    }
                    else
                    {
                        Toast.makeText(VendorMyMembershipDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorMyMembershipDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorMyMembershipDetail.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    public void setDataToWidget()
    {

        membershipId = vendorMyMembershipModel.getId();
        membershipNoTV.setText(vendorMyMembershipModel.getMembership_number());
        membershipTitleTV.setText(vendorMyMembershipModel.getMembership_title());
        membershipPriceTV.setText(getResources().getString(R.string.currency) + " " + vendorMyMembershipModel.getMembership_price());
        buyWorkshopTV.setText(getResources().getString(R.string.buy_now_in) + " " + getResources().getString(R.string.currency) + " " + vendorMyMembershipModel.getWorkshop_price());
        leadCapacityTV.setText(vendorMyMembershipModel.getMembership_leads_capacity());
        quotationCapacityTV.setText(vendorMyMembershipModel.getMembership_quotations_capacity());
        membershipBuyThroughTV.setText(vendorMyMembershipModel.getBuy_type());
        paymentIdTV.setText(vendorMyMembershipModel.getPayment_id());
        membershipBuyDateTimeTV.setText(parseDateToddMMyyyy(vendorMyMembershipModel.getCreated_at()));
        topTenDaysStartDateTV.setText(parseDate(vendorMyMembershipModel.getTop_ten_start_date()));
        topTenDaysEndDate.setText(parseDate(vendorMyMembershipModel.getTop_ten_expiry_date()));
        topTwentyDaysStartDateTV.setText(parseDate(vendorMyMembershipModel.getTop_twenty_start_date()));
        topTwentyDaysEndDateTV.setText(parseDate(vendorMyMembershipModel.getTop_twenty_expiry_date()));
        topTenDaysTV.setText(vendorMyMembershipModel.getMembership_top_ten_days());
        topTwentyDaysTV.setText(vendorMyMembershipModel.getMembership_top_twenty_days());
        membershipStatusTV.setText(vendorMyMembershipModel.getS_name());


        ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                .toBuilder()
                .setAllCorners(CornerFamily.ROUNDED,5)
                .build();

        MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
        shapeDrawable.setPadding(10 , 5 , 10 , 5);

        shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(vendorMyMembershipModel.getColor())));
        ViewCompat.setBackground(membershipStatusTV,shapeDrawable);


        if(vendorMyMembershipModel.getWorkshop_include().equals("No"))
        {
            buyWorkshopLayout.setVisibility(View.VISIBLE);
        }



        if(vendorMyMembershipModel.getWorkshop() != null)
        {
            workshopDetailsLayout.setVisibility(View.VISIBLE);
            workshopNoTV.setText(vendorMyMembershipModel.getWorkshop().getWorkshop_membership_number());
            workshopPriceTV.setText(getResources().getString(R.string.currency) + " " + vendorMyMembershipModel.getWorkshop_price());
            workshopBuyThroughTV.setText(vendorMyMembershipModel.getWorkshop().getBuy_type());
            if(vendorMyMembershipModel.getWorkshop().getBuy_type().equals("ONLINE"))
            {
                workShopCouponCodeTV.setVisibility(View.GONE);
                workShopPaymentIdTV.setText(vendorMyMembershipModel.getWorkshop().getPayment_id());

            }else
            {
                workShopPaymentIdTV.setVisibility(View.GONE);
                workShopCouponCodeTV.setText(vendorMyMembershipModel.getWorkshop().getCoupon_code());

            }

            workshopStartDateTV.setText(parseDate(vendorMyMembershipModel.getWorkshop().getWorkshop_start_date()));
            workshopEndDateTV.setText(parseDate(vendorMyMembershipModel.getWorkshop().getWorkshop_end_date()));
            workshopStatusTV.setText(vendorMyMembershipModel.getWorkshop().getS_name());


            shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(vendorMyMembershipModel.getWorkshop().getColor())));
            ViewCompat.setBackground(workshopStatusTV,shapeDrawable);

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


    public String parseDate(String time) {
        String inputPattern = "yyyy-dd-MM";
        String outputPattern = "yyyy-dd-MM";
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

    public void clickListener()
    {
        buyWorkshopTV.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                buyWorkshopDialog();
            }
        });
    }

    public void buyWorkshopDialog()
    {
        Dialog dialog = new Dialog(VendorMyMembershipDetail.this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.buy_workshop_dialog);
        Window window = dialog.getWindow();
        window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        dialog.setCancelable(true);
        dialog.show();

        Button haveCoupon = dialog.findViewById(R.id.haveCoupon);
        Button buyCard = dialog.findViewById(R.id.buyCard);

        haveCoupon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                dialog.dismiss();
                couponDialog();

            }
        });


        buyCard.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                dialog.dismiss();
                //makePayment();
            }
        });



    }


    public void couponDialog()
    {
        Dialog dialog = new Dialog(VendorMyMembershipDetail.this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.membership_coupon_dialog);
        Window window = dialog.getWindow();
        window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        dialog.setCancelable(true);
        dialog.show();

        EditText couponCode = dialog.findViewById(R.id.couponCode);
        Button applyCouponBtn = dialog.findViewById(R.id.applyCouponBtn);

        applyCouponBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(couponCode.getText().toString().equals(""))
                {
                    Toast.makeText(VendorMyMembershipDetail.this , getResources().getString(R.string.enter_coupon), Toast.LENGTH_SHORT).show();
                }
                else
                {
                    dialog.dismiss();
                    buyWorkshopBuyCoupon(couponCode.getText().toString());

                }
            }
        });



    }


//    public void makePayment()
//    {
//        Log.e("tag" , "make payment function : ");
//
//        FoloosiLog.setLogVisible(true);
//        FoloosiPay.init(this, getResources().getString(R.string.foloosi_key));
//
//        OrderData orderData = new OrderData();
//        orderData.setOrderAmount(Double.parseDouble(vendorMyMembershipModel.getWorkshop_price()));
//        Random rand = new Random();
//        int orderId = rand.nextInt(100000);
//        orderData.setCustomColor("#ab34fd");
//        orderData.setOrderId(String.valueOf(orderId));
//        orderData.setCurrencyCode(getResources().getString(R.string.currency));
//        Customer customer = new Customer();
//        customer.setName(vendorName);
//        customer.setEmail(vendorEmail);
//        customer.setMobile(vendorPhone);
//        customer.setAddress(vendorAddress);
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
//        buyWorkshop();
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


    private void buyWorkshop() {



        RequestBody vendor_id = RequestBody.create(vendorId , MediaType.parse("text/plain"));
        RequestBody membership_id = RequestBody.create(membershipId , MediaType.parse("text/plain"));
        RequestBody transaction_no = RequestBody.create(transactionId , MediaType.parse("text/plain"));


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
        call = retrofitApi.buyWorkshop(vendor_id , membership_id , transaction_no);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {
                        Toast.makeText(VendorMyMembershipDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                        finish();
                    }
                    else
                    {
                        Toast.makeText(VendorMyMembershipDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorMyMembershipDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorMyMembershipDetail.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }


    private void buyWorkshopBuyCoupon(String couponCode) {



        RequestBody vendor_id = RequestBody.create(vendorId , MediaType.parse("text/plain"));
        RequestBody membership_id = RequestBody.create(membershipId , MediaType.parse("text/plain"));
        RequestBody coupon_code = RequestBody.create(couponCode , MediaType.parse("text/plain"));


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
        call = retrofitApi.buyWorkshopByCoupon(vendor_id , membership_id , coupon_code);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {
                        Toast.makeText(VendorMyMembershipDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                        finish();
                    }
                    else
                    {
                        Toast.makeText(VendorMyMembershipDetail.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorMyMembershipDetail.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorMyMembershipDetail.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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