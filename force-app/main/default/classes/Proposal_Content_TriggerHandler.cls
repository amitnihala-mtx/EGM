/*
Owner : Amit Nihala
Createddate : 10th Mar 2022
Modifieddate : 10th Mar 2022
Comments : this class is the handler of Proposal_Content_Trigger.
*/
public class Proposal_Content_TriggerHandler {
    public static void afterInsert(){
        setParentOnProposalContent(trigger.new);
    }
    
    private static void setParentOnProposalContent(List<Proposal_Content__c> triggerNew){
        Map<Id,Id> mapOfProposalToProgram = New Map<Id,Id>();
        for(Proposal_Content__c objPC : triggerNew){
            if(objPC.Grant_Program_Content__c!=null) {
                mapOfProposalToProgram.put(objPC.Grant_Program_Content__c,objPC.Id);
            }
        }
        Map<Id,Program_Content__c> mapProgramContent = New Map<Id,Program_Content__c>([Select Id,Parent__c from Program_Content__c where Id =:mapOfProposalToProgram.keySet()]);
        List<Proposal_Content__c> lstPCToUpdate = new List<Proposal_Content__c>();
        for(Proposal_Content__c objPC : triggerNew){
            if(objPC.Grant_Program_Content__c!=null && mapProgramContent.containskey(objPC.Grant_Program_Content__c) && mapProgramContent.get(objPC.Grant_Program_Content__c).Parent__c!=null) {
                if(mapOfProposalToProgram.containskey(mapProgramContent.get(objPC.Grant_Program_Content__c).Parent__c)) {
                    lstPCToUpdate.add(new Proposal_Content__c(Id=objPC.Id,Parent__c=mapOfProposalToProgram.get(mapProgramContent.get(objPC.Grant_Program_Content__c).Parent__c)));
                }
            }
        }
        if(!lstPCToUpdate.isEmpty()) {
            setParentOnProgramContentsAsync(JSON.serialize(lstPCToUpdate));
        }
    }
    @future
    private static void setParentOnProgramContentsAsync(String listStringifyData){
        update (List<Proposal_Content__c>)JSON.deserialize(listStringifyData, List<Proposal_Content__c>.class);
    }
}