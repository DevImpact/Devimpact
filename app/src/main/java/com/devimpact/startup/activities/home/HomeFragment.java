package com.devimpact.startup.activities.home;

import android.app.Fragment;
import android.app.FragmentTransaction;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import com.devimpact.startup.OurServicesActivity;
import com.devimpact.startup.R;
import com.devimpact.startup.activities.DesignPicsActivity;
import com.devimpact.startup.activities.DevelopingAppsActivity;
import com.devimpact.startup.activities.OtherServicesActivity;
import com.devimpact.startup.activities.ProfitStrategiesActivity;
import com.devimpact.startup.activities.VideosActivity;
import com.google.android.youtube.player.YouTubePlayer;
import com.google.android.youtube.player.YouTubeInitializationResult;
import com.google.android.youtube.player.YouTubePlayerFragment;

import androidx.annotation.NonNull;


public class HomeFragment extends Fragment implements YouTubePlayer.OnInitializedListener {

    private YouTubePlayerFragment playerFragment;
    private YouTubePlayer mPlayer;
    private String videoID = "";

    public View onCreateView(@NonNull LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {

        View root = inflater.inflate(R.layout.fragment_home, container, false);
        ((OurServicesActivity) getActivity()).showNavigation();


        ///////create playerFragment to load our video on youtube
        playerFragment = YouTubePlayerFragment.newInstance();
        //////use the created youtube API Key
        playerFragment.initialize(getString(R.string.youtubeAPIKey), this);
        //// add to FrameLayout as inside the Home Fragment
        FragmentTransaction transaction = getFragmentManager().beginTransaction();
        transaction.replace(R.id.addyoutube, playerFragment).addToBackStack(null);
        transaction.commit();
        ///////////////////////// implements onClicklistener for each item  //////////////////////////////////////////
        final Button design = (Button) root.findViewById(R.id.design);
        design.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getActivity(), DesignPicsActivity.class);
                startActivity(intent);
            }
        });

        final Button programming = (Button) root.findViewById(R.id.programming);
        programming.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getActivity(), DevelopingAppsActivity.class);
                startActivity(intent);
            }
        });

        final Button videos = (Button) root.findViewById(R.id.videos);
        videos.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getActivity(), VideosActivity.class);
                startActivity(intent);
            }
        });

        final Button money = (Button) root.findViewById(R.id.money);
        money.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getActivity(), ProfitStrategiesActivity.class);
                startActivity(intent);
            }
        });
        final Button others = (Button) root.findViewById(R.id.others);
        others.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getActivity(), OtherServicesActivity.class);
                startActivity(intent);
            }
        });
        final Button askforservice = (Button) root.findViewById(R.id.askforservice);
        askforservice.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                // Intent intent = new Intent(OurServicesActivity.this, askforserviceActivity.class);
                //startActivity(intent);
            }
        });
        return root;
    }

    @Override
    public void onInitializationSuccess(YouTubePlayer.Provider provider, YouTubePlayer youTubePlayer, boolean b) {
        mPlayer = youTubePlayer;

        //Enables automatic control of orientation
        mPlayer.setFullscreenControlFlags(YouTubePlayer.FULLSCREEN_FLAG_CONTROL_ORIENTATION);

        //Show full screen in landscape mode always
        mPlayer.addFullscreenControlFlag(YouTubePlayer.FULLSCREEN_FLAG_ALWAYS_FULLSCREEN_IN_LANDSCAPE);

        //System controls will appear automatically
        mPlayer.addFullscreenControlFlag(YouTubePlayer.FULLSCREEN_FLAG_CONTROL_SYSTEM_UI);

        if (!b) {
            mPlayer.cueVideo(getString(R.string.youtubeVideo_id));
        } else {
            mPlayer.play();
        }

    }

    @Override
    public void onInitializationFailure(YouTubePlayer.Provider provider, YouTubeInitializationResult youTubeInitializationResult) {
        mPlayer = null;
    }


}
