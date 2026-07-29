package com.thecontractor.Model;

import java.util.ArrayList;

public class BasicResponseModel {

    private String error;
    private String message;
    private String status;
    private String current_status;
    private String sending;
    private String quotation_price;
    private String view;
    private String is_email_verified;
    private int current_page;
    private int total_page;
    private int cart_limit;
    private int available_cart_limit;
    private UserModel user;
    private VendorModel Vendor;
    private VendorModel Vendor_profile;
    private ArrayList<CategoriesModel> categories;
    private ArrayList<CitiesModel> cities;
    private ArrayList<SpecialityModel> specialities;
    private ArrayList<CompaniesModel> featured_companies;
    private ArrayList<CompaniesModel> simple_companies;
    private ArrayList<CompaniesModel> search;
    private ArrayList<CompaniesModel> companies_list;
    private ArrayList<EnquiryModel> enquiries;
    private ArrayList<QuotationModel> quotations;
    private ArrayList<EstimationCategoriesModel> estimation_categories;
    private ArrayList<ComplaintModel> complaints;
    private ArrayList<EstimationModel> requests;
    private ArrayList<CompaniesModel> companies;
    private ArrayList<CompaniesModel> top_ten_companies;
    private ArrayList<CompaniesModel> top_twenty_companies;
    private ArrayList<CompaniesModel> titanium_companies;
    private ArrayList<WorkshopAdModel> workshop_ads;
    private ArrayList<WorkshopAdModel> vendor_workshop_ads;
    private WorkshopAdModel workshop_ad_detail;
    private WorkshopAdModel vendor_workshop_ad_detail;
    private CompaniesModel company;
    private QuotationModel quotation;
    private EnquiryModel enquiry_detail;
    private EstimationModel estimation_request_detail;
    private ComplaintModel complaint_detail;

    private ArrayList<VendorDashboardCountModel> vendor_dashboard_counts;
    private ArrayList<VendorDashboardCountModel> quotation_counts;
    private ArrayList<VendorEnquiryModel> pending_enquiries;
    private ArrayList<VendorEnquiryModel> accepted_enquiries;
    private ArrayList<VendorEnquiryModel> today_enquiries;
    private ArrayList<VendorEnquiryModel> vendor_enquiries;
    private ArrayList<VendorQuotationModel> vendor_quotations;
    private ArrayList<VendorRatingModel> rating_enquiries;
    private ArrayList<VendorMembershipModel> memberships_list;
    private ArrayList<VendorMyMembershipModel> my_memberships;

    private VendorQuotationDetailModel vendor_quotation;
    private VendorEnquiryDetailModel vendor_enquiry;
    private VendorMyMembershipModel membership_detail;
    private ArrayList<AdvertisementAreaModel> areas;
    private ArrayList<VendorJobCitiesModel> job_cities;
    private ArrayList<VendorJobCategoriesModel> job_categories;
    private ArrayList<VendorJobTypeModel> job_types;
    private ArrayList<VendorJobListingModel> jobs_list;
    private VendorJobListingModel job_details;
    private ArrayList<AvailableJobListingModel> available_jobs;
    private ArrayList<VendorApplicantListingModel> available_users;
    private ArrayList<SearchJobTitleModel> jobs_title_list;
    private ArrayList<VendorJobAppliesListingModel> job_applies;
    private ArrayList<VendorDirectHiringModel> direct_hirings;
    private ArrayList<UserJobAppliesListingModel> job_applications;
    private ArrayList<UserDirectHiringModel> user_direct_selections;
    private ArrayList<FreelancerListModel> freelancers_list;
    private ArrayList<FreelancerSkillsModel> freelancer_skills;
    private ArrayList<VendorJobCategoriesModel> freelancer_categories;
    private ArrayList<VendorJobCitiesModel> freelancer_cities;
    private String company_comission_rate;
    private TransportationChargesModel charges;
    private ArrayList<VendorDashboardCountModel> freelancing_dashboard;
    private ArrayList<FreelancerListModel>  company_freelancers_list;
    private ArrayList<VendorHiredFreelancersSummaryModel> batch_lists;
    private ArrayList<VendorHiredFreelancersModel> hired_freelancers;
    private ArrayList<VendorFreelancingOrdersModel> freelancing_orders;
    private VendorFreelancingWalletModel wallet;
    private UserFreelancerDashboardModel user_freelancing_dashboard;
    private ArrayList<FreelancerAddressModel> addresses;
    private FreelancerListModel user_freelancer_details;
    private boolean available;
    private String action;
    private ArrayList<WorkshopTypeModel> workshop_type;
    private ArrayList<WorkshopSectorModel> work_sector;
    private ArrayList<WorkshopAdModel> workshops;
    private WorkshopAdModel workshop_details;
    private ArrayList<FreelancersChatConnectionModel> order_chats;
    private ArrayList<FreelancerChatModel> chats;


