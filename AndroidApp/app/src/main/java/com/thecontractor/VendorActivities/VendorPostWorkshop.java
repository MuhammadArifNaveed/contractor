package com.thecontractor.VendorActivities;

import static android.view.View.VISIBLE;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
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
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.PickVisualMediaRequest;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.JobCitiesSpinnerAdapter;
import com.thecontractor.Adapter.NewCustomImagesAdapter;
import com.thecontractor.Adapter.WorkshopSectorSpinnerAdapter;
import com.thecontractor.Adapter.WorkshopTypeSpinnerAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.ImagePartFromUri;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Home;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.NewCustomImagesModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Model.VendorJobCitiesModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.Model.WorkshopSectorModel;
import com.thecontractor.Model.WorkshopTypeModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.util.ArrayList;
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

public class VendorPostWorkshop extends AppCompatActivity implements NewCustomImagesAdapter.DeleteImage{

    LinearLayout requestForQuotationLayout;
    Spinner workshopTypeSpinner , workshopSectorSpinner , workshopCitySpinner;
    String selectedTypeId = "0";
    String selectedSectorId = "0";
    String selectedCityId = "0";
    EditText titleET , detailsET;
    String titleETStr , detailsETStr;
    Button chooseImages;
    RecyclerView customImagesRecyclerView;
    GridLayoutManager gridLayoutManager ;
    String userId;
    String userType;
    String vendorId;
    Button updateProfileBtn;
    ArrayList<WorkshopTypeModel> workshopTypeList;
    ArrayList<WorkshopSectorModel> workshopSectorList;
    ArrayList<VendorJobCitiesModel> workshopCitiesList;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    MultipartBody.Part[] parts;
    String selectedLanguage = "en";
    private ActivityResultLauncher<PickVisualMediaRequest> galleryLauncher;
    NewCustomImagesAdapter newCustomImagesAdapter;
    private ArrayList<NewCustomImagesModel> selectedImages;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_post_workshop);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle("Post Workshop");


        getLanguageFromSP();
        getDataFromSP();
        initLaunchers();
        initiate();
        clickListener();
        workshopFilterDataAPI();

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
        if (!SharedPrefManager.getInstance(VendorPostWorkshop.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(VendorPostWorkshop.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(VendorPostWorkshop.this).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(VendorPostWorkshop.this).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);
            vendorId = vendorModel.getId();
            userId = vendorModel.getUser_id();
            userType = vendorModel.getUser_type();

            Log.e("tag" , "Vendor id is : "+vendorId);
            Log.e("tag" , "user id is : "+userId);
            Log.e("tag" , "user type is : "+userType);
        }
    }




    public void initiate()
    {

        progressDialog = new ProgressDialog(VendorPostWorkshop.this);

        selectedImages = new ArrayList<>();
        workshopTypeList = new ArrayList<>();
        workshopSectorList = new ArrayList<>();
        workshopCitiesList = new ArrayList<>();

        workshopTypeSpinner = (Spinner) findViewById(R.id.workshopTypeSpinner);
        workshopSectorSpinner = (Spinner) findViewById(R.id.workshopSectorSpinner);
        workshopCitySpinner = (Spinner) findViewById(R.id.workshopCitySpinner);

        chooseImages = (Button) findViewById(R.id.chooseImages);


        newCustomImagesAdapter = new NewCustomImagesAdapter(VendorPostWorkshop.this , this);
        customImagesRecyclerView = findViewById(R.id.customImagesRecyclerView);
        customImagesRecyclerView.setHasFixedSize(true);
        gridLayoutManager = new GridLayoutManager(VendorPostWorkshop.this , 3 ,  GridLayoutManager.VERTICAL , false);
        customImagesRecyclerView.setLayoutManager(gridLayoutManager);
        customImagesRecyclerView.setAdapter(newCustomImagesAdapter);

        requestForQuotationLayout = (LinearLayout) findViewById(R.id.requestForQuotationLayout);
        requestForQuotationLayout.setVisibility(View.GONE);
        titleET = (EditText) findViewById(R.id.titleET);
        detailsET = (EditText) findViewById(R.id.detailsET);
        updateProfileBtn = (Button) findViewById(R.id.updateProfileBtn);

    }

    public void clickListener()
    {

        chooseImages.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                openGallery();
            }
        });


        updateProfileBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                titleETStr = titleET.getText().toString();
                detailsETStr = detailsET.getText().toString();


                if(selectedTypeId.equals("0"))
                {
                    Toast.makeText(VendorPostWorkshop.this, "Please Select Type", Toast.LENGTH_SHORT).show();
                }else if(selectedSectorId.equals("0"))
                {
                    Toast.makeText(VendorPostWorkshop.this, "Please Select Sector", Toast.LENGTH_SHORT).show();
                }else if(selectedCityId.equals("0"))
                {
                    Toast.makeText(VendorPostWorkshop.this, "Please Select City", Toast.LENGTH_SHORT).show();
                }else if(titleETStr.equals(""))
                {
                    Toast.makeText(VendorPostWorkshop.this, getResources().getString(R.string.enter_title), Toast.LENGTH_SHORT).show();
                }else if(detailsETStr.equals(""))
                {
                    Toast.makeText(VendorPostWorkshop.this, getResources().getString(R.string.enter_description), Toast.LENGTH_SHORT).show();
                }
                else
                {

                    Log.e("tag" , "selectedTypeId is : " +selectedTypeId);
                    Log.e("tag" , "selectedSectorId is : " +selectedSectorId);
                    Log.e("tag" , "selectedCityId is : " +selectedCityId);
                    Log.e("tag" , "titleETStr is : " +titleETStr);
                    Log.e("tag" , "detailsETStr is : " +detailsETStr);

                    postWorkshopAd();
                }


            }
        });
    }

    private void openGallery() {
        galleryLauncher.launch(
                new PickVisualMediaRequest.Builder()
                        .setMediaType(
                                ActivityResultContracts.PickVisualMedia.ImageOnly.INSTANCE
                        )
                        .build()
        );
    }

    private void initLaunchers() {


        // GALLERY PICKER (IMAGE ONLY)
        galleryLauncher =
                registerForActivityResult(
                        new ActivityResultContracts.PickMultipleVisualMedia(5),
                        uris -> {
                            if (uris != null) {
                                selectedImages = new ArrayList<>();
                                for (Uri uri : uris) {
                                    selectedImages.add(new NewCustomImagesModel(uri));
                                }

                                customImagesRecyclerView.setVisibility(VISIBLE);
                                newCustomImagesAdapter.setData(selectedImages);

                            }else {
                                Log.e("tag", "No image selected");
                            }
                        }
                );

    }


    private void workshopFilterDataAPI() {

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
        call = retrofitApi.workshopFilterAPI();

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


                        workshopTypeList.add(new WorkshopTypeModel("0" , "Select Type"));
                        workshopTypeList.addAll(response.body().getWorkshop_type());

                        workshopSectorList.add(new WorkshopSectorModel("0" , "Select Sector"));
                        workshopSectorList.addAll(response.body().getWork_sector());

                        workshopCitiesList.add(new VendorJobCitiesModel("0" , "Select City" ,"اختر المدينة" , new ArrayList<>()));
                        workshopCitiesList.addAll(response.body().getFreelancer_cities());

                        Log.e("tag" , "workshopTypeList size is : "+workshopTypeList.size());
                        Log.e("tag" , "workshopSectorList size is : "+workshopSectorList.size());
                        Log.e("tag" , "workshopCitiesList size is : "+workshopCitiesList.size());

                        dataSetToSpinner();
                    }
                    else
                    {
                        Toast.makeText(VendorPostWorkshop.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorPostWorkshop.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorPostWorkshop.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }


    public void dataSetToSpinner(){

        WorkshopTypeSpinnerAdapter workshopTypeSpinnerAdapter = new WorkshopTypeSpinnerAdapter(VendorPostWorkshop.this , workshopTypeList , selectedLanguage);
        workshopTypeSpinner.setAdapter(workshopTypeSpinnerAdapter);

        workshopTypeSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

                selectedTypeId = workshopTypeList.get(i).getValue();

                Log.e("tag" , "selectedTypeId is "+selectedTypeId);

            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

        WorkshopSectorSpinnerAdapter workshopSectorSpinnerAdapter = new WorkshopSectorSpinnerAdapter(VendorPostWorkshop.this , workshopSectorList , selectedLanguage);
        workshopSectorSpinner.setAdapter(workshopSectorSpinnerAdapter);

        workshopSectorSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

                selectedSectorId = workshopSectorList.get(i).getValue();


                Log.e("tag" , "selectedTypeId is : "+selectedTypeId);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

        JobCitiesSpinnerAdapter jobCitiesSpinnerAdapter = new JobCitiesSpinnerAdapter(VendorPostWorkshop.this , workshopCitiesList , selectedLanguage);
        workshopCitySpinner.setAdapter(jobCitiesSpinnerAdapter);

        workshopCitySpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

                selectedCityId = "0";
                selectedCityId = workshopCitiesList.get(i).getId();


                Log.e("tag" , "selectedCityId is : "+selectedCityId);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

    }


    private void postWorkshopAd() {



        if(selectedImages.size() > 0)
        {
            parts = new MultipartBody.Part[selectedImages.size()];

            for (int index = 0; index < selectedImages.size(); index++) {
                Uri uri = selectedImages.get(index).getUri();
                parts[index] = ImagePartFromUri.createPartFromUri(VendorPostWorkshop.this, uri, "images[]");
            }
        }

        RequestBody vendor_id = RequestBody.create(vendorId , MediaType.parse("text/plain"));
        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));
        RequestBody user_type = RequestBody.create(userType , MediaType.parse("text/plain"));
        RequestBody adType = RequestBody.create(selectedTypeId , MediaType.parse("text/plain"));
        RequestBody adSector = RequestBody.create(selectedSectorId , MediaType.parse("text/plain"));
        RequestBody adCity = RequestBody.create(selectedCityId , MediaType.parse("text/plain"));
        RequestBody title = RequestBody.create(titleETStr , MediaType.parse("text/plain"));
        RequestBody detail = RequestBody.create(detailsETStr , MediaType.parse("text/plain"));



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
        call = retrofitApi.vendorPostWorkShopAdNewAPI(vendor_id , user_id , user_type , adType , adSector , adCity , title , detail , parts);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {



                        AlertDialog alertDialog = new AlertDialog.Builder(VendorPostWorkshop.this).create();
                        alertDialog.setCancelable(false);
                        alertDialog.setTitle(getResources().getString(R.string.workshop_ad_submitted));
                        alertDialog.setMessage(response.body().getMessage());
                        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, getResources().getString(R.string.ok),
                                new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int which) {

                                        dialog.dismiss();

                                        Intent intent = new Intent(VendorPostWorkshop.this, VendorHome.class);
                                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                                        startActivity(intent);
                                        finish();
                                    }
                                });
                        alertDialog.show();
                    }
                    else
                    {
                        Toast.makeText(VendorPostWorkshop.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(VendorPostWorkshop.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(VendorPostWorkshop.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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
    public void selectedImages(int pos) {
        selectedImages.remove(pos);
        newCustomImagesAdapter.setData(selectedImages);
    }
}