package com.agrovers.app;

import android.os.Bundle;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.agrovers.app.adapter.CropAdapter;
import com.agrovers.app.model.CropItem;

import java.util.ArrayList;
import java.util.List;

public class CropRecommendationActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_crop_recommendation);
        setupBottomNavigation(R.id.nav_analysis);

        TextView tvClimate = findViewById(R.id.tvClimateValue);
        TextView tvSoilType = findViewById(R.id.tvSoilTypeValue);
        TextView tvRainfall = findViewById(R.id.tvRainfallValue);

        tvClimate.setText(R.string.crop_recommendation_climate);
        tvSoilType.setText(R.string.crop_recommendation_soil);
        tvRainfall.setText(R.string.crop_recommendation_rainfall);

        RecyclerView rv = findViewById(R.id.rvCrops);
        rv.setLayoutManager(new LinearLayoutManager(this));

        List<CropItem> crops = new ArrayList<>();
        crops.add(new CropItem("Rice", "High yield in warm climates"));
        crops.add(new CropItem("Sugarcane", "Good rainfall tolerance"));
        crops.add(new CropItem("Cotton", "Performs well in loamy soil"));
        crops.add(new CropItem("Maize", "Versatile and drought tolerant"));

        rv.setAdapter(new CropAdapter(crops));
    }
}

