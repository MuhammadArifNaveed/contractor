package com.thecontractor.Fragments;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.fragment.app.DialogFragment;
import androidx.viewpager.widget.PagerAdapter;
import androidx.viewpager.widget.ViewPager;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.thecontractor.Global.ApiUrls;
import com.thecontractor.Global.TouchImageView;
import com.thecontractor.Model.QuotationImages;
import com.thecontractor.Model.WorkshopAdImagesModel;
import com.thecontractor.R;

import java.util.ArrayList;


public class FullScreenWorkshopImageFragment extends DialogFragment {
    private ArrayList<WorkshopAdImagesModel> images;
    private ViewPager viewPager;
    private MyViewPagerAdapter myViewPagerAdapter;
    private TextView lblCount;
    private int selectedPosition = 0;


    public FullScreenWorkshopImageFragment() {
        // Required empty public constructor
    }

    public static FullScreenWorkshopImageFragment newInstance() {
        FullScreenWorkshopImageFragment f = new FullScreenWorkshopImageFragment();
        return f;
    }


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(DialogFragment.STYLE_NORMAL, R.style.GalleryDialog);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view =  inflater.inflate(R.layout.fragment_full_screen_image, container, false);

        viewPager = (ViewPager) view.findViewById(R.id.viewpager);
        lblCount = (TextView) view.findViewById(R.id.lbl_count);

        images = (ArrayList<WorkshopAdImagesModel>) getArguments().getSerializable("images");
        selectedPosition = getArguments().getInt("position");

        Log.e("tag", "position: " + selectedPosition);
        Log.e("tag", "images size: " + images.size());


        myViewPagerAdapter = new MyViewPagerAdapter();
        viewPager.setAdapter(myViewPagerAdapter);
        viewPager.addOnPageChangeListener(viewPagerPageChangeListener);

        setCurrentItem(selectedPosition);

        return view;
    }


    private void setCurrentItem(int position) {
        viewPager.setCurrentItem(position, false);
        displayMetaInfo(selectedPosition);
    }

    //  page change listener
    ViewPager.OnPageChangeListener viewPagerPageChangeListener = new ViewPager.OnPageChangeListener() {

        @Override
        public void onPageSelected(int position) {
            displayMetaInfo(position);
        }

        @Override
        public void onPageScrolled(int arg0, float arg1, int arg2) {

        }

        @Override
        public void onPageScrollStateChanged(int arg0) {

        }
    };

    private void displayMetaInfo(int position) {
        lblCount.setText((position + 1) + " of " + images.size());

    }



    //  adapter
    public class MyViewPagerAdapter extends PagerAdapter {

        private LayoutInflater layoutInflater;

        public MyViewPagerAdapter() {
        }

        @Override
        public Object instantiateItem(ViewGroup container, int position) {

            layoutInflater = (LayoutInflater) getActivity().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            View view = layoutInflater.inflate(R.layout.full_screen_images_custom_row, container, false);

            TouchImageView imageViewPreview = (TouchImageView) view.findViewById(R.id.image_preview);

            String image = images.get(position).getImage_path();

            Glide.with(getActivity())
                    .load(ApiUrls.WORKSHOP_IMAGE_URL+image)
                    .apply(new RequestOptions()
                            .placeholder(R.drawable.logo)
                            .error(R.drawable.logo))
                    .into(imageViewPreview);


            container.addView(view);

            return view;
        }

        @Override
        public int getCount() {
            return images.size();
        }

        @Override
        public boolean isViewFromObject(View view, Object obj) {
            return view == ((View) obj);
        }

        @Override
        public void destroyItem(ViewGroup container, int position, Object object) {
            container.removeView((View) object);
        }
    }



}
