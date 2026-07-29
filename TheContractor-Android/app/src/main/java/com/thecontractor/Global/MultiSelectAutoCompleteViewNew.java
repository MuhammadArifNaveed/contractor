package com.thecontractor.Global;

import android.content.Context;
import android.os.Build;
import android.text.Editable;
import android.text.InputFilter;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;

import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.content.ContextCompat;

import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;
import com.google.android.material.textfield.TextInputLayout;
import com.thecontractor.R;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;

public class MultiSelectAutoCompleteViewNew<T> extends ConstraintLayout {

    private AutoCompleteTextView autoCompleteTextView;
    private ChipGroup chipGroup;

    private final ArrayList<T> items = new ArrayList<>();
    private final ArrayList<T> selectedItems = new ArrayList<>();

    private Function<T, String> displayMapper;
    private Function<T, String> idMapper;

    // 👇 Custom callback

    private OnTextChangeListener onTextChangeListener;
    private OnItemSelectedListener<T> onItemSelectedListener;
    private OnChipAddListener<T> onChipAddListener;

    private boolean suppressTextChange = false;

    public interface OnTextChangeListener {
        void onTextChanged(String text);
    }

    public interface OnItemSelectedListener<T> {
        void onItemSelected(T item);
    }

    public interface OnChipAddListener<T> {
        void onChipAdded(T item);
    }

    public void setOnTextChangeListener(OnTextChangeListener listener) {
        this.onTextChangeListener = listener;
    }

    public void setOnItemSelectedListener(OnItemSelectedListener<T> listener) {
        this.onItemSelectedListener = listener;
    }

    public void setOnChipAddListener(OnChipAddListener<T> listener) {
        this.onChipAddListener = listener;
    }



    public MultiSelectAutoCompleteViewNew(Context context) {
        super(context);
        init(context);
    }

    public MultiSelectAutoCompleteViewNew(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public MultiSelectAutoCompleteViewNew(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        LayoutInflater.from(context).inflate(R.layout.view_multi_select_autocomplete_new, this, true);

        autoCompleteTextView = findViewById(R.id.auto_items);
        chipGroup = findViewById(R.id.chip_group);

        autoCompleteTextView.setThreshold(0);

//        // Fix dropdown positioning
//        post(() -> autoCompleteTextView.setDropDownAnchor(R.id.auto_items));

        // Show dropdown when clicked or focused
        autoCompleteTextView.setOnClickListener(v -> {
            if (!autoCompleteTextView.isPopupShowing())
                autoCompleteTextView.showDropDown();
        });
        autoCompleteTextView.setOnFocusChangeListener((v, hasFocus) -> {
            if (hasFocus && !autoCompleteTextView.isPopupShowing())
                autoCompleteTextView.showDropDown();
        });

        // ✅ Attach internal text watcher (only once)
        autoCompleteTextView.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                
                if (autoCompleteTextView.isPerformingCompletion()) {
                    // An item has been selected from the list via performCompletion().
                    // Ignore this text change event.
                    return;
                }

                if (suppressTextChange) return;
                if (onTextChangeListener != null) {
                    onTextChangeListener.onTextChanged(s.toString());
                }
            }

            @Override public void afterTextChanged(Editable s) {}
        });

        // ✅ Handle dropdown item clicks
        autoCompleteTextView.setOnItemClickListener((parent, view, position, id) -> {
            String selectedText = (String) parent.getItemAtPosition(position);
            T selectedItem = null;

            for (T item : items) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    if (displayMapper.apply(item).equals(selectedText)) {

                        if (isItemAlreadySelected(item)) {
                            break; // already selected → do nothing
                        }

                        selectedItems.add(item);
                        addChip(item);
                        selectedItem = item;
                        break;
                    }
                }
            }

            if (onItemSelectedListener != null && selectedItem != null) {
                onItemSelectedListener.onItemSelected(selectedItem);
            }

            suppressTextChange = true;
            autoCompleteTextView.setText("");
            suppressTextChange = false;

        });
    }

    private boolean isItemAlreadySelected(T newItem) {
        if (idMapper == null) return selectedItems.contains(newItem);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            String newId = idMapper.apply(newItem);
            for (T item : selectedItems) {
                if (idMapper.apply(item).equals(newId)) {
                    return true;
                }
            }
        }
        return false;
    }

    // ------------------------------------------------------
    // Public APIs
    // ------------------------------------------------------

    public void setHint(String hint) {
        autoCompleteTextView.setHint(hint);
    }

    public void setInputType(int inputType) {
        autoCompleteTextView.setInputType(inputType);
    }

    public void setMaxLength(int maxLength) {
        if (maxLength > 0) {
            autoCompleteTextView.setFilters(new InputFilter[]{ new InputFilter.LengthFilter(maxLength) });
        } else {
            autoCompleteTextView.setFilters(new InputFilter[]{});
        }
    }

    public void showDropdown() {
        if (!autoCompleteTextView.isPopupShowing()) {
            autoCompleteTextView.showDropDown();
        }
    }

    public void setItems(List<T> list, Function<T, String> displayMapper, Function<T, String> idMapper) {
        this.displayMapper = displayMapper;
        this.idMapper = idMapper;

        items.clear();
        items.addAll(list);

        ArrayList<String> displayList = new ArrayList<>();
        for (T item : list) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                displayList.add(displayMapper.apply(item));
            }
        }

        ArrayAdapter<String> adapter = new ArrayAdapter<>(
                getContext(),
                android.R.layout.simple_dropdown_item_1line,
                displayList
        );

        autoCompleteTextView.setAdapter(adapter);
    }

    public ArrayList<T> getSelectedModels() {
        return selectedItems;
    }

    public <R> ArrayList<R> getSelectedItems(Function<String, R> idMapperFn) {
        ArrayList<R> mappedList = new ArrayList<>();
        for (T item : selectedItems) {
            String id = null;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                id = (this.idMapper != null) ? this.idMapper.apply(item) : null;
                if (id != null) mappedList.add(idMapperFn.apply(id));
            }
        }
        return mappedList;
    }

    public <R> ArrayList<R> getSelectedNames(Function<String, R> nameMapperFn) {
        ArrayList<R> mappedList = new ArrayList<>();
        for (T item : selectedItems) {
            String name = null;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                name = (this.displayMapper != null) ? this.displayMapper.apply(item) : null;
                if (name != null) mappedList.add(nameMapperFn.apply(name));
            }
        }
        return mappedList;
    }

    public void setSelection(List<T> selectedList) {
        chipGroup.removeAllViews();
        selectedItems.clear();
        selectedItems.addAll(selectedList);
        for (T item : selectedList) addChip(item);
    }

    public void clearSelection() {
        chipGroup.removeAllViews();
        selectedItems.clear();
    }

    private void addChip(T item) {
        Chip chip = new Chip(getContext(), null);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            chip.setText(displayMapper.apply(item));
        }
        chip.setChipBackgroundColorResource(R.color.appColor);
        chip.setTextColor(ContextCompat.getColor(getContext(), R.color.black));
        chip.setCloseIconVisible(true);
        chip.setOnCloseIconClickListener(v -> {
            chipGroup.removeView(chip);
            selectedItems.remove(item);

            if (onChipAddListener != null) {
                onChipAddListener.onChipAdded(item);
            }

        });
        chipGroup.addView(chip);

        if (onChipAddListener != null) {
            onChipAddListener.onChipAdded(item);
        }
    }
}
