package com.thecontractor.Database;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

import com.thecontractor.Model.SelectedCompaniesModel;

import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.HashMap;


public class DatabaseHandler extends SQLiteOpenHelper {

    private static String DB_NAME = "Companies";
    private static int DB_VERSION = 1;
    private SQLiteDatabase db;

    public static final String CART_TABLE = "cart";

    public static final String COLUMN_ID = "id";
    public static final String COLUMN_COMPANY_ID = "company_id";
    public static final String COLUMN_COMPANY_NAME = "company_name";
    public static final String COLUMN_COMPANY_ARABIC_NAME = "company_arabic_name";
    public static final String COLUMN_COMPANY_IMAGE = "company_image";
    public static final String COLUMN_COMPANY_CATEGORIES = "company_categories";
    public static final String COLUMN_COMPANY_ARABIC_CATEGORIES = "company_arabic_categories";
    public static final String COLUMN_COMPANY_REVIEW_COUNT = "company_review_count";
    public static final String COLUMN_COMPANY_RATING = "company_rating";
    public static final String COLUMN_COMPANY_VERIFIED = "company_verified";


    public DatabaseHandler(Context context) {
        super(context, DB_NAME, null, DB_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        this.db = db;

        String exe = "CREATE TABLE IF NOT EXISTS " + CART_TABLE
                + "(" + COLUMN_ID + " integer primary key, "
                + COLUMN_COMPANY_ID + " integer NOT NULL,"
                + COLUMN_COMPANY_NAME + " TEXT NOT NULL, "
                + COLUMN_COMPANY_ARABIC_NAME + " TEXT NOT NULL, "
                + COLUMN_COMPANY_IMAGE + " TEXT NOT NULL, "
                + COLUMN_COMPANY_CATEGORIES + " TEXT NOT NULL, "
                + COLUMN_COMPANY_ARABIC_CATEGORIES + " TEXT NOT NULL, "
                + COLUMN_COMPANY_REVIEW_COUNT + " TEXT NOT NULL, "
                + COLUMN_COMPANY_RATING + " TEXT NOT NULL, "
                + COLUMN_COMPANY_VERIFIED + " TEXT NOT NULL "
                + ")";

        db.execSQL(exe);
    }

    // set new data or update data if already existing in local cart table
    public boolean setCart(HashMap<String, String> map) {
        db = getWritableDatabase();

        ContentValues values = new ContentValues();

            values.put(COLUMN_ID, map.get(COLUMN_ID));
        values.put(COLUMN_COMPANY_ID, map.get(COLUMN_COMPANY_ID));
        values.put(COLUMN_COMPANY_NAME, map.get(COLUMN_COMPANY_NAME));
        values.put(COLUMN_COMPANY_ARABIC_NAME, map.get(COLUMN_COMPANY_ARABIC_NAME));
        values.put(COLUMN_COMPANY_IMAGE, map.get(COLUMN_COMPANY_IMAGE));
        values.put(COLUMN_COMPANY_CATEGORIES, map.get(COLUMN_COMPANY_CATEGORIES));
        values.put(COLUMN_COMPANY_ARABIC_CATEGORIES, map.get(COLUMN_COMPANY_ARABIC_CATEGORIES));
        values.put(COLUMN_COMPANY_REVIEW_COUNT, map.get(COLUMN_COMPANY_REVIEW_COUNT));
        values.put(COLUMN_COMPANY_RATING, map.get(COLUMN_COMPANY_RATING));
        values.put(COLUMN_COMPANY_VERIFIED, map.get(COLUMN_COMPANY_VERIFIED));

        db.insert(CART_TABLE, null, values);
        return true;

    }

    // check specific item has in cart table
    public boolean isInCart(String id) {
        db = getReadableDatabase();
        String qry = "Select *  from " + CART_TABLE + " where " + COLUMN_COMPANY_ID + " = " + id;
        Cursor cursor = db.rawQuery(qry, null);
        cursor.moveToFirst();
        if (cursor.getCount() > 0) return true;

        return false;
    }



    // get total cart item
    public int getCartCount() {
        db = getReadableDatabase();
        String qry = "Select *  from " + CART_TABLE;
        Cursor cursor = db.rawQuery(qry, null);
        return cursor.getCount();
    }


    public ArrayList<SelectedCompaniesModel> getAllSelectedCompaniesFromDB() {
        ArrayList<SelectedCompaniesModel> selectedCompanies = new ArrayList<>();
        db = getReadableDatabase();


        String qry = "Select *  from " + CART_TABLE;
        Cursor c = db.rawQuery(qry, null);


        if (c != null) {
            while (c.moveToNext()) {

                selectedCompanies.add(new SelectedCompaniesModel(c.getString(c.getColumnIndex(COLUMN_COMPANY_ID)), c.getString(c.getColumnIndex(COLUMN_COMPANY_NAME)), c.getString(c.getColumnIndex(COLUMN_COMPANY_ARABIC_NAME)),c.getString(c.getColumnIndex(COLUMN_COMPANY_IMAGE)),c.getString(c.getColumnIndex(COLUMN_COMPANY_CATEGORIES)),c.getString(c.getColumnIndex(COLUMN_COMPANY_ARABIC_CATEGORIES)),c.getString(c.getColumnIndex(COLUMN_COMPANY_REVIEW_COUNT)),c.getString(c.getColumnIndex(COLUMN_COMPANY_RATING)),c.getString(c.getColumnIndex(COLUMN_COMPANY_VERIFIED)) , "" , "" , "" , "" , ""));
            }
        }


        return selectedCompanies;

    }



    // delete cart table
    public void clearCart() {
        db = getReadableDatabase();
        db.execSQL("delete from " + CART_TABLE);
    }





    // delete specifiec item form cart table
    public void removeItemFromCart(String id) {
        db = getReadableDatabase();
        db.execSQL("delete from " + CART_TABLE + " where " + COLUMN_COMPANY_ID + " = " + id);
    }



    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

    }


}
