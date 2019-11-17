package com.devimpact.startup;

import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.net.Uri;
import android.os.Bundle;
import android.view.MenuItem;
import com.google.android.material.navigation.NavigationView;
//import com.google.firebase.auth.FirebaseAuth;
import java.io.File;

import androidx.appcompat.widget.Toolbar;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;
import com.devimpact.startup.R;

public class OurServicesActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener  {
    FragmentTransaction fragmentTransaction;
    FragmentManager fragmentManager;
    //Add Navigation Drawer
    private DrawerLayout drawer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_our_services);
        //Add Navigation Drawer
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        drawer = findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.addDrawerListener(toggle);
        toggle.syncState();

        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(OurServicesActivity.this);



    }

    @Override
    public void onBackPressed() {
        if (drawer.isDrawerOpen(GravityCompat.START)){
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }


    @SuppressWarnings("StatementWithEmptyBody")
    @Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        int id = item.getItemId();
        final String appUrl = "https://play.google.com/store/apps/details?id=com.devimpact.startup";

        if (id == R.id.nav_home) {

            Intent it = new Intent(OurServicesActivity.this, OurServicesActivity.class);
            startActivity(it);
        } else if (id == R.id.nav_about) {
            Intent it = new Intent(OurServicesActivity.this, com.devimpact.startup.activities.about.About.class);
            startActivity(it);
        }  else if (id == R.id.nav_share) {
            Intent shareIntent = new Intent(Intent.ACTION_SEND);
            shareIntent.setType("text/plain");
            shareIntent.putExtra(Intent.EXTRA_TEXT, appUrl);
            startActivity(Intent.createChooser(shareIntent, "Share using"));

        } else if (id == R.id.nav_rate) {
            AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(OurServicesActivity.this);
            dialogBuilder.setTitle(R.string.rate_s);
            dialogBuilder.setMessage(R.string.if_you);
            dialogBuilder.setPositiveButton(R.string.rate_s, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    Intent i = new Intent(Intent.ACTION_VIEW);
                    i.setData(Uri.parse(appUrl));
                    startActivity(i);
                    dialog.dismiss();
                }
            });
            AlertDialog dialog = dialogBuilder.create();
            dialog.show();

        }

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }

}
