package com.thecontractor.RetrofitLibrary;

import com.thecontractor.Model.BasicResponseModel;

import java.util.HashMap;

import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.HeaderMap;
import retrofit2.http.Multipart;
import retrofit2.http.POST;
import retrofit2.http.Part;

public interface RetrofitApi {




    @Multipart
    @POST("Account/phone_check")
    Call<BasicResponseModel> otpLoginRegister(@Part("user_phone") RequestBody user_phone);


    @Multipart
    @POST("Account/user_register")
    Call<BasicResponseModel> register(@Part("username") RequestBody username,
                                      @Part("user_name") RequestBody user_first_name,
                                           @Part("sur_name") RequestBody user_last_name,
                                           @Part("user_phone") RequestBody user_phone,
                                           @Part("user_email") RequestBody user_email,
                                           @Part("user_password") RequestBody user_password,
                                           @Part("country_id") RequestBody user_country_id ,
                                           @Part("device_type") RequestBody device_type,
                                           @Part("firebase_token") RequestBody firebase_token);

    @Multipart
    @POST("Account/update_user_profile")
    Call<BasicResponseModel> updateProfile(@Part("user_id") RequestBody user_id,
                                           @Part("user_name") RequestBody user_first_name,
                                           @Part("surname") RequestBody user_last_name ,
                                           @Part("user_phone") RequestBody user_phone ,
                                           @Part("user_email") RequestBody user_email,
                                           @Part("address") RequestBody user_address,
                                           @Part("city") RequestBody city,
                                           @Part("country") RequestBody country,
                                           @Part("job_category") RequestBody job_category,
                                           @Part MultipartBody.Part file ,
                                           @Part MultipartBody.Part file2,
                                           @Part MultipartBody.Part file3);


    @Multipart
    @POST("Account/user_login")
    Call<BasicResponseModel> login(@Part("user_phone") RequestBody user_phone,
                                   @Part("user_password") RequestBody user_password,
                                   @Part("device_type") RequestBody device_type,
                                   @Part("firebase_token") RequestBody firebase_token);

    @Multipart
    @POST("Account/get_user_details_by_id")
    Call<BasicResponseModel> getUserDetailById(@Part("user_id") RequestBody user_id);

    @Multipart
    @POST("Account/update_password")
    Call<BasicResponseModel> newPassword(@Part("new_password") RequestBody new_password,
                                         @Part("user_phone") RequestBody user_phone);




    @Multipart
    @POST("Account/change_password")
    Call<BasicResponseModel> changePassword(@Part("user_email") RequestBody user_id,
                                            @Part("old_password") RequestBody old_password,
                                            @Part("new_password") RequestBody new_password);


    @Multipart
    @POST("Home/categories")
    Call<BasicResponseModel> categoriesAPI(@Part("user_id") RequestBody user_id);



    @POST("Home/categories_with_sub_categories")
    Call<BasicResponseModel> categoriesWithSubCategoriesAPI();


    @POST("Home/get_estimation_categories")
    Call<BasicResponseModel> estimationCategoriesAPI();


    @POST("Home/get_search")
    Call<BasicResponseModel> searchDataAPI();


    @Multipart
    @POST("Home/category_wise_companies")
    Call<BasicResponseModel> categoryWiseCompanies(@Part("category_id") RequestBody category_id ,
                                                   @Part("page") RequestBody page);



    @Multipart
    @POST("Home/find_companies")
    Call<BasicResponseModel> findCompanies(@Part("category_id") RequestBody category_id ,
                                           @Part("sub_category") RequestBody sub_category ,
                                           @Part("page") RequestBody page);





    @Multipart
    @POST("Home/sub_category_wise_companies")
    Call<BasicResponseModel> subCategoryWiseCompanies(@Part("category_id") RequestBody category_id ,
                                                      @Part("sub_category_id") RequestBody sub_category_id);


    @Multipart
    @POST("Home/company_detail")
    Call<BasicResponseModel> companyDetail(@Part("company_id") RequestBody company_id);


    @Multipart
    @POST("Home/submit_complaint")
    Call<BasicResponseModel> submitComplain(@Part("company_id") RequestBody company_id,
                                           @Part("user_id") RequestBody user_id,
                                           @Part("complaint") RequestBody complaint);

    @Multipart
    @POST("Home/send_enquiries")
    Call<BasicResponseModel> submitEnquiry(@Part("user_id") RequestBody user_id,
                                           @Part("user_name") RequestBody user_first_name,
                                           @Part("surname") RequestBody surname ,
                                           @Part("user_phone") RequestBody user_phone,
                                           @Part("user_email") RequestBody user_email ,
                                           @Part("companies") RequestBody companies);



