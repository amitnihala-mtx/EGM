/*
Owner : MTX
Createddate : 15th Mar 2022
Modifieddate : 15th Mar 2022
Comments : this class is the invoked from a contact flow when new grantee is created.
*/
public class Grants_ContactHandler {
    //This method notify accont delegated admin for new grantee
    @InvocableMethod
    public static void handleNewGranteeCreation(List<Contact> contactRecs){
        Set<Id> setAccountId = new Set<Id>();
        for(Contact objCon : contactRecs){
            if(objCon.AccountId!=null) {
                setAccountId.add(objCon.AccountId);
            }
        }
        if(setAccountId.isEmpty()) {
            return;
        }
        Map<Id,User> mapOfAccoutToDelegatedAdmin = new Map<Id,User>();
        for(User objUser : [Select Id,AccountId,Email,Name from User where AccountId=:setAccountId and IsDelegatedAdmin__c=true and IsActive=true]) {
            mapOfAccoutToDelegatedAdmin.put(objUser.AccountId,objUser);
        }
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for(Contact objCon : contactRecs){
            if(objCon.AccountId!=null && mapOfAccoutToDelegatedAdmin.containsKey(objCon.AccountId)) {
                User objUser = mapOfAccoutToDelegatedAdmin.get(objCon.AccountId);
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] { objUser.Email,'amit.nihala@mtxb2b.com'};
                String htmlValue='<p>Hi '+objUser.Name+',</p><br/><p>A new grantee has signed up under your organization. Kindly review the user and take necessary action.</p><p>Grantee Name: '+(String.isBlank(objCon.FirstName)?'':objCon.FirstName+' ') + objCon.LastName+'</p><p>Gramtee Email: '+objCon.Email+'</p><br/><br/><p>Thanks,<br/>MTX Grants Product</p>';
                message.setHtmlBody(htmlValue);
                message.setSubject('New Grantee is Added under your Organization');
                messages.add(message);
            }
        }
        if(!messages.isEmpty()) {
            Messaging.sendEmail(messages);
        }
        
    }
}