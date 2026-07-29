package com.thecontractor;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.MultiSelectAutoCompleteViewNew;
import com.thecontractor.Model.AdvertisementAreaModel;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.CompaniesModel;
import com.thecontractor.Model.IdModel;
import com.thecontractor.Model.IdNameModel;
import com.thecontractor.Model.NameModel;
import com.thecontractor.Model.SpecialityModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class AdvertiseCompany extends AppCompatActivity {
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    CompaniesModel companyModel;
    List<IdNameModel> companyList;
    String companyId = "";

    MultiSelectAutoCompleteViewNew<IdNameModel> autoCompleteCompany;
    MultiSelectAutoCompleteViewNew<AdvertisementAreaModel> autoCompleteArea;


    ArrayList<AdvertisementAreaModel> areaList;
    ArrayList<AdvertisementAreaModel> tempAreaList;
    Spinner daysSpinner;
    List<String> daysList;
    TextView totalAmountTV;
    Button submitBtn;
    String selectedSpinnerDay = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_advertise_company);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.advertise_company));

        initiate();
        autoCompleteClickListenerCompany();
        daysSpinnerImplementation();
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
        companyList = new ArrayList<>();
        areaList = new ArrayList<>();
        tempAreaList = new ArrayList<>();
        progressDialog = new ProgressDialog(AdvertiseCompany.this);


        autoCompleteCompany = findViewById(R.id.autoCompleteCompany);
        autoCompleteCompany.setHint("Enter 9 Digit Valid Company Serial No");
        autoCompleteCompany.setInputType(InputType.TYPE_CLASS_NUMBER);
        autoCompleteCompany.setMaxLength(9);

        autoCompleteArea = findViewById(R.id.autoCompleteArea);
        autoCompleteArea.setHint("Please Select Area");
        autoCompleteArea.setInputType(InputType.TYPE_CLASS_TEXT);


        daysSpinner = (Spinner) findViewById(R.id.daysSpinner);
        daysList = new ArrayList<>();
        totalAmountTV = (TextView) findViewById(R.id.totalAmountTV);
        submitBtn = (Button) findViewById(R.id.submitBtn);
    }

    public void clickListener(){
        submitBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                ArrayList<IdModel> areaIds =  autoCompleteArea.getSelectedItems(IdModel::new);

                if(companyId.isEmpty()){
                    Toast.makeText(AdvertiseCompany.this, "Enter 9 Digit Valid Company Serial No", Toast.LENGTH_SHORT).show();
                }else if(areaIds.isEmpty()){
                    Toast.makeText(AdvertiseCompany.this, "Select Area", Toast.LENGTH_SHORT).show();
                }else if(selectedSpinnerDay.isEmpty()){
                    Toast.makeText(AdvertiseCompany.this, "Select Days", Toast.LENGTH_SHORT).show();
                }else {

                    String jsonString = new Gson().toJson(areaIds);

                    Log.e("tag" , "json string is : "+jsonString);
                    Log.e("tag" , "company id is : "+companyId);
                    Log.e("tag" , "selected day is : "+selectedSpinnerDay);

                    //advertiseCompany(jsonString);
                }
            }
        });
    }

    public void autoCompleteClickListenerCompany(){

        autoCompleteCompany.setOnTextChangeListener(text -> {
            Log.e("tag", "User typed: " + text);

            if (text.length() == 9) {
                companyDetail(text);
            }
        });


        autoCompleteCompany.setOnItemSelectedListener(item -> {
            Log.e("MultiSelect", "User selected item: " + item.getName());

            if(areaList.isEmpty()){
                getAreas();
            }

        });

        autoCompleteArea.setOnChipAddListener(item -> {
            Log.d("MultiSelect", "Chip added for: " + item.getTitle());
            calculateTotalAmount();
        });

    }


    public void daysSpinnerImplementation(){
        daysList.add("1 Day");
        daysList.add("2 Day");
        daysList.add("3 Day");

        ArrayAdapter<String> adapter = new ArrayAdapter<>(
                this,
                android.R.layout.simple_spinner_item, // Default layout for spinner items
                daysList
        );

        // Specify the layout to use when the list of choices appears
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        // Apply the adapter to the spinner
        daysSpinner.setAdapter(adapter);

        daysSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                selectedSpinnerDay = adapterView.getItemAtPosition(i).toString();
                selectedSpinnerDay = selectedSpinnerDay.replaceAll("[^0-9]", "");
                Log.e("tag" , "day spinner item is : "+selectedSpinnerDay);

                calculateTotalAmount();

            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });
    }

    public void calculateTotalAmount(){
        int totalAmount = 0;
        ArrayList<AdvertisementAreaModel> areaIds =  autoCompleteArea.getSelectedModels();
        if(!areaIds.isEmpty()){
            for (AdvertisementAreaModel tag : areaIds) {
                totalAmount += Integer.parseInt(tag.getPer_day_rate());
            }

            totalAmount = totalAmount * Integer.parseInt(selectedSpinnerDay);
            Log.e("tag" , "total amount is : "+totalAmount);
        }
        totalAmountTV.setText(totalAmount + " " + getResources().getString(R.string.currency));

    }

    private void companyDetail(String companySerial) {


        RequestBody company_serial = RequestBody.create(companySerial , MediaType.parse("text/plain"));


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
        call = retrofitApi.companySearchBySerial(company_serial);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {
                        companyList = new ArrayList<>();
                        companyModel = response.body().getCompany();
                        companyId = companyModel.getId();
                        companyList.add(new IdNameModel(companyModel.getId() , companyModel.getCompany_name()));
                        Log.e("tag" , "companyStringList size is : "+companyList.size());

                        autoCompleteCompany.setItems(companyList , IdNameModel::getName , IdNameModel::getId);
                        autoCompleteCompany.showDropdown();

                    }
                    else
                    {
                        Toast.makeText(AdvertiseCompany.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(AdvertiseCompany.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(AdvertiseCompany.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    private void getAreas() {


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
        call = retrofitApi.getAreas();

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        areaList = response.body().getAreas();

                        for (AdvertisementAreaModel item : areaList) {
                            tempAreaList.add(new AdvertisementAreaModel(item.getId() , item.getTitle() + " ( " + getResources().getString(R.string.currency) + " " + item.getPer_day_rate() + " / day )" , item.getPer_day_rate()));
                        }

                        Log.e("tag" , "advertisement area list size is : " + areaList.size());

                        autoCompleteArea.setItems(tempAreaList , AdvertisementAreaModel::getTitle , AdvertisementAreaModel::getId);
                        autoCompleteArea.showDropdown();
                    }
                    else
                    {
                        Toast.makeText(AdvertiseCompany.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(AdvertiseCompany.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(AdvertiseCompany.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }


    private void advertiseCompany(String areaIds) {


        RequestBody company_id = RequestBody.create(companyId , MediaType.parse("text/plain"));
        RequestBody selected_spinner_day = RequestBody.create(selectedSpinnerDay , MediaType.parse("text/plain"));
        RequestBody area_id = RequestBody.create(areaIds , MediaType.parse("text/plain"));


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
        call = retrofitApi.advertiseCompany(company_id , area_id ,selected_spinner_day);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        Intent intent = new Intent(AdvertiseCompany.this, Home.class);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                        startActivity(intent);
                        finish();

                    }
                    else
                    {
                        Toast.makeText(AdvertiseCompany.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(AdvertiseCompany.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(AdvertiseCompany.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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