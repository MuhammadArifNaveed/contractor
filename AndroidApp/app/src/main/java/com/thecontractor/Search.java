package com.thecontractor;

import static android.view.View.GONE;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.AreasAdapter;
import com.thecontractor.Adapter.CategoriesAdapter;
import com.thecontractor.Adapter.CitiesAdapter;
import com.thecontractor.Adapter.SubCategoriesAdapter;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.MultiSelectAutoCompleteView;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.AreaModel;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.CategoriesModel;
import com.thecontractor.Model.CitiesModel;
import com.thecontractor.Model.IdModel;
import com.thecontractor.Global.MultiSelectAutoCompleteViewNew;
import com.thecontractor.Model.SpecialityModel;
import com.thecontractor.Model.SubCategoriesModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.util.ArrayList;
import java.util.concurrent.TimeUnit;
import okhttp3.OkHttpClient;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class Search extends AppCompatActivity implements CategoriesAdapter.SubCategoriesInterface , CitiesAdapter.AreasInterface , SubCategoriesAdapter.SubCategoryIdInterface , AreasAdapter.AreaIdInterface {

    MultiSelectAutoCompleteViewNew<SpecialityModel> multiSelectAutoCompleteView;
    RecyclerView categoriesRV;
    LinearLayoutManager categoriesLinearLayoutManager ;


    RecyclerView rvSubCategories;
    GridLayoutManager subCategoriesLinearLayoutManager ;

    RecyclerView citiesRV;
    LinearLayoutManager citiesLinearLayoutManager ;


    RecyclerView rvAreas;
    GridLayoutManager areasLinearLayoutManager ;
    Spinner areaSpinner;


    CheckBox showVerifiedCB;

    String categoryId = "0";
    String subCategoryId = "";
    String cityId = "";
    String areaId = "";
    EditText keywordET;
    String keyword;
    Button searchBtn;
    LinearLayout searchDataLayout;
    ArrayList<CategoriesModel> categoriesList;
    ArrayList<SubCategoriesModel> subCategoriesList;
    ArrayList<CitiesModel> citiesList;
    ArrayList<AreaModel> areasList;

    ArrayList<SpecialityModel> specialityList;

    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    String userId;
    String verified = "0";
    String selectedLanguage = "en";
    LinearLayout areaLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_search);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.search));

        getLanguageFromSP();
        getDataFromSP();
        initiate();
        clickListener();
        searchDataAPI();
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
        if (!SharedPrefManager.getInstance(Search.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(Search.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }


    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(Search.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(Search.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();

            Log.e("tag" , "user id is : "+userId);



        }
    }



    public void initiate()
    {

        progressDialog = new ProgressDialog(Search.this);

        categoriesList = new ArrayList<>();
        subCategoriesList = new ArrayList<>();
        citiesList = new ArrayList<>();
        areasList = new ArrayList<>();
        specialityList = new ArrayList<>();

        multiSelectAutoCompleteView = findViewById(R.id.multiSelectAutoCompleteView);
        multiSelectAutoCompleteView.setHint("Select Specialties");
        multiSelectAutoCompleteView.setInputType(InputType.TYPE_CLASS_TEXT);
        multiSelectAutoCompleteView.setMaxLength(0);

        categoriesRV = (RecyclerView) findViewById(R.id.categoriesRV);
        categoriesLinearLayoutManager = new LinearLayoutManager(Search.this  ,  LinearLayoutManager.HORIZONTAL , false);
        categoriesRV.setLayoutManager(categoriesLinearLayoutManager);


        rvSubCategories = (RecyclerView) findViewById(R.id.rvSubCategories);
        subCategoriesLinearLayoutManager = new GridLayoutManager(Search.this , 2 ,  GridLayoutManager.VERTICAL , false);
        rvSubCategories.setLayoutManager(subCategoriesLinearLayoutManager);


        citiesRV = (RecyclerView) findViewById(R.id.citiesRV);
        citiesLinearLayoutManager = new LinearLayoutManager(Search.this  ,  LinearLayoutManager.HORIZONTAL , false);
        citiesRV.setLayoutManager(citiesLinearLayoutManager);


        rvAreas = (RecyclerView) findViewById(R.id.rvAreas);
        areasLinearLayoutManager = new GridLayoutManager(Search.this , 2 ,  GridLayoutManager.VERTICAL , false);
        rvAreas.setLayoutManager(areasLinearLayoutManager);
        areaSpinner = (Spinner) findViewById(R.id.areaSpinner);

        showVerifiedCB = (CheckBox) findViewById(R.id.showVerifiedCB);

        keywordET = (EditText) findViewById(R.id.keywordET);
        keywordET.setVisibility(GONE);

        searchBtn = (Button) findViewById(R.id.searchBtn);
        searchDataLayout = (LinearLayout) findViewById(R.id.searchDataLayout);
        searchDataLayout.setVisibility(GONE);
        areaLayout = (LinearLayout) findViewById(R.id.areaLayout);
        areaLayout.setVisibility(GONE);



    }

    public void clickListener()
    {



        searchBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                keyword = keywordET.getText().toString();

                String specialities = new Gson().toJson(multiSelectAutoCompleteView.getSelectedItems(IdModel::new));

//                if(specialities.equals("[]"))
//                {
//                    Toast.makeText(Search.this, getResources().getString(R.string.select_specialities), Toast.LENGTH_SHORT).show();
//                }
                if(categoryId.equals("0"))
                {
                    Toast.makeText(Search.this, getResources().getString(R.string.select_category), Toast.LENGTH_SHORT).show();
                }
//                else if(subCategoryId.equals("all"))
//                {
//                    Toast.makeText(Search.this, getResources().getString(R.string.select_sub_category), Toast.LENGTH_SHORT).show();
//                }
//                else if(cityId.equals(""))
//                {
//                    Toast.makeText(Search.this, getResources().getString(R.string.select_city), Toast.LENGTH_SHORT).show();
//                }
//                else if(areaId.equals("0"))
//                {
//                    Toast.makeText(Search.this, getResources().getString(R.string.select_area), Toast.LENGTH_SHORT).show();
//                }
//                else if(keyword.equals(""))
//                {
//                    Toast.makeText(Search.this, getResources().getString(R.string.enter_keyword_error), Toast.LENGTH_SHORT).show();
//                }
                else
                {

                    if(showVerifiedCB.isChecked())
                    {
                        verified = "1";
                    }else
                    {
                        verified = "0";
                    }





                    Log.e("tag" , "selected specialities is : "+ specialities + " category id is : "+categoryId + " sub category id is : "+subCategoryId + " city id is : "+cityId + " area id is : "+areaId + " verified is : "+verified+ " keyword is : "+keyword);

                    Intent intent = new Intent(Search.this , SearchResult.class);
                    intent.putExtra("specialities" , specialities);
                    intent.putExtra("categoryId" , categoryId);
                    intent.putExtra("subCategoryId" , subCategoryId);
                    intent.putExtra("cityId" , cityId);
                    intent.putExtra("areaId" , areaId);
                    intent.putExtra("verified" , verified);
                    intent.putExtra("keyword" , keyword);
                    startActivity(intent);

                }


            }
        });
    }



    private void searchDataAPI() {

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
        call = retrofitApi.searchDataAPI();

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        searchDataLayout.setVisibility(View.VISIBLE);


                        specialityList = response.body().getSpecialities();

                        Log.e("tag" , "speciality list size is : "+specialityList.size());

                        multiSelectAutoCompleteView.setItems(specialityList , SpecialityModel::getSpeciality_title , SpecialityModel::getId);


                        categoriesList = response.body().getCategories();

                        Log.e("tag" , "categories list size is : "+categoriesList.size());

                        CategoriesAdapter categoriesAdapter = new CategoriesAdapter(Search.this , categoriesList , Search.this , selectedLanguage);
                        categoriesRV.setAdapter(categoriesAdapter);

                        citiesList = response.body().getCities();

                        Log.e("tag" , "cities list size is : "+citiesList.size());


                        CitiesAdapter citiesAdapter = new CitiesAdapter(Search.this , citiesList , Search.this , selectedLanguage);
                        citiesRV.setAdapter(citiesAdapter);





                    }
                    else
                    {
                        Toast.makeText(Search.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(Search.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(Search.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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
        this.subCategoryId = "";
        this.categoryId = categoryId;

        SubCategoriesAdapter subCategoriesAdapter = new SubCategoriesAdapter(Search.this , sub_categories , "false" , this , selectedLanguage);
        rvSubCategories.setAdapter(subCategoriesAdapter);
    }

    @Override
    public void selectedAreas(ArrayList<AreaModel> areas, String cityId) {
        this.areaId = "";
        this.cityId = cityId;

//        areaLayout.setVisibility(View.VISIBLE);
//
//        ArrayList<AreaModel> newAreas = new ArrayList<>();
//        newAreas.add(new AreaModel("0" , "Select Area" , "حدد المنطقة"));
//        newAreas.addAll(areas);
//
//
//        AreaSpinnerAdapter areaSpinnerAdapter = new AreaSpinnerAdapter(Search.this , newAreas , selectedLanguage);
//        areaSpinner.setAdapter(areaSpinnerAdapter);
//
//
//
//        areaSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
//            @Override
//            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
//
//                areaId = "";
//                if(!newAreas.get(i).getArea_id().equals("0"))
//                {
//                    areaId = newAreas.get(i).getArea_id();
//                }
//
//                Log.e("tag" , "selected area id is : "+areaId);
//            }
//
//            @Override
//            public void onNothingSelected(AdapterView<?> adapterView) {
//
//            }
//        });


//        AreasAdapter areasAdapter = new AreasAdapter(Search.this , areas , this , selectedLanguage);
//        rvAreas.setAdapter(areasAdapter);



    }

    @Override
    public void selectedSubCategoryId(String subCategoryId) {
        this.subCategoryId = subCategoryId;
    }

    @Override
    public void selectedAreaId(String areaId) {
        this.areaId = areaId;
    }
}