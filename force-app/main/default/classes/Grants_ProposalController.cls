public without sharing class Grants_ProposalController {

    @AuraEnabled
    public static ProposalWrapper getAllProposals(String grantId){
        try {
            Id userId = UserInfo.getUserId();
            ProposalWrapper wrapper = new ProposalWrapper();
            wrapper.projectList = new List<Proposal__c>();
            List<Proposal__c> projectList =  [SELECT  Id,Status__c, Concept_Paper__c, Proposal__c,
                            Name, Proposed_Total_Cost__c, CreatedBy.Name,
                            Grant_Solicitation__c, 
                            Grant_Solicitation_Rounds__c,Grant_Solicitation_Rounds__r.Name,
                            Grant_Solicitation_Rounds__r.Due_Date__c,Grant_Solicitation_Rounds__r.Concept_Paper_Due_Date__c,
                            Grant_Solicitation_Rounds__r.Status__c,
                            (SELECT FirstName__c, LastName__c from Project_Roles__r where Primary_Customer_Contact__c = true limit 1),
                            (Select Concept_Paper__c, Proposal__c,Status__c From Projects__r WHERE Proposal__c = true LIMIT 1)
                    FROM    Proposal__c WHERE CreatedById=: userId AND Grant_Solicitation__c = : grantId ORDER By Name DESC];
                    Grant_Solicitation__c program = [SELECT ID,Name FROM Grant_Solicitation__c WHERE Id =: grantId];
            Map<Id, String> projectIds = new Map<Id, String>();
            for(Proposal__c pr: projectList){
                projectIds.put(pr.Id, '');
            }
            wrapper.projectList = projectList;
            wrapper.fundingName = program.Name;
            wrapper.proposalToFinalReport = projectIds;
            return wrapper;
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ProposalWrapper{
        @AuraEnabled
        public String fundingName;
        @AuraEnabled
        public List<Proposal__c> projectList;
        @AuraEnabled public Map<Id, String> proposalToFinalReport;
    }

    @AuraEnabled
    public static string getAllGrants(){
        try{
            List<Grant_Solicitation__c> programVersionList = [SELECT ID,Name,Short_Description__c,Due_Date__c,Grant_Type__c,Program__r.Program_Category__c,Program__r.Type__c FROM Grant_Solicitation__c WHERE Status__c = 'Open' ];
            return JSON.serialize(programVersionList);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Grant_Solicitation__c getGrantDetails(Id grantId){
        try {
            return [SELECT Name, Concept_Paper__c, Concept_Paper_Pass_Score__c, Description__c, Short_Description__c,Solicitation_Beta_Review__c,
                        Submission_Outside_Salesforce__c, External_Link__c, NY_Green_Bank_RFP__c,
                        Display_Instructions_and_Portal_Guide__c, Manual_Submission_Only__c,Grant_Type__c,Due_Date__c
                        FROM Grant_Solicitation__c WHERE Id =: grantId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    @AuraEnabled
    public static string createNewProposal(String grantId){
        try {
            User u = [SELECT ID,ContactId, Contact.AccountId FROM USER WHERE Id=:UserInfo.getUserId()];
            Grant_Solicitation__c grant = [SELECT ID,Name,Intake_Form_URL__c,RecordType.DeveloperName FROM Grant_Solicitation__c WHERE Id=:grantId];
            Id recordTypeId = Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get(grant.RecordType.DeveloperName).getRecordTypeId();
            Proposal__c newProposal = new Proposal__c();
            newProposal.Status__c = 'Draft';
            newProposal.RecordTypeId = recordTypeId;
            newProposal.Applying_Contact__c = u.ContactId;
            newProposal.Primary_Contractor_Account__c = u.Contact.AccountId;
            newProposal.Applying_Employee__c = u.Id;
            newProposal.Grant_Solicitation__c = grantId;
            insert newProposal;
            return grant.Intake_Form_URL__c+'&c__ProposalId='+newProposal.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getFinalReport(String proposalID){
        try {
            List<Final_Report__c> finalReports = new List<Final_Report__c>([SELECT Id, Approved_Budget_Other__c, Approved_Budget_Project_Coordinator__c, Approved_Budget_Stipend__c,
                                                Approved_Budget_Supervisor_Director__c, Funds_Expended_Other__c, Funds_Expended_Project_Coordinator__c,
                                                Funds_Expended_Stipend__c, Funds_Expended_Supervisor_Director__c, Balance_Unexpended_Other__c,
                                                Balance_Unexpended_Project_Coordinator__c, Balance_Unexpended_Stipend__c, Balance_Unexpended_Supervisor_Director__c,
                                                Check_Enclosed_Amount__c FROM Final_Report__c WHERE Id =: proposalID LIMIT 1]);
            if(finalReports.size()>0)
                return JSON.serialize(finalReports[0]);
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string submitFinalReport(String data){
        try {
            FinalReportWrapper frw = (FinalReportWrapper)JSON.deserialize(data, FinalReportWrapper.class);
            Final_Report__c fr = new Final_Report__c();
            fr.Approved_Budget_Other__c = frw.approvedBudgetOther;
            fr.Approved_Budget_Project_Coordinator__c = frw.approvedBudgetPC;
            fr.Approved_Budget_Stipend__c = frw.approvedBudgetStipend;
            fr.Approved_Budget_Supervisor_Director__c = frw.approvedBudgetSupervisor;
            fr.Balance_Unexpended_Other__c = frw.balanceUnexpendedOther;
            fr.Balance_Unexpended_Project_Coordinator__c = frw.balanceUnexpendedPC;
            fr.Balance_Unexpended_Stipend__c = frw.balanceUnexpendedStipend;
            fr.Balance_Unexpended_Supervisor_Director__c = frw.balanceUnexpendedSupervisor;
            fr.Funds_Expended_Other__c = frw.fundsExpendedOther;
            fr.Funds_Expended_Project_Coordinator__c = frw.fundsExpendedPC;
            fr.Funds_Expended_Stipend__c = frw.fundsExpendedStipend;
            fr.Funds_Expended_Supervisor_Director__c = frw.fundsExpendedSupervisor;
            fr.Check_Enclosed_Amount__c = frw.checkEnclosedAmount;
            fr.Email_of_person_completing_this_report__c = frw.userEmail;
            fr.Name_of_person_completing_this_report__c = frw.userName;
            fr.Title_of_person_completing_this_report__c = frw.userTitle;
            fr.Proposal__c = frw.projectId;
            fr.Status__c = frw.status;
            insert fr;
            return 'Successfull Submission';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public class FinalReportWrapper{
        @AuraEnabled public Integer approvedBudgetSupervisor;
        @AuraEnabled public Integer approvedBudgetPC;
        @AuraEnabled public Integer approvedBudgetStipend;
        @AuraEnabled public Integer approvedBudgetOther;
        @AuraEnabled public Integer fundsExpendedSupervisor;
        @AuraEnabled public Integer fundsExpendedPC;
        @AuraEnabled public Integer fundsExpendedStipend;
        @AuraEnabled public Integer fundsExpendedOther;
        @AuraEnabled public Integer balanceUnexpendedSupervisor;
        @AuraEnabled public Integer balanceUnexpendedPC;
        @AuraEnabled public Integer balanceUnexpendedStipend;
        @AuraEnabled public Integer balanceUnexpendedOther;
        @AuraEnabled public Integer checkEnclosedAmount;
        @AuraEnabled public String userName;
        @AuraEnabled public String userTitle;
        @AuraEnabled public String userEmail;
        @AuraEnabled public String projectId;
        @AuraEnabled public String reportId;
        @AuraEnabled public String status;
    }

}