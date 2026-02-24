package com.thecontractor.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.thecontractor.Model.VendorJobCategoriesModel;
import com.thecontractor.Model.WorkshopSectorModel;
import com.thecontractor.R;

import java.util.List;


public class WorkshopSectorSpinnerAdapter extends BaseAdapter {
    private Context context;
    private List<WorkshopSectorModel> coreList;
    private LayoutInflater inflater;
    private String selectedLanguage;



    public WorkshopSectorSpinnerAdapter(Context context, List<WorkshopSectorModel> list , String selectedLanguage) {
        this.context = context;
        this.coreList = list;
        this.selectedLanguage = selectedLanguage;
    }


    @Override
    public int getCount() {
        return coreList.size();
    }

    @Override
    public Object getItem(int i) {
        return coreList.get(i);
    }

    @Override
    public long getItemId(int i) {
        return i;
    }

    @Override
    public View getView(int i, View view, ViewGroup viewGroup) {
        if (inflater == null) {
            inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        }
        if (view == null) {
            view = inflater.inflate(R.layout.spinner_cusom_row, null);
        }

        TextView txtName = (TextView) view.findViewById(R.id.spinnerName);

        WorkshopSectorModel bean = coreList.get(i);


        if(selectedLanguage.equals("en"))
        {
            txtName.setText(bean.getTitle());
        }else
        {
            txtName.setText(bean.getTitle());
        }


        return view;
    }

}
