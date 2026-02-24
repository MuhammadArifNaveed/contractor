package com.thecontractor.Fragments;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.location.Address;
import android.location.Geocoder;
import android.os.Bundle;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.VendorFreelancerAddressAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.ImagePartFromUri;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Home;
import com.thecontractor.MapsActivity;
import com.thecontractor.Model.AddFreelancerViewModel;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.FreelancerAddressModel;
import com.thecontractor.Model.FreelancerListModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Model.VendorSharedPrefModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.VendorActivities.VendorAddFreelancer;
import com.thecontractor.VendorActivities.VendorHiredFreelancersSummary;
import com.thecontractor.VendorActivities.VendorHome;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
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

public class FreelancerAddressFragment extends Fragment implements VendorFreelancerAddressAdapter.FreelancerAddressInterface {
    FreelancerListModel freelancerListModel;
    String from;
    String type;
    LinearLayout addAddressLayout;
    private EditText addressET , mapAddressET;
    String addressETStr , mapAddressETStr;
    Button btnBack , btnSubmit , addAddress;
    double lat = 0.0;
    double lng = 0.0;
    AddFreelancerViewModel addFreelancerViewModel;
    RecyclerView freeLancerAddressRV;
    LinearLayoutManager linearLayoutManager ;
    ArrayList<FreelancerAddressModel> list;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    MultipartBody.Part imagePart;
    MultipartBody.Part videoPart;
    String selectedLanguage = "en";
    String vendorId;
    String userId;
    String userType;
    String freelancerId = "";
    String currentAddress = "";
    EditText mapAddressETDialog;
    VendorFreelancerAddressAdapter vendorFreelancerAddressAdapter;
    public FreelancerAddressFragment() {
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
        View view = inflater.inflate(R.layout.fragment_freelancer_address, container, false);

        getObjectFromAdapter();
        getLanguageFromSP();

        if(from.equals("user")){
            getUserDataFromSP();
        }else if(from.equals("vendor")){
            getVendorDataFromSP();
        }

        initiate(view);

        assert type != null;
        if(type.equals("update")){
            addAddress.setVisibility(VISIBLE);
            addAddressLayout.setVisibility(GONE);
            setDataToWidget();
        }

        clickListener();
        return view;
    }

    public void getObjectFromAdapter() {
        Intent intent = requireActivity().getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {

            from = (String) bundle.get("from");
            type = (String) bundle.get("type");

            Log.e("tag" , "from is :"+from);
            Log.e("tag" , "type is :"+type);

            assert type != null;
            if(type.equals("update")){
                freelancerListModel = (FreelancerListModel) bundle.get("freelancerListModel");
                freelancerId = freelancerListModel.getId();

                Log.e("tag" , "freelancerId is : "+freelancerId);
            }

        }
    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(getActivity()).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(getActivity()).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }

