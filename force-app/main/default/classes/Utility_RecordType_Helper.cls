public class Utility_RecordType_Helper{
    
    private static Utility_MapChain recordTypes;
    private static Set<string> sObjectsQueried;

    //return a record type based on object name and record type developer name
    public static RecordType getRecordType(String sObjectName, String recTypeDevName) {
        if (recordTypes == null || !sObjectsQueried.contains(sObjectName))
            setupRecordTypes(new Set<String> {sObjectName});
        
        return (RecordType) recordTypes.getData(new string[]{sObjectName,recTypeDevName});
    }
    
    
    public static void setupRecordTypes(Set<String> sObjs)
    {
        if (sObjectsQueried == null)
            sObjectsQueried = new Set<string>();
        sObjectsQueried.addAll(sObjs);
        if (recordTypes == null)
            recordTypes = new Utility_MapChain();
        for (RecordType recType :[SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE sObjectType IN :sObjs])
        {
            recordTypes.putData(new string[] {recType.sObjectType,recType.DeveloperName},recType);
        }
    }
}