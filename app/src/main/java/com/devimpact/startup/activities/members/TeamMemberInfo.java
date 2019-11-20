package com.devimpact.startup.activities.members;

import java.io.Serializable;

public class TeamMemberInfo implements Serializable {
    private String userName;
    private String country;
    private String title;
    private String Division;
    private String profileImageUrl;

    public TeamMemberInfo(String userName, String country, String title, String Division, String profileImageUrl){
        this.userName = userName;
        this.country = country;
        this.title = title;
        this.Division = Division;
        this.profileImageUrl=profileImageUrl;
    }

    public String getProfileImageUrl() {
        return profileImageUrl;
    }

    public String getUserName() {
        return userName;
    }

    public String getCountry() {
        return country;
    }

    public String getTitle() {
        return title;
    }

    public String getDivision() {
        return Division;
    }
}
