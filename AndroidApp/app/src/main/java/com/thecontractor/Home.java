package com.thecontractor;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.content.ContextCompat;
import androidx.core.view.GravityCompat;
import androidx.core.view.WindowCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.IntentSender;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.tasks.Task;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.android.material.navigation.NavigationView;
import com.google.android.play.core.appupdate.AppUpdateInfo;
import com.google.android.play.core.appupdate.AppUpdateManager;
import com.google.android.play.core.appupdate.AppUpdateManagerFactory;
import com.google.android.play.core.install.model.UpdateAvailability;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.gson.Gson;
import com.thecontractor.Database.DatabaseHandler;
import com.thecontractor.Fragments.EstimationFragment;
import com.thecontractor.Fragments.HomeFragment;
import com.thecontractor.Fragments.WorkshopFragment;
import com.thecontractor.Fragments.ProfileFragment;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.BadgeDrawable;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Model.UserModel;
import com.thecontractor.VendorActivities.VendorLogin;

import static com.google.android.play.core.install.model.ActivityResult.RESULT_IN_APP_UPDATE_FAILED;
import static com.google.android.play.core.install.model.AppUpdateType.IMMEDIATE;

public class Home extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener{
    DrawerLayout drawerLayout;
    NavigationView navigationView;
    Menu menu;
    MenuItem nav_inbox;
    MenuItem nav_submit_enquiry;
    MenuItem nav_enquiries;
    MenuItem nav_request_for_quotation;
    MenuItem nav_quotations;
    MenuItem nav_complaints;
    MenuItem nav_estimations;
    MenuItem nav_workshop;
    MenuItem nav_contact_us;
    MenuItem nav_logout;
    MenuItem nav_my_jobs_applies;
    MenuItem nav_direct_hiring;

    private BottomNavigationView bottomNavigationView;
    Fragment homeFragment;
    Fragment workshopFragment;
    Fragment estimationFragment;
    Fragment profileFragment;
    Fragment activeFragment;
    FragmentManager fragmentManager;
    boolean doubleBackToExitPressedOnce = false;


    TextView userName, viewProfile , loginAsVendor;
    LinearLayout headerLayout , headerUserInfoLayout , loginCreateAccountLayout;
    String userId;
    Button twentyFourSevenMaintenance;
    Button submitQuotation;

    private LayerDrawable mCartMenuIcon;
    private MenuItem action_cart;
    private int cartCount = 0;
    private DatabaseHandler databaseHandler;

    AppUpdateManager appUpdateManager;
    private final int UPDATE_REQUEST_CODE = 5000;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
        setContentView(R.layout.activity_home);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setTitle("");

