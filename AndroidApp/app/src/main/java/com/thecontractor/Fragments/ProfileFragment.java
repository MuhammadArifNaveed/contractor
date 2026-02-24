package com.thecontractor.Fragments;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.fragment.app.Fragment;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.gson.Gson;
import com.thecontractor.Cart;
import com.thecontractor.ChangePassword;
import com.thecontractor.Complaints;
import com.thecontractor.Database.DatabaseHandler;
import com.thecontractor.Enquiries;
import com.thecontractor.Estimations;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.SharedPrefManager;
import com.thecontractor.Home;
import com.thecontractor.Login;
import com.thecontractor.Model.UserModel;
import com.thecontractor.Quotations;
import com.thecontractor.R;
import com.thecontractor.SubmitQuotations;
import com.thecontractor.SelectLanguage;
import com.thecontractor.UpdateProfile;
import com.thecontractor.WebViewActivity;


public class ProfileFragment extends Fragment {

    TextView userName, phoneNo;
    ImageView userImage;

    LinearLayout loginCreateAccountLayout , userInfoLayout , menuLayout ,  logoutLayout , aboutUstLayout , advertisementLayout ,  becomeVendorLayout , documentationLayout ,
            privacyPolicyLayout , termsAndConditionsLayout , guideLayout , contactUsLayout;
    LinearLayout enquiries , submitEnquiries , quotations , submitQuotations , complaintHistory , estimationsHistory ,selectLanguage , editProfile , changePassword ;

    String userId;
    private int cartCount = 0;
    private DatabaseHandler databaseHandler;


    public ProfileFragment() {
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
        View view = inflater.inflate(R.layout.fragment_profile, container, false);

        initiate(view);
        clickListener();


        return view;
    }

    public void getDataFromSP() {
        if (!SharedPrefManager.getInstance(getActivity()).getUserObject().equals("")) {
            loginCreateAccountLayout.setVisibility(View.GONE);
            userInfoLayout.setVisibility(View.VISIBLE);
            logoutLayout.setVisibility(View.VISIBLE);
            menuLayout.setVisibility(View.VISIBLE);
            editProfile.setVisibility(View.VISIBLE);
            changePassword.setVisibility(View.VISIBLE);
            contactUsLayout.setVisibility(View.VISIBLE);

            Gson gson = new Gson();
            String json = SharedPrefManager.getInstance(getActivity()).getUserObject();
            UserModel userModel = gson.fromJson(json, UserModel.class);


            userId = userModel.getId();

            Log.e("tag", "user id is : " + userId);

            userName.setText(userModel.getName() + " " + userModel.getSurname());
            phoneNo.setText(userModel.getPhone());


            if (!userModel.getImage().equals("")) {
                Glide.with(getActivity())
                        .load(ApiUrls.PROFILE_IMAGE_URL + userModel.getImage())
                        .apply(new RequestOptions().circleCrop().placeholder(R.drawable.ic_user_profile_white).error(R.drawable.ic_user_profile_white))
                        .into(userImage);
            }


        }else
        {
            loginCreateAccountLayout.setVisibility(View.VISIBLE);
            menuLayout.setVisibility(View.GONE);
            editProfile.setVisibility(View.GONE);
            changePassword.setVisibility(View.GONE);
            userInfoLayout.setVisibility(View.GONE);
            contactUsLayout.setVisibility(View.GONE);
            logoutLayout.setVisibility(View.GONE);
        }
    }

