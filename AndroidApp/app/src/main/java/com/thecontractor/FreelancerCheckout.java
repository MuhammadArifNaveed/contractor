package com.thecontractor;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.card.MaterialCardView;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.FreelancerCheckoutAdapter;
import com.thecontractor.Database.FreelancerDatabaseHelper;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SelectedFreelancerDatePicker;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.SelectedFreelancersDatabaseModel;
import com.thecontractor.Model.SelectedFreelancersDetailDatabaseModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.VendorActivities.VendorHome;

import java.util.ArrayList;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class FreelancerCheckout extends AppCompatActivity implements FreelancerCheckoutAdapter.OnItemInteractionListener {
    String from;
    String userId;
    String vendorId;
    String userType;
    String cityName;
    TextView noData;
    RecyclerView freelancerCheckoutRV;
    Button freelancerCheckout;
    MaterialCardView calculationLayout;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<SelectedFreelancersDatabaseModel> list;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    String selectedLanguage = "en";
    private TextView tvTotalFreelancers, tvTotalFreelancerCharges, tvTotalTransportCharges, tvGrandTotal;
    FreelancerDatabaseHelper dbHelper;
    FreelancerCheckoutAdapter freelancerCheckoutAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_freelancer_checkout);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(R.string.freelancer_checkout);

        getDataFromActivity();
        getLanguageFromSP();

        if(from.equals("user")){
            getUserDataFromSP();
        }else if(from.equals("vendor")){
            getVendorDataFromSP();
        }

        initiate();
        clickListener();
        getAddedFreelancer();
        updateSummary();
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

    public void getDataFromActivity(){
        Intent intent = getIntent();
        from = intent.getStringExtra("from");

        Log.e("tag" , "freelancer from is : "+from);
    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(FreelancerCheckout.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(FreelancerCheckout.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }


    public void getUserDataFromSP() {
        if (!SharedPrefManager.getInstance(FreelancerCheckout.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(FreelancerCheckout.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();
            userType = userModel.getUser_type();
            vendorId = userId;

            Log.e("tag" , "Vendor id is : "+vendorId);
            Log.e("tag" , "user id is : "+userId);
            Log.e("tag" , "user type is : "+userType);
            Log.e("tag" , "user city is : "+cityName);

        }
    }

    public void getVendorDataFromSP() {
        if (!SharedPrefManager.getInstance(FreelancerCheckout.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(FreelancerCheckout.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();
            userId = vendorModel.getUser_id();
            userType = vendorModel.getUser_type();
            cityName = vendorModel.getCity_name();


            Log.e("tag" , "Vendor id is : "+vendorId);
            Log.e("tag" , "user id is : "+userId);
            Log.e("tag" , "user type is : "+userType);
            Log.e("tag" , "Vendor city is : "+cityName);


        }
    }

    public void initiate()
    {
        progressDialog = new ProgressDialog(FreelancerCheckout.this);

        list = new ArrayList<>();
        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(GONE);

        freelancerCheckoutRV = (RecyclerView) findViewById(R.id.freelancerCheckoutRV);
        linearLayoutManager = new LinearLayoutManager(FreelancerCheckout.this  , LinearLayoutManager.VERTICAL , false);
        freelancerCheckoutRV.setLayoutManager(linearLayoutManager);
        freelancerCheckout = (Button) findViewById(R.id.freelancerCheckout);
        tvTotalFreelancers = findViewById(R.id.tvTotalFreelancers);
        tvTotalFreelancerCharges = findViewById(R.id.tvTotalFreelancerCharges);
        tvTotalTransportCharges = findViewById(R.id.tvTotalTransportCharges);
        tvGrandTotal = findViewById(R.id.tvGrandTotal);
        calculationLayout = findViewById(R.id.calculationLayout);
        dbHelper = new FreelancerDatabaseHelper(FreelancerCheckout.this);

    }

    public void clickListener(){
        freelancerCheckout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                list = dbHelper.getAllFreelancers();
                Log.e("tag" , "database freelancers is : " + new Gson().toJson(list));
                if(!list.isEmpty()){
                    hireFreelancersAPI(new Gson().toJson(list));
                }
            }
        });
    }

    public void getAddedFreelancer(){
        if(userId == null || userId.isEmpty()){
            return;
        }
        list = dbHelper.getAllFreelancers();
        freelancerCheckoutAdapter = new FreelancerCheckoutAdapter(FreelancerCheckout.this , list , selectedLanguage , this , cityName);
        freelancerCheckoutRV.setAdapter(freelancerCheckoutAdapter);
    }

    public void showHideCalculationLayout(){
        if(!list.isEmpty()){
            calculationLayout.setVisibility(VISIBLE);
            noData.setVisibility(GONE);
        }else {
            calculationLayout.setVisibility(GONE);
            noData.setVisibility(VISIBLE);
        }
    }

    private void updateSummary() {
        int totalFreelancers = list.size();
        double totalFreelancerCharges = 0;
        double totalTransportCharges = 0;

        for (SelectedFreelancersDatabaseModel freelancer : list) {
            SelectedFreelancersDetailDatabaseModel detail = freelancer.getDetail();
            int numDays = detail.getDates().size();
            double hourlyRate = new SelectedFreelancerDatePicker().calculateHourlyRatePercentage(freelancer.getHourlyRate() , freelancer.getCommission());
            double hoursPerDay = new SelectedFreelancerDatePicker().calculateHoursLegacy(detail.getFromTime(), detail.getToTime());

            totalFreelancerCharges += hoursPerDay * hourlyRate * numDays;
            // Using the same fixed transport charge for summary
            totalTransportCharges += Double.parseDouble(freelancer.getTransportation_charges());
        }

        double grandTotal = totalFreelancerCharges + totalTransportCharges;

        tvTotalFreelancers.setText(String.valueOf(totalFreelancers));
        tvTotalFreelancerCharges.setText(String.format(Locale.getDefault(), "%.2f AED", totalFreelancerCharges));
        tvTotalTransportCharges.setText(String.format(Locale.getDefault(), "%.2f AED", totalTransportCharges));
        tvGrandTotal.setText(String.format(Locale.getDefault(), "%.2f AED", grandTotal));
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


    @Override
    public void onDeleteClicked(SelectedFreelancersDatabaseModel freelancer, int position) {
        int result = dbHelper.deleteFreelancer(freelancer.getId());

        if (result > 0) {
            list.remove(position);
            freelancerCheckoutAdapter.notifyItemRemoved(position);
            updateSummary();
            Toast.makeText(this, "Freelancer removed", Toast.LENGTH_SHORT).show();
        } else {
            Toast.makeText(this, "Error removing freelancer", Toast.LENGTH_SHORT).show();
        }
        showHideCalculationLayout();
    }

    @Override
    public void onTransportChargesClicked(SelectedFreelancersDatabaseModel freelancer, int position) {
        getTransportationCharges(freelancer , position);
    }

    private void getTransportationCharges(SelectedFreelancersDatabaseModel freelancer, int position) {


        RequestBody freelancer_id = RequestBody.create(freelancer.getId() , MediaType.parse("text/plain"));
        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));
        RequestBody user_type = RequestBody.create(userType , MediaType.parse("text/plain"));


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
        call = retrofitApi.transportationApi(freelancer_id , user_id , user_type);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        SelectedFreelancersDetailDatabaseModel detail = freelancer.getDetail();
                        int numDays = detail.getDates().size();
                        double transportationCharges = Double.parseDouble(response.body().getCharges().getCost()) * numDays;
                        double transportationChargesDiscount = Double.parseDouble(response.body().getCharges().getDiscount()) * numDays;
                        double totalTransportationCharges = new SelectedFreelancerDatePicker().calculateTransportationPercentage(transportationCharges , transportationChargesDiscount , freelancer.getCommission());


                        boolean success = dbHelper.updateTransportationCharges(freelancer.getId(), String.valueOf(totalTransportationCharges));

                        if (success) {

                            freelancer.setTransportation_charges(String.valueOf(totalTransportationCharges));
                            freelancerCheckoutAdapter.notifyItemChanged(position);
                            updateSummary();
                            Toast.makeText(FreelancerCheckout.this, "Charges updated", Toast.LENGTH_SHORT).show();
                        } else {
                            Toast.makeText(FreelancerCheckout.this, "Failed to update charges", Toast.LENGTH_SHORT).show();
                        }
                    }
                    else
                    {
                        Toast.makeText(FreelancerCheckout.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(FreelancerCheckout.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(FreelancerCheckout.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }


    private void hireFreelancersAPI(String freelancingData) {


        RequestBody freelancing_data = RequestBody.create(freelancingData , MediaType.parse("text/plain"));
        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));
        RequestBody user_type = RequestBody.create(userType , MediaType.parse("text/plain"));
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
        call = retrofitApi.hireFreelancerApi(freelancing_data , user_id , user_type , vendor_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        dbHelper.resetDatabase();

                        AlertDialog alertDialog = new AlertDialog.Builder(FreelancerCheckout.this).create();
                        alertDialog.setCancelable(false);
                        alertDialog.setTitle("Submitted");
                        alertDialog.setMessage(response.body().getMessage());
                        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, getResources().getString(R.string.ok),
                                new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int which) {



                                        dialog.dismiss();
                                        if(from.equals("user")){
                                            Intent intent = new Intent(FreelancerCheckout.this, Home.class);
                                            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                                            startActivity(intent);
                                            finish();
                                        }else if(from.equals("vendor")){
                                            Intent intent = new Intent(FreelancerCheckout.this, VendorHome.class);
                                            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                                            startActivity(intent);
                                            finish();
                                        }


                                    }
                                });
                        alertDialog.show();
                    }
                    else
                    {
                        Toast.makeText(FreelancerCheckout.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(FreelancerCheckout.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(FreelancerCheckout.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

}