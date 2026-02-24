package com.thecontractor.VendorActivities;

import androidx.appcompat.app.AppCompatActivity;
import androidx.viewpager.widget.ViewPager;

import android.app.Dialog;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.text.Html;
import android.util.Log;
import android.util.TypedValue;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.foloosi.core.FPayListener;
import com.foloosi.core.FoloosiLog;
import com.foloosi.core.FoloosiPay;
import com.foloosi.models.Customer;
import com.foloosi.models.OrderData;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.VendorMembershipPagerAdapter;
import com.thecontractor.CompanyDetails;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.CarouselEffectTransformer;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.VendorMembershipModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.util.ArrayList;
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

//public class VendorMembership extends AppCompatActivity implements VendorMembershipPagerAdapter.ClickListener, FPayListener {
public class VendorMembership extends AppCompatActivity implements VendorMembershipPagerAdapter.ClickListener {
    String selectedLanguage = "en";
    String vendorId;
    String vendorName;
    String vendorEmail;
    String vendorCity;
    String vendorAddress;
    String vendorPhone;

    private ViewPager viewpager;
    TextView noData;
    String membershipId;
    String price;
    String workShopPrice;
    int totalPrice;
    String transactionId;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    ArrayList<VendorMembershipModel> list;
    LinearLayout layoutDot;
    TextView[] dot;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_membership);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle("Membership");

        getLanguageFromSP();
        getDataFromSP();
        initiate();
        membershipAPI();
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
        if (!SharedPrefManager.getInstance(VendorMembership.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorMembership.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorMembership.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorMembership.this).getVendorObject();
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

    private void initiate() {

        progressDialog = new ProgressDialog(VendorMembership.this);

        list = new ArrayList<>();
        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(View.GONE);
        viewpager = (ViewPager) findViewById(R.id.viewpager);

        viewpager.setClipChildren(false);
        viewpager.setPageMargin(getResources().getDimensionPixelOffset(R.dimen.pager_margin));
        viewpager.setPageTransformer(false, new CarouselEffectTransformer(this)); // Set transformer

        layoutDot = (LinearLayout) findViewById(R.id.layoutDot);


    }

    private void membershipAPI() {

        RequestBody vendor_id = RequestBody.create(vendorId , MediaType.parse("text/plain"));


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
        call = retrofitApi.vendorMembership(vendor_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        list = response.body().getMemberships_list();

                        Log.e("tag" , "list size is : "+list.size());

                        addDot(0);
                       setupViewPager();


                    }
                    else
                    {
                        noData.setVisibility(View.VISIBLE);
                        Toast.makeText(VendorMembership.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorMembership.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorMembership.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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


    public void addDot(int page_position) {
        dot = new TextView[list.size()];
        layoutDot.removeAllViews();

        for (int i = 0; i < dot.length; i++) {;
            dot[i] = new TextView(this);
            dot[i].setText(Html.fromHtml("&#9673;"));
            dot[i].setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);

            dot[i].setTextColor(getResources().getColor(R.color.lightColor));
            layoutDot.addView(dot[i]);
        }
        //active dot
        dot[page_position].setTextColor(getResources().getColor(R.color.red));
    }


    private void setupViewPager() {
        // Set Top ViewPager Adapter
        VendorMembershipPagerAdapter membershipPagerAdapter = new VendorMembershipPagerAdapter(this, list , VendorMembership.this);
        viewpager.setAdapter(membershipPagerAdapter);



        viewpager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {


            @Override
            public void onPageSelected(int position) {
                addDot(position);

            }

            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageScrollStateChanged(int state) {


            }
        });
    }

    @Override
    public void selectedItem(String membershipId , String price , String workShopPrice) {
        this.membershipId = membershipId;
        this.price = price;
        this.workShopPrice = workShopPrice;
        totalPrice = Integer.parseInt(price) + Integer.parseInt(workShopPrice);
        Log.e("tag" , "membership id is : "+membershipId);
        Log.e("tag" , "membership price is : "+price);
        Log.e("tag" , "membership workshop price is : "+workShopPrice);
        Log.e("tag" , "membership total price is : "+totalPrice);

        buyMemberShipDialog();

    }


    public void buyMemberShipDialog()
    {
        Dialog dialog = new Dialog(VendorMembership.this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.buy_membership_dialog);
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
        Dialog dialog = new Dialog(VendorMembership.this);
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
                    Toast.makeText(VendorMembership.this , getResources().getString(R.string.enter_coupon), Toast.LENGTH_SHORT).show();
                }
                else
                {
                    dialog.dismiss();
                    buyMembershipBuyCoupon(couponCode.getText().toString());

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
//        orderData.setOrderAmount(Double.parseDouble(price));
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
//        buyMembership();
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


    private void buyMembership() {



        RequestBody vendor_id = RequestBody.create(vendorId , MediaType.parse("text/plain"));
        RequestBody membership_id = RequestBody.create(membershipId , MediaType.parse("text/plain"));
        RequestBody paid_amount = RequestBody.create(String.valueOf(totalPrice) , MediaType.parse("text/plain"));
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
        call = retrofitApi.buyMembership(vendor_id , membership_id , paid_amount , transaction_no);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {
                        Toast.makeText(VendorMembership.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                        finish();
                    }
                    else
                    {
                        Toast.makeText(VendorMembership.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorMembership.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorMembership.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }


    private void buyMembershipBuyCoupon(String couponCode) {



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
        call = retrofitApi.buyMembershipByCoupon(vendor_id , membership_id , coupon_code);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {
                        Toast.makeText(VendorMembership.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                        finish();
                    }
                    else
                    {
                        Toast.makeText(VendorMembership.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorMembership.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorMembership.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }



}