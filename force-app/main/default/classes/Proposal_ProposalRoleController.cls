/*
* Created by : Pranay Reddy Cheruku
* Created Date : 15th Mar 2022
* Description : This class is the controller class of GrantProposal_proposalroles lwc component.
*/

public without sharing class Proposal_ProposalRoleController {
    //this method with the referrence of Proposal ID retrieves the Child Proposal Roles along with Child Contacts , and retrieves the Contact list which are not Child of Proposal Roles .
    @AuraEnabled
    public static List<String> FetchProposalRoles(String ProposalId){
        List<String> listToreturn =new List<String>();
        set<Id> setProposalContacts =new set<Id>();
        Proposal__c objProposal =[Select Id,Name
                                  from Proposal__c where Id=:ProposalId limit 1];
        
        List<Proposal_Role__c> lstExistingProposalContacts =new List<Proposal_Role__c>();
        for(Proposal_Role__c objProposalRole : [select Id,Name,Proposal__c,Contact__c,Contact__r.Name,Contact__r.Title 
                                                from Proposal_Role__c where Proposal__c =:ProposalId and Contact__c!=null]){
                                                    lstExistingProposalContacts.add(objProposalRole);
                                                    setProposalContacts.add(objProposalRole.Contact__c);
                                                    
                                                }
        // converting list to JSON array and store it in a List to return
        listToreturn.add(JSON.serialize(lstExistingProposalContacts));
        Id accId = [Select AccountId from User where Id=:userinfo.getUserId()].AccountId;
        list<Contact> lstProposalContact =new List<Contact>();
        if(setProposalContacts.isEmpty()){
            lstProposalContact=[select Id,Name,Title from Contact where accountId=:accId]; 
        }  else{
            lstProposalContact=[select Id,Name,Title from Contact where id!=:setProposalContacts and accountId=:accId]; 
        }
        // converting list to JSON array and store it in a List to return
        listToreturn.add(JSON.serialize(lstProposalContact));
        return listToreturn;
    }
    
    //this method is to delete the Proposal role 
    @AuraEnabled
    public static List<String> deleteProposalRole(String ProposalId,String ProposalRoleId){
        delete new Proposal_Role__c(Id=ProposalRoleId);
        return FetchProposalRoles(ProposalId);
    }
    
    //this method is to insert Proposal role along with child contact for a parent Proposal
    @AuraEnabled
    public static List<String> addProposalRole(String ProposalId,String ProposalContactId){
        insert new Proposal_Role__c(Proposal__c =ProposalId,Contact__c =ProposalContactId);
        return FetchProposalRoles(ProposalId);
    }
}