    @Multipart
    @POST("Home/recent_enquiries")
    Call<BasicResponseModel> recentEnquiries(@Part("user_id") RequestBody user_id,
                                             @Part("page") RequestBody page);

    @Multipart
    @POST("Home/enquiry_detail")
    Call<BasicResponseModel> enquiryDetail(@Part("id") RequestBody id ,
                                           @Part("user_id") RequestBody user_id);


    @Multipart
    @POST("Home/recent_complaints")
    Call<BasicResponseModel> recentComplaints(@Part("user_id") RequestBody user_id,
                                              @Part("page") RequestBody page);

    @Multipart
    @POST("Home/complaint")
    Call<BasicResponseModel> complaintDetail(@Part("id") RequestBody id ,
                                           @Part("user_id") RequestBody user_id);

    @Multipart
    @POST("Home/estimation_requests")
    Call<BasicResponseModel> estimationRequests(@Part("user_id") RequestBody user_id,
                                                @Part("page") RequestBody page);

    @Multipart
    @POST("Home/estimation_request")
    Call<BasicResponseModel> estimationDetail(@Part("id") RequestBody id ,
                                              @Part("user_id") RequestBody user_id);

    @Multipart
    @POST("Home/request_a_quotation")
    Call<BasicResponseModel> requestQuotation(@Part("user_id") RequestBody user_id,
                                           @Part("user_name") RequestBody user_first_name,
                                           @Part("surname") RequestBody surname ,
                                           @Part("user_phone") RequestBody user_phone,
                                           @Part("user_email") RequestBody user_email ,
                                           @Part("message") RequestBody message ,
                                           @Part("category") RequestBody category ,
                                              @Part("sub_category") RequestBody sub_category ,
                                              @Part MultipartBody.Part[] surveyImage);





    @Multipart
    @POST("Home/submit_estimate_request")
    Call<BasicResponseModel> requestEstimation(@Part("user_id") RequestBody user_id,
                                              @Part("full_name") RequestBody full_name,
                                              @Part("phone_number") RequestBody phone_number,
                                              @Part("email_address") RequestBody email_address ,
                                              @Part("note") RequestBody note ,
                                              @Part("est_enter_sqft") RequestBody est_enter_sqft ,
                                              @Part("look_id") RequestBody look_id ,
                                              @Part("cate_id") RequestBody cate_id);



    @Multipart
    @POST("Home/recent_quotations")
    Call<BasicResponseModel> recentQuotations(@Part("user_id") RequestBody user_id,
                                              @Part("page") RequestBody page);


    @Multipart
    @POST("Home/quotation")
    Call<BasicResponseModel> quotationsDetails(@Part("id") RequestBody id ,
                                               @Part("user_id") RequestBody user_id);




    @Multipart
    @POST("Home/twentyFourCompanies")
    Call<BasicResponseModel> twentyFourSevenCompanies(@Part("page") RequestBody page);



    @Multipart
    @POST("Home/find_companies")
    Call<BasicResponseModel> searchCompanies(@Part("specialities") RequestBody speciality,
                                             @Part("category") RequestBody category,
                                           @Part("sub_category") RequestBody sub_category,
                                           @Part("city") RequestBody city ,
                                           @Part("verified") RequestBody verified,
                                           @Part("page") RequestBody page);



    @Multipart
    @POST("Home/get_by_company_id")
    Call<BasicResponseModel> search(@Part("keyword") RequestBody keyword);



    @Multipart
    @POST("Home/quotation_fee_paid")
    Call<BasicResponseModel> quotationPayment(@Part("id") RequestBody id ,
                                              @Part("user_id") RequestBody user_id ,
                                              @Part("transaction_no") RequestBody transaction_no);


    @POST("workshop/workshop_filter_data")
    Call<BasicResponseModel> workshopFilterAPI();



    @Multipart
    @POST("workshop/submit_workshop_ad")
    Call<BasicResponseModel> postWorkShopAdNewAPI(@Part("user_id") RequestBody user_id,
                                            @Part("user_type") RequestBody user_type ,
                                            @Part("bid_type") RequestBody bid_type ,
                                            @Part("work_sector") RequestBody work_sector ,
                                            @Part("work_city") RequestBody work_city ,
                                            @Part("title") RequestBody title,
                                            @Part("description") RequestBody description ,
                                            @Part MultipartBody.Part[] surveyImage);


    @Multipart
    @POST("workshop/submit_workshop_ad")
    Call<BasicResponseModel> vendorPostWorkShopAdNewAPI(@Part("vendor_id") RequestBody vendor_id,
                                                        @Part("user_id") RequestBody user_id,
                                                        @Part("user_type") RequestBody user_type ,
                                                        @Part("bid_type") RequestBody bid_type ,
                                                        @Part("work_sector") RequestBody work_sector ,
                                                        @Part("work_city") RequestBody work_city ,
                                                        @Part("title") RequestBody title,
                                                        @Part("description") RequestBody description ,
                                                        @Part MultipartBody.Part[] surveyImage);


