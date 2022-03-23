/**
 * Created By :- Amit Agrawal
 * Created Date :- 21/03/2021
 * Description:- Manages the User Dashboard for community
 */

public without sharing class GrantsManageMemberController {
    
    public static Map<String, String> mapOfRoleToProfileName = new Map<String, String>{
        'Grantee Administrator'=>'Grantee Administrator',
        'Grantee Payment Signatory Fiscal Agent'=>'Grantee Payment Signatory Fiscal Agent',
        'Grantee Contributor'=>'Grantee Contributor'
    };

    // method to check if page is accessible
    @AuraEnabled
    public static Boolean isPageAccessible(){
        try {
            User u = [SELECT ID,Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
            if(u.Profile.Name == 'Grantee Delegated Admin'){
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    // method returning list of members
    @AuraEnabled
    public static string getMembersList(){
        try {
            User loggedinUser = [SELECT ID, ContactId, Contact.AccountId FROM User WHERE Id=:UserInfo.getUserId()];
            Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT ID,Name,FirstName,LastName, Email,Title, MobilePhone FROM Contact WHERE AccountId =: loggedinUser.Contact.AccountId AND Id != :loggedinUser.ContactId]);
            List<User> userList = [SELECT Id,Profile.Name, Name, Email, IsActive,ContactId  FROM User WHERE ContactId IN : contactMap.keySet()];
            Map<Id, User> mapOfContactToUser = new Map<Id, User>();
            for(User  u : userList){
                mapOfContactToUser.put(u.ContactId, u);
            }

            List<MemberWrapper> wrapperList = new List<MemberWrapper>();
            for(Contact con : contactMap.values()){
                MemberWrapper wrapper = new MemberWrapper();
                wrapper.contactId = con.Id;
                wrapper.contactFirstName = con.FirstName;
                wrapper.contactLastName = con.LastName;
                wrapper.contactName = con.Name;
                wrapper.contactEmail = con.Email;
                wrapper.contactNumber = con.MobilePhone;
                wrapper.contactRole = con.Title;
                wrapper.isActive = mapOfContactToUser.containsKey(con.Id) ? mapOfContactToUser.get(con.Id).isActive ? 'Active' : 'Inactive' : 'Inactive';
                wrapper.isUserActive = wrapper.isActive == 'Active' ? true : false;
                wrapperList.add(wrapper);
            }
            return JSON.serialize(wrapperList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //method updates contact details and also on user
    @AuraEnabled
    public static string updateContactDetails(String wrapperStr){
        try {
            MemberWrapper wrapper = (MemberWrapper)JSON.deserialize(wrapperStr, MemberWrapper.class);
            Contact con = new Contact();
            if(wrapper.contactId != null){
                con.Id = wrapper.contactId;
            } else{
                Id accountId = [SELECT ID,ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()].Contact.AccountId;
                con.AccountId = accountId;
            }
            
            con.FirstName = wrapper.contactFirstName;
            con.LastName = wrapper.contactLastName;
            con.Email = wrapper.contactEmail;
            con.MobilePhone = wrapper.contactNumber;
            con.Title = wrapper.contactRole;
            upsert con;
            List<User> userList = [SELECT ID,FirstName,LastName, Email, ProfileId,isActive FROM User WHERE ContactId =:wrapper.contactId];
            if(!userList.isEmpty()){
                Profile p = [SELECT ID FROM Profile WHERE Name = :GrantsManageMemberController.mapOfRoleToProfileName.get(wrapper.contactRole)];
                updateUser(wrapper.contactFirstName, wrapper.contactLastName, wrapper.contactEmail, p.Id, userList[0].Id);
            }
            return con.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // future method to update details on user
    @future
    public static void updateUser(String firstName, String lastName, String email, String profileid, String userId){
        User u = new User(Id=userId);
        u.FirstName = firstName;
        u.LastName = lastName;
        u.Email = email;
        u.ProfileId = profileid;
        update u;
    }

    //method to activate the user and also to create user record if required
    @AuraEnabled
    public static string activateUser(String contactId){
        try {
            List<User> userList = [SELECT ID FROM User WHERE ContactId = :contactId];
            if(!userList.isEmpty()){
                userList[0].IsActive = true;
                update userList[0];
            } else{
                Contact con = [SELECT ID,FirstName,LastName,Email, Title FROM Contact WHERE Id=:contactId];
                Profile p = [SELECT ID FROM Profile WHERE Name=:mapOfRoleToProfileName.get(con.Title)];

                String alias = (con.FirstName != null ? con.FirstName.substring(0,1).toUpperCase() :'') + 
                    (con.LastName.length() > 6 ? con.LastName.substring(0,6) : con.LastName);
                String nickname = ((con.FirstName != null && con.FirstName.length() > 0) ? con.FirstName.substring(0,1) : '' ) + con.LastName.substring(0,1);
                nickname = nickname + String.valueOf(Crypto.getRandomInteger()).substring(1,7);
                
                User u = new User();
                u.FirstName = con.FirstName;
                u.LastName =con.LastName;
                u.Email = con.Email;
                u.ProfileId = p.Id;
                u.ContactId = con.Id;
                u.IsActive = true;
                u.CommunityNickname = nickname;
                u.TimeZoneSidKey = 'America/Los_Angeles';
                u.Alias = alias;
                u.EmailEncodingKey = 'UTF-8';
                u.LanguageLocaleKey = 'en_US';
                u.LocaleSidKey = 'en_US';
                u.UserName = con.Email + '.egm';
                insert u;

            }
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //mark user as deactive
    @AuraEnabled
    public static string deactivateUser(String contactId){
        try {
           User u = [SELECT ID, IsActive FROM User WHERE ContactId =:contactId];
           u.IsActive = false;
           update u;
           return 'SUCCESS'; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class MemberWrapper{
        @AuraEnabled
        public String contactId;
        @AuraEnabled
        public String contactName;
        @AuraEnabled
        public String contactFirstName;
        @AuraEnabled
        public String contactLastName;
        @AuraEnabled
        public String contactEmail;
        @AuraEnabled
        public String contactNumber;
        @AuraEnabled
        public String isActive;
        @AuraEnabled
        public Boolean isUserActive;
        @AuraEnabled
        public String contactRole;
    }

}