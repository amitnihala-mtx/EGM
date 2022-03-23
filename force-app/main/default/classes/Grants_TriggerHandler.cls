/*
Owner : Amit Nihala
Createddate : 18th Feb 2022
Modifieddate : 1st March 2022
Comments : this class is the handler of Grants_Trigger trigger.
*/
public with sharing class Grants_TriggerHandler {
	
    //This method is called before the grant record is inserted
    public static void beforeInsert(){
        //autoCreateURLNewGrant(trigger.new,null);
	}
    
    //This method is called after the grant record is inserted
    public static void afterInsert(){
     	autoCreateRoundForNewGrant(trigger.new);
        autoCreateURLNewGrant(trigger.new,null);
	}
    
    //This method is called before the grant record is updated
    public static void beforeUpdate(){
        autoCreateURLNewGrant(trigger.new,(Map<Id,Grant_Solicitation__c>)trigger.oldMap);
	}
    
    //This method creates the round for newly created grant.
    public static void autoCreateRoundForNewGrant(List<Grant_Solicitation__c> triggerNew){
        List<Grant_Solicitation_Rounds__c> lstGrantRoundToInsert = new List<Grant_Solicitation_Rounds__c>();
        for(Grant_Solicitation__c objGrant : triggerNew) {
            lstGrantRoundToInsert.add(new Grant_Solicitation_Rounds__c(Solicitation__c=objGrant.Id,Name='Initial Review', Status__c='Open'));
        }
        insert lstGrantRoundToInsert;
    }
    
    //This method creates the intake form url for newly created grant.
    public static void autoCreateURLNewGrant(List<Grant_Solicitation__c> newList,Map<Id,Grant_Solicitation__c> oldMap){
        Set<Id> setOfIntakeFormId = new Set<Id>();
        for(Grant_Solicitation__c objGrants : newList) {
            if(objGrants.Intake_Form__c !=null && (oldMap==null || (objGrants.Intake_Form__c != oldMap.get(objGrants.Id).Intake_Form__c))) {
                setOfIntakeFormId.add(objGrants.Intake_Form__c);
            }
        }
        if(setOfIntakeFormId.isEmpty()) {
            return;
        }
        Map<Id,vlocity_ins__OmniScript__c> mapOS = new Map<Id,vlocity_ins__OmniScript__c>([Select Id, vlocity_ins__Type__c ,vlocity_ins__SubType__c ,vlocity_ins__Language__c from vlocity_ins__OmniScript__c where Id=:setOfIntakeFormId]);
        Site site = [SELECT Id FROM Site WHERE UrlPathPrefix = '/s' LIMIT 1];
        String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
        
        if(trigger.isUpdate){
            for(Grant_Solicitation__c objGrants : newList) {
                if(objGrants.Intake_Form__c !=null && (oldMap==null || (objGrants.Intake_Form__c != oldMap.get(objGrants.Id).Intake_Form__c))) {
                    vlocity_ins__OmniScript__c objOS = mapOS.get(objGrants.Intake_Form__c);
                    String name = objOS.vlocity_ins__Type__c + objOS.vlocity_ins__SubType__c + objOS.vlocity_ins__Language__c;
                    name = name.substring(0,1).toLowerCase() + name.substring(1);
                    objGrants.Intake_Form_URL__c = communityUrl + '/proposal-request?c__layout=lightning&c__tabIcon=custom:custom18&c__target=c:'+name+'&ContextId='+objGrants.Id;
                }
            }
        } else {
            List<Grant_Solicitation__c> lstToUpdate = New List<Grant_Solicitation__c>();
            for(Grant_Solicitation__c objGrants : newList) {
                if(objGrants.Intake_Form__c !=null && (oldMap==null || (objGrants.Intake_Form__c != oldMap.get(objGrants.Id).Intake_Form__c))) {
                    vlocity_ins__OmniScript__c objOS = mapOS.get(objGrants.Intake_Form__c);
                    String name = objOS.vlocity_ins__Type__c + objOS.vlocity_ins__SubType__c + objOS.vlocity_ins__Language__c;
                    name = name.substring(0,1).toLowerCase() + name.substring(1);
                    lstToUpdate.add(new Grant_Solicitation__c(Id=objGrants.Id,Intake_Form_URL__c = communityUrl + '/proposal-request?c__layout=lightning&c__tabIcon=custom:custom18&c__target=c:'+name+'&c__ContextId='+objGrants.Id));
                }
            }
            if(!lstToUpdate.isEmpty()) {
                updateIntakeURLAsync(JSON.serialize(lstToUpdate));
            }
        }
    }
    @future
    private static void updateIntakeURLAsync(String listStringifyData){
        update (List<Grant_Solicitation__c>)JSON.deserialize(listStringifyData, List<Grant_Solicitation__c>.class);
    }
}