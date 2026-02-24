package com.thecontractor.Fragments;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;

import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.CategoriesAdapter;
import com.thecontractor.Adapter.CompaniesAdapter;
import com.thecontractor.Adapter.SubCategoriesAdapter;
import com.thecontractor.Adapter.TitaniumCompaniesAdapter;
import com.thecontractor.Adapter.TopCategoriesAdapter;
import com.thecontractor.ChangePassword;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.LocaleHelper;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Login;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.CategoriesModel;
import com.thecontractor.Model.CategoriesWithCompaniesModel;
import com.thecontractor.Model.CompaniesModel;
import com.thecontractor.Model.SubCategoriesModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.R;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;
import com.thecontractor.Search;
import com.thecontractor.Splash;

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


public class HomeFragment extends Fragment implements CategoriesAdapter.SubCategoriesInterface , SubCategoriesAdapter.SubCategoryIdInterface {

    String userId = "";

    LinearLayout homeLayout;
    LinearLayout search;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    TextView noData;

    RecyclerView topCategoriesRV;
    LinearLayoutManager topCategoriesLinearLayoutManager ;
    TopCategoriesAdapter topCategoriesAdapter;

    RecyclerView categoriesRV;
    LinearLayoutManager categoriesLinearLayoutManager ;
    CategoriesAdapter categoriesAdapter;

    ArrayList<CategoriesModel> list;


    RecyclerView rvSubCategories;
    GridLayoutManager subCategoriesLinearLayoutManager ;


    LinearLayout titaniumCompaniesLayout;
    RecyclerView titaniumCompaniesRV;
    LinearLayoutManager titaniumLinearLayoutManager ;
    ArrayList<CompaniesModel> titaniumCompaniesList;


    LinearLayout homeCompaniesLayout;
    RecyclerView homeCompaniesRV;
    LinearLayoutManager homeLinearLayoutManager ;
    ArrayList<CompaniesModel> homeCompaniesList;
    CompaniesAdapter homeCompaniesAdapter;


    String selectedLanguage = "en";

    public HomeFragment() {
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
        View view = inflater.inflate(R.layout.fragment_home, container, false);

        getDataFromSP();
        getLanguageFromSP();
        initiate(view);
        clickListener();
        categoriesAPI();

        return view;
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(getActivity()).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(getActivity()).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);
            userId = userModel.getId();

