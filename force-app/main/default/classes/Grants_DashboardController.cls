public with sharing class Grants_DashboardController {

    //getting Proposal Count against Statuses of Logged In User
    @AuraEnabled
    public static Map<String, Decimal> getStatusInfo(){   
        try {
            Id accountId = [SELECT ID,ContactId, Contact.AccountId FROM User WHERE Id=:UserInfo.getUserId()].Contact.AccountId;
            Map<String,Decimal> statusToCountMap = new Map<String,Decimal>();
            for( Proposal__c ecr : [SELECT Id, Status__c FROM Proposal__c WHERE Primary_Contractor_Account__c =:accountId ]){
                if(!statusToCountMap.containsKey(ecr.Status__c)){
                    statusToCountMap.put(ecr.Status__c,0);
                }
                statusToCountMap.put(ecr.Status__c,statusToCountMap.get(ecr.Status__c)+1);
            }
            return statusToCountMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //getting Proposal against Statuses of Logged In User
    @AuraEnabled
    public static string getProposalRecords(String status){
        try {
            Set<String> statusSet = new Set<String>();

            if(status == 'Under Review'){
                statusSet.add('Under Review');
                statusSet.add('Pending Review'); 
            } else{
                statusSet.add(status);
            }
            Id accountId = [SELECT ID,ContactId, Contact.AccountId FROM User WHERE Id=:UserInfo.getUserId()].Contact.AccountId;
            List<Proposal__c> projects = new List<Proposal__c>([
                SELECT Id, Status__c, Name,Grant_Solicitation__r.Name,Grant_Solicitation__c,Requested_Amount__c,Awarded_Amount__c,RecordType.DeveloperName,Intake_Form_URL__c FROM Proposal__c WHERE Status__c IN :statusSet AND Primary_Contractor_Account__c =:accountId
                ORDER BY CreatedDate DESC
            ]);
            return JSON.serialize(projects);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //getting Final Report Id or Create New Final Report
    @AuraEnabled
    public static string getFinalReport(String proposalId){
        try {
            List<Final_Report__c> finalReportList = [SELECT ID,Status__c FROM Final_Report__c WHERE Proposal__c = :proposalId];
            if(!finalReportList.isEmpty()){
                if(finalReportList[0].Status__c == 'Draft'){
                    return finalReportList[0].Id;
                } else{
                    return 'Final Report is already submitted';
                }
            } else{
                Final_Report__c report = new Final_Report__c();
                report.Proposal__c = proposalId;
                insert report;
                return report.Id;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}