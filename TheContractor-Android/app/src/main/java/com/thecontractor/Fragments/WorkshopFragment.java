package com.thecontractor.Fragments;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.location.Address;
import android.location.Geocoder;
import android.net.Uri;
import android.os.Bundle;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.PickVisualMediaRequest;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.os.Environment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.nguyenhoanglam.imagepicker.model.Image;
import com.nguyenhoanglam.imagepicker.model.ImagePickerConfig;
import com.nguyenhoanglam.imagepicker.ui.imagepicker.ImagePickerKt;
import com.nguyenhoanglam.imagepicker.ui.imagepicker.ImagePickerLauncher;
import com.thecontractor.Adapter.CategoriesAdapter;
import com.thecontractor.Adapter.CustomImagesAdapter;
import com.thecontractor.Adapter.JobCategoriesSpinnerAdapter;
import com.thecontractor.Adapter.JobCitiesSpinnerAdapter;
import com.thecontractor.Adapter.NewCustomImagesAdapter;
import com.thecontractor.Adapter.SubCategoriesAdapter;
import com.thecontractor.Adapter.WorkshopSectorSpinnerAdapter;
import com.thecontractor.Adapter.WorkshopTypeSpinnerAdapter;
import com.thecontractor.Cart;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.ImagePartFromUri;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Home;
import com.thecontractor.MapsActivity;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.CategoriesModel;
import com.thecontractor.Model.CitiesModel;
import com.thecontractor.Model.NewCustomImagesModel;
import com.thecontractor.Model.SubCategoriesModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Model.VendorJobCategoriesModel;
import com.thecontractor.Model.VendorJobCitiesModel;
import com.thecontractor.Model.WorkshopSectorModel;
import com.thecontractor.Model.WorkshopTypeModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.SubmitQuotations;
import com.thecontractor.UpdateProfile;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
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

import static android.app.Activity.RESULT_OK;
import static android.view.View.VISIBLE;


public class WorkshopFragment extends Fragment implements NewCustomImagesAdapter.DeleteImage{

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


    public WorkshopFragment() {
        // Required empty public constructor
    }


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view =  inflater.inflate(R.layout.fragment_workshop, container, false);

        getLanguageFromSP();
        getDataFromSP();
        initLaunchers();
        initiate(view);
        clickListener();
        workshopFilterDataAPI();



        return view;
    }


    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(getActivity()).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(getActivity()).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(getActivity()).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(getActivity()).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();
            userType = userModel.getUser_type();
            vendorId = userId;

            Log.e("tag" , "user id is : "+userId);
            Log.e("tag" , "user type is : "+userType);
            Log.e("tag" , "vendor id is : "+vendorId);

        }
    }



    public void initiate(View view)
    {

        progressDialog = new ProgressDialog(getActivity());

        selectedImages = new ArrayList<>();
        workshopTypeList = new ArrayList<>();
        workshopSectorList = new ArrayList<>();
        workshopCitiesList = new ArrayList<>();

        workshopTypeSpinner = (Spinner) view.findViewById(R.id.workshopTypeSpinner);
        workshopSectorSpinner = (Spinner) view.findViewById(R.id.workshopSectorSpinner);
        workshopCitySpinner = (Spinner) view.findViewById(R.id.workshopCitySpinner);

        chooseImages = (Button) view.findViewById(R.id.chooseImages);


        newCustomImagesAdapter = new NewCustomImagesAdapter(getActivity() , this);
        customImagesRecyclerView = view.findViewById(R.id.customImagesRecyclerView);
        customImagesRecyclerView.setHasFixedSize(true);
        gridLayoutManager = new GridLayoutManager(getActivity() , 3 ,  GridLayoutManager.VERTICAL , false);
        customImagesRecyclerView.setLayoutManager(gridLayoutManager);
        customImagesRecyclerView.setAdapter(newCustomImagesAdapter);

        requestForQuotationLayout = (LinearLayout) view.findViewById(R.id.requestForQuotationLayout);
        requestForQuotationLayout.setVisibility(View.GONE);
        titleET = (EditText) view.findViewById(R.id.titleET);
        detailsET = (EditText) view.findViewById(R.id.detailsET);
        updateProfileBtn = (Button) view.findViewById(R.id.updateProfileBtn);

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
                    Toast.makeText(getActivity(), "Please Select Type", Toast.LENGTH_SHORT).show();
                }else if(selectedSectorId.equals("0"))
                {
                    Toast.makeText(getActivity(), "Please Select Sector", Toast.LENGTH_SHORT).show();
                }else if(selectedCityId.equals("0"))
                {
                    Toast.makeText(getActivity(), "Please Select City", Toast.LENGTH_SHORT).show();
                }else if(titleETStr.equals(""))
                {
                    Toast.makeText(getActivity(), getResources().getString(R.string.enter_title), Toast.LENGTH_SHORT).show();
                }else if(detailsETStr.equals(""))
                {
                    Toast.makeText(getActivity(), getResources().getString(R.string.enter_description), Toast.LENGTH_SHORT).show();
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
                        Toast.makeText(getActivity(), response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(getActivity(), getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(getActivity() , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }


    public void dataSetToSpinner(){

        WorkshopTypeSpinnerAdapter workshopTypeSpinnerAdapter = new WorkshopTypeSpinnerAdapter(getActivity() , workshopTypeList , selectedLanguage);
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

        WorkshopSectorSpinnerAdapter workshopSectorSpinnerAdapter = new WorkshopSectorSpinnerAdapter(getActivity() , workshopSectorList , selectedLanguage);
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

        JobCitiesSpinnerAdapter jobCitiesSpinnerAdapter = new JobCitiesSpinnerAdapter(getActivity() , workshopCitiesList , selectedLanguage);
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
                parts[index] = ImagePartFromUri.createPartFromUri(getActivity(), uri, "images[]");
            }
        }

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
        call = retrofitApi.postWorkShopAdNewAPI(user_id , user_type , adType , adSector , adCity , title , detail , parts);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {



                        AlertDialog alertDialog = new AlertDialog.Builder(getActivity()).create();
                        alertDialog.setCancelable(false);
                        alertDialog.setTitle(getResources().getString(R.string.workshop_ad_submitted));
                        alertDialog.setMessage(response.body().getMessage());
                        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, getResources().getString(R.string.ok),
                                new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int which) {

                                        dialog.dismiss();

                                        Intent intent = new Intent(getActivity(), Home.class);
                                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                                        startActivity(intent);
                                        getActivity().finish();
                                    }
                                });
                        alertDialog.show();
                    }
                    else
                    {
                        Toast.makeText(getActivity(), response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(getActivity(), getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(getActivity() , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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