    public void initiate(View view)
    {
        databaseHandler = new DatabaseHandler(getActivity());

        userName = (TextView) view.findViewById(R.id.userName);
        phoneNo = (TextView) view.findViewById(R.id.phoneNo);
        userImage = (ImageView) view.findViewById(R.id.userImage);


        loginCreateAccountLayout = (LinearLayout) view.findViewById(R.id.loginCreateAccountLayout);
        userInfoLayout = (LinearLayout) view.findViewById(R.id.userInfoLayout);
        menuLayout = (LinearLayout) view.findViewById(R.id.menuLayout);
        logoutLayout = (LinearLayout) view.findViewById(R.id.logoutLayout);
        enquiries = (LinearLayout) view.findViewById(R.id.enquiries);
        submitEnquiries = (LinearLayout) view.findViewById(R.id.submitEnquiries);
        quotations = (LinearLayout) view.findViewById(R.id.quotations);
        submitQuotations = (LinearLayout) view.findViewById(R.id.submitQuotations);
        complaintHistory = (LinearLayout) view.findViewById(R.id.complaintHistory);
        estimationsHistory = (LinearLayout) view.findViewById(R.id.estimationsHistory);
        selectLanguage = (LinearLayout) view.findViewById(R.id.selectLanguage);
        editProfile = (LinearLayout) view.findViewById(R.id.editProfile);
        changePassword = (LinearLayout) view.findViewById(R.id.changePassword);
        aboutUstLayout = (LinearLayout) view.findViewById(R.id.aboutUstLayout);
        advertisementLayout = (LinearLayout) view.findViewById(R.id.advertisementLayout);
        becomeVendorLayout = (LinearLayout) view.findViewById(R.id.becomeVendorLayout);
        documentationLayout = (LinearLayout) view.findViewById(R.id.documentationLayout);
        privacyPolicyLayout = (LinearLayout) view.findViewById(R.id.privacyPolicyLayout);
        termsAndConditionsLayout = (LinearLayout) view.findViewById(R.id.termsAndConditionsLayout);
        guideLayout = (LinearLayout) view.findViewById(R.id.guideLayout);
        contactUsLayout = (LinearLayout) view.findViewById(R.id.contactUsLayout);
    }