    public String getError() {
        return error;
    }

    public String getMessage() {
        return message;
    }

    public String getStatus() {
        return status;
    }

    public String getCurrent_status() {
        return current_status;
    }

    public String getSending() {
        return sending;
    }

    public String getQuotation_price() {
        return quotation_price;
    }

    public String getView() {
        return view;
    }

    public String getIs_email_verified() {
        return is_email_verified;
    }

    public int getCurrent_page() {
        return current_page;
    }

    public int getTotal_page() {
        return total_page;
    }

    public int getCart_limit() {
        return cart_limit;
    }

    public int getAvailable_cart_limit() {
        return available_cart_limit;
    }

    public UserModel getUser() {
        return user;
    }

    public VendorModel getVendor() {
        return Vendor;
    }

    public VendorModel getVendor_profile() {
        return Vendor_profile;
    }

    public ArrayList<CategoriesModel> getCategories() {
        return categories;
    }

    public ArrayList<CitiesModel> getCities() {
        return cities;
    }

    public ArrayList<SpecialityModel> getSpecialities() {
        return specialities;
    }

    public ArrayList<CompaniesModel> getFeatured_companies() {
        return featured_companies;
    }

    public ArrayList<CompaniesModel> getSimple_companies() {
        return simple_companies;
    }

    public ArrayList<CompaniesModel> getSearch() {
        return search;
    }

    public ArrayList<CompaniesModel> getCompanies_list() {
        return companies_list;
    }

    public ArrayList<EnquiryModel> getEnquiries() {
        return enquiries;
    }

    public ArrayList<QuotationModel> getQuotations() {
        return quotations;
    }

    public ArrayList<EstimationCategoriesModel> getEstimation_categories() {
        return estimation_categories;
    }

    public ArrayList<ComplaintModel> getComplaints() {
        return complaints;
    }

    public ArrayList<EstimationModel> getRequests() {
        return requests;
    }

    public ArrayList<CompaniesModel> getCompanies() {
        return companies;
    }

    public ArrayList<CompaniesModel> getTop_ten_companies() {
        return top_ten_companies;
    }

    public ArrayList<CompaniesModel> getTop_twenty_companies() {
        return top_twenty_companies;
    }

    public ArrayList<CompaniesModel> getTitanium_companies() {
        return titanium_companies;
    }

    public CompaniesModel getCompany() {
        return company;
    }

    public QuotationModel getQuotation() {
        return quotation;
    }

    public EnquiryModel getEnquiry_detail() {
        return enquiry_detail;
    }

    public EstimationModel getEstimation_request_detail() {
        return estimation_request_detail;
    }

    public ComplaintModel getComplaint_detail() {
        return complaint_detail;
    }

    public ArrayList<VendorDashboardCountModel> getVendor_dashboard_counts() {
        return vendor_dashboard_counts;
    }

    public ArrayList<VendorDashboardCountModel> getQuotation_counts() {
        return quotation_counts;
    }

    public ArrayList<VendorEnquiryModel> getPending_enquiries() {
        return pending_enquiries;
    }

    public ArrayList<VendorEnquiryModel> getAccepted_enquiries() {
        return accepted_enquiries;
    }

    public ArrayList<VendorEnquiryModel> getToday_enquiries() {
        return today_enquiries;
    }

    public ArrayList<VendorEnquiryModel> getVendor_enquiries() {
        return vendor_enquiries;
    }

    public ArrayList<VendorQuotationModel> getVendor_quotations() {
        return vendor_quotations;
    }

    public ArrayList<VendorRatingModel> getRating_enquiries() {
        return rating_enquiries;
    }

    public ArrayList<VendorMembershipModel> getMemberships_list() {
        return memberships_list;
    }

    public ArrayList<VendorMyMembershipModel> getMy_memberships() {
        return my_memberships;
    }

