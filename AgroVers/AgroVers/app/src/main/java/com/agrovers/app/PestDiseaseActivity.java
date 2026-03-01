package com.agrovers.app;

import android.os.Bundle;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

public class PestDiseaseActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pest_disease);
        setupBottomNavigation(R.id.nav_analysis);

        ImageView iv = findViewById(R.id.ivPlantImage);
        Button btnTake = findViewById(R.id.btnTakePhoto);
        Button btnUpload = findViewById(R.id.btnUploadGallery);
        TextView tvDetected = findViewById(R.id.tvDetectedDiseaseValue);
        TextView tvSteps = findViewById(R.id.tvImmediateStepsValue);

        Runnable runDetection = () -> {
            iv.setImageResource(R.drawable.sample_leaf);
            tvDetected.setText(R.string.pest_disease_detected);
            tvSteps.setText(R.string.pest_disease_steps);
            Toast.makeText(this, R.string.pest_disease_demo_complete, Toast.LENGTH_SHORT).show();
        };

        btnTake.setOnClickListener(v -> runDetection.run());
        btnUpload.setOnClickListener(v -> runDetection.run());
    }
}

