package com.thecontractor.Global;

import java.util.HashMap;

public class ApiUrls {
    
    //public static final String BASE_URL = "https://thecontractor.ae/";
    public static final String BASE_URL = "https://contractor.bidcont.com/";
    public static final String API_URL = BASE_URL+ "rest/";
    public static final String PROFILE_IMAGE_URL = BASE_URL + "uploads/users/";
    public static final String PROFILE_VIDEO_URL = BASE_URL + "uploads/applicant_videos/";
    public static final String CATEGORIES_IMAGE_URL = BASE_URL + "uploads/icons/";
    public static final String COMPANIES_IMAGE_URL = BASE_URL + "uploads/companies/";
    public static final String QUOTATION_IMAGE_URL = BASE_URL + "uploads/quotations/";
    public static final String WORKSHOP_IMAGE_URL = BASE_URL + "uploads/workshop/";
    public static final String DOWNLOAD_QUOTATIONS_IMAGE_URL = BASE_URL + "uploads/documents/";

    public static HashMap<String, String> remoteMessageHeader = null;

    public static HashMap<String, String> getRemoteMessageHeader()
    {
        if(remoteMessageHeader == null)
        {
            remoteMessageHeader = new HashMap<>();
            remoteMessageHeader.put("Authorization" , "key=AAAAZop1KxM:APA91bHYBOH8GqORrZuHkFXhhflCljdnkD-rdLfEJI8MVKAxc2MPuqOq8dq4fZsIS-C3gxo5HkaMTsZk6t1b5Fz7E_xKCE4Gh9Dd-SfhZI5oELRSm7T7t2OiHp4qqLRlXXmthwxAgMzR");
            remoteMessageHeader.put("Content-Type" , "application/json");
        }
        return remoteMessageHeader;
    }
}

