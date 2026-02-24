package com.thecontractor.VendorActivities;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.app.ProgressDialog;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RatingBar;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.CompanyDetailSubCategoriesAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.CompanyDetailSubCategoriesModel;
import com.thecontractor.Model.VendorModel;
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

public class VendorProfile extends AppCompatActivity {
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    ImageView companyImage;
    RatingBar ratingBar;
    TextView companyName , companyTotalRatingCount , categoriesName , companyDescriptionTV , companyAddressTV , companyCityTV , companyAreaTV , companyCountryTV ,
            registerDateTV , companyIdTV , companyMembershipNoTV , licenseNumberTV , noOfEmployeesTV , companyPhoneTV , companyEmailTV , facebookTV , twitterTV , linkedinTV,
            ownerNameTV , ownerContactNumberTV , ownerEmailTV , availableTwentyFourSevenTV , accountStatusTV , verifiedCompanyTV , companyApprovedTV , companyFeaturedTV , companyInstalmentsTV,
            noSubCategoriesTV , companyTitaniumTV , companyTrustedTV , companyVipTV , companyOnlineTV;

    Button onlineOfflineBtn;

    LinearLayout vendorProfileLayout , subCategoryLayout , descriptionLayout , addressLayout , cityLayout , areaLayout , countryLayout , registerDateLayout , companyIdLayout , companyMembershipNoLayout,
            licenseNumberLayout , noOfEmployeesLayout , companyPhoneLayout , companyEmailLayout , facebookLayout , twitterLayout , linkedInLayout , ownerNameLayout , ownerContactNumberLayout,
            ownerEmailLayout , availableTwentyFourSevenLayout , accountStatusLayout , verifiedCompanyLayout , companyApprovedLayout , companyFeaturedLayout , companyInstalmentsLayout ,
            companyTitaniumLayout, companyTrustedLayout , companyVipLayout;

    RecyclerView subCategoriesRV;
    GridLayoutManager gridLayoutManager ;
    ArrayList<CompanyDetailSubCategoriesModel> list;

