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
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.JobCategoriesSpinnerAdapter;
import com.thecontractor.Adapter.JobCitiesSpinnerAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.MultiSelectAutoCompleteViewNew;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.FreelancerSkillsModel;
import com.thecontractor.Model.NameModel;
import com.thecontractor.Model.SearchJobTitleModel;
import com.thecontractor.Model.VendorJobCategoriesModel;
import com.thecontractor.Model.VendorJobCitiesModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.util.ArrayList;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class SearchFreelancer extends AppCompatActivity {
    LinearLayout searchLayout;
    ArrayList<FreelancerSkillsModel> list;
    MultiSelectAutoCompleteViewNew<FreelancerSkillsModel> multiSelectAutoCompleteView;
    EditText rate;
    Spinner categorySpinner , citySpinner;
    Button searchBtn;
    String selectedRate;
    String selectedCategory = "0", selectedCity = "0";
    ArrayList<VendorJobCategoriesModel> categoriesList;
    ArrayList<VendorJobCitiesModel> citiesList;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    String from;
    String selectedLanguage = "en";
    String selectedSkills = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_search_freelancer);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle("Search Freelancer");

        getLanguageFromSP();
        initiate();
        clickListener();
        autoCompleteClickListener();
        getFreelancerDataAPI();
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
        if (!SharedPrefManager.getInstance(SearchFreelancer.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(SearchFreelancer.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }

    public void initiate(){

        list = new ArrayList<>();
        categoriesList = new ArrayList<>();
        citiesList = new ArrayList<>();

        progressDialog = new ProgressDialog(SearchFreelancer.this);

        searchLayout = (LinearLayout) findViewById(R.id.searchLayout);
        searchLayout.setVisibility(GONE);

        multiSelectAutoCompleteView = findViewById(R.id.multiSelectAutoCompleteView);
        multiSelectAutoCompleteView.setHint("Search Skills");
        multiSelectAutoCompleteView.setInputType(InputType.TYPE_CLASS_TEXT);
        multiSelectAutoCompleteView.setMaxLength(0);

        rate = (EditText) findViewById(R.id.rate);
        categorySpinner = (Spinner) findViewById(R.id.categorySpinner);
        citySpinner = (Spinner) findViewById(R.id.citySpinner);

        searchBtn = (Button) findViewById(R.id.searchBtn);

    }

    public void clickListener() {
        searchBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                selectedRate = rate.getText().toString();

                if (selectedCategory.equals("0")) {
                    Toast.makeText(SearchFreelancer.this, "Select category", Toast.LENGTH_SHORT).show();
                } else if (selectedCity.equals("0")) {
                    Toast.makeText(SearchFreelancer.this, "Select city", Toast.LENGTH_SHORT).show();
                } else {

                        selectedSkills = new Gson().toJson(multiSelectAutoCompleteView.getSelectedNames(name -> new NameModel(name)));

                        if(selectedSkills.equals("[]")){
                            selectedSkills = "";
                        }

                        Log.e("tag", "selectedSkills is : " + selectedSkills);
                        Log.e("tag", "selectedRate is : " + selectedRate);
                        Log.e("tag", "selectedCategory is : " + selectedCategory);
                        Log.e("tag", "selectedCity is : " + selectedCity);

                        Intent returnIntent = new Intent();
                        returnIntent.putExtra("selectedSkills" , selectedSkills);
                        returnIntent.putExtra("selectedRate" , selectedRate);
                        returnIntent.putExtra("selectedCategory" , selectedCategory);
                        returnIntent.putExtra("selectedCity" , selectedCity);
                        setResult(Activity.RESULT_OK,returnIntent);
                        finish();

                }
            }
        });

    }

    public void autoCompleteClickListener() {

        multiSelectAutoCompleteView.setOnTextChangeListener(text -> {
            Log.e("tag", "User typed: " + text);

        });

    }



    private void getFreelancerDataAPI() {

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
        call = retrofitApi.freelancerDataAPI();

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

                        list = response.body().getFreelancer_skills();

                        multiSelectAutoCompleteView.setItems(list , FreelancerSkillsModel::getTitle , FreelancerSkillsModel::getId);
                        //multiSelectAutoCompleteView.showDropdown();

                        categoriesList.add(new VendorJobCategoriesModel("0" , "Select Category" ,"حدد الفئة"));
                        categoriesList.addAll(response.body().getFreelancer_categories());

                        citiesList.add(new VendorJobCitiesModel("0" , "Select City" ,"اختر المدينة" , new ArrayList<>()));
                        citiesList.addAll(response.body().getFreelancer_cities());

                        Log.e("tag" , "list size is : "+list.size());
                        Log.e("tag" , "categories list size is : "+categoriesList.size());
                        Log.e("tag" , "cities list size is : "+citiesList.size());

                        dataSetToSpinner();

                    }
                    else
                    {
                        Toast.makeText(SearchFreelancer.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(SearchFreelancer.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(SearchFreelancer.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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


        JobCategoriesSpinnerAdapter jobCategoriesSpinnerAdapter = new JobCategoriesSpinnerAdapter(SearchFreelancer.this , categoriesList , selectedLanguage);
        categorySpinner.setAdapter(jobCategoriesSpinnerAdapter);


        categorySpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

                selectedCategory = "0";
                selectedCategory = categoriesList.get(i).getId();


                Log.e("tag" , "selectedCategory is : "+selectedCategory);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });


        JobCitiesSpinnerAdapter jobCitiesSpinnerAdapter = new JobCitiesSpinnerAdapter(SearchFreelancer.this , citiesList , selectedLanguage);
        citySpinner.setAdapter(jobCitiesSpinnerAdapter);

        citySpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

                selectedCity = "0";
                selectedCity = citiesList.get(i).getId();


                Log.e("tag" , "selectedCity is : "+selectedCity);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

    }

}