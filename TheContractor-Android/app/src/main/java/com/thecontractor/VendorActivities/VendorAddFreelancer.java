package com.thecontractor.VendorActivities;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.widget.LinearLayout;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.ViewModelProvider;
import androidx.viewpager2.adapter.FragmentStateAdapter;
import androidx.viewpager2.widget.ViewPager2;

import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;
import com.thecontractor.Fragments.FreelancerAddressFragment;
import com.thecontractor.Fragments.FreelancerBankDetailFragment;
import com.thecontractor.Fragments.FreelancerGeneralFragment;
import com.thecontractor.Model.AddFreelancerViewModel;
import com.thecontractor.Model.AvailableJobListingModel;
import com.thecontractor.Model.FreelancerListModel;
import com.thecontractor.R;

public class VendorAddFreelancer extends AppCompatActivity {
    FreelancerListModel freelancerListModel;
    String from;
    String type;
    private TabLayout tabLayout;
    private ViewPager2 viewPager;
    private StepAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vendor_add_freelancer);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setTitle("Add Freelancer");

        getObjectFromAdapter();
        initiate();

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

    public void getObjectFromAdapter() {
        Intent intent = getIntent();
        Bundle bundle = intent.getExtras();
        if (bundle != null) {

            from = (String) bundle.get("from");
            type = (String) bundle.get("type");

            assert type != null;
            if(type.equals("update")){
                getSupportActionBar().setTitle("Update Freelancer");
                freelancerListModel = (FreelancerListModel) bundle.get("freelancerListModel");
            }

        }
    }



    public void initiate(){

        tabLayout = findViewById(R.id.tabLayout);
        viewPager = findViewById(R.id.viewPager);

        adapter = new StepAdapter(this);
        viewPager.setAdapter(adapter);

        // Disable swiping so validation is enforced via buttons
        viewPager.setUserInputEnabled(false);
        // Keep all 3 pages in memory so they don't redraw unnecessarily
        viewPager.setOffscreenPageLimit(3);

        new TabLayoutMediator(tabLayout, viewPager, (tab, position) -> {
            switch (position) {
                case 0: tab.setText("General"); break;
                case 1: tab.setText("Bank Account"); break;
                case 2: tab.setText("Address"); break;
            }
        }).attach();

        disableTabClick();

        getOnBackPressedDispatcher().addCallback(this, new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                // If we are on Step 2 or 3 (Index > 0), go back one step
                if (viewPager.getCurrentItem() > 0) {
                    viewPager.setCurrentItem(viewPager.getCurrentItem() - 1);
                }
                // If we are on Step 1 (Index 0), allow the system to close the Activity
                else {
                    setEnabled(false); // Disable this callback
                    getOnBackPressedDispatcher().onBackPressed(); // Call default behavior
                }
            }
        });
    }

    private void disableTabClick() {
        // This effectively disables the click listener on the internal tab view
        LinearLayout tabStrip = ((LinearLayout) tabLayout.getChildAt(0));
        for (int i = 0; i < tabStrip.getChildCount(); i++) {
            tabStrip.getChildAt(i).setOnTouchListener((v, event) -> true);
        }
    }

    public void nextPage() {
        if (viewPager.getCurrentItem() < 2) {
            viewPager.setCurrentItem(viewPager.getCurrentItem() + 1);
        }
    }

    public void previousPage() {
        if (viewPager.getCurrentItem() > 0) {
            viewPager.setCurrentItem(viewPager.getCurrentItem() - 1);
        }
    }

    // ViewPager Adapter
    class StepAdapter extends FragmentStateAdapter {
        public StepAdapter(@NonNull FragmentActivity fragmentActivity) {
            super(fragmentActivity);
        }

        @NonNull
        @Override
        public Fragment createFragment(int position) {
            switch (position) {
                case 0: return new FreelancerGeneralFragment();
                case 1: return new FreelancerBankDetailFragment();
                case 2: return new FreelancerAddressFragment();
                default: return new FreelancerGeneralFragment();
            }
        }

        @Override
        public int getItemCount() { return 3; }
    }
}