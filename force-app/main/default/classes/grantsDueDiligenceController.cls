public without sharing class grantsDueDiligenceController {
    public grantsDueDiligenceController() {

    }
    @AuraEnabled
    public static List<DueDiligenceWrapper> getDueDiligenceRecords(String idField){
        try {
            List<Proposal_Content__c> dueDiligenceList = new List<Proposal_Content__c>();
            if(idField!=null || idField!=''){
                // Schema.DescribeSObjectResult applicationPrefix = vlocity_ins__Application__c.sObjectType.getDescribe();
                // if(idField.substring(0, 3) == applicationPrefix.getKeyPrefix() ){
                dueDiligenceList = [SELECT Id, Name__c,Status__c,Responsible_Party__c , Start_Date__c, LastModifiedBy.Id,LastModifiedBy.Name 
                FROM Proposal_Content__c Where Proposal__c = :idField AND RecordType.Name IN ('Due Diligence')];
            //     } 
            }
            
            List<DueDiligenceWrapper> dueDiligenceWrapperList = new List<DueDiligenceWrapper>();
            for(Proposal_Content__c dueDiligence : dueDiligenceList){
                DueDiligenceWrapper wrapper = new DueDiligenceWrapper();
                wrapper.id = dueDiligence.Id;
                wrapper.dueDiligenceName = dueDiligence.Name__c != null ? dueDiligence.Name__c : '';
                wrapper.responsibleParty = dueDiligence.Responsible_Party__c;
                wrapper.status = dueDiligence.Status__c != null ? dueDiligence.Status__c : '';
                wrapper.lastModifiedByName = dueDiligence.LastModifiedBy.Name;
                wrapper.lastModifiedById = dueDiligence.LastModifiedBy.Id;
                // wrapper.notes = dueDiligence.Notes__c;
                // wrapper.helpText = dueDiligence.Help_Text__c;
                // wrapper.referenceLink = dueDiligence.Reference_Link__c;
                wrapper.Start_Date = dueDiligence.Start_Date__c != null ? dueDiligence.Start_Date__c : null;
                dueDiligenceWrapperList.add(wrapper);  
            }
            return dueDiligenceWrapperList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateDueDiligenceRecords(String jsonMap){
        try {

            Set<Id> dueDiligenceIds = new Set<Id>();
            List<Proposal_Content__c> dueDiligenceList = new List<Proposal_Content__c>();
            List<DueDiligenceWrapper> wrapperList = (List<DueDiligenceWrapper>) JSON.deserialize(jsonMap, List<DueDiligenceWrapper>.class);
            
            for(DueDiligenceWrapper wrapper : wrapperList) {
                dueDiligenceIds.add( wrapper.Id );
            }
            Map<Id,Proposal_Content__c> dueDiligenceMap = new Map<Id,Proposal_Content__c>(
                [SELECT Id, Status__c 
                FROM Proposal_Content__c 
                WHERE Id IN :dueDiligenceIds]
            );

            for(DueDiligenceWrapper wrapper : wrapperList){

                if( dueDiligenceMap.containsKey( wrapper.Id ) && wrapper.status != dueDiligenceMap.get( wrapper.Id ).Status__c ) {
                    Proposal_Content__c dueDiligence = new Proposal_Content__c();
                    dueDiligence.Id = wrapper.Id;
                    dueDiligence.Status__c = wrapper.status;
                    // dueDiligence.Notes__c = wrapper.notes;
                    if(dueDiligence.Status__c == 'Completed' || dueDiligence.Status__c == 'Not Applicable'){
                        dueDiligence.Start_Date__c = Date.today();
                    }else{
                        dueDiligence.Start_Date__c = null;
                    }
                    dueDiligenceList.add(dueDiligence);
                }  
            }

            if(!dueDiligenceList.isEmpty()){
                if ( !dueDiligenceList[0].getSObjectType().getDescribe().isUpdateable() ) {
                    throw new AuraHandledException('Insufficient update access. ( Object: '+dueDiligenceList[0].getSObjectType() +' )' );
                }
                update dueDiligenceList;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class DueDiligenceWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String dueDiligenceName;
        @AuraEnabled public String responsibleParty;
        @AuraEnabled public String status;
        @AuraEnabled public String lastModifiedByName;
        @AuraEnabled public String lastModifiedById;
        // @AuraEnabled public String notes;
        // @AuraEnabled public String helpText;
        // @AuraEnabled public String referenceLink;
        @AuraEnabled public Date Start_Date;
    }

    // public class SelectOptionWrapper{
    //     @AuraEnabled public string value;
    //     @AuraEnabled public string label;
        
    //     public SelectOptionWrapper(string value, string label){
    //         this.value = value;
    //         this.label = label;
    //     }
    // }
}