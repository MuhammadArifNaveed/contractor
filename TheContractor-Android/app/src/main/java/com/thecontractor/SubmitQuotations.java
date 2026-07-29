package com.thecontractor;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.nguyenhoanglam.imagepicker.model.Image;
import com.nguyenhoanglam.imagepicker.model.ImagePickerConfig;
import com.nguyenhoanglam.imagepicker.ui.imagepicker.ImagePickerKt;
import com.nguyenhoanglam.imagepicker.ui.imagepicker.ImagePickerLauncher;
import com.thecontractor.Adapter.CategoriesAdapter;
import com.thecontractor.Adapter.CustomImagesAdapter;
import com.thecontractor.Adapter.SubCategoriesAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.ImagePartFromUri;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.CategoriesModel;
import com.thecontractor.Model.SubCategoriesModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.io.File;
import java.util.ArrayList;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class SubmitQuotations extends AppCompatActivity implements CustomImagesAdapter.DeleteImage , CategoriesAdapter.SubCategoriesInterface , SubCategoriesAdapter.SubCategoryIdInterface{
    LinearLayout requestForQuotationLayout;

    RecyclerView categoriesRV;
    LinearLayoutManager categoriesLinearLayoutManager ;


    RecyclerView rvSubCategories;
    GridLayoutManager subCategoriesLinearLayoutManager ;


    String categoryId = "0";
    String subCategoryId = "0";
    EditText fistNameET , lastNameET   , mobileET , emailET , detailsET;
    String fistNameETStr , lastNameETStr   , mobileETStr , emailETStr , detailsETStr ;
    Button chooseImages;
    RecyclerView customImagesRecyclerView;
    GridLayoutManager gridLayoutManager ;
    CustomImagesAdapter customImagesAdapter;
    private ArrayList<Image> selectedImages = new ArrayList<>();
    String userId;
    Button updateProfileBtn;
    ArrayList<CategoriesModel> categoriesList;
    ArrayList<SubCategoriesModel> subCategoriesList;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    MultipartBody.Part[] parts;
    String selectedLanguage = "en";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_submit_quotations);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.submit_quotation));

        getLanguageFromSP();
        getDataFromSP();
        initiate();
        clickListener();
        categoriesAPI();
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
        if (!SharedPrefManager.getInstance(SubmitQuotations.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(SubmitQuotations.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(SubmitQuotations.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(SubmitQuotations.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();

            Log.e("tag" , "user id is : "+userId);

            fistNameETStr = userModel.getName();
            lastNameETStr = userModel.getSurname();
            mobileETStr = userModel.getPhone();
            emailETStr = userModel.getEmail();


        }
    }



    public void initiate()
    {

        progressDialog = new ProgressDialog(SubmitQuotations.this);

        categoriesList = new ArrayList<>();
        subCategoriesList = new ArrayList<>();


        categoriesRV = (RecyclerView) findViewById(R.id.categoriesRV);
        categoriesLinearLayoutManager = new LinearLayoutManager(SubmitQuotations.this  ,  LinearLayoutManager.HORIZONTAL , false);
        categoriesRV.setLayoutManager(categoriesLinearLayoutManager);


        rvSubCategories = (RecyclerView) findViewById(R.id.rvSubCategories);
        subCategoriesLinearLayoutManager = new GridLayoutManager(SubmitQuotations.this , 2 ,  GridLayoutManager.VERTICAL , false);
        rvSubCategories.setLayoutManager(subCategoriesLinearLayoutManager);

        chooseImages = (Button) findViewById(R.id.chooseImages);


        customImagesAdapter = new CustomImagesAdapter(this , this);

        customImagesRecyclerView = findViewById(R.id.customImagesRecyclerView);
        customImagesRecyclerView.setHasFixedSize(true);
        gridLayoutManager = new GridLayoutManager(SubmitQuotations.this , 3 ,  GridLayoutManager.VERTICAL , false);
        customImagesRecyclerView.setLayoutManager(gridLayoutManager);
        customImagesRecyclerView.setAdapter(customImagesAdapter);

        requestForQuotationLayout = (LinearLayout) findViewById(R.id.requestForQuotationLayout);
        requestForQuotationLayout.setVisibility(View.GONE);
        fistNameET = (EditText) findViewById(R.id.fistNameET);
        lastNameET = (EditText) findViewById(R.id.lastNameET);
        mobileET = (EditText) findViewById(R.id.mobileET);
        emailET = (EditText) findViewById(R.id.emailET);
        detailsET = (EditText) findViewById(R.id.detailsET);
        updateProfileBtn = (Button) findViewById(R.id.updateProfileBtn);


        fistNameET.setText(fistNameETStr);
        lastNameET.setText(lastNameETStr);
        emailET.setText(emailETStr);
        mobileET.setText(mobileETStr);


    }

    public void clickListener()
    {




        chooseImages.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                startImagesPicker();
            }
        });


        updateProfileBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                fistNameETStr = fistNameET.getText().toString();
                lastNameETStr = lastNameET.getText().toString();
                mobileETStr = mobileET.getText().toString();
                emailETStr = emailET.getText().toString();
                detailsETStr = detailsET.getText().toString();

                if(categoryId.equals("0"))
                {
                    Toast.makeText(SubmitQuotations.this, getResources().getString(R.string.select_category), Toast.LENGTH_SHORT).show();
                }else if(subCategoryId.equals("0"))
                {
                    Toast.makeText(SubmitQuotations.this, getResources().getString(R.string.select_sub_category), Toast.LENGTH_SHORT).show();
                }else if(fistNameETStr.equals(""))
                {
                    Toast.makeText(SubmitQuotations.this, getResources().getString(R.string.enter_name_error), Toast.LENGTH_SHORT).show();
                }else if(lastNameETStr.equals(""))
                {
                    Toast.makeText(SubmitQuotations.this, getResources().getString(R.string.enter_sur_name_error), Toast.LENGTH_SHORT).show();
                }else if(mobileETStr.equals(""))
                {
                    Toast.makeText(SubmitQuotations.this, getResources().getString(R.string.phone_no_error), Toast.LENGTH_SHORT).show();
                } else if(emailETStr.equals(""))
                {
                    Toast.makeText(SubmitQuotations.this, getResources().getString(R.string.enter_email_address_error), Toast.LENGTH_SHORT).show();
                }else if(!isValidEmail(emailETStr))
                {
                    Toast.makeText(SubmitQuotations.this, getResources().getString(R.string.enter_valid_email_address), Toast.LENGTH_SHORT).show();
                }else if(detailsETStr.equals(""))
                {
                    Toast.makeText(SubmitQuotations.this, getResources().getString(R.string.enter_details), Toast.LENGTH_SHORT).show();
                }else
                {
                    requestQuote();
                }


            }
        });
    }


    private void startImagesPicker() {

        ImagePickerConfig config = new ImagePickerConfig();
        config.setFolderMode(true);
        config.setShowCamera(true);
        config.setLimitSize(5);
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

    public static boolean isValidEmail(final String emailAddress) {

        Pattern pattern;
        Matcher matcher;

        final String EMAIL_PATTERN = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@" + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";

        pattern = Pattern.compile(EMAIL_PATTERN);
        matcher = pattern.matcher(emailAddress);
        return matcher.matches();
    }


    private void categoriesAPI() {

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
        call = retrofitApi.categoriesWithSubCategoriesAPI();

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        requestForQuotationLayout.setVisibility(View.VISIBLE);

                        categoriesList = response.body().getCategories();

                        Log.e("tag" , "categories list size is : "+categoriesList.size());

                        CategoriesAdapter categoriesAdapter = new CategoriesAdapter(SubmitQuotations.this , categoriesList , SubmitQuotations.this , selectedLanguage);
                        categoriesRV.setAdapter(categoriesAdapter);

                    }
                    else
                    {
                        Toast.makeText(SubmitQuotations.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(SubmitQuotations.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(SubmitQuotations.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }



    private void requestQuote() {



        if(selectedImages.size() > 0)
        {
            parts = new MultipartBody.Part[selectedImages.size()];

            for (int index = 0; index < selectedImages.size(); index++) {
//                Log.e("tag", "ad image in service" + index + "  " + selectedImages.get(index).getPath());
//                File file = new File(selectedImages.get(index).getPath());
//                RequestBody requestBody = RequestBody.create(file,MediaType.parse("image/*"));
//                parts[index] = MultipartBody.Part.createFormData("images[]", file.getName(), requestBody);


                Uri uri = selectedImages.get(index).getUri();
                String fileName = "upload_" + System.currentTimeMillis() + "_" + index + ".jpg";
                parts[index] = ImagePartFromUri.createPartFromUri(this, uri, "images[]", fileName , "image/*");
            }

        }

        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));
        RequestBody firstName = RequestBody.create(fistNameETStr , MediaType.parse("text/plain"));
        RequestBody lastName = RequestBody.create(lastNameETStr , MediaType.parse("text/plain"));
        RequestBody phone = RequestBody.create(mobileETStr , MediaType.parse("text/plain"));
        RequestBody email = RequestBody.create(emailETStr , MediaType.parse("text/plain"));
        RequestBody detail = RequestBody.create(detailsETStr , MediaType.parse("text/plain"));
        RequestBody category_id = RequestBody.create(categoryId , MediaType.parse("text/plain"));
        RequestBody sub_category_id = RequestBody.create(subCategoryId , MediaType.parse("text/plain"));

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
        call = retrofitApi.requestQuotation(user_id , firstName , lastName  , phone , email , detail , category_id , sub_category_id , parts);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {



                        AlertDialog alertDialog = new AlertDialog.Builder(SubmitQuotations.this).create();
                        alertDialog.setCancelable(false);
                        alertDialog.setTitle(getResources().getString(R.string.quotation_submitted));
                        alertDialog.setMessage(response.body().getMessage());
                        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, getResources().getString(R.string.ok),
                                new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int which) {

                                        dialog.dismiss();

                                        Intent intent = new Intent(SubmitQuotations.this, Home.class);
                                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                                        startActivity(intent);
                                        finish();
                                    }
                                });
                        alertDialog.show();
                    }
                    else
                    {
                        Toast.makeText(SubmitQuotations.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(SubmitQuotations.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(SubmitQuotations.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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

    @Override
    public void selectedSubCategories(ArrayList<SubCategoriesModel> sub_categories, String categoryId) {
        this.subCategoryId = "0";
        this.categoryId = categoryId;

        SubCategoriesAdapter subCategoriesAdapter = new SubCategoriesAdapter(SubmitQuotations.this , sub_categories , "false" , this , selectedLanguage);
        rvSubCategories.setAdapter(subCategoriesAdapter);
    }

    @Override
    public void selectedSubCategoryId(String subCategoryId) {
        this.subCategoryId = subCategoryId;
    }
}