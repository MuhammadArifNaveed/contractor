package com.thecontractor.Global;

import android.content.Context;
import android.content.SharedPreferences;

public class SharedPrefManager {

    private static SharedPrefManager mInstance;
    private static Context mCtx;



    SharedPreferences sharedPreferencesForUserData;
    SharedPreferences.Editor editorForUserData;
    private static final String SHARED_PREF_USER_DATA = "userData";

    private static final String USER_OBJECT = "userObject";
    private static final String CART_LIMIT = "cartLimit";
    private static final String CART_AVAILABLE_LIMIT = "cartAvailableLimit";
    private static final String VENDOR_OBJECT = "vendorObject";
    private static final String USER_SELECTED_LANGUAGE = "userLanguage";


    private SharedPrefManager(Context context) {
        mCtx = context;

        sharedPreferencesForUserData = context.getSharedPreferences(SHARED_PREF_USER_DATA, Context.MODE_PRIVATE);
        editorForUserData = sharedPreferencesForUserData.edit();

    }

    public static synchronized SharedPrefManager getInstance(Context context) {
        if (mInstance == null) {
            mInstance = new SharedPrefManager(context);
        }
        return mInstance;
    }

    

    public boolean userLogin(String userModel) {
        editorForUserData.putString(USER_OBJECT, userModel);
        editorForUserData.apply();
        return true;
    }

    public boolean cartLimit(int cartLimit , int cartAvailableLimit) {
        editorForUserData.putInt(CART_LIMIT, cartLimit);
        editorForUserData.putInt(CART_AVAILABLE_LIMIT, cartAvailableLimit);
        editorForUserData.apply();
        return true;
    }
    public boolean vendorLogin(String userModel) {
        editorForUserData.putString(VENDOR_OBJECT, userModel);
        editorForUserData.apply();
        return true;
    }



    public boolean userLanguage(String language) {
        editorForUserData.putString(USER_SELECTED_LANGUAGE, language);
        editorForUserData.apply();
        return true;
    }


    public boolean userLogout() {
        SharedPreferences sharedPreferences = mCtx.getSharedPreferences(SHARED_PREF_USER_DATA, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();
        return true;
    }

    public String getUserObject() {
        return sharedPreferencesForUserData.getString(USER_OBJECT, "");
    }


    public int getCartLimit() {
        return sharedPreferencesForUserData.getInt(CART_LIMIT, 0);
    }


    public int getCartAvailableLimit() {
        return sharedPreferencesForUserData.getInt(CART_AVAILABLE_LIMIT, 0);
    }


    public String getVendorObject() {
        return sharedPreferencesForUserData.getString(VENDOR_OBJECT, "");
    }


    public String getUserLanguage() {
        return sharedPreferencesForUserData.getString(USER_SELECTED_LANGUAGE, "");
    }


}
