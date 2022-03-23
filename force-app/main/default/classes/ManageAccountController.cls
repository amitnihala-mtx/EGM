public without sharing class ManageAccountController {
    // Function to get profile picture from user
    @AuraEnabled
    public static User fetchUserDetail(){
        try {
            return [Select id,Name,SmallPhotoUrl, FullPhotoUrl
            From User
            Where Id =: Userinfo.getUserId()];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void uploadProilePhoto(String documentId){
        try {
            ContentVersion cv = [Select id , FileExtension, FileType, title,VersionData from ContentVersion Where ContentDocumentId =: documentId Limit 1];
            ConnectApi.UserProfiles.setPhoto(null, UserInfo.getUserId(), new ConnectApi.BinaryInput(cv.VersionData,'image/' + cv.FileExtension,cv.title + '.' + cv.FileExtension));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //To get Acccount details
    @AuraEnabled
    public static string getManageAccountEmployerDetails(){
        try {
            User user = [SELECT Id, FirstName,ContactId,LastName, Email, MobilePhone FROM User WHERE Id = :UserInfo.getUserId()];
            Contact con = [SELECT Id,AccountId,Name,MobilePhone,Birthdate,OtherPhone,Email,MailingStreet,MailingCity,MailingPostalCode,MailingState FROM Contact WHERE Id = :user.ContactId];
            // User user = [SELECT Id, FirstName, LastName, Email, MobilePhone FROM User WHERE Id = :UserInfo.getUserId()];


            Account acc = [SELECT Id,Name,Type,Organization_ID__c,Website,vlocity_ins__Email__c,ShippingStreet,ShippingCountry,ShippingCity,ShippingState,ShippingPostalCode,Phone
            
                FROM Account WHERE Id = :con.AccountId];
            ManageAccountWrapper manageWrapper = new ManageAccountWrapper();
            // manageWrapper.Id = con.Id;
            manageWrapper.FirstName = user.FirstName;
            manageWrapper.LastName = user.LastName;
            manageWrapper.PhoneNumber = con.MobilePhone;
            manageWrapper.Email = con.Email;
            manageWrapper.DateofBirth = con.Birthdate;
            manageWrapper.EmergencyPhoneNumber = con.OtherPhone;
            manageWrapper.StreetAddress = con.MailingStreet;
            manageWrapper.City = con.MailingCity;
            manageWrapper.Province = con.MailingState;
            manageWrapper.PostalCode = con.MailingPostalCode;
            //account
            manageWrapper.AccountID = acc.Id;
            manageWrapper.OrganizationID = acc.Organization_ID__c;
            manageWrapper.OrganizationName = acc.Name;
            manageWrapper.OrganizationType = acc.Type;
            manageWrapper.OrganizationEmail = acc.vlocity_ins__Email__c;
            manageWrapper.OrganizationWebsite = acc.Website;
            manageWrapper.OrganizationAddressLine1 = acc.ShippingStreet;
            manageWrapper.OrganizationAddressLine2 = acc.ShippingCountry;
            manageWrapper.OrganizationCity = acc.ShippingCity;
            manageWrapper.OrganizationState = acc.ShippingState;
            manageWrapper.OrganizationPostalCode = acc.ShippingPostalCode;
            manageWrapper.OrganizationPhoneNumber = acc.Phone;


            // manageWrapper.Email = con.Contacts[0].Email;
            //user
           

            return JSON.serialize(manageWrapper);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string updateManageAccountEmployer(String manageAccData){
        try {
            ManageAccountWrapper wrapperList = (ManageAccountWrapper)JSON.deserialize(manageAccData, ManageAccountWrapper.class);
           
            Id contactId = [SELECT ID,ContactId FROM User WHERE Id = :UserInfo.getUserId()]?.ContactId;

            Account acc = new Account();
            acc.Id = wrapperList.AccountID;
            acc.Organization_ID__c = wrapperList.OrganizationID;
            acc.Name = wrapperList.OrganizationName;
            acc.Type = wrapperList.OrganizationType;
            acc.vlocity_ins__Email__c = wrapperList.OrganizationEmail;
            acc.Website = wrapperList.OrganizationWebsite;
            acc.ShippingStreet = wrapperList.OrganizationAddressLine1;
            acc.ShippingCountry = wrapperList.OrganizationAddressLine2;
            acc.ShippingCity = wrapperList.OrganizationCity;
            acc.ShippingState = wrapperList.OrganizationState;
            acc.ShippingPostalCode = wrapperList.OrganizationPostalCode;
            acc.Phone = wrapperList.OrganizationPhoneNumber;

            update acc;

            Contact con = new Contact();
            con.Id = contactId;
            // con.Name = wrapperList.FirstName;
            // con.LastName = wrapperList.LastName;
            con.MobilePhone = wrapperList.PhoneNumber;
            con.Email = wrapperList.Email;
            con.OtherPhone = wrapperList.EmergencyPhoneNumber;
            con.Birthdate = wrapperList.DateofBirth;
            con.MailingStreet = wrapperList.StreetAddress;
            con.MailingCity = wrapperList.City;
            con.MailingState = wrapperList.Province;
            con.MailingPostalCode = wrapperList.PostalCode;
            update con;

            // con.Email = wrapperList.Email;

            User user = new User();
            user.Id = UserInfo.getUserId();
            user.FirstName = wrapperList.FirstName;
            user.LastName = wrapperList.LastName;
            user.MobilePhone = wrapperList.PhoneNumber;
            user.Email = wrapperList.Email;

            update user;
            // update acc;
            return 'success';
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class ManageAccountWrapper {
        @AuraEnabled Public String Id;
        // @AuraEnabled Public String Name;
        // @AuraEnabled Public String Type;
        // @AuraEnabled Public String Website;
        // @AuraEnabled Public String Email;

        @AuraEnabled Public String FirstName;
        @AuraEnabled Public String LastName;
        @AuraEnabled Public String EmergencyPhoneNumber;
        @AuraEnabled Public String StreetAddress;
        @AuraEnabled Public String City;
        @AuraEnabled Public String Province;
        @AuraEnabled Public String PostalCode;
        @AuraEnabled Public Date DateofBirth;
        @AuraEnabled Public String PhoneNumber;
        @AuraEnabled Public String Email;
        @AuraEnabled Public String AccountID;
        @AuraEnabled Public String OrganizationID;
        @AuraEnabled Public String OrganizationName;
        @AuraEnabled Public String OrganizationType;
        @AuraEnabled Public String OrganizationEmail;
        @AuraEnabled Public String OrganizationWebsite;
        @AuraEnabled Public String OrganizationAddressLine1;
        @AuraEnabled Public String OrganizationAddressLine2;
        @AuraEnabled Public String OrganizationCity;
        @AuraEnabled Public String OrganizationState;
        @AuraEnabled Public String OrganizationPostalCode;
        @AuraEnabled Public String OrganizationPhoneNumber;
    }
}