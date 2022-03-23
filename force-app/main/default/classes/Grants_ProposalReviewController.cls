public with sharing class Grants_ProposalReviewController {
    
    @AuraEnabled(cacheable=true)
    public static List<Grant_Solicitation_Rounds__c> getSolicitationRoundRecords(){
        return new List<Grant_Solicitation_Rounds__c>([SELECT Id, Name, Solicitation__c, Solicitation__r.Name, Solicitation__r.No_of_Proposals_to_review__c,Solicitation__r.End_Date__c,(Select Id from Projects__r) FROM Grant_Solicitation_Rounds__c
        WHERE Solicitation__r.Due_Date__c > TODAY WITH SECURITY_ENFORCED ORDER BY Solicitation__r.Name, Name]);
    }

    @AuraEnabled
    public static List<Proposal__c> getProposalsByStatus(String status, String grantId, String solRoundId){
        String queryStr = 'SELECT Id, Primary_Contractor_Account__r.Name, Proposal_Number__c,Requested_Amount__c, Completed_Date__c, Status__c, Grant_Solicitation__r.Name,Grant_Solicitation_Group__r.Name FROM Proposal__c'
                        + ' WHERE Grant_Solicitation__c =: grantId AND Grant_Solicitation_Rounds__c =: solRoundId AND Status__c != \'Draft\'  ';

        if(!status.equalsIgnoreCase('all')){
            queryStr = queryStr + ' AND Status__c =: status';
        }
        queryStr = queryStr + ' WITH SECURITY_ENFORCED ORDER BY Proposal_Number__c';
        return Database.query(queryStr);
    }

    @AuraEnabled
    public static List<Scorecard__c> getScorecards(String proposalRecId){
        return new List<Scorecard__c>([SELECT Id, Assign_To_User__c, Assign_To_User__r.Name, Assign_To_User__r.FullPhotoUrl, Assign_To_User__r.Email, 
        LastModifiedDate, Status__c, Scored_Points__c, Proposal__r.Proposal_Average_Score__c FROM Scorecard__c 
        WHERE Proposal__c =: proposalRecId WITH SECURITY_ENFORCED]);
    }

    @AuraEnabled(cacheable=true)
    public static Map<ID, String> getRelatedFilesByRecordId(String recordId){
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
    
        List<ContentVersion> docs = [SELECT ContentDocumentId, Title FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        return mapIdTitle;
    }
}