package com.devimpact.startup.Account;

public class UserProfile {
    public String email;
    public String name;

    public UserProfile(){
    }

    public UserProfile(String userEmail, String userName) {
        this.email= userEmail;
        this.name = userName;
    }


    public String getUserEmail() {
        return email;
    }

    public void setUserEmail(String userEmail) {
        this.email = userEmail;
    }

    public String getUserName() {
        return name;
    }

    public void setUserName(String name) {
        this.name = name;
    }
}