            Log.e("tag" , "user id is : "+userId);


        }
    }

    public void getLanguageFromSP() {
        if (!SharedPrefManager.getInstance(getActivity()).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(getActivity()).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }

    public void initiate(View view)
    {

        progressDialog = new ProgressDialog(getActivity());

        homeLayout = (LinearLayout) view.findViewById(R.id.homeLayout);
        homeLayout.setVisibility(View.GONE);

        search = (LinearLayout) view.findViewById(R.id.search);


        noData = (TextView) view.findViewById(R.id.noData);
        noData.setVisibility(View.GONE);

        list = new ArrayList<>();
        topCategoriesRV = (RecyclerView) view.findViewById(R.id.topCategoriesRV);
        topCategoriesLinearLayoutManager = new LinearLayoutManager(getActivity()  ,  LinearLayoutManager.HORIZONTAL , false);
        topCategoriesRV.setLayoutManager(topCategoriesLinearLayoutManager);
        topCategoriesAdapter = new TopCategoriesAdapter(getActivity() , list , selectedLanguage);
        topCategoriesRV.setAdapter(topCategoriesAdapter);

        categoriesRV = (RecyclerView) view.findViewById(R.id.categoriesRV);
        categoriesLinearLayoutManager = new LinearLayoutManager(getActivity()  ,  LinearLayoutManager.HORIZONTAL , false);
        categoriesRV.setLayoutManager(categoriesLinearLayoutManager);
        categoriesAdapter = new CategoriesAdapter(getActivity() , list , this , selectedLanguage);
        categoriesRV.setAdapter(categoriesAdapter);



        rvSubCategories = (RecyclerView) view.findViewById(R.id.rvSubCategories);
        subCategoriesLinearLayoutManager = new GridLayoutManager(getActivity() , 2 ,  GridLayoutManager.VERTICAL , false);
        rvSubCategories.setLayoutManager(subCategoriesLinearLayoutManager);



        titaniumCompaniesLayout = (LinearLayout) view.findViewById(R.id.titaniumCompaniesLayout);
        titaniumCompaniesLayout.setVisibility(View.GONE);
        titaniumCompaniesList = new ArrayList<>();
        titaniumCompaniesRV = (RecyclerView) view.findViewById(R.id.titaniumCompaniesRV);
        titaniumLinearLayoutManager = new LinearLayoutManager(getActivity()  ,  LinearLayoutManager.HORIZONTAL , false);
        titaniumCompaniesRV.setLayoutManager(titaniumLinearLayoutManager);


        homeCompaniesLayout = (LinearLayout) view.findViewById(R.id.homeCompaniesLayout);
        homeCompaniesLayout.setVisibility(View.GONE);
        homeCompaniesList = new ArrayList<>();
        homeCompaniesRV = (RecyclerView) view.findViewById(R.id.homeCompaniesRV);
        homeLinearLayoutManager = new LinearLayoutManager(getActivity()  ,  LinearLayoutManager.VERTICAL , false);
        homeCompaniesRV.setLayoutManager(homeLinearLayoutManager);


    }

    public void clickListener()
    {
        search.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity() , Search.class);
                startActivity(intent);
            }
        });
    }

    private void categoriesAPI() {

        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));


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
        call = retrofitApi.categoriesAPI(user_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        homeLayout.setVisibility(View.VISIBLE);

                        list = response.body().getCategories();
                        homeCompaniesList = response.body().getCompanies_list();
                        titaniumCompaniesList = response.body().getTitanium_companies();
                        SharedPrefManager.getInstance(getActivity()).cartLimit(response.body().getCart_limit() , response.body().getAvailable_cart_limit());

                        Log.e("tag" , "cart available limit is : "+response.body().getAvailable_cart_limit());
                        Log.e("tag" , "list size is : "+list.size());
                        Log.e("tag" , "company list size is : "+homeCompaniesList.size());
                        Log.e("tag" , "titanium company list size is : "+titaniumCompaniesList.size());

                        topCategoriesAdapter.setItems(list);
                        categoriesAdapter.setItems(list);

                        if(titaniumCompaniesList.size() > 0)
                        {
                            titaniumCompaniesLayout.setVisibility(View.VISIBLE);

                            TitaniumCompaniesAdapter titaniumCompaniesAdapter = new TitaniumCompaniesAdapter(getActivity() , titaniumCompaniesList);
                            titaniumCompaniesRV.setAdapter(titaniumCompaniesAdapter);
                        }else
                        {
                            titaniumCompaniesLayout.setVisibility(View.GONE);
                        }

                        if(homeCompaniesList.size() > 0)
                        {
                            homeCompaniesLayout.setVisibility(View.VISIBLE);

                            homeCompaniesAdapter = new CompaniesAdapter(getActivity() , homeCompaniesList , selectedLanguage);
                            homeCompaniesRV.setAdapter(homeCompaniesAdapter);
                        }else
                        {
                            homeCompaniesLayout.setVisibility(View.GONE);
                        }






                    }
                    else
                    {
                        noData.setVisibility(View.VISIBLE);
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
    public void onResume() {
        super.onResume();

        if(homeCompaniesAdapter != null)
        {
            homeCompaniesAdapter.notifyDataSetChanged();
        }


    }

    @Override
    public void selectedSubCategories(ArrayList<SubCategoriesModel> sub_categories, String categoryId) {

        SubCategoriesAdapter subCategoriesAdapter = new SubCategoriesAdapter(getActivity() , sub_categories , "true" , this , selectedLanguage);
        rvSubCategories.setAdapter(subCategoriesAdapter);
    }

    @Override
    public void selectedSubCategoryId(String id) {

    }
}