/*
# Created By : Mounika Thamarana
# Description : This apex class is to insert a Contact record when the user successfully registered.
                This class is called in RemoteActionGetAccounts and RemoteActionInsertContact of grants/registerform omniscript.
*/
global without sharing class RegisterFormRemoteActionClass implements vlocity_ins.VlocityOpenInterface {    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        Boolean result = false;
        try {
            if (methodName.equals('getInsertContact')) {
                insertContact(inputMap, outMap, options );
            }
            else if(methodName.equals('getSearchAccount')){
                outMap.put('accounts', searchAccount(inputMap, outMap, options ));
            }       
            else {
                result = false;
            }
        } catch (Exception e) {
            result = false;
        }
        return result;
    }
    
    // this method is used to get searched organization names  
    public List<Account> searchAccount(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options){
        String name = (String)inputMap.get('name');
        String searchString='%'+(String)inputMap.get('searchString')+'%';
        List<Account> accList=[SELECT Id,Name,Organization_ID__c  from Account ];
        return accList;
    }
       
    // this method is to insert the account when organization name is not found in searched results
    public string insertAccount(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options){
        Map <String,object> stepInfo = (Map <String,object> )inputMap.get('Register');
        String organizationId = (String)stepInfo.get('orgId'); 
        String accountname = (String)stepInfo.get('accName'); 
        String accountWeb = (String)stepInfo.get('accountwebsite');
        String accountPhone = (String)stepInfo.get('accountPhone');
        Map <String,object> accountBlockAddressInfo = (Map <String,object> )stepInfo.get('searchAddress-Block');
        String accountAddress = (String)accountBlockAddressInfo.get('searchAddress');
        String accountStreet = (String)accountBlockAddressInfo.get('street');
        String accountCity = (String)accountBlockAddressInfo.get('city');
        String accountCountry = (String)accountBlockAddressInfo.get('country');
        String accountPostal = (String)accountBlockAddressInfo.get('postalCode');
        Account acc = new Account();
        acc.Organization_ID__c = organizationId;
        acc.Name = accountname;
        acc.Website = accountWeb;
        acc.Phone = accountPhone;
        acc.BillingStreet=accountStreet;
        acc.BillingCity=accountCity;
        acc.BillingCountry=accountCountry;
        acc.BillingPostalCode=accountPostal;
        acc.IsNewOrganization__c =true;
        outMap.put('AccountId',acc);
        insert acc;
        return acc.Id;
        
    }
    
    // this method is to insert a contact record when the user get registered
    public void insertContact(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options){
        string accId;
        Boolean isDelegate=false;
        Map <String,object> stepConInfo = (Map <String,object> )inputMap.get('Register');
        Map <String,object> selectedAccInfoBlock =  (Map <String,object> )stepConInfo.get('SearchOrg-Block');
        if(selectedAccInfoBlock == null || !selectedAccInfoBlock.containsKey('Id')){ 
            accId= insertAccount(inputMap,outMap,options);
            isDelegate=true;
        }
        else{
            accId = (String)selectedAccInfoBlock.get('Id');
        }
        String lastName = (String)stepConInfo.get('lastname');
        String firstname = (String)stepConInfo.get('firstName');
        String middlename = (String)stepConInfo.get('middleName');
        String mail = (String)stepConInfo.get('EmailId');
        Contact con=new Contact();
        con.FirstName=firstname;
        con.vlocity_ins__MiddleName__c=middlename;
        con.LastName=lastName;
        con.Email=mail;
        con.AccountId=accId;
        con.IsDelegatedAdmin__c=isDelegate;
        con.Title=isDelegate?'Delegated Admin':'Grantee';
        outMap.put('ContactId',con);
        insert con;   
    }
}