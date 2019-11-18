package com.devimpact.startup;

import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.Intent;
import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import android.content.DialogInterface;
import android.net.Uri;
import android.os.Bundle;
import android.view.MenuItem;
import com.devimpact.startup.activities.home.HomeFragment;
import com.devimpact.startup.activities.members.DeveloperListFragment;
import com.google.android.material.navigation.NavigationView;
//import com.google.firebase.auth.FirebaseAuth;
import androidx.appcompat.widget.Toolbar;
import androidx.navigation.ui.AppBarConfiguration;
import android.view.View;


public class OurServicesActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener {
    private AppBarConfiguration mAppBarConfiguration;

    FragmentTransaction fragmentTransaction;
    private DrawerLayout drawer;
    ActionBarDrawerToggle toggle;
    Toolbar toolbar;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_our_services);

        //Add Navigation Drawer
        toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        drawer = findViewById(R.id.drawer_layout);
        toggle = new ActionBarDrawerToggle(this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.addDrawerListener(toggle);
        toggle.syncState();
        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(OurServicesActivity.this);
        LoadHomeFragment();

    }

    /*@Override
    public void onBackPressed() {
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }*/

    @Override
    public void onBackPressed() {
        int count = getSupportFragmentManager().getBackStackEntryCount();
        ///////  case of HomeFragment
        Fragment currentFragment = getFragmentManager().findFragmentById(R.id.fragment_container);
        if (currentFragment instanceof HomeFragment) {
                Intent intent = new Intent(Intent.ACTION_MAIN);
                intent.addCategory(Intent.CATEGORY_HOME);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        /////////// case of Other Fragments
         else if (count >1 ) {
            getSupportFragmentManager().popBackStack();
        }
        else if (count == 0) {
            super.onBackPressed();
        }
    }


    @SuppressWarnings("StatementWithEmptyBody")
    @Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        int id = item.getItemId();
        final String appUrl = "https://play.google.com/store/apps/details?id=com.devimpact.startup";

        if (id == R.id.nav_home) {
          LoadHomeFragment();
        }

        if (id == R.id.ListOfDeveloper) {
            fragmentTransaction =  getFragmentManager().beginTransaction();
            DeveloperListFragment fragmentList = new DeveloperListFragment();
            fragmentTransaction.replace(R.id.fragment_container, fragmentList).addToBackStack(null);
            fragmentTransaction.commit();
        }

        else if (id == R.id.nav_about) {
            Intent it = new Intent(OurServicesActivity.this, com.devimpact.startup.activities.about.About.class);
            startActivity(it);
        } else if (id == R.id.nav_share) {
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
////////////  load homeFragment
    private void LoadHomeFragment() {
        fragmentTransaction =  getFragmentManager().beginTransaction();
        HomeFragment home = new HomeFragment();
        fragmentTransaction.replace(R.id.fragment_container, home,"homeFragment").addToBackStack(null);
        fragmentTransaction.commit();
    }
    /////////// it called from every fragment have to show the back arrow , except the starting Fragment
    public void showBackIcon() {
        toggle.setDrawerIndicatorEnabled(false);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        toggle.setToolbarNavigationClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });
        toolbar.setNavigationIcon(OurServicesActivity.this.getDrawerToggleDelegate().getThemeUpIndicator());
        drawer.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);

    }
//////////// to show the navigation icon after removing back arrow
    public void showNavigation(){
        //You must regain the power of swipe for the drawer.
        drawer.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED);
        // Remove back button
        getSupportActionBar().setDisplayHomeAsUpEnabled(false);
        // Show hamburger icon
        toggle.setDrawerIndicatorEnabled(true);
        toggle.setToolbarNavigationClickListener(null);
    }

}
