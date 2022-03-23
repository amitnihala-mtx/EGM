@isTest
public class RegisterFormRemoteActionClassTest {
    @testSetup
    static void setup(){
        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.Organization_ID__c = '890875';
        insert acc;
    }
    static testmethod void testinvokeMethod(){
        RegisterFormRemoteActionClass classObj = new RegisterFormRemoteActionClass();
        //Contact con = new Contact();
        Map<String,Object> inputMap = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();
        Map<String,Object> options = new  Map<String,Object>();
        inputMap.put('name','');
        inputMap.put('searchString','');
        inputMap.put('Register','');
        classObj.invokeMethod('getSearchAccount',inputMap,outMap,options);
        classObj.invokeMethod('getInsertContact',inputMap,outMap,options);
        classObj.invokeMethod('',inputMap,outMap,options);
    }
    static testmethod void testinsertMethod(){
        string accId =[SELECT Id FROM Account].Id;
        RegisterFormRemoteActionClass classObj1 = new RegisterFormRemoteActionClass();
        Map<String,Object> inputMap = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();
        Map<String,Object> options = new  Map<String,Object>();
        inputMap.put('name','');
        inputMap.put('searchString','');
        Map<String,Object> selectedAccInfoBlock = new Map<String,Object>();
        selectedAccInfoBlock.put('Id',accId);
        Map<String,Object> stepConInfo = new Map<String,Object>();
        stepConInfo.put('SearchOrg-Block',selectedAccInfoBlock);
        stepConInfo.put('lastname','meeeeeee2');
        stepConInfo.put('firstName','hduhs');
        stepConInfo.put('middleName','');
        stepConInfo.put('EmailId','teyu@mail.com');
        inputMap.put('Register',stepConInfo);
        classObj1.insertContact(inputMap,outMap,options);
    }
    /*Static testmethod void testinsertAccount(){
        RegisterFormRemoteActionClass classObj2 = new RegisterFormRemoteActionClass();
        Map<String,Object> inputMap = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();
        Map<String,Object> options = new  Map<String,Object>();
        inputMap.put('name','');
        inputMap.put('searchString','');
        Map<String,Object> stepInfo = new Map<String,Object>();
        stepInfo.put('orgId','098902');
        stepInfo.put('accName','testtest');
        stepInfo.put('accountwebsite','mee.com');
        stepInfo.put('accountPhone','677767637867');
        Map<String,Object> accountBlockAddressInfo = new Map<String,Object>();
        accountBlockAddressInfo.put('searchAddress','676 N St Clair St, Chicago, IL 60611, USA');
        accountBlockAddressInfo.put('street','676 N St Clair St');
        accountBlockAddressInfo.put('city','Chicago');
        accountBlockAddressInfo.put('country','USA');
        accountBlockAddressInfo.put('postalCode','IL 60611');
        stepInfo.put('searchAddress-Block',accountBlockAddressInfo);
        inputMap.put('Register',stepInfo);
        classObj2.insertAccount(inputMap,outMap,options);
    }*/
    static testmethod void testinsertcontactIf(){
        try{
        RegisterFormRemoteActionClass classObj1 = new RegisterFormRemoteActionClass();
        Map<String,Object> inputMap = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();
        Map<String,Object> options = new  Map<String,Object>();
        inputMap.put('name','');
        inputMap.put('searchString','');
        Map<String,Object> stepInfo = new Map<String,Object>();
        stepInfo.put('orgId','098902');
        stepInfo.put('accName','testtest');
        stepInfo.put('accountwebsite','mee.com');
        stepInfo.put('accountPhone','677767637867');
        Map<String,Object> accountBlockAddressInfo = new Map<String,Object>();
        accountBlockAddressInfo.put('searchAddress','acc');
        accountBlockAddressInfo.put('street','yty');
        accountBlockAddressInfo.put('city','uio');
        accountBlockAddressInfo.put('country','ioo');
        accountBlockAddressInfo.put('postalCode','425526');
        stepInfo.put('searchAddress-Block',accountBlockAddressInfo);
        inputMap.put('Register',stepInfo);
        string accountId = classObj1.insertAccount(inputMap,outMap,options);
        Map<String,Object> selectedAccInfoBlock = new Map<String,Object>();
        //selectedAccInfoBlock.put('Id',accountId);
        Map<String,Object> stepConInfo = new Map<String,Object>();
        stepConInfo.put('lastname','test6767');
        stepConInfo.put('firstName','tretyr');
        stepConInfo.put('middleName','');
        stepConInfo.put('EmailId','mee@mail.com');
        inputMap.put('Register',stepConInfo);
        classObj1.insertContact(inputMap,outMap,options);
        }
        catch(Exception e){
            
        }
    }
}