package com.thecontractor.Adapter;

import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.content.res.AppCompatResources;
import androidx.core.view.ViewCompat;
import androidx.viewpager.widget.PagerAdapter;

import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.thecontractor.Model.VendorMembershipModel;
import com.thecontractor.R;

import java.util.ArrayList;


public class VendorMembershipPagerAdapter extends PagerAdapter {

    Context context;
    ArrayList<VendorMembershipModel> list;
    ClickListener clickListener;


    public VendorMembershipPagerAdapter(Context context, ArrayList<VendorMembershipModel> list , ClickListener clickListener) {
        this.context = context;
        this.list = list;
        this.clickListener = clickListener;
    }

    @Override
    public Object instantiateItem(ViewGroup container, final int position) {
        View view = LayoutInflater.from(context).inflate(R.layout.membership_custom_row, null);
        try {

            LinearLayout linMain = (LinearLayout) view.findViewById(R.id.linMain);
            TextView membershipName = (TextView) view.findViewById(R.id.membershipName);
            TextView membershipPrice = (TextView) view.findViewById(R.id.membershipPrice);
            TextView topTen = (TextView) view.findViewById(R.id.topTen);
            TextView topTwenty = (TextView) view.findViewById(R.id.topTwenty);
            TextView leadCapacity = (TextView) view.findViewById(R.id.leadCapacity);
            TextView quotationByPhoto = (TextView) view.findViewById(R.id.quotationByPhoto);
            TextView customerSupport = (TextView) view.findViewById(R.id.customerSupport);
            TextView authenticationCertificate = (TextView) view.findViewById(R.id.authenticationCertificate);
            TextView ListingInTwentySeven = (TextView) view.findViewById(R.id.ListingInTwentySeven);
            TextView welcomeKit = (TextView) view.findViewById(R.id.welcomeKit);
            TextView membershipStatus = (TextView) view.findViewById(R.id.membershipStatus);
            LinearLayout buyStatusTypeValueLayout = (LinearLayout) view.findViewById(R.id.buyStatusTypeValueLayout);
            buyStatusTypeValueLayout.setVisibility(View.GONE);
            TextView buyType = (TextView) view.findViewById(R.id.buyType);
            TextView buyValue = (TextView) view.findViewById(R.id.buyValue);
            CheckBox Workshop = (CheckBox) view.findViewById(R.id.Workshop);
            Button buyMembershipBtn = (Button) view.findViewById(R.id.buyMembershipBtn);
            linMain.setTag(position);

            if(!list.get(position).getStatus_id().equals(""))
            {
                buyMembershipBtn.setVisibility(View.GONE);
                buyStatusTypeValueLayout.setVisibility(View.VISIBLE);
                membershipStatus.setText(list.get(position).getStatus_name());
                buyType.setText(list.get(position).getBuy_type());
                buyValue.setText(" ("+list.get(position).getBuy_value()+")");

                ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                        .toBuilder()
                        .setAllCorners(CornerFamily.ROUNDED,5)
                        .build();

                MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
                shapeDrawable.setPadding(10 , 5 , 10 , 5);

                shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(list.get(position).getColor())));
                ViewCompat.setBackground(membershipStatus,shapeDrawable);

            }


            membershipName.setText(list.get(position).getTitle());
            membershipPrice.setText(list.get(position).getPrice());
            if(list.get(position).getTop_ten_days().equals("0"))
            {
                topTen.setCompoundDrawablesWithIntrinsicBounds(AppCompatResources.getDrawable(context,R.drawable.ic_cross), null, null, null);

            }else
            {
                topTen.setText(list.get(position).getTop_ten_days() + " Days");
            }

            if(list.get(position).getTop_twenty_days().equals("0"))
            {
                topTwenty.setCompoundDrawablesWithIntrinsicBounds(AppCompatResources.getDrawable(context,R.drawable.ic_cross), null, null, null);

            }else
            {
                topTwenty.setText(list.get(position).getTop_twenty_days() + " Days");
            }

