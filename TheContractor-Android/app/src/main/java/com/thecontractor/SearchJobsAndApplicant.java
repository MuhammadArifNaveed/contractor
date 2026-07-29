package com.thecontractor;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.GridLayoutManager;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.CustomImagesAdapter;
import com.thecontractor.Adapter.JobCategoriesSpinnerAdapter;
import com.thecontractor.Adapter.JobCitiesSpinnerAdapter;
import com.thecontractor.Adapter.JobTypeSpinnerAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.MultiSelectAutoCompleteViewNew;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.IdModel;
import com.thecontractor.Model.NameModel;
import com.thecontractor.Model.SearchJobTitleModel;
import com.thecontractor.Model.SpecialityModel;
import com.thecontractor.Model.VendorJobCategoriesModel;
import com.thecontractor.Model.VendorJobCitiesModel;
import com.thecontractor.Model.VendorJobListingModel;
import com.thecontractor.Model.VendorJobTypeModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.VendorActivities.VendorPostJob;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class SearchJobsAndApplicant extends AppCompatActivity {
    LinearLayout searchLayout;
    ArrayList<SearchJobTitleModel> list;
    MultiSelectAutoCompleteViewNew<SearchJobTitleModel> multiSelectAutoCompleteView;
    Spinner jobCategorySpinner , jobCitySpinner;
    Button searchBtn;
    String selectedJobCategory = "0", selectedJobCity = "0";
    ArrayList<VendorJobCategoriesModel> jobCategoriesList;
    ArrayList<VendorJobCitiesModel> citiesList;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    String from;
    String selectedLanguage = "en";
    String selectedJobsTitle = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_search_jobs_and_applicant);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle("Search Job");

        getObjectFromAdapter();
        getLanguageFromSP();
        initiate();
        clickListener();
        autoCompleteClickListener();
        getJobDataAPI();

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

            from = (String) bundle.getString("from");

            assert from != null;
            if(from.equals("job")){
                getSupportActionBar().setTitle("Search Job");
            }else if(from.equals("applicant")){
                getSupportActionBar().setTitle("Search Applicant");
            }

            Log.e("tag" , "from is : "+from);

        }
    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(SearchJobsAndApplicant.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(SearchJobsAndApplicant.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }

    public void initiate(){

        list = new ArrayList<>();
        jobCategoriesList = new ArrayList<>();
        citiesList = new ArrayList<>();

        progressDialog = new ProgressDialog(SearchJobsAndApplicant.this);

        searchLayout = (LinearLayout) findViewById(R.id.searchLayout);
        searchLayout.setVisibility(GONE);

        multiSelectAutoCompleteView = findViewById(R.id.multiSelectAutoCompleteView);
        multiSelectAutoCompleteView.setVisibility(GONE);
        multiSelectAutoCompleteView.setHint("Search Jobs Title");
        multiSelectAutoCompleteView.setInputType(InputType.TYPE_CLASS_TEXT);
        multiSelectAutoCompleteView.setMaxLength(0);

        if(from.equals("job")){
            multiSelectAutoCompleteView.setVisibility(VISIBLE);
        }

        jobCategorySpinner = (Spinner) findViewById(R.id.jobCategorySpinner);
        jobCitySpinner = (Spinner) findViewById(R.id.jobCitySpinner);

        searchBtn = (Button) findViewById(R.id.searchBtn);

    }

    public void clickListener() {
        searchBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (selectedJobCategory.equals("0")) {
                    Toast.makeText(SearchJobsAndApplicant.this, "Select category", Toast.LENGTH_SHORT).show();
                } else if (selectedJobCity.equals("0")) {
                    Toast.makeText(SearchJobsAndApplicant.this, "Select city", Toast.LENGTH_SHORT).show();
                } else {

                    if(from.equals("job")){
                        selectedJobsTitle = new Gson().toJson(multiSelectAutoCompleteView.getSelectedNames(name -> new NameModel(name)));

                        if(selectedJobsTitle.equals("[]")){
                            selectedJobsTitle = "";
                        }


                        Log.e("tag", "selectedJobsTitle is : " + selectedJobsTitle);
                    }


                    Log.e("tag", "selectedJobCategory is : " + selectedJobCategory);
                    Log.e("tag", "selectedJobCity is : " + selectedJobCity);

                    Intent returnIntent = new Intent();
                    returnIntent.putExtra("selectedJobsTitle" , selectedJobsTitle);
                    returnIntent.putExtra("selectedJobCategory" , selectedJobCategory);
                    returnIntent.putExtra("selectedJobCity" , selectedJobCity);
                    setResult(Activity.RESULT_OK,returnIntent);
                    finish();

                }
            }
        });

    }

    public void autoCompleteClickListener() {

        multiSelectAutoCompleteView.setOnTextChangeListener(text -> {
            Log.e("tag", "User typed: " + text);

            getSearchJobDataAPI(text);

        });

    }

    private void getSearchJobDataAPI(String title) {

        RequestBody mTitle = RequestBody.create(title , MediaType.parse("text/plain"));


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
        call = retrofitApi.searchJobTitleApi(mTitle);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        list = new ArrayList<>();
                        list = response.body().getJobs_title_list();

                        Log.e("tag" , "job title list size is : "+list.size());


                        multiSelectAutoCompleteView.setItems(list , SearchJobTitleModel::getName , SearchJobTitleModel::getName);
                        multiSelectAutoCompleteView.showDropdown();


                    }
                    else
                    {
                        Toast.makeText(SearchJobsAndApplicant.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(SearchJobsAndApplicant.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(SearchJobsAndApplicant.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    private void getJobDataAPI() {

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
        call = retrofitApi.jobDataAPI();

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        searchLayout.setVisibility(VISIBLE);

                        jobCategoriesList.add(new VendorJobCategoriesModel("0" , "Select Job Category" ,"حدد فئة الوظيفة"));
                        jobCategoriesList.addAll(response.body().getJob_categories());

                        citiesList.add(new VendorJobCitiesModel("0" , "Select City" , "اختر المدينة" , new ArrayList<>()));
                        citiesList.addAll(response.body().getJob_cities());

                        Log.e("tag" , "categories list size is : "+jobCategoriesList.size());
                        Log.e("tag" , "cities list size is : "+citiesList.size());

                        dataSetToSpinner();

                    }
                    else
                    {
                        Toast.makeText(SearchJobsAndApplicant.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(SearchJobsAndApplicant.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(SearchJobsAndApplicant.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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

    public void dataSetToSpinner(){


        JobCategoriesSpinnerAdapter jobCategoriesSpinnerAdapter = new JobCategoriesSpinnerAdapter(SearchJobsAndApplicant.this , jobCategoriesList , selectedLanguage);
        jobCategorySpinner.setAdapter(jobCategoriesSpinnerAdapter);


        jobCategorySpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

                selectedJobCategory = "Select Job Type";
                selectedJobCategory = jobCategoriesList.get(i).getId();


                Log.e("tag" , "selectedJobCategory is : "+selectedJobCategory);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });


        JobCitiesSpinnerAdapter jobCitiesSpinnerAdapter = new JobCitiesSpinnerAdapter(SearchJobsAndApplicant.this , citiesList , selectedLanguage);
        jobCitySpinner.setAdapter(jobCitiesSpinnerAdapter);

        jobCitySpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

                selectedJobCity = "0";
                selectedJobCity = citiesList.get(i).getId();


                Log.e("tag" , "selectedJobCity is : "+selectedJobCity);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

    }

}