    @Multipart
    @POST("workshop/workshops")
    Call<BasicResponseModel> workshopAds(@Part("vendor_id") RequestBody vendor_id,
                                         @Part("user_id") RequestBody user_id,
                                         @Part("user_type") RequestBody user_type,
                                         @Part("bid_type") RequestBody bid_type,
                                         @Part("page") RequestBody page);


    @Multipart
    @POST("workshop/get_workshop_details")
    Call<BasicResponseModel> workshopAdDetails(@Part("workshop_id") RequestBody workshop_id);


    @Multipart
    @POST("workshop/quotation_toggle_lock")
    Call<BasicResponseModel> updateWorkshopQuotationLock(@Part("chatEntryId") RequestBody chatEntryId,
                                                         @Part("action") RequestBody action);


    @Multipart
    @POST("workshop/toggle_workshop_status")
    Call<BasicResponseModel> updateWorkshopStatus(@Part("workshop_id") RequestBody workshop_id);


    @Multipart
    @POST("workshop/show_workshops_for_interest")
    Call<BasicResponseModel> allWorkshopAds(@Part("vendor_id") RequestBody vendor_id,
                                         @Part("user_id") RequestBody user_id,
                                         @Part("user_type") RequestBody user_type,
                                         @Part("bid_type") RequestBody bid_type,
                                         @Part("page") RequestBody page);

    @Multipart
    @POST("workshop/mark_workshop_interested")
    Call<BasicResponseModel> workshopMarkInterested(@Part("vendor_id") RequestBody vendor_id,
                                         @Part("user_id") RequestBody user_id,
                                         @Part("user_type") RequestBody user_type,
                                         @Part("bid_type") RequestBody bid_type,
                                         @Part("workshop_ad_id") RequestBody workshop_ad_id);


    @Multipart
    @POST("workshop/workshop_my_page")
    Call<BasicResponseModel> interestedWorkshops(@Part("vendor_id") RequestBody vendor_id,
                                                 @Part("user_id") RequestBody user_id,
                                                 @Part("user_type") RequestBody user_type,
                                                 @Part("bid_type") RequestBody bid_type,
                                                 @Part("page") RequestBody page);

    @Multipart
    @POST("workshop/add_workshop_quotation")
    Call<BasicResponseModel> workshopsQuotation(@Part("vendor_id") RequestBody vendor_id,
                                                 @Part("user_id") RequestBody user_id,
                                                 @Part("user_type") RequestBody user_type,
                                                 @Part("workshop_id") RequestBody workshop_id,
                                                 @Part("price") RequestBody price ,
                                                 @Part("message") RequestBody message,
                                                 @Part MultipartBody.Part file);

    @Multipart
    @POST("Home/submit_workshop_ad")
    Call<BasicResponseModel> postWorkShopAd(@Part("user_id") RequestBody user_id,
                                            @Part("category") RequestBody category ,
                                            @Part("sub_category") RequestBody sub_category ,
                                            @Part("title") RequestBody title ,
                                            @Part("description") RequestBody description ,
                                            @Part("user_name") RequestBody user_name,
                                            @Part("surname") RequestBody surname ,
                                            @Part("phone") RequestBody phone,
                                            @Part("address") RequestBody address,
                                            @Part("lat") RequestBody lat,
                                            @Part("lng") RequestBody lng,
                                            @Part("hide_info") RequestBody hide_info,
                                            @Part("call_icon") RequestBody call_icon,
                                            @Part("whatsapp_icon") RequestBody whatsapp_icon,
                                            @Part("chat_icon") RequestBody chat_icon,
                                            @Part MultipartBody.Part[] surveyImage);




    @Multipart
    @POST("Home/recent_workshop_ads")
    Call<BasicResponseModel> workshopAds(@Part("user_id") RequestBody user_id,
                                              @Part("page") RequestBody page);




    @Multipart
    @POST("Home/workshop_ad_detail")
    Call<BasicResponseModel> workshopAdDetails(@Part("ad_id") RequestBody ad_id ,
                                               @Part("user_id") RequestBody user_id);




    @Multipart
    @POST("Home/update_workshop_ad_status")
    Call<BasicResponseModel> updateWorkshopAdStatus(@Part("id") RequestBody id ,
                                               @Part("status_id") RequestBody status_id);




    @Multipart
    @POST("Home/check_cart_limit")
    Call<BasicResponseModel> checkCartLimit(@Part("user_id") RequestBody user_id);

