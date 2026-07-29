package com.thecontractor.Database;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.DatabaseUtils;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

import androidx.annotation.Nullable;

import com.thecontractor.Model.SelectedFreelancersDatabaseModel;
import com.thecontractor.Model.SelectedFreelancersDateDatabaseModel;
import com.thecontractor.Model.SelectedFreelancersDetailDatabaseModel;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FreelancerDatabaseHelper extends SQLiteOpenHelper {

    private static final String DATABASE_NAME = "freelancers.db";
    private static final int DATABASE_VERSION = 1;

    // Table: freelancers
    public static final String TABLE_FREELANCERS = "freelancers";
    public static final String COLUMN_FREELANCER_ID = "freelancer_id";
    public static final String COLUMN_ID = "id";
    public static final String COLUMN_UUID = "uuid";
    public static final String COLUMN_CITY_ID = "city_id";
    public static final String COLUMN_NAME = "name";
    public static final String COLUMN_IMAGE = "image"; // <-- ADDED
    public static final String COLUMN_CATEGORY = "category"; // <-- ADDED
    public static final String COLUMN_HOURLY_RATE = "hourly_rate";
    public static final String COLUMN_COMMISSION = "commission";
    public static final String COLUMN_CITY = "city";
    public static final String COLUMN_AREA = "area";
    public static final String COLUMN_TRANSPORTATION_CHARGES = "transportation_charges";

    // ... (rest of the constants are unchanged)
    public static final String TABLE_FREELANCER_DETAILS = "freelancer_details";
    public static final String COLUMN_DETAIL_ID = "detail_id";
    public static final String COLUMN_FREELANCER_ID_FK = "freelancer_id_fk";
    public static final String COLUMN_IS_HOURLY = "is_hourly";
    public static final String COLUMN_FROM_TIME = "from_time";
    public static final String COLUMN_TO_TIME = "to_time";
    public static final String COLUMN_IS_PICKED = "is_picked";
    public static final String TABLE_FREELANCER_DATES = "freelancer_dates";
    public static final String COLUMN_DATE_ID = "date_id";
    public static final String COLUMN_DETAIL_ID_FK = "detail_id_fk";
    public static final String COLUMN_BOOKING_DATE = "booking_date";


    public FreelancerDatabaseHelper(@Nullable Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        final String CREATE_FREELANCERS_TABLE = "CREATE TABLE " + TABLE_FREELANCERS + " (" +
                COLUMN_FREELANCER_ID + " INTEGER PRIMARY KEY AUTOINCREMENT, " +
                COLUMN_ID + " TEXT NOT NULL, " +
                COLUMN_UUID + " TEXT, " +
                COLUMN_CITY_ID + " TEXT, " +
                COLUMN_NAME + " TEXT NOT NULL, " +
                COLUMN_IMAGE + " TEXT, " +
                COLUMN_CATEGORY + " TEXT, " +
                COLUMN_HOURLY_RATE + " TEXT, " +
                COLUMN_COMMISSION + " TEXT, " +
                COLUMN_CITY + " TEXT, " +
                COLUMN_AREA + " TEXT, " +
                COLUMN_TRANSPORTATION_CHARGES + " REAL DEFAULT 0);";

        final String CREATE_DETAILS_TABLE = "CREATE TABLE " + TABLE_FREELANCER_DETAILS + " (" +
                COLUMN_DETAIL_ID + " INTEGER PRIMARY KEY AUTOINCREMENT, " +
                COLUMN_FREELANCER_ID_FK + " INTEGER NOT NULL, " +
                COLUMN_IS_HOURLY + " TEXT NOT NULL, " +
                COLUMN_FROM_TIME + " TEXT, " +
                COLUMN_TO_TIME + " TEXT, " +
                COLUMN_IS_PICKED + " TEXT NOT NULL, " +
                "FOREIGN KEY(" + COLUMN_FREELANCER_ID_FK + ") REFERENCES " + TABLE_FREELANCERS + "(" + COLUMN_FREELANCER_ID + ") ON DELETE CASCADE);";

        final String CREATE_DATES_TABLE = "CREATE TABLE " + TABLE_FREELANCER_DATES + " (" +
                COLUMN_DATE_ID + " INTEGER PRIMARY KEY AUTOINCREMENT, " +
                COLUMN_DETAIL_ID_FK + " INTEGER NOT NULL, " +
                COLUMN_BOOKING_DATE + " TEXT NOT NULL, " +
                "FOREIGN KEY(" + COLUMN_DETAIL_ID_FK + ") REFERENCES " + TABLE_FREELANCER_DETAILS + "(" + COLUMN_DETAIL_ID + ") ON DELETE CASCADE);";


        db.execSQL(CREATE_FREELANCERS_TABLE);
        db.execSQL(CREATE_DETAILS_TABLE);
        db.execSQL(CREATE_DATES_TABLE);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_FREELANCER_DATES);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_FREELANCER_DETAILS);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_FREELANCERS);
        onCreate(db);
    }

    @Override
    public void onConfigure(SQLiteDatabase db) {
        super.onConfigure(db);
        db.setForeignKeyConstraintsEnabled(true);
    }

    public boolean addFreelancerBooking(SelectedFreelancersDatabaseModel freelancer) {
        SQLiteDatabase db = this.getWritableDatabase();
        db.beginTransaction();

        try {
            ContentValues freelancerValues = new ContentValues();
            freelancerValues.put(COLUMN_ID, freelancer.getId());
            freelancerValues.put(COLUMN_UUID, freelancer.getUuid());
            freelancerValues.put(COLUMN_CITY_ID, freelancer.getCityId());
            freelancerValues.put(COLUMN_NAME, freelancer.getName());
            freelancerValues.put(COLUMN_IMAGE, freelancer.getImage()); // <-- ADDED
            freelancerValues.put(COLUMN_CATEGORY, freelancer.getCategory()); // <-- ADDED
            freelancerValues.put(COLUMN_HOURLY_RATE, freelancer.getHourlyRate());
            freelancerValues.put(COLUMN_COMMISSION, freelancer.getCommission());
            freelancerValues.put(COLUMN_CITY, freelancer.getCity());
            freelancerValues.put(COLUMN_AREA, freelancer.getArea());
            freelancerValues.put(COLUMN_TRANSPORTATION_CHARGES, freelancer.getTransportation_charges());
            long freelancerId = db.insert(TABLE_FREELANCERS, null, freelancerValues);
            if (freelancerId == -1) return false;

            // ... (rest of the addFreelancerBooking method is unchanged)
            SelectedFreelancersDetailDatabaseModel detail = freelancer.getDetail();
            ContentValues detailValues = new ContentValues();
            detailValues.put(COLUMN_FREELANCER_ID_FK, freelancerId);
            detailValues.put(COLUMN_IS_HOURLY, detail.getIsHourly());
            detailValues.put(COLUMN_FROM_TIME, detail.getFromTime());
            detailValues.put(COLUMN_TO_TIME, detail.getToTime());
            detailValues.put(COLUMN_IS_PICKED, detail.getIsPicked());
            long detailId = db.insert(TABLE_FREELANCER_DETAILS, null, detailValues);
            if (detailId == -1) return false;

            ArrayList<SelectedFreelancersDateDatabaseModel> dates = detail.getDates();
            for (SelectedFreelancersDateDatabaseModel date : dates) {
                ContentValues dateValues = new ContentValues();
                dateValues.put(COLUMN_DETAIL_ID_FK, detailId);
                dateValues.put(COLUMN_BOOKING_DATE, date.getDate());
                db.insert(TABLE_FREELANCER_DATES, null, dateValues);
            }

            db.setTransactionSuccessful();
            return true;
        } catch (Exception e) {
            Log.e("FreelancerDbHelper", "Error while adding freelancer booking", e);
            return false;
        } finally {
            db.endTransaction();
            db.close();
        }
    }

    public ArrayList<SelectedFreelancersDatabaseModel> getAllFreelancers() {
        Map<String, SelectedFreelancersDatabaseModel> freelancerMap = new HashMap<>();
        String query = "SELECT * FROM " + TABLE_FREELANCERS + " f " +
                "LEFT JOIN " + TABLE_FREELANCER_DETAILS + " fd ON f." + COLUMN_FREELANCER_ID + " = fd." + COLUMN_FREELANCER_ID_FK + " " +
                "LEFT JOIN " + TABLE_FREELANCER_DATES + " fdt ON fd." + COLUMN_DETAIL_ID + " = fdt." + COLUMN_DETAIL_ID_FK +
                " ORDER BY f." + COLUMN_FREELANCER_ID;

        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = null;

        try {
            cursor = db.rawQuery(query, null);

            if (cursor.moveToFirst()) {
                do {
                    String freelancerId = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_ID));
                    SelectedFreelancersDatabaseModel currentFreelancer;

                    if (!freelancerMap.containsKey(freelancerId)) {
                        currentFreelancer = new SelectedFreelancersDatabaseModel();
                        currentFreelancer.setId(freelancerId);
                        currentFreelancer.setUuid(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_UUID)));
                        currentFreelancer.setCityId(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_CITY_ID)));
                        currentFreelancer.setName(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_NAME)));
                        currentFreelancer.setImage(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_IMAGE))); // <-- ADDED
                        currentFreelancer.setCategory(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_CATEGORY))); // <-- ADDED
                        currentFreelancer.setHourlyRate(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_HOURLY_RATE)));
                        currentFreelancer.setCommission(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_COMMISSION)));
                        currentFreelancer.setCity(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_CITY)));
                        currentFreelancer.setArea(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_AREA)));
                        currentFreelancer.setTransportation_charges(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_TRANSPORTATION_CHARGES)));

                        // ... (rest of the getAllFreelancers method is unchanged)
                        SelectedFreelancersDetailDatabaseModel detail = new SelectedFreelancersDetailDatabaseModel();
                        detail.setIsHourly(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_IS_HOURLY)));
                        detail.setFromTime(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_FROM_TIME)));
                        detail.setToTime(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_TO_TIME)));
                        detail.setIsPicked(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_IS_PICKED)));
                        detail.setDates(new ArrayList<>());

                        currentFreelancer.setDetail(detail);
                        freelancerMap.put(freelancerId, currentFreelancer);
                    } else {
                        currentFreelancer = freelancerMap.get(freelancerId);
                    }

                    String bookingDate = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_BOOKING_DATE));
                    if (bookingDate != null) {
                        SelectedFreelancersDateDatabaseModel dateModel = new SelectedFreelancersDateDatabaseModel();
                        dateModel.setDate(bookingDate);
                        currentFreelancer.getDetail().getDates().add(dateModel);
                    }

                } while (cursor.moveToNext());
            }
        } catch (Exception e) {
            Log.e("FreelancerDbHelper", "Error while getting all freelancers", e);
        } finally {
            if (cursor != null) {
                cursor.close();
            }
            db.close();
        }
        return new ArrayList<>(freelancerMap.values());
    }

    // --- NO CHANGES NEEDED for delete and checkExists ---
    public int deleteFreelancer(String freelancerUniqueId) {
        SQLiteDatabase db = this.getWritableDatabase();
        int rowsDeleted = 0;
        try {
            String whereClause = COLUMN_ID + " = ?";
            String[] whereArgs = {freelancerUniqueId};
            rowsDeleted = db.delete(TABLE_FREELANCERS, whereClause, whereArgs);
        } catch (Exception e) {
            Log.e("FreelancerDbHelper", "Error while deleting freelancer", e);
        } finally {
            db.close();
        }
        return rowsDeleted;
    }

    public boolean checkFreelancerExists(String freelancerUniqueId) {
        SQLiteDatabase db = this.getReadableDatabase();
        long count = 0;
        try {
            String selection = COLUMN_ID + " = ?";
            String[] selectionArgs = {freelancerUniqueId};
            count = DatabaseUtils.queryNumEntries(db, TABLE_FREELANCERS, selection, selectionArgs);
        } catch (Exception e) {
            Log.e("FreelancerDbHelper", "Error while checking if freelancer exists", e);
        } finally {
            if (db != null && db.isOpen()) {
                db.close();
            }
        }
        return count > 0;
    }

    public boolean updateTransportationCharges(String freelancerUniqueId, String newCharge) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues values = new ContentValues();
        values.put(COLUMN_TRANSPORTATION_CHARGES, newCharge);

        // Update the main freelancers table using the unique string ID
        String whereClause = COLUMN_ID + " = ?";
        String[] whereArgs = {freelancerUniqueId};

        int rowsAffected = db.update(TABLE_FREELANCERS, values, whereClause, whereArgs);
        db.close();

        return rowsAffected > 0;
    }

    public void resetDatabase() {
        SQLiteDatabase db = this.getWritableDatabase();
        try {
            // Drop the tables in reverse order of dependency
            db.execSQL("DROP TABLE IF EXISTS " + TABLE_FREELANCER_DATES);
            db.execSQL("DROP TABLE IF EXISTS " + TABLE_FREELANCER_DETAILS);
            db.execSQL("DROP TABLE IF EXISTS " + TABLE_FREELANCERS);
            // Recreate the tables by calling onCreate
            onCreate(db);
            Log.d("FreelancerDbHelper", "Database has been reset.");
        } catch (Exception e) {
            Log.e("FreelancerDbHelper", "Error while resetting database", e);
        } finally {
            if (db != null && db.isOpen()) {
                db.close();
            }
        }
    }

}