            if(list.get(position).getLeads_capacity().equals("0"))
            {
                leadCapacity.setCompoundDrawablesWithIntrinsicBounds(AppCompatResources.getDrawable(context,R.drawable.ic_cross), null, null, null);

            }else
            {
                leadCapacity.setText("1 to " +list.get(position).getLeads_capacity() + " (Max)");
            }

            if(list.get(position).getQuotations_capacity().equals("0"))
            {
                quotationByPhoto.setCompoundDrawablesWithIntrinsicBounds(AppCompatResources.getDrawable(context,R.drawable.ic_cross), null, null, null);

            }else
            {
                quotationByPhoto.setText("1 to " +list.get(position).getQuotations_capacity() + " (Max)");
            }

            if(list.get(position).getCustomer_support().equals("0"))
            {
                customerSupport.setCompoundDrawablesWithIntrinsicBounds(AppCompatResources.getDrawable(context,R.drawable.ic_cross), null, null, null);

            }else
            {
                customerSupport.setCompoundDrawablesWithIntrinsicBounds(AppCompatResources.getDrawable(context,R.drawable.ic_tick), null, null, null);
            }

            if(list.get(position).getAuthentication_certificate().equals("0"))
            {
                authenticationCertificate.setCompoundDrawablesWithIntrinsicBounds(AppCompatResources.getDrawable(context,R.drawable.ic_cross), null, null, null);

            }else
            {
                authenticationCertificate.setCompoundDrawablesWithIntrinsicBounds(AppCompatResources.getDrawable(context,R.drawable.ic_tick), null, null, null);
            }

            if(list.get(position).getListing_in_24().equals("0"))
            {
                ListingInTwentySeven.setCompoundDrawablesWithIntrinsicBounds(AppCompatResources.getDrawable(context,R.drawable.ic_cross), null, null, null);

            }else
            {
                ListingInTwentySeven.setCompoundDrawablesWithIntrinsicBounds(AppCompatResources.getDrawable(context,R.drawable.ic_tick), null, null, null);
            }

            if(list.get(position).getWelcome_kit().equals("0"))
            {
                welcomeKit.setCompoundDrawablesWithIntrinsicBounds(AppCompatResources.getDrawable(context,R.drawable.ic_cross), null, null, null);

            }else
            {
                welcomeKit.setCompoundDrawablesWithIntrinsicBounds(AppCompatResources.getDrawable(context,R.drawable.ic_tick), null, null, null);
            }

            if(list.get(position).getWorkshop_price().equals("0"))
            {

                Workshop.setCompoundDrawablesWithIntrinsicBounds(AppCompatResources.getDrawable(context,R.drawable.ic_cross), null, null, null);

            }else
            {
                Workshop.setText("Additional AED " +list.get(position).getWorkshop_price());
            }





            container.addView(view);

            buyMembershipBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {

                    if(Workshop.isChecked())
                    {
                        clickListener.selectedItem(list.get(position).getId() , list.get(position).getPrice() , list.get(position).getWorkshop_price());

                    }else
                    {
                        clickListener.selectedItem(list.get(position).getId() , list.get(position).getPrice() , "0");

                    }


                }
            });

            Workshop.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if(isChecked)
                    {
                        int total = Integer.parseInt(list.get(position).getPrice()) + Integer.parseInt(list.get(position).getWorkshop_price());

                        Log.e("tag" , "total price is : "+total);

                        membershipPrice.setText(""+total);

                    }else
                    {
                        membershipPrice.setText(list.get(position).getPrice());

                    }
                }
            });



        } catch (Exception e) {
            e.printStackTrace();
        }

        return view;
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
        container.removeView((View) object);
    }

    @Override
    public int getCount() {
        return list.size();
    }

    @Override
    public boolean isViewFromObject(View view, Object object) {
        return (view == object);
    }

    public interface ClickListener
    {
        void selectedItem(String subscriptionId , String price , String workShopPrice);
    }
}