    @Multipart
    @POST("vendor/login_company")
    Call<BasicResponseModel> vendorLogin(@Part("login_email") RequestBody user_phone,
                                   @Part("login_password") RequestBody user_password,
                                   @Part("device_type") RequestBody device_type,
                                   @Part("firebase_token") RequestBody firebase_token);



    @Multipart
    @POST("vendor/register_company")
    Call<BasicResponseModel> vendorRegistration(@Part("company_english") RequestBody company_english,
                                      @Part("company_arabic") RequestBody company_arabic,
                                      @Part("company_email") RequestBody company_email,
                                      @Part("company_phone") RequestBody company_phone,
                                      @Part("company_address") RequestBody company_address,
                                      @Part("owner_name") RequestBody owner_name ,
                                      @Part("owner_phone") RequestBody owner_phone ,
                                      @Part("agent_code") RequestBody agent_code ,
                                      @Part("login_email") RequestBody login_email ,
                                      @Part("login_password") RequestBody login_password ,
                                      @Part("device_type") RequestBody device_type,
                                      @Part("firebase_token") RequestBody firebase_token);






    @Multipart
    @POST("vendor/dashboard")
    Call<BasicResponseModel> vendorDashboard(@Part("vendor_id") RequestBody vendor_id);


    @Multipart
    @POST("vendor/enquiries_status")
    Call<BasicResponseModel> vendorEnquiriesStatus(@Part("vendor_id") RequestBody vendor_id);


    @Multipart
    @POST("vendor/quotations_dashnoard")
    Call<BasicResponseModel> vendorQuotationsStatus(@Part("vendor_id") RequestBody vendor_id);


    @Multipart
    @POST("vendor/my_company")
    Call<BasicResponseModel> vendorProfile(@Part("vendor_id") RequestBody vendor_id);


    @Multipart
    @POST("vendor/view")
    Call<BasicResponseModel> vendorParticularEnquiries(@Part("id") RequestBody id ,
                                           @Part("vendor_id") RequestBody vendor_id );

    @Multipart
    @POST("vendor/quotations")
    Call<BasicResponseModel> vendorParticularQuotations(@Part("id") RequestBody id ,
                                           @Part("vendor_id") RequestBody vendor_id );

    @Multipart
    @POST("vendor/quotation")
    Call<BasicResponseModel> vendorParticularQuotationDetail(@Part("id") RequestBody id);


    @Multipart
    @POST("vendor/rating")
    Call<BasicResponseModel> vendorRating(@Part("vendor_id") RequestBody vendor_id);

    @Multipart
    @POST("vendor/memberships")
    Call<BasicResponseModel> vendorMembership(@Part("vendor_id") RequestBody vendor_id);



    @Multipart
    @POST("vendor/buy_membership_online")
    Call<BasicResponseModel> buyMembership(@Part("vendor_id") RequestBody vendor_id,
                                         @Part("membership_id") RequestBody membership_id,
                                         @Part("paid_amount") RequestBody paid_amount,
                                         @Part("transaction_no") RequestBody transaction_no);


    @Multipart
    @POST("vendor/buy_membership_by_coupon")
    Call<BasicResponseModel> buyMembershipByCoupon(@Part("vendor_id") RequestBody vendor_id,
                                         @Part("membership_id") RequestBody membership_id,
                                         @Part("coupon_code") RequestBody coupon_code);


    @Multipart
    @POST("vendor/my_memberships")
    Call<BasicResponseModel> myMembership(@Part("vendor_id") RequestBody vendor_id);



    @Multipart
    @POST("vendor/is_online")
    Call<BasicResponseModel> vendorIsOnline(@Part("vendor_id") RequestBody vendor_id ,
                                           @Part("is_online") RequestBody is_online );


    @Multipart
    @POST("vendor/enquiry")
    Call<BasicResponseModel> vendorParticularEnquiryDetail(@Part("id") RequestBody id ,
                                                           @Part("vendor_id") RequestBody vendor_id);

    @Multipart
    @POST("vendor/update_enquiry_status")
    Call<BasicResponseModel> updateEnquiryStatus(@Part("enquiry_id") RequestBody enquiry_id ,
                                                 @Part("vendor_id") RequestBody vendor_id ,
                                                 @Part("status_id") RequestBody status_id);
    @Multipart
    @POST("vendor/enquiry_rejection_reason")
    Call<BasicResponseModel> updateEnquiryRejectionStatus(@Part("enquiry_id") RequestBody enquiry_id ,
                                                   @Part("vendor_id") RequestBody vendor_id ,
                                                   @Part("status_id") RequestBody status_id ,
                                                   @Part("reason") RequestBody reason);



