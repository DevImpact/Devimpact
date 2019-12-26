package com.devimpact.startup.Account;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatButton;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.ContentResolver;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Patterns;
import android.view.View;
import android.view.WindowManager;
import android.webkit.MimeTypeMap;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.devimpact.startup.OurServicesActivity;
import com.devimpact.startup.R;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.android.material.textfield.TextInputEditText;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.UserProfileChangeRequest;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;

import java.io.IOException;

public class Register extends AppCompatActivity {

    TextInputEditText mPassword,mEmail,mUserName,mRePassword;
    ImageView mprofile_pic;
    AppCompatButton mRegister;
    ProgressDialog progressDialog;

    private FirebaseAuth mAuth;
    // Storage reference for profile picture
    StorageReference mStorageRef;

    DatabaseReference reff;

    //a constant to track the file chooser intent
    private static final int PICK_IMAGE_REQUEST = 234;

    //a Uri object to store file path
     Uri filePath;

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if(requestCode == PICK_IMAGE_REQUEST && resultCode == RESULT_OK && data.getData() != null){
            filePath = data.getData();
            try {
                Bitmap bitmap = MediaStore.Images.Media.getBitmap(getContentResolver(), filePath);
                mprofile_pic.setImageBitmap(bitmap);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //Remove notification bar
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_register);
        //Activity Title
        getSupportActionBar().setTitle("Register");


        //User id/Images/Profile Pic.jpg
        reff = FirebaseDatabase.getInstance().getReference().child("DevImpact_app_user");

        // if user already have account

        TextView signIN = (TextView) findViewById(R.id.haveAccount);
        signIN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent mainIntent = new Intent(Register.this, LogIn.class);
                startActivity(mainIntent);
            }
        });

        // if user want to sign in with phone number

        TextView RegPhone = (TextView) findViewById(R.id.reg_phone);
        RegPhone.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent mainIntent = new Intent(Register.this, PhoneAuth.class);
                startActivity(mainIntent);
            }
        });



        mUserName = findViewById(R.id.Rname);
        mEmail = findViewById(R.id.Remail);
        mPassword = findViewById(R.id.Rpassword);
        mRePassword = findViewById(R.id.Rre_passoword);
        mRegister = findViewById(R.id.reg_button);

        // Choose Profile picture
        mprofile_pic= (ImageView) findViewById(R.id.profile_pic);
        mprofile_pic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent();
                intent.setType("image/*");
                intent.setAction(Intent.ACTION_GET_CONTENT);
                startActivityForResult(Intent.createChooser(intent, "Select Picture"), PICK_IMAGE_REQUEST);
            }
        });


        // Initialize Firebase Auth
        mAuth = FirebaseAuth.getInstance();

        progressDialog = new ProgressDialog(this);
        progressDialog.setMessage("Registring user...");

        //handel register btn click

        mRegister.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //input email and password
                String userName = mUserName.getText().toString().trim();
                String Email = mEmail.getText().toString().trim();
                String Password = mPassword.getText().toString().trim();
                String RePassowrd = mRePassword.getText().toString().trim();


                //validate
                if (userName.isEmpty()) {

                    //set error and focus to password editText
                    mUserName.setError("user name is required");
                    mUserName.setFocusable(true);

                } else if (!Patterns.EMAIL_ADDRESS.matcher(Email).matches()) {

                    //set error and focus to email editText

                    mEmail.setError("Invalid email");
                    mEmail.setFocusable(true);
                } else if (Password.length() < 6) {

                    //set error and focus to password editText
                    mPassword.setError("password length at least 6 characters");
                    mPassword.setFocusable(true);

                } else if (!Password.equals(RePassowrd)){
                    mRePassword.setError("password not matching");
                    mRePassword.setFocusable(true);

                }
                else if (!Password.equals(RePassowrd)){
                    mRePassword.setError("password not matching");
                    mRePassword.setFocusable(true);

                }else {
                    RegisterUser(Email, Password);  // registeruser
                }

            }
        });
    }

        private void RegisterUser(final String email, final String password) {
            final String userName = mUserName.getText().toString().trim();
            final String rePassword = mRePassword.getText().toString().trim();

            //email and password patterns is valid show prgressdialog and registeruser
            progressDialog.show();
            mAuth.createUserWithEmailAndPassword(email, password)
                    .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                        @Override
                        public void onComplete(@NonNull Task<AuthResult> task) {
                            if (task.isSuccessful()) {

                                updateUserInfo (userName, filePath, mAuth.getCurrentUser());

                                // Sign in success, dismiss dialog and start registration activity
                                FirebaseUser user = mAuth.getCurrentUser();
                                progressDialog.dismiss();
                                UserInfo userInfo = new UserInfo(userName, email, password);


                                // create firebase database
                                FirebaseDatabase.getInstance().getReference()
                                        .child("DevImpact_app_user")
                                        .child(user.getUid())
                                        .setValue(userInfo)
                                        .addOnFailureListener(new OnFailureListener() {
                                            @Override
                                            public void onFailure(@NonNull Exception e) {
                                                Toast.makeText(Register.this, "" + e.getMessage(), Toast.LENGTH_SHORT).show();

                                            }
                                        });


                            } else {
                                progressDialog.dismiss();
                                // If sign in fails, display a message to the user.
                                Toast.makeText(Register.this, "Authentication failed.",
                                        Toast.LENGTH_SHORT).show();
                            }

                        }
                    }).addOnFailureListener(new OnFailureListener() {
                @Override
                public void onFailure(@NonNull Exception e) {

                    //error and cancel progress dialog and get and show error message
                    progressDialog.dismiss();
                    Toast.makeText(Register.this, "" + e.getMessage(), Toast.LENGTH_SHORT).show();

                }
            });


        }

    private void updateUserInfo(final String username, final Uri filePath, final FirebaseUser currentUser) {

        // upload user profile picture

        StorageReference mStorage = FirebaseStorage.getInstance().getReference().child("users_photos");
        final StorageReference imgFilePath = mStorage.child(mAuth.getUid()).child("Images/Profile Pic");
        imgFilePath.putFile(filePath).addOnSuccessListener(new OnSuccessListener<UploadTask.TaskSnapshot>() {
            @Override
            public void onSuccess(UploadTask.TaskSnapshot taskSnapshot) {
                //image uploaded successfully

                imgFilePath.getDownloadUrl().addOnSuccessListener(new OnSuccessListener<Uri>() {
                    @Override
                    public void onSuccess(Uri uri) {

                        // uri contain user image url

                        UserProfileChangeRequest profileUpdate = new UserProfileChangeRequest.Builder()
                                .setDisplayName(username)
                                .setPhotoUri(uri)
                                .build();

                        currentUser.updateProfile(profileUpdate)
                                .addOnCompleteListener(new OnCompleteListener<Void>() {
                                    @Override
                                    public void onComplete(@NonNull Task<Void> task) {

                                        if (task.isSuccessful()) {
                                            Toast.makeText(Register.this, "Register complete",
                                                    Toast.LENGTH_SHORT).show();
                                            updateUI();
                                        }
                                    }
                                });
                    }
                });
            }
        });
    }

    private void updateUI() {
        Intent activity = new Intent(getApplicationContext(), OurServicesActivity.class);
        startActivity(activity);
        finish();
    }


    // Creating Method to get the selected image file Extension from File Path URI.
    private String GetFileExtension(Uri uri) {

        ContentResolver contentResolver = getContentResolver();

        MimeTypeMap mimeTypeMap = MimeTypeMap.getSingleton();

        // Returning the file Extension.
        return mimeTypeMap.getExtensionFromMimeType(contentResolver.getType(uri));

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
