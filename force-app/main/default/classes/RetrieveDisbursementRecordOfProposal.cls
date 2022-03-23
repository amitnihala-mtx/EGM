/*
#Created By: Pranay reddy cheruku
#Created date: March 11th 2022
#Where to find this Work Result: One can find this work in Proposal Record Page >> Besides Proposal Record Details tab
#Description: This apex class is to retrieve the Disbursement records for Story S-32166 and Task T-35867 of Sprint 3 - Pre-Sales Enterprise Grants Management System 

#Requirement:

****Ability to re-certify the Disbursement needed***

***Acceptance Criteria***
>> For Every Disbursement, the user should be able to re-certify the record.
>> Re-certification button will be available for every Disbursement and on click, a new screen will open with all the details/information for certification with DocuSign functionality.
>> Details in Certification will flow from Grant's certification Description field, some important fields from Proposal will flow and some fields from Disbursement record.

*/
public class RetrieveDisbursementRecordOfProposal {
    //This method fetch Disbursement records with input recordId(parent proposal recordId) from lwc component called GrantProposalDisbursment
    @AuraEnabled(cacheable=true)
     public static list<Disbursement__c> Disbursements(string recordId) {
     return [SELECT Id,Name,Status__c,Disbursement_Date__c, NotEligibleforRecertification__c  ,Recertification_Date__c , Recertification_By_Legal_Name__c , Amount__c ,Scheduled_Date__c 
             
             FROM Disbursement__c WHERE Disbursement__c.Proposal__c =:recordId
           ];
     }  
    
    
}