    @Multipart
    @POST("vendor/update_quotation_status")
    Call<BasicResponseModel> updateQuotationStatus(@Part("quotation_id") RequestBody enquiry_id ,
                                                 @Part("vendor_id") RequestBody vendor_id ,
                                                 @Part("status_id") RequestBody status_id);
    @Multipart
    @POST("vendor/quotation_rejection_reason")
    Call<BasicResponseModel> updateQuotationRejectionStatus(@Part("quotation_id") RequestBody enquiry_id ,
                                                   @Part("vendor_id") RequestBody vendor_id ,
                                                   @Part("status_id") RequestBody status_id ,
                                                   @Part("reason") RequestBody reason);






    @Multipart
    @POST("vendor/upload_document")
    Call<BasicResponseModel> uploadDocument(@Part("quotation_id") RequestBody user_id,
                                           @Part("vendor_id") RequestBody user_email,
                                           @Part MultipartBody.Part file);





    @Multipart
    @POST("vendor/send_reset_password_pin")
    Call<BasicResponseModel> vendorForgotPassword(@Part("login_email") RequestBody login_email);



    @Multipart
    @POST("vendor/reset_pin_check")
    Call<BasicResponseModel> vendorForgotPasswordPin(@Part("login_email") RequestBody login_email ,
                                                  @Part("pin") RequestBody pin);



    @Multipart
    @POST("vendor/update_password")
    Call<BasicResponseModel> vendorNewPassword(@Part("password") RequestBody password,
                                         @Part("login_email") RequestBody login_email);



    @Multipart
    @POST("Vendor/workshop_ads")
    Call<BasicResponseModel> vendorWorkshop(@Part("category_id") RequestBody user_id,
                                            @Part("vendor_id") RequestBody user_email,
                                            @Part("page") RequestBody page);


    @Multipart
    @POST("Vendor/workshop_ad_detail")
    Call<BasicResponseModel> vendorWorkshopAdDetail(@Part("id") RequestBody id);



    @Multipart
    @POST("vendor/membership_details")
    Call<BasicResponseModel> membershipDetail(@Part("vendor_id") RequestBody vendor_id,
                                         @Part("id") RequestBody membership_id);



    @Multipart
    @POST("vendor/buy_workshop_membership_online")
    Call<BasicResponseModel> buyWorkshop(@Part("vendor_id") RequestBody vendor_id,
                                           @Part("membership_id") RequestBody membership_id,
                                           @Part("transaction_no") RequestBody transaction_no);



    @Multipart
    @POST("vendor/buy_workshop_membership_by_coupon")
    Call<BasicResponseModel> buyWorkshopByCoupon(@Part("vendor_id") RequestBody vendor_id,
                                                   @Part("membership_id") RequestBody membership_id,
                                                   @Part("coupon_code") RequestBody coupon_code);


    @Multipart
    @POST("vendor/send_message_notification")
    Call<BasicResponseModel> sendNotificationVendor(@Part("meesage") RequestBody meesage,
                                                 @Part("username") RequestBody username,
                                                    @Part("chatUDID") RequestBody chatUDID,
                                                    @Part("vendor_serial_no") RequestBody vendor_serial_no);


    @Multipart
    @POST("Home/send_message_notification")
    Call<BasicResponseModel> sendNotificationUser(@Part("meesage") RequestBody meesage ,
                                                  @Part("company_id") RequestBody company_id);


    @Multipart
    @POST("vendor/resent_company_email_verification_mail")
    Call<BasicResponseModel> sendEmailVendor(@Part("email") RequestBody email);



    // New APIs From Bilal Jan

    @Multipart
    @POST("Home/company_by_serial_no")
    Call<BasicResponseModel> companySearchBySerial(@Part("s_no") RequestBody s_no);

    @POST("Home/get_all_advertisement_areas")
    Call<BasicResponseModel> getAreas();


    @Multipart
    @POST("Home/advertise_company_mobile")
    Call<BasicResponseModel> advertiseCompany(@Part("company_id") RequestBody company_id,
                                              @Part("area_ids") RequestBody area_ids,
                                             @Part("days") RequestBody days);


    @Multipart
    @POST("jobs/app_jobs_dashboard")
    Call<BasicResponseModel> vendorJobsStatus(@Part("vendor_id") RequestBody vendor_id ,
                                              @Part("user_id") RequestBody user_id ,
                                              @Part("user_type") RequestBody user_type);


    @POST("jobs/get_job_search_fields")
    Call<BasicResponseModel> jobDataAPI();


    @Multipart
    @POST("jobs/post_job")
    Call<BasicResponseModel> postJob(@Part("title") RequestBody title,
                                            @Part("arabic_title") RequestBody arabic_title ,
                                            @Part("vaccancies") RequestBody vaccancies ,
                                            @Part("description") RequestBody description ,
                                            @Part("arabic_description") RequestBody arabic_description ,
                                            @Part("salary") RequestBody salary,
                                            @Part("job_category") RequestBody job_category ,
                                            @Part("job_location") RequestBody job_location,
                                            @Part("job_type") RequestBody job_type,
                                            @Part("deadline") RequestBody deadline,
                                            @Part("vendor_id") RequestBody vendor_id,
                                            @Part("user_id") RequestBody user_id,
                                            @Part("user_type") RequestBody user_type,
                                            @Part MultipartBody.Part file);

