global with sharing class POCAccountInsert implements vlocity_ins.VlocityOpenInterface {    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        Boolean result = false;
        try {
            if (methodName.equals('getInsertAccount')) {
                insertAccount(inputMap, outMap, options );
               
            } else {
                result = false;
            }
        } catch (Exception e) {
            result = false;
        }
        return result;
    }  
    public void insertAccount(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options){
        String accountname = (String)inputMap.get('accountname');
        String accountWeb = (String)inputMap.get('accountWeb');
        String accountPhone = (String)inputMap.get('accountPhone');
        String accountAddress = (String)inputMap.get('accountAddress');
        String accountStreet = (String)inputMap.get('accountStreet');
        String accountCity = (String)inputMap.get('accountCity');
        String accountCountry = (String)inputMap.get('accountCountry');
        String accountPostal = (String)inputMap.get('accountPostal');
        Account acc = new Account();
        acc.Name = accountname;
        acc.Website = accountWeb;
        acc.Phone = accountPhone;
        //acc.BillingAddress=accountAddress;
        acc.BillingStreet=accountStreet;
        //system.debug(acc.BillingStreet);
        acc.BillingCity=accountCity;
        acc.BillingCountry=accountCountry;
        acc.BillingPostalCode=accountPostal;
        outMap.put('Account',acc);
        insert acc;        
        }
}