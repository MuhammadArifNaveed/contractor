package com.thecontractor.Fragments;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.EstimationCategoriesAdapter;
import com.thecontractor.Adapter.EstimationSubCategoriesAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Home;
import com.thecontractor.Login;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.EstimationCategoriesModel;
import com.thecontractor.Model.EstimationSubCategoriesModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.Search;
import com.thecontractor.SelectLanguage;

import java.util.ArrayList;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;


public class EstimationFragment extends Fragment implements EstimationCategoriesAdapter.EstimationSubCategoriesInterface , EstimationSubCategoriesAdapter.EstimationSubCategoryIdInterface{

    LinearLayout requestForEstimationLayout;
    LinearLayout estimationCategoriesLayout;
    LinearLayout estimationResultLayout;
    LinearLayout estimationContactLayout;
    Button freeConsultationBtn;
    TextView estimateAgain;

    RecyclerView estimationCategoriesRV;
    LinearLayoutManager estimationCategoriesLinearLayoutManager ;
    EstimationCategoriesAdapter estimationCategoriesAdapter;
    RecyclerView estimationSubCategoriesRV;
    GridLayoutManager estimationSubCategoriesLinearLayoutManager ;

    String estimationCategoryId = "0";
    String estimationCategoryName;
    String estimationSubCategoryId = "0";
    String estimationSubCategoryName;
    String estimationSubCategoryValue;

    TextView lookingFor , estimationCategory , totalSqft , estimatedBudget;


    EditText squareFeet , fistNameET    , mobileET , emailET , noteET;
    String squareFeetStr , fistNameETStr , lastNameETStr   , mobileETStr , emailETStr  , noteETStr;

    String userId;
    Button updateProfileBtn;
    Button calculateEstimatedBtn;
    ArrayList<EstimationCategoriesModel> estimationCategoriesList;
    ArrayList<EstimationSubCategoriesModel> estimationSubCategoriesList;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    String selectedLanguage = "en";