    @Multipart
    @POST("jobs/update_job")
    Call<BasicResponseModel> updateJob(@Part("title") RequestBody title,
                                     @Part("arabic_title") RequestBody arabic_title ,
                                     @Part("vaccancies") RequestBody vaccancies ,
                                     @Part("description") RequestBody description ,
                                     @Part("arabic_description") RequestBody arabic_description ,
                                     @Part("salary") RequestBody salary,
                                     @Part("job_category") RequestBody job_category ,
                                     @Part("job_location") RequestBody job_location,
                                     @Part("job_type") RequestBody job_type,
                                     @Part("deadline") RequestBody deadline,
                                     @Part("vendor_id") RequestBody vendor_id,
                                     @Part("user_id") RequestBody user_id,
                                     @Part("user_type") RequestBody user_type,
                                     @Part MultipartBody.Part file,
                                     @Part("job_id") RequestBody job_id);

    @Multipart
    @POST("jobs/jobs_listing")
    Call<BasicResponseModel> vendorJobListing(@Part("id") RequestBody id ,
                                              @Part("vendor_id") RequestBody vendor_id ,
                                              @Part("user_id") RequestBody user_id ,
                                              @Part("user_type") RequestBody user_type);

    @Multipart
    @POST("jobs/view_job")
    Call<BasicResponseModel> vendorJobDetail(@Part("job_uuid") RequestBody job_uuid);

    @Multipart
    @POST("jobs/toggle_job_publish")
    Call<BasicResponseModel> vendorUpdateJobPublishStatus(@Part("job_id") RequestBody job_id,
                                                          @Part("check") RequestBody check);


    @Multipart
    @POST("jobs/delete_job")
    Call<BasicResponseModel> vendorDelectJob(@Part("job_id") RequestBody job_id);

    @Multipart
    @POST("jobs/search_job_title")
    Call<BasicResponseModel> searchJobTitleApi(@Part("title") RequestBody title);

    @Multipart
    @POST("jobs/search_jobs")
    Call<BasicResponseModel> availableJobsApi(@Part("page") RequestBody page ,
                                              @Part("jobs") RequestBody jobs ,
                                              @Part("job_category") RequestBody job_category ,
                                              @Part("job_city") RequestBody job_city);

    @Multipart
    @POST("jobs/job_apply")
    Call<BasicResponseModel> applyJob(@Part("user_id") RequestBody user_id,
                                                          @Part("job_uuid") RequestBody job_uuid);


    @Multipart
    @POST("jobs/search_applicants")
    Call<BasicResponseModel> availableApplicantApi(@Part("page") RequestBody page ,
                                                   @Part("category") RequestBody job_category ,
                                                   @Part("city") RequestBody job_city);


    @Multipart
    @POST("jobs/direct_hire")
    Call<BasicResponseModel> hireApplicantApi(@Part("vendor_id") RequestBody vendor_id ,
                                                   @Part("user_id") RequestBody user_id ,
                                                   @Part("user_type") RequestBody user_type ,
                                                   @Part("applicant_uuid") RequestBody applicant_uuid ,
                                                   @Part("status") RequestBody status);


    @Multipart
    @POST("jobs/view_applies")
    Call<BasicResponseModel> viewAppliesApi(@Part("page") RequestBody page ,
                                                   @Part("job_uuid") RequestBody job_uuid);


    @Multipart
    @POST("jobs/update_job_application_status")
    Call<BasicResponseModel> updateJobHireStatusApi(@Part("vendor_id") RequestBody vendor_id ,
                                              @Part("application_id") RequestBody application_id ,
                                              @Part("status") RequestBody status);


    @Multipart
    @POST("jobs/view_direct_hirings")
    Call<BasicResponseModel> directHiringApi(@Part("page") RequestBody page ,
                                             @Part("vendor_id") RequestBody vendor_id ,
                                              @Part("user_id") RequestBody user_id ,
                                              @Part("user_type") RequestBody user_type);




    @Multipart
    @POST("jobs/update_direct_hiring_status")
    Call<BasicResponseModel> updateDirectHireStatusApi(@Part("vendor_id") RequestBody vendor_id ,
                                                    @Part("hiring_id") RequestBody hiring_id ,
                                                    @Part("status") RequestBody status);



    @Multipart
    @POST("jobs/user_direct_selections")
    Call<BasicResponseModel> userDirectHiringApi(@Part("page") RequestBody page ,
                                                 @Part("user_id") RequestBody user_id);

