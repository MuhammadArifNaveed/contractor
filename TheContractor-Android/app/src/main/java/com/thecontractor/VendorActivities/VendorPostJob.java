package com.thecontractor.VendorActivities;

import static android.view.View.GONE;

import android.app.DatePickerDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.nguyenhoanglam.imagepicker.model.Image;
import com.nguyenhoanglam.imagepicker.model.ImagePickerConfig;
import com.nguyenhoanglam.imagepicker.ui.imagepicker.ImagePickerKt;
import com.nguyenhoanglam.imagepicker.ui.imagepicker.ImagePickerLauncher;
import com.thecontractor.Adapter.CustomImagesAdapter;
import com.thecontractor.Adapter.JobCategoriesSpinnerAdapter;
import com.thecontractor.Adapter.JobCitiesSpinnerAdapter;
import com.thecontractor.Adapter.JobTypeSpinnerAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.ImagePartFromUri;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Home;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.VendorJobCategoriesModel;
import com.thecontractor.Model.VendorJobCitiesModel;
import com.thecontractor.Model.VendorJobListingModel;
import com.thecontractor.Model.VendorJobTypeModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.io.File;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class VendorPostJob extends AppCompatActivity implements CustomImagesAdapter.DeleteImage{

    VendorJobListingModel vendorJobListingModel;
    String from;
    LinearLayout postJobLayout;
    EditText jobTitleEnglish , jobTitleArabic , vacancies , descriptionEnglish  , descriptionArabic , salary , deadline;
    String jobTitleEnglishStr , jobTitleArabicStr , vacanciesStr , descriptionEnglishStr  , descriptionArabicStr , salaryStr , deadlineStr;
    Spinner jobTypeSpinner , jobCategorySpinner , jobLocationSpinner;
    String selectedJobType = "Select Job Type", selectedJobCategory = "0", selectedJobLocation = "0";
    CheckBox payJobCB;
    String payJob = "Yes";
    Button chooseImages , submitBtn;
    RecyclerView customImagesRecyclerView;
    GridLayoutManager gridLayoutManager ;
    CustomImagesAdapter customImagesAdapter;
    String selectedLanguage = "en";
    String vendorId;
    String userId;
    String userType;
    String jobId;
    ArrayList<VendorJobCitiesModel> citiesList;
    ArrayList<VendorJobCategoriesModel> jobCategoriesList;
    ArrayList<VendorJobTypeModel> jobTypeList;


    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    private Calendar calendar;
    private ArrayList<Image> selectedImages = new ArrayList<>();
    MultipartBody.Part part;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_post_job);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle("Post Job");

        getObjectFromAdapter();
        getLanguageFromSP();
        getDataFromSP();
        initiate();
        clickListener();
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

            Log.e("tag" , "from is : "+from);

            assert from != null;
            if(from.equals("update")){
                vendorJobListingModel = (VendorJobListingModel) bundle.getParcelable("vendorJobListingModel");
                jobId = vendorJobListingModel.getId();

                Log.e("tag" ,"job id is : "+jobId);

            }



        }
    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(VendorPostJob.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorPostJob.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);

        }
    }

    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorPostJob.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorPostJob.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();
            userId = vendorModel.getUser_id();
            userType = vendorModel.getUser_type();

            Log.e("tag" , "Vendor id is : "+vendorId);
            Log.e("tag" , "user id is : "+userId);
            Log.e("tag" , "user type is : "+userType);
        }
    }

    public void initiate(){

        calendar = Calendar.getInstance();

        citiesList = new ArrayList<>();
        jobCategoriesList = new ArrayList<>();
        jobTypeList = new ArrayList<>();

        progressDialog = new ProgressDialog(VendorPostJob.this);

        postJobLayout = (LinearLayout) findViewById(R.id.postJobLayout);
        postJobLayout.setVisibility(GONE);


        jobTitleEnglish = (EditText) findViewById(R.id.jobTitleEnglish);
        jobTitleArabic = (EditText) findViewById(R.id.jobTitleArabic);
        vacancies = (EditText) findViewById(R.id.vacancies);
        descriptionEnglish = (EditText) findViewById(R.id.descriptionEnglish);
        descriptionArabic = (EditText) findViewById(R.id.descriptionArabic);
        salary = (EditText) findViewById(R.id.salary);
        deadline = (EditText) findViewById(R.id.deadline);

        jobLocationSpinner = (Spinner) findViewById(R.id.jobLocationSpinner);
        jobCategorySpinner = (Spinner) findViewById(R.id.jobCategorySpinner);
        jobTypeSpinner = (Spinner) findViewById(R.id.jobTypeSpinner);



        payJobCB = (CheckBox) findViewById(R.id.payJobCB);

        chooseImages = (Button) findViewById(R.id.chooseImages);
        submitBtn = (Button) findViewById(R.id.submitBtn);

        customImagesAdapter = new CustomImagesAdapter(this , this);

        customImagesRecyclerView = findViewById(R.id.customImagesRecyclerView);
        customImagesRecyclerView.setHasFixedSize(true);
        gridLayoutManager = new GridLayoutManager(VendorPostJob.this , 3 ,  GridLayoutManager.VERTICAL , false);
        customImagesRecyclerView.setLayoutManager(gridLayoutManager);
        customImagesRecyclerView.setAdapter(customImagesAdapter);


    }

    public void clickListener(){
        submitBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                jobTitleEnglishStr = jobTitleEnglish.getText().toString();
                jobTitleArabicStr = jobTitleArabic.getText().toString();
                vacanciesStr = vacancies.getText().toString();
                descriptionEnglishStr = descriptionEnglish.getText().toString();
                descriptionArabicStr = descriptionArabic.getText().toString();
                salaryStr = salary.getText().toString();
                deadlineStr = deadline.getText().toString();

                if(jobTitleEnglishStr.isEmpty()){
                    Toast.makeText(VendorPostJob.this, "Enter job title in english", Toast.LENGTH_SHORT).show();
                }else if(jobTitleArabicStr.isEmpty()){
                    Toast.makeText(VendorPostJob.this, "Enter job title in arabic", Toast.LENGTH_SHORT).show();
                }else if(vacanciesStr.isEmpty()){
                    Toast.makeText(VendorPostJob.this, "Enter vacancies", Toast.LENGTH_SHORT).show();
                }else if(descriptionEnglishStr.isEmpty()){
                    Toast.makeText(VendorPostJob.this, "Enter job description in english", Toast.LENGTH_SHORT).show();
                }else if(descriptionArabicStr.isEmpty()){
                    Toast.makeText(VendorPostJob.this, "Enter job description in arabic", Toast.LENGTH_SHORT).show();
                }else if(salaryStr.isEmpty()){
                    Toast.makeText(VendorPostJob.this, "Enter salary", Toast.LENGTH_SHORT).show();
                }else if(deadlineStr.isEmpty()){
                    Toast.makeText(VendorPostJob.this, "Select deadline", Toast.LENGTH_SHORT).show();
                }else if(selectedJobType.equals("Select Job Type")){
                    Toast.makeText(VendorPostJob.this, "Select job type", Toast.LENGTH_SHORT).show();
                }else if(selectedJobCategory.equals("0")){
                    Toast.makeText(VendorPostJob.this, "Select job category", Toast.LENGTH_SHORT).show();
                }else if(selectedJobLocation.equals("0")){
                    Toast.makeText(VendorPostJob.this, "Select city", Toast.LENGTH_SHORT).show();
                }else {

                    if(payJobCB.isChecked()){
                        payJob = "Yes";
                    }else {
                        payJob = "No";
                    }


                    Log.e("tag" , "jobTitleEnglishStr is : "+jobTitleEnglishStr);
                    Log.e("tag" , "jobTitleArabicStr is : "+jobTitleArabicStr);
                    Log.e("tag" , "vacanciesStr is : "+vacanciesStr);
                    Log.e("tag" , "descriptionEnglishStr is : "+descriptionEnglishStr);
                    Log.e("tag" , "descriptionArabicStr is : "+descriptionArabicStr);
                    Log.e("tag" , "salaryStr is : "+salaryStr);
                    Log.e("tag" , "deadlineStr is : "+deadlineStr);
                    Log.e("tag" , "selectedJobType is : "+selectedJobType);
                    Log.e("tag" , "selectedJobCategory is : "+selectedJobCategory);
                    Log.e("tag" , "selectedJobLocation is : "+selectedJobLocation);
                    Log.e("tag" , "payJob checkbox is : "+payJob);

                    postJobAPI();


                }
            }
        });


        deadline.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showDatePickerDialog();
            }
        });

        chooseImages.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                startImagesPicker();
            }
        });



    }


    public void setDateToWidget(){

        jobTitleEnglish.setText(vendorJobListingModel.getTitle());
        jobTitleArabic.setText(vendorJobListingModel.getArabic_title());
        vacancies.setText(vendorJobListingModel.getVaccancies());
        descriptionEnglish.setText(vendorJobListingModel.getDescription());
        descriptionArabic.setText(vendorJobListingModel.getArabic_description());
        salary.setText(vendorJobListingModel.getSalary());
        deadline.setText(parseDateToddMMyyyy(vendorJobListingModel.getDeadline()));


        if(!citiesList.isEmpty()){
            for (int i = 0; i < citiesList.size(); i++) {
                if (citiesList.get(i).getId().equals(vendorJobListingModel.getJob_location())) { // Or compare by name, or a unique identifier
                    jobLocationSpinner.setSelection(i);
                    break;
                }
            }
        }

        if(!jobCategoriesList.isEmpty()){
            for (int i = 0; i < jobCategoriesList.size(); i++) {
                if (jobCategoriesList.get(i).getId().equals(vendorJobListingModel.getJob_category())) { // Or compare by name, or a unique identifier
                    jobCategorySpinner.setSelection(i);
                    break;
                }
            }
        }

        if(!jobTypeList.isEmpty()){
            for (int i = 0; i < jobTypeList.size(); i++) {
                if (jobTypeList.get(i).getType().equals(vendorJobListingModel.getJob_type())) { // Or compare by name, or a unique identifier
                    jobTypeSpinner.setSelection(i);
                    break;
                }
            }
        }



    }


    private void startImagesPicker() {

        ImagePickerConfig config = new ImagePickerConfig();
        config.setFolderMode(true);
        config.setShowCamera(true);
        config.setLimitSize(1);
        config.setImageTitle("Select Images");
        config.setDoneButtonTitle("Done");

        imagePickerLauncher.launch(config);



    }

    private final ImagePickerLauncher imagePickerLauncher = ImagePickerKt.registerImagePicker(
            this,
            () -> this,
            (ArrayList<Image> images) -> {

                selectedImages = images;
                customImagesRecyclerView.setVisibility(View.VISIBLE);
                customImagesAdapter.setData(selectedImages);
                return null;
            }
    );


    @Override
    public void selectedImages(int pos) {
        selectedImages.remove(pos);
        customImagesAdapter.setData(selectedImages);

    }



    private void showDatePickerDialog() {
        DatePickerDialog.OnDateSetListener dateSetListener = new DatePickerDialog.OnDateSetListener() {
            @Override
            public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                calendar.set(Calendar.YEAR, year);
                calendar.set(Calendar.MONTH, monthOfYear);
                calendar.set(Calendar.DAY_OF_MONTH, dayOfMonth);
                updateEditTextWithFormattedDate();
            }
        };

        DatePickerDialog datePickerDialog = new DatePickerDialog(
                VendorPostJob.this,
                dateSetListener,
                calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH),
                calendar.get(Calendar.DAY_OF_MONTH)
        );

        datePickerDialog.getDatePicker().setMinDate(System.currentTimeMillis() - 1000);

        datePickerDialog.show();
    }

    private void updateEditTextWithFormattedDate() {
        // Define your desired date format here
        String dateFormat = "MM/dd/yyyy"; // Example: 25/10/2025
        // String dateFormat = "MM-dd-yyyy"; // Example: 10-25-2025
        // String dateFormat = "yyyy-MM-dd"; // Example: 2025-10-25

        SimpleDateFormat sdf = new SimpleDateFormat(dateFormat, Locale.getDefault());
        deadline.setText(sdf.format(calendar.getTime()));
    }

    public String parseDateToddMMyyyy(String time) {
        String inputPattern = "yyyy-MM-dd";
        String outputPattern = "MM/dd/yyyy";
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

                        postJobLayout.setVisibility(View.VISIBLE);

                        citiesList.add(new VendorJobCitiesModel("0" , "Select City" ,   "اختر المدينة" , new ArrayList<>()));
                        citiesList.addAll(response.body().getJob_cities());

                        jobCategoriesList.add(new VendorJobCategoriesModel("0" , "Select Job Category" ,"حدد فئة الوظيفة"));
                        jobCategoriesList.addAll(response.body().getJob_categories());

                        jobTypeList.add(new VendorJobTypeModel("Select Job Type"));
                        jobTypeList.addAll(response.body().getJob_types());


                        //citiesList = response.body().getJob_cities();
                        //jobCategoriesList = response.body().getJob_categories();
                        //jobTypeList = response.body().getJob_types();

                        Log.e("tag" , "cities list size is : "+citiesList.size());
                        Log.e("tag" , "categories list size is : "+jobCategoriesList.size());
                        Log.e("tag" , "type list size is : "+jobTypeList.size());



                        dataSetToSpinner();

                        assert from != null;
                        if(from.equals("update")){
                            setDateToWidget();

                        }

                    }
                    else
                    {
                        Toast.makeText(VendorPostJob.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorPostJob.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorPostJob.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }


    private void postJobAPI() {
        File file;
        if(selectedImages.size() > 0)
        {
            Image img = selectedImages.get(0);
             file = ImagePartFromUri.getFileFromUri(VendorPostJob.this, img.getUri() , "image");

            if (file != null && file.exists()) {
                Log.e("tag", "Uploading image # : " + file.getAbsolutePath());
                RequestBody requestBody = RequestBody.create(file, MediaType.parse("image/*"));
                part = MultipartBody.Part.createFormData("advertisement", file.getName(), requestBody);

            }else {
                Log.e("tag", "Failed to resolve file for image #");
            }
        } else {
            file = null;
        }

        RequestBody job_id = null;
        assert from != null;
        if(from.equals("update")){
            job_id = RequestBody.create(jobId , MediaType.parse("text/plain"));

        }

        RequestBody jobTitleEnglish = RequestBody.create(jobTitleEnglishStr , MediaType.parse("text/plain"));
        RequestBody jobTitleArabic = RequestBody.create(jobTitleArabicStr , MediaType.parse("text/plain"));
        RequestBody vacancies = RequestBody.create(vacanciesStr , MediaType.parse("text/plain"));
        RequestBody descriptionEnglish = RequestBody.create(descriptionEnglishStr, MediaType.parse("text/plain"));
        RequestBody descriptionArabic = RequestBody.create(descriptionArabicStr , MediaType.parse("text/plain"));
        RequestBody salary = RequestBody.create(salaryStr , MediaType.parse("text/plain"));
        RequestBody deadline = RequestBody.create(deadlineStr , MediaType.parse("text/plain"));
        RequestBody mSelectedJobType = RequestBody.create(selectedJobType , MediaType.parse("text/plain"));
        RequestBody mSelectedJobCategory = RequestBody.create(selectedJobCategory , MediaType.parse("text/plain"));
        RequestBody mSelectedJobLocation = RequestBody.create(selectedJobLocation , MediaType.parse("text/plain"));
        RequestBody mPayJob = RequestBody.create(payJob , MediaType.parse("text/plain"));
        RequestBody vendor_id = RequestBody.create(vendorId , MediaType.parse("text/plain"));
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

        assert from != null;
        if(from.equals("update")){
            call = retrofitApi.updateJob(jobTitleEnglish , jobTitleArabic , vacancies , descriptionEnglish , descriptionArabic , salary ,
                    mSelectedJobCategory , mSelectedJobLocation , mSelectedJobType , deadline , vendor_id , user_id , user_type , part , job_id);
        }else{
            call = retrofitApi.postJob(jobTitleEnglish , jobTitleArabic , vacancies , descriptionEnglish , descriptionArabic , salary ,
                    mSelectedJobCategory , mSelectedJobLocation , mSelectedJobType , deadline , vendor_id , user_id , user_type , part);
        }


        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        if (file != null && file.exists()) {
                            file.delete();
                        }

                        Toast.makeText(VendorPostJob.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();


                        Intent intent = new Intent(VendorPostJob.this, VendorHome.class);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                        startActivity(intent);
                        finish();


                    }
                    else
                    {
                        Toast.makeText(VendorPostJob.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorPostJob.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorPostJob.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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

//        ArrayList<VendorJobCitiesModel> newCitiesList = new ArrayList<>();
//        newCitiesList.add(new VendorJobCitiesModel("0" , "Select City" ,"اختر المدينة"));
//        newCitiesList.addAll(citiesList);
//
//
//        ArrayList<VendorJobCategoriesModel> newJobCategoriesList = new ArrayList<>();
//        newJobCategoriesList.add(new VendorJobCategoriesModel("0" , "Select Job Category" ,"حدد فئة الوظيفة"));
//        newJobCategoriesList.addAll(jobCategoriesList);
//
//
//        ArrayList<VendorJobTypeModel> newJobTypeList = new ArrayList<>();
//        newJobTypeList.add(new VendorJobTypeModel("Select Job Type"));
//        newJobTypeList.addAll(jobTypeList);


        JobCitiesSpinnerAdapter jobCitiesSpinnerAdapter = new JobCitiesSpinnerAdapter(VendorPostJob.this , citiesList , selectedLanguage);
        jobLocationSpinner.setAdapter(jobCitiesSpinnerAdapter);

        jobLocationSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

                selectedJobLocation = "0";
                selectedJobLocation = citiesList.get(i).getId();


                Log.e("tag" , "selectedJobLocation is : "+selectedJobLocation);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });


        JobCategoriesSpinnerAdapter jobCategoriesSpinnerAdapter = new JobCategoriesSpinnerAdapter(VendorPostJob.this , jobCategoriesList , selectedLanguage);
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


        JobTypeSpinnerAdapter jobTypeSpinnerAdapter = new JobTypeSpinnerAdapter(VendorPostJob.this , jobTypeList , selectedLanguage);
        jobTypeSpinner.setAdapter(jobTypeSpinnerAdapter);

        jobTypeSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

                selectedJobType = "0";
                selectedJobType = jobTypeList.get(i).getType();


                Log.e("tag" , "selectedJobCategory is : "+selectedJobType);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

    }

}