    public EstimationFragment() {
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
        View view =  inflater.inflate(R.layout.fragment_estimation, container, false);


        getLanguageFromSP();
        initiate(view);
        getDataFromSP();
        clickListener();
        estimationCategoriesAPI();

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

            Log.e("tag" , "user id is in estimation fragment : "+userId);

            fistNameETStr = userModel.getName();
            lastNameETStr = userModel.getSurname();
            mobileETStr = userModel.getPhone();
            emailETStr = userModel.getEmail();


            fistNameET.setText(fistNameETStr + " " + lastNameETStr);
            emailET.setText(emailETStr);
            mobileET.setText(mobileETStr);



        }
    }



    public void initiate(View view)
    {

        progressDialog = new ProgressDialog(getActivity());

        estimationCategoriesList = new ArrayList<>();
        estimationSubCategoriesList = new ArrayList<>();


        estimationCategoriesRV = (RecyclerView) view.findViewById(R.id.estimationCategoriesRV);
        estimationCategoriesLinearLayoutManager = new LinearLayoutManager(getActivity()  ,  LinearLayoutManager.HORIZONTAL , false);
        estimationCategoriesRV.setLayoutManager(estimationCategoriesLinearLayoutManager);
        estimationCategoriesAdapter = new EstimationCategoriesAdapter(getActivity() , estimationCategoriesList , this , selectedLanguage);
        estimationCategoriesRV.setAdapter(estimationCategoriesAdapter);


        estimationSubCategoriesRV = (RecyclerView) view.findViewById(R.id.estimationSubCategoriesRV);
        estimationSubCategoriesLinearLayoutManager = new GridLayoutManager(getActivity() , 2 ,  GridLayoutManager.VERTICAL , false);
        estimationSubCategoriesRV.setLayoutManager(estimationSubCategoriesLinearLayoutManager);



        requestForEstimationLayout = (LinearLayout) view.findViewById(R.id.requestForEstimationLayout);
        requestForEstimationLayout.setVisibility(View.GONE);
        estimationCategoriesLayout = (LinearLayout) view.findViewById(R.id.estimationCategoriesLayout);
        estimationResultLayout = (LinearLayout) view.findViewById(R.id.estimationResultLayout);
        estimationResultLayout.setVisibility(View.GONE);
        estimationContactLayout = (LinearLayout) view.findViewById(R.id.estimationContactLayout);
        estimationContactLayout.setVisibility(View.GONE);
        freeConsultationBtn = (Button) view.findViewById(R.id.freeConsultationBtn);
        freeConsultationBtn.setVisibility(View.GONE);
        estimateAgain = (TextView) view.findViewById(R.id.estimateAgain);




        lookingFor = (TextView) view.findViewById(R.id.lookingFor);
        estimationCategory = (TextView) view.findViewById(R.id.estimationCategory);
        totalSqft = (TextView) view.findViewById(R.id.totalSqft);
        estimatedBudget = (TextView) view.findViewById(R.id.estimatedBudget);


        squareFeet = (EditText) view.findViewById(R.id.squareFeet);
        fistNameET = (EditText) view.findViewById(R.id.fistNameET);
        mobileET = (EditText) view.findViewById(R.id.mobileET);
        emailET = (EditText) view.findViewById(R.id.emailET);
        noteET = (EditText) view.findViewById(R.id.noteET);
        updateProfileBtn = (Button) view.findViewById(R.id.updateProfileBtn);
        calculateEstimatedBtn = (Button) view.findViewById(R.id.calculateEstimatedBtn);



    }

    public void clickListener()
    {
        estimateAgain.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                estimationCategoriesLayout.setVisibility(View.VISIBLE);
                estimationResultLayout.setVisibility(View.GONE);
                freeConsultationBtn.setVisibility(View.GONE);
                estimationContactLayout.setVisibility(View.GONE);
            }
        });

        freeConsultationBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (!SharedPrefManager.getInstance(getActivity()).getUserObject().equals("")) {
                    estimationCategoriesLayout.setVisibility(View.GONE);
                    freeConsultationBtn.setVisibility(View.GONE);
                    estimationContactLayout.setVisibility(View.VISIBLE);
                } else{
                    Intent intent =  new Intent(getActivity() , Login.class);
                    intent.putExtra("requestForLogin" , "yes");
                    someActivityResultLauncher.launch(intent);
                }


            }
        });

        calculateEstimatedBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                squareFeetStr = squareFeet.getText().toString();

                if(estimationCategoryId.equals("0"))
                {
                    Toast.makeText(getActivity(), getResources().getString(R.string.looking_for_error), Toast.LENGTH_SHORT).show();
                }else if(estimationSubCategoryId.equals("0"))
                {
                    Toast.makeText(getActivity(),  getResources().getString(R.string.select_category), Toast.LENGTH_SHORT).show();
                }else if(squareFeetStr.equals(""))
                {
                    Toast.makeText(getActivity(), getResources().getString(R.string.squre_feed_error), Toast.LENGTH_SHORT).show();
                }
                else
                {
                    calculateEstimatedBudget(squareFeetStr);
                }
            }
        });


        updateProfileBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                fistNameETStr = fistNameET.getText().toString();
                mobileETStr = mobileET.getText().toString();
                emailETStr = emailET.getText().toString();
                noteETStr = noteET.getText().toString();

                if(fistNameETStr.equals(""))
                {
                    Toast.makeText(getActivity(), getResources().getString(R.string.full_name_error), Toast.LENGTH_SHORT).show();
                }else if(mobileETStr.equals(""))
                {
                    Toast.makeText(getActivity(), getResources().getString(R.string.phone_no_error), Toast.LENGTH_SHORT).show();
                } else if(emailETStr.equals(""))
                {
                    Toast.makeText(getActivity(), getResources().getString(R.string.enter_email_address_error), Toast.LENGTH_SHORT).show();
                }else if(!isValidEmail(emailETStr))
                {
                    Toast.makeText(getActivity(), getResources().getString(R.string.enter_valid_email_address), Toast.LENGTH_SHORT).show();
                }else
                {
                    requestEstimation();
                }


            }
        });
    }

    ActivityResultLauncher<Intent> someActivityResultLauncher = registerForActivityResult(
    new ActivityResultContracts.StartActivityForResult(),
    new ActivityResultCallback<ActivityResult>() {
        @Override
        public void onActivityResult(ActivityResult result) {
            if (result.getResultCode() == Activity.RESULT_OK) {

                Intent data = result.getData();

                Log.e("tag" , "result back");

                getDataFromSP();
            }
        }
    });

    public void calculateEstimatedBudget(String squareFeetStr)
    {
        estimationResultLayout.setVisibility(View.VISIBLE);
        freeConsultationBtn.setVisibility(View.VISIBLE);

        lookingFor.setText(estimationCategoryName);
        estimationCategory.setText(estimationSubCategoryName);
        totalSqft.setText(squareFeetStr + " " + getResources().getString(R.string.sqft));
        estimatedBudget.setText(Integer.parseInt(squareFeetStr) * Integer.parseInt(estimationSubCategoryValue) + " " + getResources().getString(R.string.currency));
    }


    public static boolean isValidEmail(final String emailAddress) {

        Pattern pattern;
        Matcher matcher;

        final String EMAIL_PATTERN = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@" + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";

        pattern = Pattern.compile(EMAIL_PATTERN);
        matcher = pattern.matcher(emailAddress);
        return matcher.matches();
    }


    private void estimationCategoriesAPI() {

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
        call = retrofitApi.estimationCategoriesAPI();

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        requestForEstimationLayout.setVisibility(View.VISIBLE);

                        estimationCategoriesList = response.body().getEstimation_categories();

                        Log.e("tag" , "estimation categories list size is : "+estimationCategoriesList.size());

                        estimationCategoriesAdapter.setItems(estimationCategoriesList);


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



    private void requestEstimation() {





        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));
        RequestBody fullName = RequestBody.create(fistNameETStr , MediaType.parse("text/plain"));
        RequestBody phone = RequestBody.create(mobileETStr , MediaType.parse("text/plain"));
        RequestBody email = RequestBody.create(emailETStr , MediaType.parse("text/plain"));
        RequestBody note = RequestBody.create(noteETStr , MediaType.parse("text/plain"));
        RequestBody sqft = RequestBody.create(squareFeetStr , MediaType.parse("text/plain"));
        RequestBody category_id = RequestBody.create(estimationCategoryId , MediaType.parse("text/plain"));
        RequestBody sub_category_id = RequestBody.create(estimationSubCategoryId , MediaType.parse("text/plain"));

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
        call = retrofitApi.requestEstimation(user_id , fullName  , phone , email  , note ,sqft ,  category_id , sub_category_id);

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
                        alertDialog.setTitle(getString(R.string.estimation_submitted));
                        alertDialog.setMessage(response.body().getMessage());
                        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, getResources().getString(R.string.ok),
                                new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int which) {

                                        dialog.dismiss();


                                        Intent intent = new Intent(getActivity(), Home.class);
                                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                                        startActivity(intent);
                                        getActivity().finish();

//                                        estimationCategoriesLayout.setVisibility(View.VISIBLE);
//                                        estimationResultLayout.setVisibility(View.GONE);
//                                        freeConsultationBtn.setVisibility(View.GONE);
//                                        estimationContactLayout.setVisibility(View.GONE);
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
    public void selectedEstimationSubCategories(ArrayList<EstimationSubCategoriesModel> sub_categories, String categoryId, String categoryName) {
        this.estimationSubCategoryId = "0";
        this.estimationCategoryId = categoryId;
        this.estimationCategoryName = categoryName;
        EstimationSubCategoriesAdapter estimationSubCategoriesAdapter = new EstimationSubCategoriesAdapter(getActivity() , sub_categories , this , selectedLanguage);
        estimationSubCategoriesRV.setAdapter(estimationSubCategoriesAdapter);
    }

    @Override
    public void selectedEstimationSubCategoryId(String id, String name, String value) {
        this.estimationSubCategoryId = id;
        this.estimationSubCategoryName = name;
        this.estimationSubCategoryValue = value;
    }
}