    @Multipart
    @POST("jobs/user_job_applies")
    Call<BasicResponseModel> userJobAppliesApi(@Part("page") RequestBody page ,
                                                 @Part("user_id") RequestBody user_id);

    @Multipart
    @POST("jobs/update_user_job_status")
    Call<BasicResponseModel> userJobStatusApi(@Part("uuid") RequestBody uuid);


    @Multipart
    @POST("freelancing/freelancers_frontend")
    Call<BasicResponseModel> freelancerApi(@Part("page") RequestBody page ,
                                              @Part("skills") RequestBody skills ,
                                              @Part("rate") RequestBody rate ,
                                              @Part("category") RequestBody category ,
                                              @Part("city") RequestBody city,
                                              @Part("user_id") RequestBody user_id,
                                              @Part("user_type") RequestBody user_type,
                                              @Part("vendor_id") RequestBody vendor_id);



    @POST("freelancing/get_freelancing_search")
    Call<BasicResponseModel> freelancerDataAPI();



    @Multipart
    @POST("freelancing/transportation_charges")
    Call<BasicResponseModel> transportationApi(@Part("freelancer_id") RequestBody freelancer_id,
                                           @Part("user_id") RequestBody user_id,
                                           @Part("user_type") RequestBody user_type);


    @Multipart
    @POST("freelancing/hire_freelancers")
    Call<BasicResponseModel> hireFreelancerApi(@Part("freelancer_data") RequestBody freelancer_data,
                                           @Part("user_id") RequestBody user_id,
                                           @Part("user_type") RequestBody user_type,
                                           @Part("vendor_id") RequestBody vendor_id);


    @Multipart
    @POST("freelancing/freelancing_dashboard")
    Call<BasicResponseModel> vendorFreelancerStatus(@Part("vendor_id") RequestBody vendor_id ,
                                              @Part("user_id") RequestBody user_id ,
                                              @Part("user_type") RequestBody user_type);


    @Multipart
    @POST("freelancing/user_freelancing_dashboard")
    Call<BasicResponseModel> userFreelancerStatus(@Part("vendor_id") RequestBody vendor_id ,
                                              @Part("user_id") RequestBody user_id ,
                                              @Part("user_type") RequestBody user_type);


    @Multipart
    @POST("freelancing/register_user_freelancer")
    Call<BasicResponseModel> userFreelancerData(@Part("user_id") RequestBody user_id);



    @Multipart
    @POST("freelancing/freelancers_list")
    Call<BasicResponseModel> vendorFreelancerApi(@Part("page") RequestBody page ,
                                           @Part("user_id") RequestBody user_id,
                                           @Part("user_type") RequestBody user_type,
                                           @Part("vendor_id") RequestBody vendor_id);


    @Multipart
    @POST("freelancing/hired_freelancers_summary")
    Call<BasicResponseModel> vendorHiredFreelancerSummaryApi(@Part("user_id") RequestBody user_id,
                                           @Part("user_type") RequestBody user_type,
                                           @Part("vendor_id") RequestBody vendor_id);


    @Multipart
    @POST("freelancing/hired_freelancers")
    Call<BasicResponseModel> vendorHiredFreelancerApi(@Part("batch_id") RequestBody batch_id,
                                                      @Part("user_id") RequestBody user_id,
                                           @Part("user_type") RequestBody user_type,
                                           @Part("vendor_id") RequestBody vendor_id);



    @Multipart
    @POST("freelancing/freelancing_orders")
    Call<BasicResponseModel> vendorFreelancingOrderApi(@Part("user_id") RequestBody user_id,
                                                      @Part("user_type") RequestBody user_type,
                                                      @Part("vendor_id") RequestBody vendor_id);

    @Multipart
    @POST("freelancing/change_order_status")
    Call<BasicResponseModel> vendorFreelancingOrderAcceptRejectApi(@Part("user_id") RequestBody user_id,
                                                      @Part("user_type") RequestBody user_type,
                                                      @Part("vendor_id") RequestBody vendor_id,
                                                      @Part("order_id") RequestBody order_id,
                                                      @Part("type") RequestBody type);
    @Multipart
    @POST("freelancing/wallet")
    Call<BasicResponseModel> vendorFreelancingWalletApi(@Part("user_id") RequestBody user_id,
                                                      @Part("user_type") RequestBody user_type,
                                                      @Part("vendor_id") RequestBody vendor_id);

