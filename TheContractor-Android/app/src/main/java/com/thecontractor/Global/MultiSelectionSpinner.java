package com.thecontractor.Global;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Color;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.SpinnerAdapter;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.widget.AppCompatSpinner;

import com.google.android.flexbox.FlexboxLayout;
import com.thecontractor.Model.IdModel;
import com.thecontractor.Model.SpecialityModel;
import com.thecontractor.R;

import java.util.ArrayList;
import java.util.Arrays;

public class MultiSelectionSpinner extends AppCompatSpinner implements
        DialogInterface.OnMultiChoiceClickListener {

    ArrayList<SpecialityModel> items = null;
    boolean[] selection = null;
    ChipsAdapter adapter;

    public MultiSelectionSpinner(Context context) {
        super(context);
        init(context);
    }

    public MultiSelectionSpinner(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    private void init(Context context) {
        adapter = new ChipsAdapter(context);
        super.setAdapter(adapter);
    }

    @Override
    public void onClick(DialogInterface dialog, int which, boolean isChecked) {
        if (selection != null && which < selection.length) {
            selection[which] = isChecked;
            adapter.update();
        } else {
            throw new IllegalArgumentException("Argument 'which' is out of bounds.");
        }
    }

    @Override
    public boolean performClick() {
        final AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
        String[] itemNames = new String[items.size()];

        for (int i = 0; i < items.size(); i++) {
            itemNames[i] = items.get(i).getSpeciality_title();
        }

        if (itemNames.length > 0) {
            builder.setMultiChoiceItems(itemNames, selection, this);
            builder.setPositiveButton("OK", (dialog, which) -> { /* do nothing */ });
            builder.show();
        } else {
            Toast.makeText(getContext(), "This city categories not available", Toast.LENGTH_SHORT).show();
        }

        return true;
    }

    @Override
    public void setAdapter(SpinnerAdapter adapter) {
        throw new RuntimeException("setAdapter is not supported by MultiSelectionSpinner.");
    }

    public void setItems(ArrayList<SpecialityModel> items) {
        this.items = items;
        selection = new boolean[this.items.size()];
        Arrays.fill(selection, false);
        adapter.update();
    }

    public void setSelection(ArrayList<SpecialityModel> selectedList) {
        Arrays.fill(this.selection, false);
        for (SpecialityModel sel : selectedList) {
            for (int j = 0; j < items.size(); ++j) {
                if (items.get(j).getId().equals(sel.getId())) {
                    this.selection[j] = true;
                }
            }
        }
        adapter.update();
    }

    public ArrayList<IdModel> getSelectedItems() {
        ArrayList<IdModel> selectedItems = new ArrayList<>();
        for (int i = 0; i < items.size(); ++i) {
            if (selection[i]) {
                selectedItems.add(new IdModel(items.get(i).getId()));
            }
        }
        return selectedItems;
    }

    // --------------------------
    // Custom Adapter Inner Class
    // --------------------------
    private class ChipsAdapter extends BaseAdapter implements SpinnerAdapter {
        Context context;
        View currentView;

        ChipsAdapter(Context ctx) {
            context = ctx;
        }

        void update() {
            notifyDataSetChanged();
        }

        @Override
        public int getCount() {
            return 1; // always 1 visible "view" for spinner
        }

        @Override
        public Object getItem(int position) {
            return null;
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int position, View convertView, android.view.ViewGroup parent) {
            LayoutInflater inflater = LayoutInflater.from(context);
            View layout = inflater.inflate(R.layout.spinner_selected_items, parent, false);
            FlexboxLayout flexboxLayout = layout.findViewById(R.id.flex_container);

            if (items != null && selection != null) {
                int selectedCount = 0;

                for (int i = 0; i < items.size(); i++) {
                    if (selection[i]) {
                        selectedCount++;
                        View chip = inflater.inflate(R.layout.item_chip, flexboxLayout, false);
                        TextView chipText = chip.findViewById(R.id.chip_text);
                        chipText.setText(items.get(i).getSpeciality_title());
                        flexboxLayout.addView(chip);
                    }
                }

                if (selectedCount == 0) {
                    TextView placeholder = new TextView(context);
                    placeholder.setText("Select Specialties");
                    placeholder.setTextSize(16);
                    placeholder.setTextColor(Color.GRAY);
                    flexboxLayout.addView(placeholder);
                }
            }

            currentView = layout;
            return layout;
        }
    }
}