    public void clickListener()
    {
        loginCreateAccountLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent =  new Intent(getActivity() , Login.class);
                intent.putExtra("requestForLogin" , "yes");
                loginActivityResultLauncher.launch(intent);
            }
        });

        enquiries.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!SharedPrefManager.getInstance(getActivity()).getUserObject().equals("")) {
                    Intent intent =  new Intent(getActivity() , Enquiries.class);
                    startActivity(intent);
                }else
                {
                    Intent intent =  new Intent(getActivity() , Login.class);
                    intent.putExtra("requestForLogin" , "yes");
                    loginActivityResultLauncher.launch(intent);
                }

            }
        });

        submitEnquiries.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                dbCount();

                if (cartCount == 0) {
                    Toast.makeText(getActivity(), getResources().getString(R.string.cart_empty), Toast.LENGTH_SHORT).show();
                } else {
                    Intent intent =  new Intent(getActivity() , Cart.class);
                    startActivity(intent);
                }


            }
        });

        quotations.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (!SharedPrefManager.getInstance(getActivity()).getUserObject().equals("")) {
                    Intent intent =  new Intent(getActivity() , Quotations.class);
                    startActivity(intent);
                }else
                {
                    Intent intent =  new Intent(getActivity() , Login.class);
                    intent.putExtra("requestForLogin" , "yes");
                    loginActivityResultLauncher.launch(intent);
                }


            }
        });

        submitQuotations.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


                if (!SharedPrefManager.getInstance(getActivity()).getUserObject().equals("")) {
                    Intent intent =  new Intent(getActivity() , SubmitQuotations.class);
                    startActivity(intent);
                }else
                {
                    Intent intent =  new Intent(getActivity() , Login.class);
                    intent.putExtra("requestForLogin" , "yes");
                    loginActivityResultLauncher.launch(intent);
                }

            }
        });

        complaintHistory.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!SharedPrefManager.getInstance(getActivity()).getUserObject().equals("")) {
                    Intent intent =  new Intent(getActivity() , Complaints.class);
                    startActivity(intent);
                }else
                {
                    Intent intent =  new Intent(getActivity() , Login.class);
                    intent.putExtra("requestForLogin" , "yes");
                    loginActivityResultLauncher.launch(intent);
                }

            }
        });

        estimationsHistory.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!SharedPrefManager.getInstance(getActivity()).getUserObject().equals("")) {
                    Intent intent =  new Intent(getActivity() , Estimations.class);
                    startActivity(intent);
                }else
                {
                    Intent intent =  new Intent(getActivity() , Login.class);
                    intent.putExtra("requestForLogin" , "yes");
                    loginActivityResultLauncher.launch(intent);
                }

            }
        });
        selectLanguage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent =  new Intent(getActivity() , SelectLanguage.class);
                intent.putExtra("from" , "profileFragment");
                profileActivityResultLauncher.launch(intent);
            }
        });

        editProfile.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!SharedPrefManager.getInstance(getActivity()).getUserObject().equals("")) {
                    Intent intent =  new Intent(getActivity() , UpdateProfile.class);
                    startActivity(intent);
                }else
                {
                    Intent intent =  new Intent(getActivity() , Login.class);
                    intent.putExtra("requestForLogin" , "yes");
                    loginActivityResultLauncher.launch(intent);
                }

            }
        });

        changePassword.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!SharedPrefManager.getInstance(getActivity()).getUserObject().equals("")) {
                    Intent intent =  new Intent(getActivity() , ChangePassword.class);
                    startActivity(intent);
                }else
                {
                    Intent intent =  new Intent(getActivity() , Login.class);
                    intent.putExtra("requestForLogin" , "yes");
                    loginActivityResultLauncher.launch(intent);
                }

            }
        });

        aboutUstLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity() , WebViewActivity.class);
                intent.putExtra("link" , ApiUrls.BASE_URL + "about-app");
                intent.putExtra("page" , getResources().getString(R.string.about_us));
                startActivity(intent);
            }
        });
        advertisementLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity() , WebViewActivity.class);
                intent.putExtra("link" , ApiUrls.BASE_URL + "advertisement-app");
                intent.putExtra("page" , getResources().getString(R.string.advertisement));
                startActivity(intent);
            }
        });
        becomeVendorLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity() , WebViewActivity.class);
                intent.putExtra("link" , ApiUrls.BASE_URL + "become-a-vender-app");
                intent.putExtra("page" , getResources().getString(R.string.become_a_vendor));
                startActivity(intent);
            }
        });
        documentationLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity() , WebViewActivity.class);
                intent.putExtra("link" , ApiUrls.BASE_URL + "documentations-app");
                intent.putExtra("page" , getResources().getString(R.string.documentations));
                startActivity(intent);
            }
        });
        privacyPolicyLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity() , WebViewActivity.class);
                intent.putExtra("link" , ApiUrls.BASE_URL + "privacy-policy-app");
                intent.putExtra("page" , getResources().getString(R.string.privacy_policy));
                startActivity(intent);
            }
        });
        termsAndConditionsLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity() , WebViewActivity.class);
                intent.putExtra("link" , ApiUrls.BASE_URL + "terms-and-conditions-app");
                intent.putExtra("page" , getResources().getString(R.string.terms_and_conditions));
                startActivity(intent);
            }
        });
        guideLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity() , WebViewActivity.class);
                intent.putExtra("link" , ApiUrls.BASE_URL + "guide-app");
                intent.putExtra("page" , getResources().getString(R.string.guide));
                startActivity(intent);
            }
        });
        contactUsLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity() , WebViewActivity.class);
                intent.putExtra("link" , ApiUrls.BASE_URL + "contact-app");
                intent.putExtra("page" , getResources().getString(R.string.contact_us));
                startActivity(intent);
            }
        });

        logoutLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                AlertDialog alertDialog = AlertDialog();
                alertDialog.show();
            }
        });
    }


    public void dbCount() {
        cartCount = databaseHandler.getCartCount();

        Log.e("tag", "cart count is : " + cartCount);
    }

    private AlertDialog AlertDialog() {
        AlertDialog myDialogBox = new AlertDialog.Builder(getActivity())
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


    public void logout() {

        SharedPrefManager.getInstance(getActivity()).userLogout();

        Intent intent = new Intent(getActivity(), Home.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        getActivity().finish();

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

                getActivity().finish();
                startActivity(getActivity().getIntent());
            }
        }
    });

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

    @Override
    public void onResume() {
        super.onResume();
        getDataFromSP();
    }
}