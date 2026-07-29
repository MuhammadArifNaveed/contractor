package com.thecontractor.Adapter;

import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.RecyclerView;
import com.google.android.material.shape.CornerFamily;
import com.google.android.material.shape.MaterialShapeDrawable;
import com.google.android.material.shape.ShapeAppearanceModel;
import com.thecontractor.Model.VendorStatusModel;
import com.thecontractor.R;

import java.util.List;


public class VendorStatusAdapter extends RecyclerView.Adapter<VendorStatusAdapter.ViewHolder>  {

    private List<VendorStatusModel> list;
    private Context mContext;
    private String selectedLanguage;
    private StatusIdInterface statusIdInterface;


    public class ViewHolder extends RecyclerView.ViewHolder {

        TextView vendor_status;


        public ViewHolder(final View view) {
            super(view);

            vendor_status = (TextView) view.findViewById(R.id.vendor_status);



            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int pos = getAdapterPosition();

                    VendorStatusModel vendorStatusModel = list.get(pos);
                    statusIdInterface.selectedId(vendorStatusModel.getId());

                }
            });




        }
    }


    public VendorStatusAdapter(Context context, List<VendorStatusModel> list , String selectedLanguage , StatusIdInterface statusIdInterface) {
        this.list = list;
        this.mContext = context;
        this.selectedLanguage = selectedLanguage;
        this.statusIdInterface = statusIdInterface;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = null;
        itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.status_custom_row, parent, false);
        return new ViewHolder(itemView);

    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {

        VendorStatusModel model = list.get(position);

        holder.vendor_status.setText(model.getName());

        ShapeAppearanceModel shapeAppearanceModel = new ShapeAppearanceModel()
                .toBuilder()
                .setAllCorners(CornerFamily.ROUNDED,5)
                .build();

        MaterialShapeDrawable shapeDrawable = new MaterialShapeDrawable(shapeAppearanceModel);
        shapeDrawable.setPadding(10 , 5 , 10 , 5);

        shapeDrawable.setFillColor(ColorStateList.valueOf(Color.parseColor(model.getColor())));
        ViewCompat.setBackground( holder.vendor_status,shapeDrawable);

    }


    @Override
    public int getItemCount() {
        return list.size();
    }
    @Override

    public long getItemId(int position) {
        return position;
    }

    @Override
    public int getItemViewType(int position) {
        return position;
    }


    public interface StatusIdInterface
    {
        void selectedId(String id);
    }

}