    public ArrayList<WorkshopAdModel> getWorkshop_ads() {
        return workshop_ads;
    }

    public ArrayList<WorkshopAdModel> getVendor_workshop_ads() {
        return vendor_workshop_ads;
    }

    public WorkshopAdModel getWorkshop_ad_detail() {
        return workshop_ad_detail;
    }

    public WorkshopAdModel getVendor_workshop_ad_detail() {
        return vendor_workshop_ad_detail;
    }

    public VendorQuotationDetailModel getVendor_quotation() {
        return vendor_quotation;
    }

    public VendorEnquiryDetailModel getVendor_enquiry() {
        return vendor_enquiry;
    }

    public VendorMyMembershipModel getMembership_detail() {
        return membership_detail;
    }

    public ArrayList<AdvertisementAreaModel> getAreas() {
        return areas;
    }

    public ArrayList<VendorJobCitiesModel> getJob_cities() {
        return job_cities;
    }

    public ArrayList<VendorJobCategoriesModel> getJob_categories() {
        return job_categories;
    }

    public ArrayList<VendorJobTypeModel> getJob_types() {
        return job_types;
    }

    public ArrayList<VendorJobListingModel> getJobs_list() {
        return jobs_list;
    }

    public VendorJobListingModel getJob_details() {
        return job_details;
    }

    public ArrayList<AvailableJobListingModel> getAvailable_jobs() {
        return available_jobs;
    }

    public ArrayList<VendorApplicantListingModel> getAvailable_users() {
        return available_users;
    }

    public ArrayList<SearchJobTitleModel> getJobs_title_list() {
        return jobs_title_list;
    }

    public ArrayList<VendorJobAppliesListingModel> getJob_applies() {
        return job_applies;
    }

    public ArrayList<VendorDirectHiringModel> getDirect_hirings() {
        return direct_hirings;
    }

    public ArrayList<UserJobAppliesListingModel> getJob_applications() {
        return job_applications;
    }

    public ArrayList<UserDirectHiringModel> getUser_direct_selections() {
        return user_direct_selections;
    }

    public ArrayList<FreelancerListModel> getFreelancers_list() {
        return freelancers_list;
    }

    public ArrayList<FreelancerSkillsModel> getFreelancer_skills() {
        return freelancer_skills;
    }

    public ArrayList<VendorJobCategoriesModel> getFreelancer_categories() {
        return freelancer_categories;
    }

    public ArrayList<VendorJobCitiesModel> getFreelancer_cities() {
        return freelancer_cities;
    }

    public String getCompany_comission_rate() {
        return company_comission_rate;
    }

    public TransportationChargesModel getCharges() {
        return charges;
    }

    public ArrayList<VendorDashboardCountModel> getFreelancing_dashboard() {
        return freelancing_dashboard;
    }

    public ArrayList<FreelancerListModel> getCompany_freelancers_list() {
        return company_freelancers_list;
    }

    public ArrayList<VendorHiredFreelancersSummaryModel> getBatch_lists() {
        return batch_lists;
    }

    public ArrayList<VendorHiredFreelancersModel> getHired_freelancers() {
        return hired_freelancers;
    }

    public ArrayList<VendorFreelancingOrdersModel> getFreelancing_orders() {
        return freelancing_orders;
    }

    public VendorFreelancingWalletModel getWallet() {
        return wallet;
    }

    public UserFreelancerDashboardModel getUser_freelancing_dashboard() {
        return user_freelancing_dashboard;
    }

    public ArrayList<FreelancerAddressModel> getAddresses() {
        return addresses;
    }

    public FreelancerListModel getUser_freelancer_details() {
        return user_freelancer_details;
    }

    public boolean isAvailable() {
        return available;
    }

    public String getAction() {
        return action;
    }

    public ArrayList<WorkshopTypeModel> getWorkshop_type() {
        return workshop_type;
    }

    public ArrayList<WorkshopSectorModel> getWork_sector() {
        return work_sector;
    }

    public ArrayList<WorkshopAdModel> getWorkshops() {
        return workshops;
    }

    public WorkshopAdModel getWorkshop_details() {
        return workshop_details;
    }

    public ArrayList<FreelancersChatConnectionModel> getOrder_chats() {
        return order_chats;
    }

    public ArrayList<FreelancerChatModel> getChats() {
        return chats;
    }
}


