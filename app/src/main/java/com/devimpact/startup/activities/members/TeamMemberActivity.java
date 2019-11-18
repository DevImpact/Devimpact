package com.devimpact.startup.activities.members;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.devimpact.startup.R;
public class TeamMemberActivity1 extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_team_member1);
        getSupportActionBar().setDisplayShowHomeEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        setTitle(getString(R.string.ListOfDeveloper));
        Intent intent = getIntent();
        TeamMemberInfo developer = (TeamMemberInfo) intent.getSerializableExtra("developer");

        ((TextView)findViewById(R.id.profileName)).setText(developer.getUserName());
        ((TextView)findViewById(R.id.country)).setText(developer.getCountry());
        ((TextView)findViewById(R.id.title)).setText(developer.getTitle());
        ((TextView)findViewById(R.id.Division)).setText(developer.getDivision());
        ((ImageView)findViewById(R.id.profilePhoto)).setImageResource(getResources().getIdentifier(developer.getProfileImageUrl(), "drawable", getPackageName()));
///// implements when button facebook pressed , it open DevImpact Page
        findViewById(R.id.facebook).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String FACEBOOK_URL="https://www.facebook.com/DevImpactOfficial";
                String FACEBOOK_PAGE_ID="DevImpactOfficial";
                PackageManager packageManager = getPackageManager();
                try {
                    int versionCode = packageManager.getPackageInfo("com.facebook.katana", 0).versionCode;
                    if (versionCode >= 3002850) { //newer versions of fb app
                        Intent i= new Intent(Intent.ACTION_VIEW, Uri.parse("fb://facewebmodal/f?href=" + FACEBOOK_URL));
                        startActivity(i);
                    } else { //older versions of fb app
                        Intent i= new Intent(Intent.ACTION_VIEW, Uri.parse("fb://page/" + FACEBOOK_PAGE_ID));
                        startActivity(i);
                    }
                } catch (PackageManager.NameNotFoundException e) {
                    // If no fb app found, open on browser
                    Intent i =  new Intent(Intent.ACTION_VIEW, Uri.parse(FACEBOOK_URL));
                    startActivity(i);
                }
            }
        });

        ///// implements when button twitter pressed , it open DevImpact Page
        findViewById(R.id.twitter).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                // https://twitter.com/DevImpact2018
                Intent intent;
                try{
                    // Get Twitter app
                    getPackageManager().getPackageInfo("com.twitter.android", 0);
                    intent = new Intent(Intent.ACTION_VIEW, Uri.parse("twitter://user?screen_name=DevImpact2018"));
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                } catch (Exception e) {
                    // If no Twitter app found, open on browser
                    intent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://twitter.com/DevImpact2018"));
                }
                startActivity(intent);
            }
        });

///// implements when button youtube pressed , it open DevImpact channel
        findViewById(R.id.youtube).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                ///https://www.youtube.com/c/Devimpact
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse("https://www.youtube.com/c/Devimpact"));
                startActivity(intent);
            }
        });
    }

    @Override
    public void onBackPressed(){
        super.onBackPressed();
    }

    @Override
    public boolean onSupportNavigateUp() {
        onBackPressed();
        return true;
    }
}