        callInAppUpdate();
        subscribeFirebaseToken();
        initiate(toolbar);
        clickListener();
        dbCount();

    }


    public void subscribeFirebaseToken()
    {
        FirebaseMessaging.getInstance().subscribeToTopic("toAll").addOnCompleteListener(new com.google.android.gms.tasks.OnCompleteListener<Void>() {
            @Override
            public void onComplete(@NonNull com.google.android.gms.tasks.Task<Void> task) {
                String msg = "Topic Subscribed";
                if (!task.isSuccessful()) {
                    msg = "Topic Not Subscribed";
                }
                Log.e("tag", msg);
            }
        });
    }

    public void initiate(Toolbar toolbar)
    {

        databaseHandler = new DatabaseHandler(Home.this);


        bottomNavigationView = (BottomNavigationView) findViewById(R.id.bottomNavigationView);
        bottomNavigationView.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);

        homeFragment = new HomeFragment();
        workshopFragment = new WorkshopFragment();
        estimationFragment = new EstimationFragment();
        profileFragment = new ProfileFragment();
        activeFragment = homeFragment;
        fragmentManager = getSupportFragmentManager();
        loadFragment(activeFragment);


        drawerLayout = findViewById(R.id.drawer_layout);
        drawerLayout.closeDrawer(GravityCompat.START);
        drawerLayout.setStatusBarBackgroundColor(ContextCompat.getColor(this, R.color.white));

        navigationView = findViewById(R.id.nav_view);

        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawerLayout, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close) {
            @Override
            public void onDrawerClosed(View drawerView) {
                super.onDrawerClosed(drawerView);
            }

            @Override
            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);

                InputMethodManager inputMethodManager = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);

                if (inputMethodManager.isAcceptingText()) {
                    inputMethodManager.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
                }
            }

            @Override
            public void onDrawerSlide(View drawerView, float slideOffset) {
                super.onDrawerSlide(drawerView, slideOffset);


                InputMethodManager inputMethodManager = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);

                if (inputMethodManager.isAcceptingText()) {
                    inputMethodManager.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
                }
            }
        };
        drawerLayout.addDrawerListener(toggle);
        toggle.syncState();

        navigationView.setNavigationItemSelectedListener(this);

        View view = navigationView.getHeaderView(0);
        userName = (TextView) view.findViewById(R.id.userName);
        viewProfile = (TextView) view.findViewById(R.id.viewProfile);
        loginAsVendor = (TextView) view.findViewById(R.id.loginAsVendor);
        headerLayout = (LinearLayout) view.findViewById(R.id.headerLayout);
        headerUserInfoLayout = (LinearLayout) view.findViewById(R.id.headerUserInfoLayout);
        loginCreateAccountLayout = (LinearLayout) view.findViewById(R.id.loginCreateAccountLayout);

        menu = navigationView.getMenu();


        nav_inbox = menu.findItem(R.id.nav_inbox);
        nav_submit_enquiry = menu.findItem(R.id.nav_submit_enquiry);
        nav_enquiries = menu.findItem(R.id.nav_enquiries);
        nav_request_for_quotation = menu.findItem(R.id.nav_request_for_quotation);
        nav_quotations = menu.findItem(R.id.nav_quotations);
        nav_complaints = menu.findItem(R.id.nav_complaints);
        nav_estimations = menu.findItem(R.id.nav_estimations);
        nav_workshop = menu.findItem(R.id.nav_workshop);
        nav_contact_us = menu.findItem(R.id.nav_contact_us);
        nav_logout = menu.findItem(R.id.nav_logout);
        nav_my_jobs_applies = menu.findItem(R.id.nav_my_jobs_applies);
        nav_direct_hiring = menu.findItem(R.id.nav_direct_hiring);

        twentyFourSevenMaintenance = (Button) findViewById(R.id.twentyFourSevenMaintenance);
        submitQuotation = (Button) findViewById(R.id.submitQuotation);

    }


    private BottomNavigationView.OnNavigationItemSelectedListener mOnNavigationItemSelectedListener
            = new BottomNavigationView.OnNavigationItemSelectedListener() {

        @Override
        public boolean onNavigationItemSelected(@NonNull MenuItem item) {
            int itemId = item.getItemId();
            if (itemId == R.id.action_home) {
                homeFragment = new HomeFragment();
                activeFragment = homeFragment;
                loadFragment(activeFragment);
                return true;
            } else if (itemId == R.id.action_workshop) {
                if (!SharedPrefManager.getInstance(Home.this).getUserObject().equals("")) {
                    workshopFragment = new WorkshopFragment();
                    activeFragment = workshopFragment;
                    loadFragment(activeFragment);
                    return true;
                } else {
                    Intent intent = new Intent(Home.this, Login.class);
                    intent.putExtra("requestForLogin", "yes");
                    loginActivityResultLauncher.launch(intent);
                    return false;
                }
            } else if (itemId == R.id.action_search) {
                Intent searchIntent = new Intent(Home.this, Search.class);
                startActivity(searchIntent);
                return false;
            } else if (itemId == R.id.action_estimation) {
                estimationFragment = new EstimationFragment();
                activeFragment = estimationFragment;
                loadFragment(activeFragment);
                return true;
            } else if (itemId == R.id.action_profile) {
                profileFragment = new ProfileFragment();
                activeFragment = profileFragment;
                loadFragment(activeFragment);
                return true;
            }
            return false;
        }
    };

    private void loadFragment(Fragment fragment) {
        // load fragment
        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        transaction.replace(R.id.nav_bottom_fragment, fragment);
        transaction.commit();
    }

    public void clickListener()
    {
        twentyFourSevenMaintenance.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Home.this , TwentyFourSeven.class);
                startActivity(intent);
            }
        });

        submitQuotation.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (!SharedPrefManager.getInstance(Home.this).getUserObject().equals("")) {
                    Intent intent = new Intent(Home.this, SubmitQuotations.class);
                    startActivity(intent);
                }
                else
                {
                    Intent intent =  new Intent(Home.this , Login.class);
                    intent.putExtra("requestForLogin" , "yes");
                    loginActivityResultLauncher.launch(intent);
                }

            }
        });

        loginAsVendor.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Home.this , VendorLogin.class);
                startActivity(intent);
            }
        });

        headerLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (!SharedPrefManager.getInstance(Home.this).getUserObject().equals("")) {
                    if (bottomNavigationView.getSelectedItemId() != R.id.action_profile) {
                        bottomNavigationView.setSelectedItemId(R.id.action_profile);
                    }
                }
                else
                {
                    Intent intent =  new Intent(Home.this , Login.class);
                    intent.putExtra("requestForLogin" , "yes");
                    loginActivityResultLauncher.launch(intent);
                }


                if (drawerLayout.isDrawerOpen(GravityCompat.START)) {
                    drawerLayout.closeDrawer(GravityCompat.START);
                }
            }
        });
    }

    ActivityResultLauncher<Intent> loginActivityResultLauncher = registerForActivityResult(
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

    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(Home.this).getUserObject().equals("")) {
            headerUserInfoLayout.setVisibility(View.VISIBLE);
            loginCreateAccountLayout.setVisibility(View.GONE);
            loginAsVendor.setVisibility(View.GONE);
            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(Home.this).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();

            Log.e("tag", "user id is : " + userId);

            userName.setText(userModel.getName() + " " + userModel.getSurname());

            nav_inbox.setVisible(true);
            nav_submit_enquiry.setVisible(true);
            nav_enquiries.setVisible(true);
            nav_request_for_quotation.setVisible(true);
            nav_quotations.setVisible(true);
            nav_complaints.setVisible(true);
            nav_estimations.setVisible(true);
            nav_workshop.setVisible(true);
            nav_contact_us.setVisible(true);
            nav_logout.setVisible(true);
            nav_my_jobs_applies.setVisible(true);
            nav_direct_hiring.setVisible(true);

        }
        else
        {
            headerUserInfoLayout.setVisibility(View.GONE);
            loginCreateAccountLayout.setVisibility(View.VISIBLE);
            loginAsVendor.setVisibility(View.VISIBLE);

            nav_inbox.setVisible(false);
            nav_submit_enquiry.setVisible(false);
            nav_enquiries.setVisible(false);
            nav_request_for_quotation.setVisible(false);
            nav_quotations.setVisible(false);
            nav_complaints.setVisible(false);
            nav_estimations.setVisible(false);
            nav_workshop.setVisible(false);
            nav_contact_us.setVisible(false);
            nav_logout.setVisible(false);
            nav_my_jobs_applies.setVisible(false);
            nav_direct_hiring.setVisible(false);
        }
    }

    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        int id = item.getItemId();

        if (id == R.id.nav_home) {

            if (bottomNavigationView.getSelectedItemId() != R.id.action_home) {
                bottomNavigationView.setSelectedItemId(R.id.action_home);
            }

        }else if (id == R.id.nav_select_language) {
            Intent intent =  new Intent(Home.this , SelectLanguage.class);
            intent.putExtra("from" , "profileFragment");
            profileActivityResultLauncher.launch(intent);

        }else if (id == R.id.nav_inbox) {
            Intent intent =  new Intent(Home.this , ChatConnection.class);
            startActivity(intent);

        }else if (id == R.id.nav_company_finder) {
            searchDialog();
        }else if (id == R.id.nav_submit_enquiry) {

            dbCount();

            if (cartCount == 0) {
                Toast.makeText(Home.this, getResources().getString(R.string.cart_empty), Toast.LENGTH_SHORT).show();
            } else {
                Intent intent = new Intent(Home.this, Cart.class);
                startActivity(intent);
            }



        }else if (id == R.id.nav_enquiries) {
            if (!SharedPrefManager.getInstance(Home.this).getUserObject().equals("")) {
                Intent intent = new Intent(Home.this, Enquiries.class);
                startActivity(intent);
            }
            else
            {
                Intent intent =  new Intent(Home.this , Login.class);
                intent.putExtra("requestForLogin" , "yes");
                loginActivityResultLauncher.launch(intent);
            }
        }else if (id == R.id.nav_request_for_quotation) {
            if (!SharedPrefManager.getInstance(Home.this).getUserObject().equals("")) {
                Intent intent = new Intent(Home.this, SubmitQuotations.class);
                startActivity(intent);
            }
            else
            {
                Intent intent =  new Intent(Home.this , Login.class);
                intent.putExtra("requestForLogin" , "yes");
                loginActivityResultLauncher.launch(intent);
            }


        }else if (id == R.id.nav_quotations) {
            if (!SharedPrefManager.getInstance(Home.this).getUserObject().equals("")) {
                Intent intent = new Intent(Home.this, Quotations.class);
                startActivity(intent);
            }
            else
            {
                Intent intent =  new Intent(Home.this , Login.class);
                intent.putExtra("requestForLogin" , "yes");
                loginActivityResultLauncher.launch(intent);
            }


        }else if (id == R.id.nav_complaints) {
            if (!SharedPrefManager.getInstance(Home.this).getUserObject().equals("")) {
                Intent intent = new Intent(Home.this, Complaints.class);
                startActivity(intent);
            }
            else
            {
                Intent intent =  new Intent(Home.this , Login.class);
                intent.putExtra("requestForLogin" , "yes");
                loginActivityResultLauncher.launch(intent);
            }


        }else if (id == R.id.nav_estimations) {
            if (!SharedPrefManager.getInstance(Home.this).getUserObject().equals("")) {
                Intent intent = new Intent(Home.this, Estimations.class);
                startActivity(intent);
            }
            else
            {
                Intent intent =  new Intent(Home.this , Login.class);
                intent.putExtra("requestForLogin" , "yes");
                loginActivityResultLauncher.launch(intent);
            }
        } else if (id == R.id.nav_twenty_four_seven) {
            Intent intent = new Intent(Home.this, TwentyFourSeven.class);
            startActivity(intent);

        }else if (id == R.id.nav_advertise_company) {
            Intent intent = new Intent(Home.this, AdvertiseCompany.class);
            startActivity(intent);

        }else if (id == R.id.nav_available_jobs) {
            Intent intent = new Intent(Home.this, AvailableJobs.class);
            startActivity(intent);

        }else if (id == R.id.nav_freelancer) {
            Intent intent = new Intent(Home.this, Freelancers.class);
            intent.putExtra("from" , "user");
            startActivity(intent);

        } else if (id == R.id.nav_freelancer_dashboard) {

            if (!SharedPrefManager.getInstance(Home.this).getUserObject().equals("")) {
                Intent intent = new Intent(Home.this, UserDashboardFreelancer.class);
                startActivity(intent);
            } else {
                Intent intent =  new Intent(Home.this , Login.class);
                intent.putExtra("requestForLogin" , "yes");
                loginActivityResultLauncher.launch(intent);
            }

        }else if (id == R.id.nav_my_jobs_applies) {

            if (!SharedPrefManager.getInstance(Home.this).getUserObject().equals("")) {
                Intent intent = new Intent(Home.this, UserJobApplied.class);
                startActivity(intent);
            } else {
                Intent intent =  new Intent(Home.this , Login.class);
                intent.putExtra("requestForLogin" , "yes");
                loginActivityResultLauncher.launch(intent);
            }

        }else if (id == R.id.nav_direct_hiring) {

            if (!SharedPrefManager.getInstance(Home.this).getUserObject().equals("")) {
                Intent intent = new Intent(Home.this, UserDirectHiring.class);
                startActivity(intent);
            } else {
                Intent intent =  new Intent(Home.this , Login.class);
                intent.putExtra("requestForLogin" , "yes");
                loginActivityResultLauncher.launch(intent);
            }

        }else if (id == R.id.nav_workshop) {

            if (!SharedPrefManager.getInstance(Home.this).getUserObject().equals("")) {
                Intent intent = new Intent(Home.this, WorkShopAds.class);
                intent.putExtra("type" , "user");
                startActivity(intent);
            } else {
                Intent intent =  new Intent(Home.this , Login.class);
                intent.putExtra("requestForLogin" , "yes");
                loginActivityResultLauncher.launch(intent);
            }

        } else if (id == R.id.nav_about_us) {
            Intent intent = new Intent(Home.this , WebViewActivity.class);
            intent.putExtra("link" , ApiUrls.BASE_URL + "about-app");
            intent.putExtra("page" , getResources().getString(R.string.about_us));
            startActivity(intent);
        }else if (id == R.id.nav_terms_and_conditions) {
            Intent intent = new Intent(Home.this , WebViewActivity.class);
            intent.putExtra("link" , ApiUrls.BASE_URL + "terms-and-conditions-app");
            intent.putExtra("page" , getResources().getString(R.string.terms_and_conditions));
            startActivity(intent);
        }else if (id == R.id.nav_privacy_policy) {
            Intent intent = new Intent(Home.this , WebViewActivity.class);
            intent.putExtra("link" , ApiUrls.BASE_URL + "privacy-policy-app");
            intent.putExtra("page" , getResources().getString(R.string.privacy_policy));
            startActivity(intent);
        }else if (id == R.id.nav_advertisement) {
            Intent intent = new Intent(Home.this , WebViewActivity.class);
            intent.putExtra("link" , ApiUrls.BASE_URL + "advertisement-app");
            intent.putExtra("page" , getResources().getString(R.string.advertisement));
            startActivity(intent);
        }else if (id == R.id.nav_become_vendor) {
            Intent intent = new Intent(Home.this , WebViewActivity.class);
            intent.putExtra("link" , ApiUrls.BASE_URL + "become-a-vender-app");
            intent.putExtra("page" , getResources().getString(R.string.become_a_vendor));
            startActivity(intent);
        }else if (id == R.id.nav_guide) {
            Intent intent = new Intent(Home.this , WebViewActivity.class);
            intent.putExtra("link" , ApiUrls.BASE_URL + "guide-app");
            intent.putExtra("page" , getResources().getString(R.string.guide));
            startActivity(intent);
        }else if (id == R.id.nav_documentations) {
            Intent intent = new Intent(Home.this , WebViewActivity.class);
            intent.putExtra("link" , ApiUrls.BASE_URL + "documentations-app");
            intent.putExtra("page" , getResources().getString(R.string.documentations));
            startActivity(intent);
        }else if (id == R.id.nav_contact_us) {
            Intent intent = new Intent(Home.this , WebViewActivity.class);
            intent.putExtra("link" , ApiUrls.BASE_URL + "contact-app");
            intent.putExtra("page" , getResources().getString(R.string.contact_us));
            startActivity(intent);
        }else if (id == R.id.nav_rate_us) {
            rateUs();

        } else if (id == R.id.nav_share) {
            shareApp();

        } else if (id == R.id.nav_logout) {
            AlertDialog alertDialog = AlertDialog();
            alertDialog.show();

        }


        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }

    private AlertDialog AlertDialog() {
        AlertDialog myDialogBox = new AlertDialog.Builder(Home.this)
                // set message, title, and icon
                .setTitle(getResources().getString(R.string.logout))
                .setMessage(getResources().getString(R.string.want_to_logout))

                .setPositiveButton(getResources().getString(R.string.yes), new DialogInterface.OnClickListener() {

                    public void onClick(DialogInterface dialog, int whichButton) {
                        //your deleting code
                        dialog.dismiss();

                        logout();
                    }

                })
                .setNegativeButton(getResources().getString(R.string.no), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {

                        dialog.dismiss();

                    }
                })
                .create();

        return myDialogBox;
    }

    ActivityResultLauncher<Intent> profileActivityResultLauncher = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(),
            new ActivityResultCallback<ActivityResult>() {
                @Override
                public void onActivityResult(ActivityResult result) {
                    if (result.getResultCode() == Activity.RESULT_OK) {
                        // There are no request codes
                        Intent data = result.getData();

                        Log.e("tag" , "result back");

                        finish();
                        startActivity(getIntent());
                    }
                }
            });

    public void logout() {

        SharedPrefManager.getInstance(Home.this).userLogout();

        Intent intent = new Intent(Home.this, Home.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        finish();

    }


    public void rateUs() {
        Uri uri = Uri.parse("market://details?id=" + getPackageName());
        Intent goToMarket = new Intent(Intent.ACTION_VIEW, uri);
        // To count with Play market backstack, After pressing back button,
        // to taken back to our application, we need to add following flags to intent.
        goToMarket.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY |
                Intent.FLAG_ACTIVITY_NEW_DOCUMENT |
                Intent.FLAG_ACTIVITY_MULTIPLE_TASK);
        try {
            startActivity(goToMarket);
        } catch (ActivityNotFoundException e) {
            startActivity(new Intent(Intent.ACTION_VIEW,
                    Uri.parse("http://play.google.com/store/apps/details?id=" + getPackageName())));
        }
    }

    public void shareApp() {
        try {
            Intent shareIntent = new Intent(Intent.ACTION_SEND);
            shareIntent.setType("text/plain");
            shareIntent.putExtra(Intent.EXTRA_SUBJECT, "The Contractor");
            String shareMessage = "Recommend you this application\n";
            shareMessage = shareMessage + "https://play.google.com/store/apps/details?id=" + getPackageName() + "\n\n";
            shareIntent.putExtra(Intent.EXTRA_TEXT, shareMessage);
            startActivity(Intent.createChooser(shareIntent, "choose one"));
        } catch (Exception e) {
            //e.toString();
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

        action_search.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {

                searchDialog();
                return false;
            }
        });

        action_cart.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {


                dbCount();

                if (cartCount == 0) {
                    Toast.makeText(Home.this, getResources().getString(R.string.cart_empty), Toast.LENGTH_SHORT).show();
                } else {
                    Intent i = new Intent(Home.this, Cart.class);
                    startActivity(i);
                }


                return false;
            }
        });

        action_twenty_four_seven.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {

                Intent intent = new Intent(Home.this , TwentyFourSeven.class);
                startActivity(intent);
                return false;
            }
        });


        dbCount();
        setBadgeCount(Home.this, mCartMenuIcon, String.valueOf(cartCount));
        return super.onCreateOptionsMenu(menu);


    }

    public void searchDialog()
    {
        Dialog dialog = new Dialog(Home.this ,  R.style.DialogTheme);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.getWindow().setBackgroundDrawable(new ColorDrawable(android.graphics.Color.TRANSPARENT));
        dialog.setContentView(R.layout.search_dialog);
        Window window = dialog.getWindow();
        window.setGravity(Gravity.TOP);
        window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        dialog.setCancelable(true);
        dialog.show();

        EditText enterCompany = (EditText) dialog.findViewById(R.id.enterCompany);
        ImageView searchCompany = (ImageView) dialog.findViewById(R.id.searchCompany);

        searchCompany.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(enterCompany.getText().toString().equals(""))
                {
                    Toast.makeText(Home.this, "Enter company name or ID", Toast.LENGTH_SHORT).show();
                }else
                {
                    dialog.dismiss();
                    Intent intent = new Intent(Home.this , CompanyFinder.class);
                    intent.putExtra("keyword" , enterCompany.getText().toString());
                    startActivity(intent);
                }
            }
        });
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
                setBadgeCount(Home.this, mCartMenuIcon, String.valueOf(cartCount));
            }
        }
    };

    @Override
    protected void onResume() {
        super.onResume();

        appUpdateManager.getAppUpdateInfo().addOnSuccessListener(
                appUpdateInfo -> {

                    if (appUpdateInfo.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS) {
                        // If an in-app update is already running, resume the update.
                        try {
                            appUpdateManager.startUpdateFlowForResult(appUpdateInfo, IMMEDIATE, Home.this, UPDATE_REQUEST_CODE);
                        } catch (IntentSender.SendIntentException e) {
                            e.printStackTrace();
                        }
                    }
                });


        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(updateValue, new IntentFilter("update") , RECEIVER_NOT_EXPORTED);
        }else {
            registerReceiver(updateValue, new IntentFilter("update"));
        }


        getDataFromSP();
        dbCount();
        invalidateOptionsMenu();

    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == UPDATE_REQUEST_CODE) {

            if(resultCode == RESULT_CANCELED)
            {
                Log.e("tag" , "result cancal");
            }else if (resultCode == RESULT_IN_APP_UPDATE_FAILED) {
                Log.e("tag","Update flow failed! Result code: " + resultCode);
                finish();
            }
        }
    }


    @Override
    protected void onPause() {
        super.onPause();
        unregisterReceiver(updateValue);

    }

    public void dbCount() {
        cartCount = databaseHandler.getCartCount();

        Log.e("tag", "cart count is : " + cartCount);
    }

    @Override
    public void onBackPressed() {
        if (drawerLayout.isDrawerOpen(GravityCompat.START)) {
            drawerLayout.closeDrawer(GravityCompat.START);
        } else {


            if (bottomNavigationView.getSelectedItemId() == R.id.action_home) {
                if (doubleBackToExitPressedOnce) {
                    super.onBackPressed();
                    return;
                }

                this.doubleBackToExitPressedOnce = true;
                Toast.makeText(this, getResources().getString(R.string.press_again_to_exit), Toast.LENGTH_SHORT).show();

                new Handler().postDelayed(new Runnable() {

                    @Override
                    public void run() {
                        doubleBackToExitPressedOnce = false;
                    }
                }, 2000);
            } else {
                bottomNavigationView.setSelectedItemId(R.id.action_home);
            }


        }
    }

    public void callInAppUpdate()
    {
        appUpdateManager = AppUpdateManagerFactory.create(Home.this);
        // Returns an intent object that you use to check for an update.
        Task<AppUpdateInfo> appUpdateInfoTask = appUpdateManager.getAppUpdateInfo();
        // Checks that the platform will allow the specified type of update.
        appUpdateInfoTask.addOnSuccessListener(appUpdateInfo -> {
            // This example applies an immediate update. To apply a flexible update// instead, pass in AppUpdateType.FLEXIBLE

            if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE && appUpdateInfo.isUpdateTypeAllowed(IMMEDIATE)) {
                try {
                    appUpdateManager.startUpdateFlowForResult(appUpdateInfo, IMMEDIATE, Home.this, UPDATE_REQUEST_CODE);
                } catch (IntentSender.SendIntentException e) {
                    Log.e("tag" , "app update exception is : "+e.getMessage());
                }
            }
        });



    }



}