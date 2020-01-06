package com.devimpact.startup.activities.about;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.NavUtils;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.Toolbar;
import com.devimpact.startup.R;
public class About extends AppCompatActivity {

    TextView text;
    Animation anim;
    Animation put,out,rotat;
    Button button,facebook,twet,youtub;
    Boolean open=true;
    long time;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_about);


        //ربط الانميشن مع النص
        text=(TextView)findViewById(R.id.titel);
        anim= AnimationUtils.loadAnimation(this,R.anim.mov);
        text.setAnimation(anim);

        //ربط الانميشن مع العنوان
        text=(TextView)findViewById(R.id.dev);
        anim= AnimationUtils.loadAnimation(this,R.anim.txt_mov);
        text.setAnimation(anim);



        button=(Button)findViewById(R.id.button);
        facebook=(Button)findViewById(R.id.facebook);
        twet=(Button)findViewById(R.id.twet);
        youtub=(Button)findViewById(R.id.youtube) ;



        put=AnimationUtils.loadAnimation(this,R.anim.put);
        out=AnimationUtils.loadAnimation(this,R.anim.out);
        rotat=AnimationUtils.loadAnimation(this,R.anim.rotat);

    }


    @Override
    public boolean onOptionsItemSelected(MenuItem item) {


        if (item.getItemId()==android.R.id.home){

            finish();
        }
        return super.onOptionsItemSelected(item);
    }


    //عند الضعط على شعار الفريق
    public void devClick(View view) {

        //عند الضغط للمره الاولى تظهر الايقوتات المختغية
        if (open){
            open=false;
            button.startAnimation(rotat);
            facebook.startAnimation(put);
            twet.startAnimation(put);
            youtub.startAnimation(put);

            facebook.setVisibility(View.VISIBLE);
            twet.setVisibility(View.VISIBLE);
            youtub.setVisibility(View.VISIBLE);



        }else{
            //عند الضغط للمره الثانية تختفي
            open=true;


            button.startAnimation(rotat);
            facebook.startAnimation(out);
            twet.startAnimation(out);
            youtub.startAnimation(out);

            facebook.setVisibility(View.INVISIBLE);
            twet.setVisibility(View.INVISIBLE);
            youtub.setVisibility(View.INVISIBLE);

        }
    }




    //زر الذخاب الر الفيس بوك
    public void facebook(View view) {

        Intent facebook= new Intent(Intent.ACTION_VIEW);
        facebook.setData(Uri.parse("https://www.facebook.com/DevImpactOfficial"));
//التاكد بان ليس هناكintentاخرى تفتح في نفس اللحظة
        if (facebook.resolveActivity(getPackageManager()) !=null){
            startActivity(facebook);

        }
    }



    // زر الذهاب الى اليوتيوب
    public void youtube_btn(View view) {

        Intent youtube = new Intent(Intent.ACTION_VIEW);
        youtube.setData(Uri.parse("https://www.youtube.com/c/Devimpact"));
//التاكد بان ليس هناكintentاخرى تفتح في نفس اللحظة
        if (youtube.resolveActivity(getPackageManager()) !=null){
            startActivity(youtube);

        }
    }



    public void twitter_btn(View view) {


        Intent twet = new Intent(Intent.ACTION_VIEW);
        twet.setData(Uri.parse("https://twitter.com/DevImpact2018"));
//التاكد بان ليس هناكintentاخرى تفتح في نفس اللحظة
        if (twet.resolveActivity(getPackageManager()) !=null){
            startActivity(twet);

        }
    }

}


