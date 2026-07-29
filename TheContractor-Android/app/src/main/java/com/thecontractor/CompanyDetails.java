package com.thecontractor;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;
import androidx.viewpager.widget.ViewPager;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RatingBar;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.android.material.tabs.TabLayout;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.thecontractor.Database.DatabaseHandler;
import com.thecontractor.Fragments.CompanyDetailFragment;
import com.thecontractor.Fragments.OpeningHoursFragment;
import com.thecontractor.Fragments.ReviewsFragment;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.BadgeDrawable;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.BasicResponseModel;
import com.thecontractor.Model.CompaniesModel;
import com.thecontractor.Model.UserModel;
import com.thecontractor.RetrofitLibrary.RetrofitApi;
import com.thecontractor.RetrofitLibrary.SSSHandShake;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class CompanyDetails extends AppCompatActivity {
    CompaniesModel companyModel;
    String companyId;
//    String averageRating;
//    String companyReviewCount;
    LinearLayout companyDetailLayout;
    ImageView companyImage;
    TextView companyName , categoriesName , companyTotalRatingCount ;
    ImageView verified;
    ImageView twentyFourSeven;
    ImageView trusted;
    ImageView vip;
    RatingBar ratingBar;
    Button selectOrRemoveBtn;
    Button complaintBtn;
    String userId;
    String selectedLanguage = "en";
    private TabLayout tabLayout;
    public ViewPager viewPager;
    ProgressDialog progressDialog;
    Call<BasicResponseModel> call;
    private LayerDrawable mCartMenuIcon;
    private MenuItem action_cart;
    private int cartCount = 0;
    DatabaseHandler databaseHandler;

    LinearLayout companyPhoneLayout , companyWhatsappLayout , companyEmailLayout;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_company_details);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle(R.string.company_details);

        getLanguageFromSP();
        getDataFromSP();
        getObjectFromAdapter();
        initiate();
        clickListener();
        companyDetail();
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
        if (!SharedPrefManager.getInstance(CompanyDetails.this).getUserLanguage().equals("")) {
            selectedLanguage = SharedPrefManager.getInstance(CompanyDetails.this).getUserLanguage();

            Log.e("tag" , "selected language is : "+selectedLanguage);


        }
    }

    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(CompanyDetails.this).getUserObject().equals("")) {
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(CompanyDetails.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();

            Log.e("tag" , "user id is : "+userId);

        }
    }


    public void getObjectFromAdapter() {
        Intent intent = getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {

            companyId = (String) bundle.getString("companyId");


            Log.e("tag" , "company id is : "+companyId);



        }
    }

    public void initiate()
    {
        databaseHandler = new DatabaseHandler(CompanyDetails.this);


        progressDialog = new ProgressDialog(CompanyDetails.this);
        companyDetailLayout = (LinearLayout) findViewById(R.id.companyDetailLayout);
        companyDetailLayout.setVisibility(View.GONE);
        companyImage = (ImageView) findViewById(R.id.companyImage);
        companyName = (TextView) findViewById(R.id.companyName);
        categoriesName = (TextView) findViewById(R.id.categoriesName);
        companyTotalRatingCount = (TextView) findViewById(R.id.companyTotalRatingCount);
        verified = (ImageView) findViewById(R.id.verified);
        twentyFourSeven = (ImageView) findViewById(R.id.twentyFourSeven);
        trusted = (ImageView) findViewById(R.id.trusted);
        vip = (ImageView) findViewById(R.id.vip);
        ratingBar = (RatingBar) findViewById(R.id.ratingBar);
        selectOrRemoveBtn = (Button) findViewById(R.id.selectOrRemoveBtn);
        complaintBtn = (Button) findViewById(R.id.complaintBtn);
        companyPhoneLayout = (LinearLayout) findViewById(R.id.companyPhoneLayout);
        companyPhoneLayout.setVisibility(View.GONE);
        companyWhatsappLayout = (LinearLayout) findViewById(R.id.companyWhatsappLayout);
        companyWhatsappLayout.setVisibility(View.GONE);
        companyEmailLayout = (LinearLayout) findViewById(R.id.companyEmailLayout);
        companyEmailLayout.setVisibility(View.GONE);

        viewPager = (ViewPager) findViewById(R.id.viewpager);
        viewPager.setOffscreenPageLimit(3);
        tabLayout = (TabLayout) findViewById(R.id.tabs);


    }

    public void setTextToButton()
    {
        if (databaseHandler.isInCart(companyId)) {
            selectOrRemoveBtn.setText(getResources().getString(R.string.remove_company));
            selectOrRemoveBtn.setBackground(ContextCompat.getDrawable(CompanyDetails.this, R.drawable.red_button_bacground));
            selectOrRemoveBtn.setTextColor(ContextCompat.getColor(CompanyDetails.this, R.color.white));

        }
        else
        {
            selectOrRemoveBtn.setText(getResources().getString(R.string.select_company));
            selectOrRemoveBtn.setBackground(ContextCompat.getDrawable(CompanyDetails.this, R.drawable.button_bacground));
            selectOrRemoveBtn.setTextColor(ContextCompat.getColor(CompanyDetails.this, R.color.black));

        }
    }


    public void clickListener()
    {
        selectOrRemoveBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(selectOrRemoveBtn.getText().toString().equals(getResources().getString(R.string.remove_company)))
                {

                    databaseHandler.removeItemFromCart(companyId);

                    dbCount();
                    setBadgeCount(CompanyDetails.this, mCartMenuIcon, String.valueOf(cartCount));
                }
                else
                {


                    Log.e("tag" , "cart count is : "+databaseHandler.getCartCount());


                    int usedLimit = SharedPrefManager.getInstance(CompanyDetails.this).getCartLimit() - SharedPrefManager.getInstance(CompanyDetails.this).getCartAvailableLimit();

                    if(databaseHandler.getCartCount() >= SharedPrefManager.getInstance(CompanyDetails.this).getCartAvailableLimit())
                    {
                         if(SharedPrefManager.getInstance(CompanyDetails.this).getCartAvailableLimit() == 0)
                         {
                             Toast.makeText(CompanyDetails.this, getResources().getString(R.string.your_today_enquiries_limit), Toast.LENGTH_SHORT).show();

                         }else {
                             Toast.makeText(CompanyDetails.this, getResources().getString(R.string.you_can_select) + SharedPrefManager.getInstance(CompanyDetails.this).getCartAvailableLimit() + getResources().getString(R.string.you_can_select_companies), Toast.LENGTH_SHORT).show();
                         }
                    }else
                    {

                        HashMap<String, String> map = new HashMap<>();
                        map.put("company_id",companyModel.getId());
                        map.put("company_name",companyModel.getCompany_name());
                        map.put("company_arabic_name",companyModel.getCompany_arabic_name());
                        map.put("company_image",companyModel.getCompany_logo());
                        map.put("company_categories",companyModel.getCategory_name());
                        map.put("company_arabic_categories",companyModel.getCategory_arabic_name());
                        map.put("company_review_count",companyModel.getReview_count());
                        map.put("company_rating",companyModel.getAvg_rating());
                        map.put("company_verified",companyModel.getIs_verified());


                        if(databaseHandler.setCart(map))
                        {
                            dbCount();
                            setBadgeCount(CompanyDetails.this, mCartMenuIcon, String.valueOf(cartCount));

                        }
                        else
                        {
                            Toast.makeText(CompanyDetails.this, R.string.something_wrong_company, Toast.LENGTH_SHORT).show();
                        }
                    }

                }

                setTextToButton();
            }
        });


        complaintBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                complaintDialog();
            }
        });
    }



    public void complaintDialog()
    {
        Dialog dialog = new Dialog(CompanyDetails.this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.complaint_dialog);
        Window window = dialog.getWindow();
        window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        dialog.setCancelable(true);
        dialog.show();

        EditText editText = dialog.findViewById(R.id.complain);
        Button submitComplainBtn = dialog.findViewById(R.id.submitComplainBtn);

        submitComplainBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(editText.getText().toString().equals(""))
                {
                    Toast.makeText(CompanyDetails.this , getResources().getString(R.string.enter_your_complain_first), Toast.LENGTH_SHORT).show();
                }
                else
                {
                    dialog.dismiss();
                    submitComplain(editText.getText().toString());
                }
            }
        });
    }

    private void submitComplain(String complain) {


        RequestBody company_id = RequestBody.create(companyId , MediaType.parse("text/plain"));
        RequestBody user_id = RequestBody.create(userId , MediaType.parse("text/plain"));
        RequestBody text = RequestBody.create(complain , MediaType.parse("text/plain"));


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
        call = retrofitApi.submitComplain(company_id , user_id , text);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {



                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {


                        AlertDialog alertDialog = new AlertDialog.Builder(CompanyDetails.this).create();
                        alertDialog.setTitle(getResources().getString(R.string.complaint_submitted));
                        alertDialog.setMessage(response.body().getMessage());
                        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, getResources().getString(R.string.ok),
                                new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int which) {

                                        dialog.dismiss();


                                    }
                                });
                        alertDialog.show();

                    }
                    else
                    {
                        Toast.makeText(CompanyDetails.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(CompanyDetails.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(CompanyDetails.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
                    Log.e("tag", "on failure error : " + t.getMessage());

                }
            }
        });
    }

    private void companyDetail() {


        RequestBody company_id = RequestBody.create(companyId , MediaType.parse("text/plain"));


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
        call = retrofitApi.companyDetail(company_id);

        //finally performing the call
        call.enqueue(new Callback<BasicResponseModel>() {
            @Override
            public void onResponse(Call<BasicResponseModel> call, Response<BasicResponseModel> response) {


                Log.e("tag", "API response is : "+new Gson().toJson(response.body()) );


                hideProgress();
                if(response.isSuccessful())
                {
                    if(response.body().getError().equals("false")) {

                        companyDetailLayout.setVisibility(View.VISIBLE);
                        companyModel = response.body().getCompany();

                        setDataToWidget();
                        setupViewPager(viewPager);
                        tabLayout.setupWithViewPager(viewPager);

                    }
                    else
                    {
                        Toast.makeText(CompanyDetails.this, response.body().getMessage(), Toast.LENGTH_SHORT).show();
                    }
                }
                else
                {
                    Toast.makeText(CompanyDetails.this, getResources().getString(R.string.please_try_again), Toast.LENGTH_SHORT).show();
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
                    Toast.makeText(CompanyDetails.this , getResources().getString(R.string.serviceError), Toast.LENGTH_LONG).show();
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


    private void setupViewPager(ViewPager viewPager) {
        ViewPagerAdapter adapter = new ViewPagerAdapter(getSupportFragmentManager());
        if(selectedLanguage.equals("en"))
        {
            adapter.addFragment(new CompanyDetailFragment(companyModel.getCompany_discription() , companyModel.getCompany_address() , companyModel.getCity_name() , companyModel.getArea_name() , companyModel.getCategories(), companyModel.getCompany_since(), companyModel.getCompany_employees()), getString(R.string.details));
        }
        else
        {
            adapter.addFragment(new CompanyDetailFragment(companyModel.getCompany_arabic_discription() , companyModel.getCompany_arabic_address() , companyModel.getCity_arabic_name() , companyModel.getArea_arabic_name() , companyModel.getCategories(), companyModel.getCompany_since(), companyModel.getCompany_employees()), getString(R.string.details));
        }
        adapter.addFragment(new OpeningHoursFragment(companyModel.getTiming()), getString(R.string.opening_hours));
        adapter.addFragment(new ReviewsFragment(companyModel.getReviews()), getString(R.string.reviews));
        viewPager.setAdapter(adapter);

    }

    public class ViewPagerAdapter extends FragmentPagerAdapter {
        private final List<Fragment> mFragmentList = new ArrayList<>();
        private final List<String> mFragmentTitleList = new ArrayList<>();

        public ViewPagerAdapter(FragmentManager manager) {
            super(manager);
        }

        @Override
        public Fragment getItem(int position) {


            return mFragmentList.get(position);
        }

        @Override
        public int getCount() {
            return mFragmentList.size();
        }

        public void addFragment(Fragment fragment, String title) {
            mFragmentList.add(fragment);
            mFragmentTitleList.add(title);
        }

        @Override
        public CharSequence getPageTitle(int position) {
            return mFragmentTitleList.get(position);
        }
    }




    public void setDataToWidget()
    {
        Glide.with(CompanyDetails.this)
                .load(ApiUrls.COMPANIES_IMAGE_URL+companyModel.getCompany_logo())
                .apply(new RequestOptions().placeholder(R.drawable.ic_image_placeholder).error(R.drawable.ic_image_placeholder))
                .into(companyImage);


        if(selectedLanguage.equals("en"))
        {
            companyName.setText(companyModel.getCompany_name());
            categoriesName.setText(companyModel.getCategory_name());

        }else
        {
            companyName.setText(companyModel.getCompany_arabic_name());
            categoriesName.setText(companyModel.getCategory_arabic_name());
        }


        companyTotalRatingCount.setText("("+companyModel.getReview_count()+")");

        if(companyModel.getAvg_rating() != null)
        {
            ratingBar.setRating(Float.parseFloat(companyModel.getAvg_rating()));
        }
        else
        {
            ratingBar.setRating(0);
        }

        if(companyModel.getIs_verified().equals("1"))
        {
            verified.setVisibility(View.VISIBLE);
        }
        else
        {
            verified.setVisibility(View.GONE);
        }

        if(companyModel.getCompany_for_24_hours().equals("1"))
        {
            twentyFourSeven.setVisibility(View.VISIBLE);
        }
        else
        {
            twentyFourSeven.setVisibility(View.GONE);
        }

        if(companyModel.getIs_trusted().equals("1"))
        {
            trusted.setVisibility(View.VISIBLE);
        }
        else
        {
            trusted.setVisibility(View.GONE);
        }

        if(companyModel.getIs_vip().equals("1"))
        {
            vip.setVisibility(View.VISIBLE);
        }
        else
        {
            vip.setVisibility(View.GONE);
        }

        if(!companyModel.getCompany_phone().equals("") && companyModel.getCompany_phone() != null)
        {
            companyPhoneLayout.setVisibility(View.VISIBLE);
        }

        if(!companyModel.getCompany_whatsapp().equals("") && companyModel.getCompany_whatsapp() != null)
        {
            companyWhatsappLayout.setVisibility(View.VISIBLE);
        }

        if(!companyModel.getCompany_email().equals("") && companyModel.getCompany_email() != null)
        {
            companyEmailLayout.setVisibility(View.VISIBLE);
        }


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
                    Toast.makeText(CompanyDetails.this, getResources().getString(R.string.cart_empty), Toast.LENGTH_SHORT).show();
                } else {
                    Intent i = new Intent(CompanyDetails.this, Cart.class);
                    startActivity(i);
                }


                return false;
            }
        });


        dbCount();
        setBadgeCount(CompanyDetails.this, mCartMenuIcon, String.valueOf(cartCount));
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



    @Override
    protected void onResume() {
        super.onResume();
        dbCount();
        invalidateOptionsMenu();
        setTextToButton();
    }


    @Override
    protected void onPause() {
        super.onPause();

    }

    public void dbCount() {
        cartCount = databaseHandler.getCartCount();

        Log.e("tag", "cart count is : " + cartCount);
    }


}