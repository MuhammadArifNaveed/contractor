package com.thecontractor.Global;

import android.content.Context;
import android.os.Build;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;

import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.content.ContextCompat;

import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;
import com.google.android.material.textfield.TextInputLayout;
import com.thecontractor.Model.IdModel;
import com.thecontractor.Model.SpecialityModel;
import com.thecontractor.R;

import java.util.ArrayList;
import java.util.List;

public class MultiSelectAutoCompleteView extends ConstraintLayout {

    private TextInputLayout inputLayout;
    private AutoCompleteTextView autoCompleteTextView;
    private ChipGroup chipGroup;

    private final ArrayList<SpecialityModel> items = new ArrayList<>();
    private final ArrayList<SpecialityModel> selectedItems = new ArrayList<>();

    public MultiSelectAutoCompleteView(Context context) {
        super(context);
        init(context);
    }

    public MultiSelectAutoCompleteView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public MultiSelectAutoCompleteView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        LayoutInflater.from(context).inflate(R.layout.view_multi_select_autocomplete, this, true);

        autoCompleteTextView = findViewById(R.id.auto_items);
        chipGroup = findViewById(R.id.chip_group);

        autoCompleteTextView.setThreshold(1);

        // 🔹 Show suggestions when user clicks the field (even before typing)
        autoCompleteTextView.setOnClickListener(v -> {
            if (!autoCompleteTextView.isPopupShowing()) {
                autoCompleteTextView.showDropDown();
            }
        });

        // 🔹 Show suggestions when focus is gained
        autoCompleteTextView.setOnFocusChangeListener((v, hasFocus) -> {
            if (hasFocus && !autoCompleteTextView.isPopupShowing()) {
                autoCompleteTextView.showDropDown();
            }
        });

        autoCompleteTextView.setOnItemClickListener((parent, view, position, id) -> {
            String selectedName = (String) parent.getItemAtPosition(position);

            for (SpecialityModel item : items) {
                if (item.getSpeciality_title().equals(selectedName) && !selectedItems.contains(item)) {
                    selectedItems.add(item);
                    addChip(item);
                    break;
                }
            }
            autoCompleteTextView.setText("");
        });
    }

    // ---------------------
    // Public Methods
    // ---------------------
    public void setItems(List<SpecialityModel> list) {
        items.clear();
        items.addAll(list);
        ArrayAdapter<String> adapter = null;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            adapter = new ArrayAdapter<>(
                    getContext(),
                    android.R.layout.simple_dropdown_item_1line,
                    items.stream().map(SpecialityModel::getSpeciality_title).toArray(String[]::new)
            );
        }
        autoCompleteTextView.setAdapter(adapter);
    }

    public ArrayList<IdModel> getSelectedItems() {
        ArrayList<IdModel> idList = new ArrayList<>();
        for (SpecialityModel item : selectedItems) {
            idList.add(new IdModel(item.getId()));
        }
        return idList;
    }

    public void setSelection(List<SpecialityModel> selectedList) {
        chipGroup.removeAllViews();
        selectedItems.clear();
        selectedItems.addAll(selectedList);
        for (SpecialityModel item : selectedList) {
            addChip(item);
        }
    }

    // ---------------------
    // Private Helpers
    // ---------------------
    private void addChip(SpecialityModel item) {
        Chip chip = new Chip(getContext());
        chip.setChipBackgroundColorResource(R.color.appColor);
        chip.setTextColor(ContextCompat.getColor(getContext(), R.color.black));
        chip.setText(item.getSpeciality_title());
        chip.setCloseIconVisible(true);
        chip.setOnCloseIconClickListener(v -> {
            chipGroup.removeView(chip);
            selectedItems.remove(item);
        });
        chipGroup.addView(chip);
    }
}
