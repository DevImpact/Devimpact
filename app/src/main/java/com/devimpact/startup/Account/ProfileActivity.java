package com.devimpact.startup.Account;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.devimpact.startup.R;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.squareup.picasso.Picasso;

public class ProfileActivity extends AppCompatActivity {


    private ImageView profilePic;
    private TextView name, email;
    private FirebaseAuth firebaseAuth;
    private DatabaseReference databaseReference;
    private FirebaseUser currentUser;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //Remove notification bar
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_profile);
        //Activity Title
        getSupportActionBar().setTitle("Profile");


        profilePic = findViewById(R.id.ivProfilePic);
        name = findViewById(R.id.tvProfileName);
        email = findViewById(R.id.tvProfileEmail);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        firebaseAuth = FirebaseAuth.getInstance();
        currentUser = firebaseAuth.getCurrentUser();

        // Retrive user profile picture with glide library
        Glide.with(this).load(currentUser.getPhotoUrl()).into(profilePic);

        databaseReference = FirebaseDatabase.getInstance().getReference("DevImpact_app_user").child(firebaseAuth.getUid());

        // Retrive user information
        databaseReference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                UserInfo userProfile = dataSnapshot.getValue(UserInfo.class);
                name.setText("Name: " + userProfile.getName());
                email.setText("Email: " + userProfile.getEmail());
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                Toast.makeText(ProfileActivity.this, databaseError.getCode(), Toast.LENGTH_SHORT).show();
            }
        });

    }

    // return button
    @Override
    public void onBackPressed() {{

        AlertDialog alertDialog = new AlertDialog.Builder(this).create();
        alertDialog.setTitle("Back was pressed");
    }
        finish();
    }

    }
