package com.devimpact.startup.activities.about;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProviders;

import com.devimpact.startup.R;

public class AboutFragment extends Fragment {

    private About About;

    public View onCreateView(@NonNull LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {
        About =
                ViewModelProviders.of(this).get(About.class);
        View root = inflater.inflate(R.layout.fragment_about, container, false);
        final TextView textView = root.findViewById(R.id.text_gallery);
        About.getText().observe(this, new Observer<String>() {
            @Override
            public void onChanged(@Nullable String s) {
                textView.setText(s);
            }
        });
        return root;
    }
}