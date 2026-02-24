package com.thecontractor.Global;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.os.Build;
import android.util.DisplayMetrics;
import android.util.Log;

import java.util.Locale;

public class LocaleHelper {

    public static void setLocale(Context context, String language) {
        persist(context, language);

        setApplicationLocale(context , language);
    }
    private static String getPersistedData(Context context) {
        return SharedPrefManager.getInstance(context).getUserLanguage();
    }
    private static void persist(Context context, String language) {
        SharedPrefManager.getInstance(context).userLanguage(language);
    }

    private static void setApplicationLocale(Context context , String locale) {
        Resources resources = context.getResources();
        DisplayMetrics dm = resources.getDisplayMetrics();
        Configuration config = resources.getConfiguration();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            config.setLocale(new Locale(locale.toLowerCase()));
        } else {
            config.locale = new Locale(locale.toLowerCase());
        }
        resources.updateConfiguration(config, dm);
    }
}
