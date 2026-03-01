package com.agrovers.app;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;

public class AnalysisActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_analysis);
        setupBottomNavigation(R.id.nav_analysis);

        Button btnCrop = findViewById(R.id.btnGoCropRecommendation);
        Button btnPest = findViewById(R.id.btnGoPestDetection);
        Button btnSoil = findViewById(R.id.btnGoSoilMonitoring);

        btnCrop.setOnClickListener(v -> startActivity(new Intent(this, CropRecommendationActivity.class)));
        btnPest.setOnClickListener(v -> startActivity(new Intent(this, PestDiseaseActivity.class)));
        btnSoil.setOnClickListener(v -> startActivity(new Intent(this, SoilMonitoringActivity.class)));
    }
}

