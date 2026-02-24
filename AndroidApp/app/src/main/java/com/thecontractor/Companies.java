package com.thecontractor;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.widget.NestedScrollView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Adapter.CategoriesAdapter;
import com.thecontractor.Adapter.CompaniesAdapter;
import com.thecontractor.Database.DatabaseHandler;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.BadgeDrawable;
import com.thecontractor.Global.PaginationScrollListener;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.CategoriesModel;
import com.thecontractor.Model.CompaniesModel;
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

public class Companies extends AppCompatActivity {
    String categoryId;
    String subCategoryId;
    String subCategoryName;

    TextView noData;

    RecyclerView featuredCompaniesRV;
    LinearLayoutManager linearLayoutManagerFeatured ;
    ArrayList<CompaniesModel> featuredList;


    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;

    CompaniesAdapter companiesAdapter;

    int currentPage = 1;
    int lastPage = 0;
    private boolean isLoading = false;
    private boolean isLastPage = false;

    private LayerDrawable mCartMenuIcon;
    private MenuItem action_cart;
    private int cartCount = 0;
    private DatabaseHandler databaseHandler;
    String selectedLanguage = "en";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_companies);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(getResources().getString(R.string.companies));

        getLanguageFromSP();
        getDataFromPreviousActivity();
        initiate();
        companiesAPI(true);
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
        if (!SharedPrefManager.getInstance(Companies.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(Companies.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }

    public void getDataFromPreviousActivity()
    {
        Intent intent = getIntent();
        categoryId = intent.getStringExtra("categoryId");
        subCategoryId = intent.getStringExtra("subCategoryId");
        subCategoryName = intent.getStringExtra("subCategoryName");

        Log.e("tag" , "categories id is : "+categoryId);
        Log.e("tag" , "sub categories id is : "+subCategoryId);
        Log.e("tag" , "sub categories name is : "+subCategoryName);


    }
    
    public void initiate()
    {
        databaseHandler = new DatabaseHandler(Companies.this);

        progressDialog = new ProgressDialog(Companies.this);

        noData = (TextView) findViewById(R.id.noData);
        noData.setVisibility(View.GONE);



        featuredList = new ArrayList<>();
        featuredCompaniesRV = (RecyclerView) findViewById(R.id.featuredCompaniesRV);
        linearLayoutManagerFeatured = new LinearLayoutManager(Companies.this ,  LinearLayoutManager.VERTICAL , false);
        featuredCompaniesRV.setLayoutManager(linearLayoutManagerFeatured);
        companiesAdapter = new CompaniesAdapter(Companies.this , featuredList , selectedLanguage);
        featuredCompaniesRV.setAdapter(companiesAdapter);


    }

    private void companiesAPI(final boolean firstTimeCall) {

        RequestBody category_id = RequestBody.create(categoryId , MediaType.parse("text/plain"));
        RequestBody sub_category_id = RequestBody.create(subCategoryId , MediaType.parse("text/plain"));
        RequestBody page = RequestBody.create(String.valueOf(currentPage) , MediaType.parse("text/plain"));


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

        if(firstTimeCall)
        {
            showProgress();
        }

        RetrofitApi retrofitApi = retrofit.create(RetrofitApi.class);

        //creating a call and calling the upload image method
        call = retrofitApi.findCompanies(category_id , sub_category_id , page);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        featuredList = response.body().getCompanies_list();
                        lastPage = response.body().getTotal_page();

                        Log.e("tag" , "companies list size is : "+featuredList.size());
                        Log.e("tag" , "current page is : "+currentPage);
                        Log.e("tag" , "last page is : "+lastPage);
                        Log.e("tag"  ," firstTimeCall is : "+firstTimeCall);

                        if(!firstTimeCall)
                        {
                            companiesAdapter.removeLoadingFooter();
                            isLoading = false;
                        }else
                        {
                            recyclerViewPaginationScroller();
                        }

                        companiesAdapter.addAll(featuredList);

                        if (lastPage != currentPage)
                        {
                            companiesAdapter.addLoadingFooter();
                        }
                        else
                        {
                            isLastPage = true;
                        }

                        currentPage++;






                    }
                    else
                    {
                        noData.setVisibility(View.VISIBLE);
                        //Toast.makeText(Companies.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(Companies.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(Companies.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    public void recyclerViewPaginationScroller()
    {

        featuredCompaniesRV.addOnScrollListener(new PaginationScrollListener(linearLayoutManagerFeatured) {
            @Override
            protected void loadMoreItems() {
                isLoading = true;

                // mocking network delay for API call
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        companiesAPI(false);

                    }
                }, 100);
            }

            @Override
            public int getTotalPageCount() {
                return lastPage;
            }

            @Override
            public boolean isLastPage() {
                return isLastPage;
            }

            @Override
            public boolean isLoading() {
                return isLoading;
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
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);

        mCartMenuIcon = (LayerDrawable) menu.findItem(R.id.action_cart).getIcon();
        action_cart = (MenuItem) menu.findItem(R.id.action_cart);
        MenuItem action_search = (MenuItem) menu.findItem(R.id.action_search);
        MenuItem action_twenty_four_seven = (MenuItem) menu.findItem(R.id.action_twenty_four_seven);

        action_search.setVisible(false);
        action_twenty_four_seven.setVisible(false);

        action_cart.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {


                dbCount();

                if (cartCount == 0) {
                    Toast.makeText(Companies.this, getResources().getString(R.string.cart_empty), Toast.LENGTH_SHORT).show();
                } else {
                    Intent i = new Intent(Companies.this, Cart.class);
                    startActivity(i);
                }


                return false;
            }
        });


        dbCount();
        setBadgeCount(Companies.this, mCartMenuIcon, String.valueOf(cartCount));
        return super.onCreateOptionsMenu(menu);


    }

    public static void setBadgeCount(Context context, LayerDrawable icon, String count) {

        Log.e("tag", "count in badge" + count);

        BadgeDrawable badge;

        // Reuse drawable if possible
        Drawable reuse = icon.findDrawableByLayerId(R.id.ic_badge);
        if (reuse != null && reuse instanceof BadgeDrawable) {
            badge = (BadgeDrawable) reuse;
        } else {
            badge = new BadgeDrawable(context);
        }

        badge.setCount(count);
        icon.mutate();
        icon.setDrawableByLayerId(R.id.ic_badge, badge);
    }

    private BroadcastReceiver updateValue = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {

            String type = intent.getStringExtra("type");

            if (type.contentEquals("update_value")) {
                dbCount();
                setBadgeCount(Companies.this, mCartMenuIcon, String.valueOf(cartCount));
            }
        }
    };

    public void dbCount() {
        cartCount = databaseHandler.getCartCount();

        Log.e("tag", "cart count is : " + cartCount);
    }


    @Override
    protected void onResume() {
        super.onResume();
        registerReceiver(updateValue , new IntentFilter("update"));
        dbCount();
        invalidateOptionsMenu();

        if(companiesAdapter != null)
        {
            companiesAdapter.notifyDataSetChanged();
        }


    }

    @Override
    protected void onPause() {
        super.onPause();
        unregisterReceiver(updateValue);

    }
}