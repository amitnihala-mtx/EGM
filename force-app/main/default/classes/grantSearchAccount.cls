global with sharing class grantSearchAccount implements vlocity_ins.VlocityOpenInterface {    
   
    global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        Boolean result = true;
        try {
            if ('getContacts'.equalsIgnoreCase(methodName)) {
                getContacts(inputMap, outMap, options);
            } else {
                result = false;
            }
        } catch (Exception e) {
            result = false;
        }
        return result;
    }
   
    public void getContacts(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        String AccountId = (String)inputMap.get('AccountId');
        Set<Contact> Contacts = new Set<Contact>([SELECT Id, Name, Email, Phone from Contact where AccountId=:AccountId]);
        outMap.put('Contacts',Contacts);
    }
   
}