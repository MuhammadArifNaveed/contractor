package com.thecontractor.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.thecontractor.Model.AreaModel;
import com.thecontractor.R;

import java.util.List;


public class AreaSpinnerAdapter extends BaseAdapter {
    private Context context;
    private List<AreaModel> coreList;
    private LayoutInflater inflater;
    private String selectedLanguage;



    public AreaSpinnerAdapter(Context context, List<AreaModel> list , String selectedLanguage) {
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

        AreaModel bean = coreList.get(i);


        if(selectedLanguage.equals("en"))
        {
            txtName.setText(bean.getArea_name());
        }else
        {
            txtName.setText(bean.getArabic_name());
        }


        return view;
    }

}
