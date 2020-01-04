package com.devimpact.startup.Account;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Patterns;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.devimpact.startup.OurServicesActivity;
import com.devimpact.startup.R;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.Task;
import com.google.android.material.textfield.TextInputEditText;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;

public class LogIn extends AppCompatActivity {

    EditText mEmailEt;
    TextInputEditText mPasswordEt;
    Button mLoginBtn;
    //Declare an instance of FirebaseAuth
    public FirebaseAuth mAuth;
    //progres dialog
    ProgressDialog progressDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //Remove notification bar
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_log_in);
        //Activity Title
        getSupportActionBar().setTitle(getString(R.string.login));



        //initialize the FirebaseAuth instance.
        mAuth = FirebaseAuth.getInstance();

        //New user Sign in
        TextView signIN = (TextView) findViewById(R.id.new_sign);
        signIN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent mainIntent = new Intent(LogIn.this, Register.class);
                startActivity(mainIntent);
            }
        });

        // if user want to sign in with phone number

        TextView RegPhone = (TextView) findViewById(R.id.reg_phone);
        RegPhone.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent mainIntent = new Intent(LogIn.this, PhoneAuth.class);
                startActivity(mainIntent);
            }
        });

        mEmailEt = findViewById(R.id.email);
        mPasswordEt = findViewById(R.id.password);

        mLoginBtn = findViewById(R.id.log_in);

        mLoginBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //input data
                String email = mEmailEt.getText().toString();
                String password = mPasswordEt.getText().toString().trim();

                if (!Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
                    //invalid email pattern set error
                    mEmailEt.setError("InValid email");
                    mEmailEt.setFocusable(true);

                } else {
                    //valid email patterns
                    Loginuser(email, password);
                }


            }
        });


        //init progress dialog
        progressDialog = new ProgressDialog(LogIn.this);
        progressDialog.setMessage("Logging in ....");


    }

    private void Loginuser(String email, String password) {
        // show progress dialog
        progressDialog.show();

        mAuth.signInWithEmailAndPassword(email, password)
                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        if (task.isSuccessful()) {
                            //dismiss progress dialog
                            progressDialog.dismiss();
                            // Sign in success, update UI with the signed-in user's information
                            FirebaseUser user = mAuth.getCurrentUser();
                            // user is logged in ,open profile activity
                            startActivity(new Intent(LogIn.this, OurServicesActivity.class));
                            finish();
                        } else {
                            //dismiss progress dialog
                            progressDialog.dismiss();
                            // If sign in fails, display a message to the user.
                            Toast.makeText(LogIn.this, "Authentication failed.",
                                    Toast.LENGTH_SHORT).show();
                        }

                    }
                }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                //error and get error
                Toast.makeText(LogIn.this, "" + e.getMessage(), Toast.LENGTH_LONG).show();

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
