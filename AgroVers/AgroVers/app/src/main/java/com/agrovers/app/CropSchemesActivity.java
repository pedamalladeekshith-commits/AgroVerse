package com.agrovers.app;

import android.os.Bundle;
import android.widget.Toast;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.agrovers.app.adapter.SchemeAdapter;
import com.agrovers.app.model.SchemeItem;

import java.util.ArrayList;
import java.util.List;

public class CropSchemesActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_crop_schemes);
        setupBottomNavigation(R.id.nav_home);

        RecyclerView rv = findViewById(R.id.rvSchemes);
        rv.setLayoutManager(new LinearLayoutManager(this));

        List<SchemeItem> schemes = new ArrayList<>();
        schemes.add(new SchemeItem("PM Kisan Samman Nidhi Yojana", "Income support scheme for eligible farmers."));
        schemes.add(new SchemeItem("Fasal Bima Yojana (Crop Insurance)", "Protects farmers against crop loss due to natural calamities."));
        schemes.add(new SchemeItem("Kisan Credit Card (KCC)", "Provides timely credit support for cultivation and allied needs."));
        schemes.add(new SchemeItem("Soil Health Card", "Advisory based on soil testing to improve productivity."));

        rv.setAdapter(new SchemeAdapter(schemes, item ->
                Toast.makeText(CropSchemesActivity.this, "Applied: " + item.getName(), Toast.LENGTH_SHORT).show()
        ));
    }
}

