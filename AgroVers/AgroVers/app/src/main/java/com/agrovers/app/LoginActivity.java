package com.agrovers.app;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

public class LoginActivity extends AppCompatActivity {

    private static final String PREFS = "agrovers_prefs";
    private static final String KEY_PHONE = "phone";

    private EditText etPhone;
    private LinearLayout otpSection;
    private EditText etOtp;
    private Button btnSendOtp;
    private Button btnVerifyOtp;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        etPhone = findViewById(R.id.etPhone);
        otpSection = findViewById(R.id.otpSection);
        etOtp = findViewById(R.id.etOtp);
        btnSendOtp = findViewById(R.id.btnSendOtp);
        btnVerifyOtp = findViewById(R.id.btnVerifyOtp);

        otpSection.setVisibility(View.GONE);

        btnSendOtp.setOnClickListener(v -> {
            String phone = etPhone.getText().toString().trim();
            if (TextUtils.isEmpty(phone) || phone.length() < 10) {
                Toast.makeText(this, "Enter a valid phone number", Toast.LENGTH_SHORT).show();
                return;
            }
            otpSection.setVisibility(View.VISIBLE);
            Toast.makeText(this, "OTP sent (demo): 1234", Toast.LENGTH_SHORT).show();
        });

        btnVerifyOtp.setOnClickListener(v -> {
            String phone = etPhone.getText().toString().trim();
            String otp = etOtp.getText().toString().trim();
            if (TextUtils.isEmpty(phone) || phone.length() < 10) {
                Toast.makeText(this, "Enter a valid phone number", Toast.LENGTH_SHORT).show();
                return;
            }
            if (!"1234".equals(otp)) {
                Toast.makeText(this, "Invalid OTP", Toast.LENGTH_SHORT).show();
                return;
            }

            SharedPreferences sp = getSharedPreferences(PREFS, MODE_PRIVATE);
            sp.edit().putString(KEY_PHONE, phone).apply();

            Intent intent = new Intent(this, DashboardActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
            finish();
        });
    }
}

