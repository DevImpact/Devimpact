package com.devimpact.startup.Account;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.devimpact.startup.R;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.UserProfileChangeRequest;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;

import java.io.IOException;
import java.util.HashMap;

public class ProfileActivity extends AppCompatActivity {


    private ImageView profilePic;
    private TextView name, email;
    private FirebaseAuth firebaseAuth;
    private DatabaseReference databaseReference;
    private FirebaseUser currentUser;
    FloatingActionButton fab;
    ProgressDialog progressDialog;
    DatabaseReference databaseRef;

    //a constant to track the file chooser intent
    private static final int PICK_IMAGE_REQUEST = 567;

    //a Uri object to store file path
    Uri filePath;


    //checking Profile picture
    String profilePicture;



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
        fab = findViewById(R.id.fab);
        progressDialog = new ProgressDialog(this);

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

        //fab button click
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showEditProfileDialoge();
            }
        });

    }


    private void showEditProfileDialoge() {

        //show Dialog containg options

        String options[] = {"Edit Profile Picture"};

        //alert Dialog
        AlertDialog.Builder builder= new AlertDialog.Builder(this);
        builder.setTitle("Choose Action");
        builder.setItems(options, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {

                if (which == 0) {
                    progressDialog.setMessage("Updating Profile Picture");
                    showImagePicDialog();
                    profilePicture = "Image"; }

            }

        });

        // create and show Dialog
        builder.create().show();
    }

    // Change Profile Image
    private void showImagePicDialog() {
        // Pick from gallery
        Intent intent = new Intent();
        intent.setType("image/*");
        intent.setAction(Intent.ACTION_GET_CONTENT);
        startActivityForResult(Intent.createChooser(intent, "Select Picture"), PICK_IMAGE_REQUEST);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if(requestCode == PICK_IMAGE_REQUEST && resultCode == RESULT_OK && data.getData() != null){
            filePath = data.getData();
            updateProfilePhoto(filePath);
            try {
                Bitmap bitmap = MediaStore.Images.Media.getBitmap(getContentResolver(), filePath);
                profilePic.setImageBitmap(bitmap);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        super.onActivityResult(requestCode, resultCode, data);
    }


    private void updateProfilePhoto(final Uri filePath) {


        final StorageReference mStorage = FirebaseStorage.getInstance().getReference().child("users_photos");
        final StorageReference imgFilePath = mStorage.child(firebaseAuth.getUid()).child("Images/Profile Pic");
        imgFilePath.putFile(filePath).addOnSuccessListener(new OnSuccessListener<UploadTask.TaskSnapshot>() {
            @Override
            public void onSuccess(final UploadTask.TaskSnapshot taskSnapshot) {

                imgFilePath.getDownloadUrl().addOnSuccessListener(new OnSuccessListener<Uri>() {
                    @Override
                    public void onSuccess(Uri uri) {
                        // uri contain user image url

                        FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                        UserProfileChangeRequest profileUpdate = new UserProfileChangeRequest.Builder()
                                .setDisplayName("userName")
                                .setPhotoUri(uri)
                                .build();

                        currentUser.updateProfile(profileUpdate)
                                .addOnCompleteListener(new OnCompleteListener<Void>() {
                                    @Override
                                    public void onComplete(@NonNull Task<Void> task) {
                                        Task<Uri> uriTask = taskSnapshot.getStorage().getDownloadUrl();
                                        while (!uriTask.isSuccessful());
                                        Uri downloadUri = uriTask.getResult();
                                        if (uriTask.isSuccessful()) {
                                            // Image Uploaded
                                            HashMap<String, Object> results = new HashMap<>();
                                            results.put(String.valueOf(profilePic), downloadUri.toString());
                                        } else {
                                            progressDialog.dismiss();
                                            Toast.makeText(ProfileActivity.this, "Error Occoured", Toast.LENGTH_SHORT).show();
                                        }
                                    }
                                });
                    }
                });

            }


        })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        progressDialog.dismiss();
                        Toast.makeText(ProfileActivity.this, "Upload Failure",
                                Toast.LENGTH_SHORT).show();
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
