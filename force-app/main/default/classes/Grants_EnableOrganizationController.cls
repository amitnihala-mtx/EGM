/*
Owner : MTX Group
Createddate : 11th March 2022
Comments : this class is the handler of Grants_EnableOrganization lwc component.
*/
public class Grants_EnableOrganizationController {
    @AuraEnabled
    public static String createDelegatedAdminForOrganization(String recordId){
        Savepoint sp = Database.setSavepoint();
        try{
            List<Contact> delegatedAdmin = [Select Id,FirstName,LastName,Email,Phone,IsDelegatedAdmin__c,Title from Contact where (AccountId=:recordId and IsDelegatedAdmin__c=true) order by createddate limit 1];
            if(delegatedAdmin==null || delegatedAdmin.isEmpty()){
                return 'Error: This organization doesn\'t have any delegated admin contact. Please create a contact record for the same and try again.';
            }
            List<User> lstExistingUser = [Select Id from User where ContactId=:delegatedAdmin[0].Id or Email=:delegatedAdmin[0].Email];
            if(lstExistingUser!=null && !lstExistingUser.isEmpty()){
                return 'Error: An user is already present in the system with the same email as delegated admin of this organization ' + delegatedAdmin[0].Email;
            }
            Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'Grantee Delegated Admin' limit 1];
            String alias = (delegatedAdmin[0].FirstName != null ? delegatedAdmin[0].FirstName.substring(0,1).toUpperCase() :'') + 
                (delegatedAdmin[0].LastName.length() > 6 ? delegatedAdmin[0].LastName.substring(0,6) : delegatedAdmin[0].LastName);
            String nickname = ((delegatedAdmin[0].FirstName != null && delegatedAdmin[0].FirstName.length() > 0) ? delegatedAdmin[0].FirstName.substring(0,1) : '' ) + delegatedAdmin[0].LastName.substring(0,1);
            nickname = nickname + String.valueOf(Crypto.getRandomInteger()).substring(1,7);
            User objUser = new User(ContactId=delegatedAdmin[0].Id,FirstName=delegatedAdmin[0].FirstName,
                                    LastName=delegatedAdmin[0].LastName,Email=delegatedAdmin[0].Email,
                                    Phone=delegatedAdmin[0].Phone,ProfileId=objProfile.Id,
                                    IsActive=true,CommunityNickname = nickname,
                                    TimeZoneSidKey = 'America/Los_Angeles',Alias = alias,
                                    EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',
                                    LocaleSidKey = 'en_US',UserName = delegatedAdmin[0].Email + '.egm');
            insert objUser;
            update new Account(Id=recordId,IsNewOrganization__c=false);
            return 'Organization is approved successfully.';
        } catch(Exception exp) {
            Database.rollback(sp);
            return 'Error: '+exp.getMessage();
        }
    }
}