    @Multipart
    @POST("freelancing/register_company_freelancer")
    Call<BasicResponseModel> vendorAddFreelancer(@Part("name") RequestBody name,
                                     @Part("email") RequestBody email ,
                                     @Part("phone") RequestBody phone ,
                                     @Part("rate") RequestBody rate ,
                                     @Part("freelancer_skills") RequestBody freelancer_skills ,
                                     @Part("job_category") RequestBody job_category,
                                     @Part("city") RequestBody city ,
                                     @Part("area") RequestBody area,
                                     @Part("available_per_hour") RequestBody available_per_hour,
                                     @Part("from_time") RequestBody from_time,
                                     @Part("to_time") RequestBody to_time,
                                     @Part("bank_name") RequestBody bank_name,
                                     @Part("bank_address") RequestBody bank_address,
                                     @Part("account_title") RequestBody account_title,
                                     @Part("iban") RequestBody iban,
                                     @Part("address") RequestBody address,
                                     @Part("pick_up_address") RequestBody pick_up_address,
                                     @Part("pick_up_latitude") RequestBody pick_up_latitude,
                                     @Part("pick_up_longitude") RequestBody pick_up_longitude,
                                     @Part("user_id") RequestBody user_id,
                                     @Part("user_type") RequestBody user_type,
                                     @Part("vendor_id") RequestBody vendor_id,
                                     @Part MultipartBody.Part image,
                                     @Part MultipartBody.Part video);
    @Multipart
    @POST("freelancing/update_company_freelancer")
    Call<BasicResponseModel> vendorUpdateFreelancer(@Part("name") RequestBody name,
                                     @Part("email") RequestBody email ,
                                     @Part("phone") RequestBody phone ,
                                     @Part("rate") RequestBody rate ,
                                     @Part("freelancer_skills") RequestBody freelancer_skills ,
                                     @Part("job_category") RequestBody job_category,
                                     @Part("city") RequestBody city ,
                                     @Part("area") RequestBody area,
                                     @Part("available_per_hour") RequestBody available_per_hour,
                                     @Part("from_time") RequestBody from_time,
                                     @Part("to_time") RequestBody to_time,
                                     @Part("bank_name") RequestBody bank_name,
                                     @Part("bank_address") RequestBody bank_address,
                                     @Part("account_title") RequestBody account_title,
                                     @Part("iban") RequestBody iban,
                                     @Part("default_address") RequestBody default_address,
                                     @Part("freelancer_id") RequestBody freelancer_id,
                                     @Part("user_type") RequestBody user_type,
                                     @Part MultipartBody.Part image,
                                     @Part MultipartBody.Part video);

    @Multipart
    @POST("freelancing/add_freelancer_address")
    Call<BasicResponseModel> addAddressFreelancer(@Part("address") RequestBody address,
                                                  @Part("pick_up_address") RequestBody pick_up_address,
                                                  @Part("pick_up_latitude") RequestBody pick_up_latitude,
                                                  @Part("pick_up_longitude") RequestBody pick_up_longitude,
                                                  @Part("current") RequestBody current,
                                                  @Part("freelancer_id") RequestBody freelancer_id);
    @Multipart
    @POST("freelancing/get_freelancer_addresses")
    Call<BasicResponseModel> getAddressFreelancer(@Part("freelancer_id") RequestBody freelancer_id);

    @Multipart
    @POST("freelancing/delete_freelancer_address")
    Call<BasicResponseModel> deleteAddressFreelancer(@Part("address_id") RequestBody address_id);


    @Multipart
    @POST("freelancing/update_user_freelance_status")
    Call<BasicResponseModel> updateUserFreelanceStatus(@Part("user_id") RequestBody user_id,
                                                       @Part("user_type") RequestBody user_type,
                                                       @Part("vendor_id") RequestBody vendor_id,
                                                       @Part("isChecked") RequestBody isChecked);


    @Multipart
    @POST("freelancing/update_company_freelancer_status")
    Call<BasicResponseModel> updateVendorFreelanceStatus(@Part("freelancer_id") RequestBody freelancer_id,
                                                       @Part("user_type") RequestBody user_type,
                                                       @Part("vendor_id") RequestBody vendor_id,
                                                       @Part("is_checked") RequestBody isChecked);



    @Multipart
    @POST("freelancing/order_placed_chats")
    Call<BasicResponseModel> freelancersPlacedChatConnection(@Part("vendor_id") RequestBody vendor_id,
                                                       @Part("user_id") RequestBody user_id,
                                                       @Part("user_type") RequestBody user_type);


    @Multipart
    @POST("freelancing/order_recieved_chats")
    Call<BasicResponseModel> freelancersReceivedChatConnection(@Part("vendor_id") RequestBody vendor_id,
                                                       @Part("user_id") RequestBody user_id,
                                                       @Part("user_type") RequestBody user_type);

    @Multipart
    @POST("freelancing/fetch_order_chats")
    Call<BasicResponseModel> freelancerOrderChat(@Part("order_id") RequestBody order_id);
}


