package com.devimpact.startup.Account;

public class UserInfo {
    public String email,password,name,imageURL;

    public UserInfo(){

    }
    public UserInfo(String name,String email,String password){
        this.name=name;
        this.password=password;
        this.email=email;

    }

    public String getEmail() {
        return email;
    }

    public void setUserEmail(String userEmail) {
        this.email = userEmail;
    }

    public String getName() {
        return name;
    }

    public void setUserName(String name) {
        this.name = name;
    }
}
