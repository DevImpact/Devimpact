package com.devimpact.startup;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.widget.VideoView;

public class SplashScreen extends AppCompatActivity {


    VideoView videoView;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);


        videoView = (VideoView) findViewById(R.id.videoView);

        Uri video = Uri.parse("android.resource://" + getPackageName() + "/" + R.raw.dev_imp);
        videoView.setVideoURI(video);
//عرض القديو داخل الشاشة الموقته
        videoView.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            public void onCompletion(MediaPlayer mp) {
                startNextActivity();
            }
        });

        videoView.start();
    }



    //عند انتهاء هرض الفديو يقوم بفتح صفحة اخرى
    private void startNextActivity() {
        if (isFinishing())
            return;
        startActivity(new Intent(this, OurServicesActivity.class));
        finish();
    }

}