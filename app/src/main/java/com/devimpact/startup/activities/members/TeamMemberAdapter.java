package com.devimpact.startup.activities;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.devimpact.startup.R;

import java.util.ArrayList;

public class TeamMemberAdapter  extends ArrayAdapter<TeamMemberInfo> {

    public TeamMemberAdapter(Activity context , ArrayList<TeamMemberInfo> Feeds){
        super(context, 0, Feeds);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View ListItemView=convertView;
        if(ListItemView ==null){
            ListItemView= LayoutInflater.from(getContext()).inflate(R.layout.team_member_item,parent,false);
        }
        TeamMemberInfo currentDeveloper=getItem(position);

        ImageView profileImage=(ImageView)ListItemView.findViewById(R.id.profileImage);
        profileImage.setImageResource(this.getContext().getResources().getIdentifier(currentDeveloper.getProfileImageUrl(), "drawable", this.getContext().getPackageName()));

        TextView profileName=(TextView)ListItemView.findViewById(R.id.profile_name);
        profileName.setText(currentDeveloper.getUserName());

        return ListItemView;
    }
}