    String vendorId;
    VendorModel vendorModel;
    String selectedLanguage = "en";



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_profile);
        getSupportActionBar().setTitle(getResources().getString(R.string.profile));
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);


        getLanguageFromSP();
        getDataFromSP();
        initiate();
        vendorProfile();
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



    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(VendorProfile.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorProfile.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorProfile.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorProfile.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();


            Log.e("tag" , "Vendor id is : "+vendorId);


        }
    }

    public void initiate()
    {
        progressDialog = new ProgressDialog(VendorProfile.this);


        companyImage = (ImageView) findViewById(R.id.companyImage);
        ratingBar = (RatingBar) findViewById(R.id.ratingBar);
        companyName = (TextView) findViewById(R.id.companyName);
        companyTotalRatingCount = (TextView) findViewById(R.id.companyTotalRatingCount);
        categoriesName = (TextView) findViewById(R.id.categoriesName);
        companyDescriptionTV = (TextView) findViewById(R.id.companyDescriptionTV);
        companyAddressTV = (TextView) findViewById(R.id.companyAddressTV);
        companyCityTV = (TextView) findViewById(R.id.companyCityTV);
        companyAreaTV = (TextView) findViewById(R.id.companyAreaTV);
        companyCountryTV = (TextView) findViewById(R.id.companyCountryTV);
        registerDateTV = (TextView) findViewById(R.id.registerDateTV);
        companyIdTV = (TextView) findViewById(R.id.companyIdTV);
        companyMembershipNoTV = (TextView) findViewById(R.id.companyMembershipNoTV);
        licenseNumberTV = (TextView) findViewById(R.id.licenseNumberTV);
        noOfEmployeesTV = (TextView) findViewById(R.id.noOfEmployeesTV);
        companyPhoneTV = (TextView) findViewById(R.id.companyPhoneTV);
        companyEmailTV = (TextView) findViewById(R.id.companyEmailTV);
        facebookTV = (TextView) findViewById(R.id.facebookTV);
        twitterTV = (TextView) findViewById(R.id.twitterTV);
        linkedinTV = (TextView) findViewById(R.id.linkedinTV);
        ownerNameTV = (TextView) findViewById(R.id.ownerNameTV);
        ownerContactNumberTV = (TextView) findViewById(R.id.ownerContactNumberTV);
        ownerEmailTV = (TextView) findViewById(R.id.ownerEmailTV);
        availableTwentyFourSevenTV = (TextView) findViewById(R.id.availableTwentyFourSevenTV);
        accountStatusTV = (TextView) findViewById(R.id.accountStatusTV);
        verifiedCompanyTV = (TextView) findViewById(R.id.verifiedCompanyTV);
        companyApprovedTV = (TextView) findViewById(R.id.companyApprovedTV);
        companyFeaturedTV = (TextView) findViewById(R.id.companyFeaturedTV);
        companyInstalmentsTV = (TextView) findViewById(R.id.companyInstalmentsTV);
        noSubCategoriesTV = (TextView) findViewById(R.id.noSubCategoriesTV);
        noSubCategoriesTV.setVisibility(View.GONE);
        companyTitaniumTV = (TextView) findViewById(R.id.companyTitaniumTV);
        companyTrustedTV = (TextView) findViewById(R.id.companyTrustedTV);
        companyVipTV = (TextView) findViewById(R.id.companyVipTV);
        companyOnlineTV = (TextView) findViewById(R.id.companyOnlineTV);

        onlineOfflineBtn = (Button) findViewById(R.id.onlineOfflineBtn);

        vendorProfileLayout = (LinearLayout) findViewById(R.id.vendorProfileLayout);
        vendorProfileLayout.setVisibility(View.GONE);
        subCategoryLayout = (LinearLayout) findViewById(R.id.subCategoryLayout);
        descriptionLayout = (LinearLayout) findViewById(R.id.descriptionLayout);
        addressLayout = (LinearLayout) findViewById(R.id.addressLayout);
        cityLayout = (LinearLayout) findViewById(R.id.cityLayout);
        cityLayout = (LinearLayout) findViewById(R.id.cityLayout);
        areaLayout = (LinearLayout) findViewById(R.id.areaLayout);
        countryLayout = (LinearLayout) findViewById(R.id.countryLayout);
        registerDateLayout = (LinearLayout) findViewById(R.id.registerDateLayout);
        companyIdLayout = (LinearLayout) findViewById(R.id.companyIdLayout);
        companyMembershipNoLayout = (LinearLayout) findViewById(R.id.companyMembershipNoLayout);
        licenseNumberLayout = (LinearLayout) findViewById(R.id.licenseNumberLayout);
        noOfEmployeesLayout = (LinearLayout) findViewById(R.id.noOfEmployeesLayout);
        companyPhoneLayout = (LinearLayout) findViewById(R.id.companyPhoneLayout);
        companyEmailLayout = (LinearLayout) findViewById(R.id.companyEmailLayout);
        facebookLayout = (LinearLayout) findViewById(R.id.facebookLayout);
        twitterLayout = (LinearLayout) findViewById(R.id.twitterLayout);
        linkedInLayout = (LinearLayout) findViewById(R.id.linkedInLayout);
        ownerNameLayout = (LinearLayout) findViewById(R.id.ownerNameLayout);
        ownerContactNumberLayout = (LinearLayout) findViewById(R.id.ownerContactNumberLayout);
        ownerEmailLayout = (LinearLayout) findViewById(R.id.ownerEmailLayout);
        availableTwentyFourSevenLayout = (LinearLayout) findViewById(R.id.availableTwentyFourSevenLayout);
        accountStatusLayout = (LinearLayout) findViewById(R.id.accountStatusLayout);
        verifiedCompanyLayout = (LinearLayout) findViewById(R.id.verifiedCompanyLayout);
        companyApprovedLayout = (LinearLayout) findViewById(R.id.companyApprovedLayout);
        companyFeaturedLayout = (LinearLayout) findViewById(R.id.companyFeaturedLayout);
        companyInstalmentsLayout = (LinearLayout) findViewById(R.id.companyInstalmentsLayout);
        companyTitaniumLayout = (LinearLayout) findViewById(R.id.companyTitaniumLayout);
        companyTrustedLayout = (LinearLayout) findViewById(R.id.companyTrustedLayout);
        companyVipLayout = (LinearLayout) findViewById(R.id.companyVipLayout);


        subCategoriesRV = (RecyclerView) findViewById(R.id.subCategoriesRV);
        gridLayoutManager = new GridLayoutManager(VendorProfile.this , 2 , LinearLayoutManager.VERTICAL , false);
        subCategoriesRV.setLayoutManager(gridLayoutManager);
        list = new ArrayList<>();

    }


    private void vendorProfile() {


        RequestBody id = RequestBody.create(vendorId , MediaType.parse("text/plain"));


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
        call = retrofitApi.vendorProfile(id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        vendorProfileLayout.setVisibility(View.VISIBLE);
                        vendorModel = response.body().getVendor_profile();
                        setDataToWidget();


                    }
                    else
                    {
                        Toast.makeText(VendorProfile.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorProfile.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorProfile.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    private void changeStatus(String status) {


        RequestBody id = RequestBody.create(vendorId , MediaType.parse("text/plain"));
        RequestBody online_status = RequestBody.create(status , MediaType.parse("text/plain"));


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
        call = retrofitApi.vendorIsOnline(id , online_status);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        vendorModel.setIs_online(status);

                        if(status.equals("0"))
                        {
                            onlineOfflineBtn.setText("Go Online");
                            companyOnlineTV.setText("No");
                        }else
                        {
                            onlineOfflineBtn.setText("Go Offline");
                            companyOnlineTV.setText("Yes");
                        }

                    }
                    else
                    {
                        Toast.makeText(VendorProfile.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorProfile.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorProfile.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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


    public void clickListener()
    {
        onlineOfflineBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(vendorModel.getIs_online().equals("0"))
                {
                    changeStatus("1");

                }else
                {
                    changeStatus("0");
                }
            }
        });
    }

    public void setDataToWidget()
    {
        Glide.with(VendorProfile.this)
                .load(ApiUrls.COMPANIES_IMAGE_URL+vendorModel.getCompany_logo())
                .apply(new RequestOptions().placeholder(R.drawable.ic_user_profile).error(R.drawable.ic_user_profile))
                .into(companyImage);

        companyName.setText(vendorModel.getCompany_name());
        categoriesName.setText(vendorModel.getCategory_name());


        if(vendorModel.getCategories().size() > 0)
        {
            CompanyDetailSubCategoriesAdapter companyDetailSubCategoriesAdapter = new CompanyDetailSubCategoriesAdapter(VendorProfile.this , vendorModel.getCategories() , selectedLanguage);
            subCategoriesRV.setAdapter(companyDetailSubCategoriesAdapter);
        }else
        {
            noSubCategoriesTV.setVisibility(View.VISIBLE);
        }


        if(vendorModel.getCompany_discription() == null || vendorModel.getCompany_discription().equals(""))
        {
            companyDescriptionTV.setText("Not Added");
        }else
        {
            companyDescriptionTV.setText(vendorModel.getCompany_discription());
        }

        companyAddressTV.setText(vendorModel.getCompany_address());

        if(vendorModel.getCity_name() == null || vendorModel.getCity_name().equals(""))
        {
            companyCityTV.setText("Not Added");
        }else
        {
            companyCityTV.setText(vendorModel.getCity_name());
        }

        if(vendorModel.getArea_name() == null || vendorModel.getArea_name().equals(""))
        {
            companyAreaTV.setText("Not Added");
        }else
        {
            companyAreaTV.setText(vendorModel.getArea_name());
        }

        if(vendorModel.getCountry_name() == null || vendorModel.getCountry_name().equals(""))
        {
            companyCountryTV.setText("Not Added");
        }else
        {
            companyCountryTV.setText(vendorModel.getCountry_name());
        }




        registerDateTV.setText(parseDateToddMMyyyy(vendorModel.getCreated_at()));
        companyIdTV.setText(vendorModel.getCompany_serial_number());
        companyMembershipNoTV.setText(vendorModel.getCompany_membership_number());

        if(vendorModel.getCompany_license() == null || vendorModel.getCompany_license().equals(""))
        {
            licenseNumberTV.setText("Not Added");
        }else
        {
            licenseNumberTV.setText(vendorModel.getCompany_license());
        }

        noOfEmployeesTV.setText(vendorModel.getCompany_employees());
        companyPhoneTV.setText(vendorModel.getCompany_phone());
        companyEmailTV.setText(vendorModel.getCompany_email());

        if(vendorModel.getCompany_facebook() == null || vendorModel.getCompany_facebook().equals(""))
        {
            facebookTV.setText("Not Added");
        }else
        {
            facebookTV.setText(vendorModel.getCompany_facebook());
        }

        if(vendorModel.getCompany_twitter() == null || vendorModel.getCompany_twitter().equals(""))
        {
            twitterTV.setText("Not Added");
        }else
        {
            twitterTV.setText(vendorModel.getCompany_twitter());
        }

        if(vendorModel.getCompany_linkedin() == null || vendorModel.getCompany_linkedin().equals(""))
        {
            linkedinTV.setText("Not Added");
        }else
        {
            linkedinTV.setText(vendorModel.getCompany_linkedin());
        }

        ownerNameTV.setText(vendorModel.getCompany_owner_name());
        ownerContactNumberTV.setText(vendorModel.getCompany_owner_contact());



        if(vendorModel.getCompany_owner_email() == null || vendorModel.getCompany_owner_email().equals(""))
        {
            ownerEmailTV.setText("Not Added");
        }else
        {
            ownerEmailTV.setText(vendorModel.getCompany_owner_email());
        }

        if(vendorModel.getCompany_for_24_hours().equals("0"))
        {
            availableTwentyFourSevenTV.setText("No");

        }else
        {
            availableTwentyFourSevenTV.setText("Yes");
        }

        if(vendorModel.getCompany_status().equals("0"))
        {
            accountStatusTV.setText("Deactivate");

        }else
        {
            accountStatusTV.setText("Activate");
        }

        if(vendorModel.getIs_verified().equals("0"))
        {
            verifiedCompanyTV.setText("No");

        }else
        {
            verifiedCompanyTV.setText("Yes");
        }

        if(vendorModel.getIs_approved().equals("0"))
        {
            companyApprovedTV.setText("No");

        }else
        {
            companyApprovedTV.setText("Yes");
        }

        if(vendorModel.getIs_featured().equals("0"))
        {
            companyFeaturedTV.setText("No");

        }else
        {
            companyFeaturedTV.setText("Yes");
        }

        if(vendorModel.getIs_instalment().equals("0"))
        {
            companyInstalmentsTV.setText("No");

        }else
        {
            companyInstalmentsTV.setText("Yes");
        }

        if(vendorModel.getIs_titanium().equals("0"))
        {
            companyTitaniumTV.setText("No");

        }else
        {
            companyTitaniumTV.setText("Yes");
        }

        if(vendorModel.getIs_trusted().equals("0"))
        {
            companyTrustedTV.setText("No");

        }else
        {
            companyTrustedTV.setText("Yes");
        }

        if(vendorModel.getIs_vip().equals("0"))
        {
            companyVipTV.setText("No");

        }else
        {
            companyVipTV.setText("Yes");
        }

        if(vendorModel.getIs_online().equals("0"))
        {
            onlineOfflineBtn.setText("Go Online");
            companyOnlineTV.setText("No");

        }else
        {
            onlineOfflineBtn.setText("Go Offline");
            companyOnlineTV.setText("Yes");
        }





//        companyTotalRatingCount.setText("("+vendorModel.getReview_count()+")");
//
//        if(vendorModel.getAvg_rating() != null)
//        {
//            ratingBar.setRating(Float.parseFloat(vendorModel.getAvg_rating()));
//        }
//        else
//        {
//            ratingBar.setRating(0);
//        }

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