    public void getUserDataFromSP() {
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

    public void getVendorDataFromSP() {
        if (!SharedPrefManager.getInstance(getActivity()).getVendorObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(getActivity()).getVendorObject();
            VendorSharedPrefModel vendorModel = gson.fromJson(json, VendorSharedPrefModel.class);

            vendorId = vendorModel.getId();
            userId = vendorModel.getUser_id();
            userType = vendorModel.getUser_type();


            Log.e("tag" , "Vendor id is : "+vendorId);
            Log.e("tag" , "user id is : "+userId);
            Log.e("tag" , "user type is : "+userType);


        }
    }


    public void initiate(View view){
        addFreelancerViewModel = new ViewModelProvider(requireActivity()).get(AddFreelancerViewModel.class);

        progressDialog = new ProgressDialog(getActivity());

        addAddressLayout = view.findViewById(R.id.addAddressLayout);
        addressET = view.findViewById(R.id.addressET);
        mapAddressET = view.findViewById(R.id.mapAddressET);

        list = new ArrayList<>();
        freeLancerAddressRV = (RecyclerView) view.findViewById(R.id.freeLancerAddressRV);
        freeLancerAddressRV.setVisibility(GONE);
        linearLayoutManager = new LinearLayoutManager(getActivity()  ,  LinearLayoutManager.VERTICAL , false);
        freeLancerAddressRV.setLayoutManager(linearLayoutManager);

        addAddress = view.findViewById(R.id.addAddress);
        addAddress.setVisibility(GONE);
        btnBack = view.findViewById(R.id.btnBack);
        btnSubmit = view.findViewById(R.id.btnSubmit);

    }

    public void setDataToWidget() {
        if (freelancerListModel != null) {
            list = freelancerListModel.getAddresses();
            if(list.size() > 0){
                vendorFreelancerAddressAdapter = new VendorFreelancerAddressAdapter(getActivity() , list , selectedLanguage , this);
                freeLancerAddressRV.setAdapter(vendorFreelancerAddressAdapter);
                freeLancerAddressRV.setVisibility(VISIBLE);
            }

        }
    }

    public void clickListener(){

        mapAddressET.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity() , MapsActivity.class);
                mapResultLauncher.launch(intent);
            }
        });

        btnBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ((VendorAddFreelancer) requireActivity()).previousPage();
            }
        });

        addAddress.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                addAddressDialog();
            }
        });

        btnSubmit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                addressETStr = addressET.getText().toString();
                mapAddressETStr = mapAddressET.getText().toString();

                if(addressETStr.isEmpty() && type.equals("add")){
                    Toast.makeText(getActivity(), "Please enter address", Toast.LENGTH_SHORT).show();
                }if(mapAddressETStr.isEmpty() && type.equals("add")){
                    Toast.makeText(getActivity(), "Please select address from map", Toast.LENGTH_SHORT).show();
                }else {
                    addFreelancer();
                }
            }
        });
    }

    public void addAddressDialog() {
        Dialog dialog = new Dialog(getActivity());
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.freelancer_add_address_dialog);
        Window window = dialog.getWindow();
        window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        dialog.setCancelable(true);
        dialog.show();

        EditText addressETDialog = dialog.findViewById(R.id.addressET);
        mapAddressETDialog = dialog.findViewById(R.id.mapAddressET);
        CheckBox cbCurrent = dialog.findViewById(R.id.cbCurrent);
        Button saveAddressBtn = dialog.findViewById(R.id.saveAddressBtn);

        mapAddressETDialog.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity() , MapsActivity.class);
                mapResultLauncher1.launch(intent);
            }
        });




        saveAddressBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String addressStr = addressETDialog.getText().toString();
                String mapAddressStr = mapAddressETDialog.getText().toString();

                if (addressStr.isEmpty()) {
                    Toast.makeText(getActivity(), "Please enter address", Toast.LENGTH_SHORT).show();
                }
                if (mapAddressStr.isEmpty()) {
                    Toast.makeText(getActivity(), "Please select address from map", Toast.LENGTH_SHORT).show();
                } else {

                    String currentAddress;

                    if(cbCurrent.isChecked()){
                        currentAddress = "1";
                    }else {
                        currentAddress = "0";
                    }

                    dialog.dismiss();
                    addAddressFreelancer(addressStr , mapAddressStr , currentAddress);

                }
            }
        });
    }



    ActivityResultLauncher<Intent> mapResultLauncher = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(),
            new ActivityResultCallback<ActivityResult>() {
                @Override
                public void onActivityResult(ActivityResult result) {
                    if (result.getResultCode() == Activity.RESULT_OK) {
                        // There are no request codes
                        Intent data = result.getData();

                        lat = data.getDoubleExtra("lat"  , 0.0);
                        lng = data.getDoubleExtra("lng" , 0.0);

                        Log.e("tag" , "lat lng in onActivityResult : "+ lat  +"  "+ lng);

                        mapAddressET.setText(getAddressFromLatLng(lat , lng));



                    }
                }
            });


    ActivityResultLauncher<Intent> mapResultLauncher1 = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(),
            new ActivityResultCallback<ActivityResult>() {
                @Override
                public void onActivityResult(ActivityResult result) {
                    if (result.getResultCode() == Activity.RESULT_OK) {
                        // There are no request codes
                        Intent data = result.getData();

                        lat = data.getDoubleExtra("lat"  , 0.0);
                        lng = data.getDoubleExtra("lng" , 0.0);

                        Log.e("tag" , "lat lng in onActivityResult : "+ lat  +"  "+ lng);

                        mapAddressETDialog.setText(getAddressFromLatLng(lat , lng));



                    }
                }
            });

    private String getAddressFromLatLng(double LATITUDE, double LONGITUDE) {
        String address = "";
        Geocoder geocoder = new Geocoder(getActivity(), Locale.getDefault());
        try {
            List<Address> addressList = geocoder.getFromLocation(LATITUDE, LONGITUDE, 1);
            if (addressList != null) {
                Address returnedAddress = addressList.get(0);
                Log.e("tag", "My Current address returnedAddress : " + returnedAddress);

                address = addressList.get(0).getAddressLine(0);


                Log.e("tag", "My Complete address is : " + address);

            } else {
                address = "unknown address";
                Log.e("tag", "My Current address No Address returned!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            address = "unknown address";
            Log.e("tag", "My Current address Cannnot get Address!");
        }
        return address;
    }



    private void addAddressFreelancer(String addressStr, String mapAddressStr, String current) {



        RequestBody address = RequestBody.create(addressStr , MediaType.parse("text/plain"));
        RequestBody pick_up_address = RequestBody.create(mapAddressStr , MediaType.parse("text/plain"));
        RequestBody pick_up_latitude = RequestBody.create(String.valueOf(lat), MediaType.parse("text/plain"));
        RequestBody pick_up_longitude = RequestBody.create(String.valueOf(lng), MediaType.parse("text/plain"));
        RequestBody currentAddress = RequestBody.create(current , MediaType.parse("text/plain"));
        RequestBody mFreelancerId = RequestBody.create(freelancerId , MediaType.parse("text/plain"));



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
        call = retrofitApi.addAddressFreelancer(address , pick_up_address , pick_up_latitude , pick_up_longitude , currentAddress , mFreelancerId);


        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        Toast.makeText(getActivity(), response.body().getMessage(), Toast.LENGTH_SHORT).show();
                        getAddressFreelancer();
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

    private void getAddressFreelancer() {

        RequestBody mFreelancerId = RequestBody.create(freelancerId , MediaType.parse("text/plain"));



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
        call = retrofitApi.getAddressFreelancer(mFreelancerId);


        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        //Toast.makeText(getActivity(), response.body().getMessage(), Toast.LENGTH_SHORT).show();
                        list = response.body().getAddresses();
                        if(list.size() > 0){
                            vendorFreelancerAddressAdapter = new VendorFreelancerAddressAdapter(getActivity() , list , selectedLanguage , FreelancerAddressFragment.this);
                            freeLancerAddressRV.setAdapter(vendorFreelancerAddressAdapter);
                        }
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


    private void deleteAddressFreelancer(int pos, String id) {

        RequestBody addressId = RequestBody.create(id , MediaType.parse("text/plain"));



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
        call = retrofitApi.deleteAddressFreelancer(addressId);


        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        //Toast.makeText(getActivity(), response.body().getMessage(), Toast.LENGTH_SHORT).show();
                        list.remove(pos);
                        if(vendorFreelancerAddressAdapter != null){
                            vendorFreelancerAddressAdapter.notifyDataSetChanged();
                        }
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



    private void addFreelancer() {


        File imageFile;
        if(addFreelancerViewModel.getImage() != null)
        {
            imageFile = ImagePartFromUri.getFileFromUri(getActivity(), addFreelancerViewModel.getImage() , "image");

            if (imageFile != null && imageFile.exists()) {
                Log.e("tag", "Uploading image # : " + imageFile.getAbsolutePath());
                RequestBody requestBody = RequestBody.create(imageFile, MediaType.parse("image/*"));
                imagePart = MultipartBody.Part.createFormData("image", imageFile.getName(), requestBody);

            }else {
                Log.e("tag", "Failed to resolve file for image #");
            }
        }else {
            imageFile = null;
        }


        File videoFileFile = null;
//        if(addFreelancerViewModel.getVideo() != null)
//        {
//            videoFileFile = ImagePartFromUri.getFileFromUri(getActivity(), addFreelancerViewModel.getVideo() , "video");
//
//            if (videoFileFile != null && videoFileFile.exists()) {
//                Log.e("tag", "Uploading video # : " + videoFileFile.getAbsolutePath());
//                RequestBody requestBody = RequestBody.create(videoFileFile, MediaType.parse("video/*"));
//                videoPart = MultipartBody.Part.createFormData("video", videoFileFile.getName(), requestBody);
//
//            }else {
//                Log.e("tag", "Failed to resolve file for image #");
//            }
//        }else {
//            videoFileFile = null;
//        }

        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));
        RequestBody user_type = RequestBody.create(userType , MediaType.parse("text/plain"));
        RequestBody vendor_id = RequestBody.create(vendorId , MediaType.parse("text/plain"));
        RequestBody name = RequestBody.create(addFreelancerViewModel.getName() , MediaType.parse("text/plain"));
        RequestBody email = RequestBody.create(addFreelancerViewModel.getEmail() , MediaType.parse("text/plain"));
        RequestBody phone = RequestBody.create(addFreelancerViewModel.getPhone() , MediaType.parse("text/plain"));
        RequestBody rate = RequestBody.create(addFreelancerViewModel.getHourlyRate() , MediaType.parse("text/plain"));
        RequestBody freelancer_skills = RequestBody.create(addFreelancerViewModel.getSkills() , MediaType.parse("text/plain"));
        RequestBody category_id = RequestBody.create(addFreelancerViewModel.getCategory() , MediaType.parse("text/plain"));
        RequestBody city_id = RequestBody.create(addFreelancerViewModel.getCity() , MediaType.parse("text/plain"));
        RequestBody area_id = RequestBody.create(addFreelancerViewModel.getArea() , MediaType.parse("text/plain"));
        RequestBody available_per_hour = RequestBody.create(addFreelancerViewModel.getPerHour() , MediaType.parse("text/plain"));
        RequestBody from_time = RequestBody.create(addFreelancerViewModel.getFromTime() , MediaType.parse("text/plain"));
        RequestBody to_time = RequestBody.create(addFreelancerViewModel.getToTime() , MediaType.parse("text/plain"));
        RequestBody bank_name = RequestBody.create(addFreelancerViewModel.getBankName() , MediaType.parse("text/plain"));
        RequestBody bank_address = RequestBody.create(addFreelancerViewModel.getBankAddress() , MediaType.parse("text/plain"));
        RequestBody account_title = RequestBody.create(addFreelancerViewModel.getAccountName() , MediaType.parse("text/plain"));
        RequestBody iban = RequestBody.create(addFreelancerViewModel.getAccountIBAN() , MediaType.parse("text/plain"));
        RequestBody address = RequestBody.create(addressETStr , MediaType.parse("text/plain"));
        RequestBody pick_up_address = RequestBody.create(mapAddressETStr , MediaType.parse("text/plain"));
        RequestBody pick_up_latitude = RequestBody.create(String.valueOf(lat), MediaType.parse("text/plain"));
        RequestBody pick_up_longitude = RequestBody.create(String.valueOf(lng), MediaType.parse("text/plain"));
        RequestBody currentAddressId = RequestBody.create(currentAddress , MediaType.parse("text/plain"));
        RequestBody mFreelancerId = RequestBody.create(freelancerId , MediaType.parse("text/plain"));



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
        if(type.equals("update")){
            call = retrofitApi.vendorUpdateFreelancer(name , email , phone , rate , freelancer_skills , category_id , city_id  , area_id ,
                    available_per_hour, from_time , to_time , bank_name , bank_address , account_title , iban , currentAddressId , mFreelancerId ,
                    user_type , imagePart , videoPart);
        }else{
            call = retrofitApi.vendorAddFreelancer(name , email , phone , rate , freelancer_skills , category_id , city_id  , area_id ,
                    available_per_hour, from_time , to_time , bank_name , bank_address , account_title , iban , address , pick_up_address ,
                    pick_up_latitude , pick_up_longitude , user_id , user_type , vendor_id ,imagePart , videoPart);
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

                        if(from.equals("user")){
                            Toast.makeText(getActivity(), response.body().getMessage(), Toast.LENGTH_SHORT).show();
                            Intent intent = new Intent(getActivity(), Home.class);
                            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                            startActivity(intent);
                            getActivity().finish();
                        }else if(from.equals("vendor")){
                            Toast.makeText(getActivity(), response.body().getMessage(), Toast.LENGTH_SHORT).show();
                            Intent intent = new Intent(getActivity(), VendorHome.class);
                            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                            startActivity(intent);
                            getActivity().finish();
                        }



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
    public void selectedCurrentAddress(int pos, String id) {
        currentAddress = id;
        Log.e("tag" , "current address id is : "+id);
    }

    @Override
    public void selectedDeleteAddress(int pos, String id) {
        Log.e("tag" , "address id is : "+id);
        AlertDialog alertDialog = AlertDialog(pos , id);
        alertDialog.show();

    }


    private AlertDialog AlertDialog(int pos , String id)
    {
        AlertDialog myDialogBox = new AlertDialog.Builder(getActivity())
                // set message, title, and icon
                .setTitle("Delete")
                .setMessage("Are you sure want to delete address?")

                .setPositiveButton("Yes", new DialogInterface.OnClickListener() {

                    public void onClick(DialogInterface dialog, int whichButton) {
                        //your deleting code
                        dialog.dismiss();


                        deleteAddressFreelancer(pos , id);

                    }

                })
                .setNegativeButton("No", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {

                        dialog.dismiss();

                    }
                })
                .create();

        return myDialogBox;
    }
}