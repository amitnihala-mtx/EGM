/*
 * Created by : Amit Kumar Nihala
 * Created Date : 25th Feb 2022
 * Description : This class is the controller class of grants_ManageGroupMembers lwc component.
*/
public class Grants_ManageGroupMembersController {
    //This method fetches all the existing group members and the review team members those can be added as group member
	@AuraEnabled
    public static List<String> fetchGroupMembersInfo(String groupId){
        List<String> lstToReturn = new List<String>();
        Set<Id> setOfMemebers = new Set<Id>();
        Set<Id> setOfGrants = new Set<Id>();
        Grant_Solicitation_Group__c objGroup = [Select Id,Grant_Solicitation_Round__c,Grant_Solicitation_Round__r.Solicitation__c from Grant_Solicitation_Group__c where Id=:groupId limit 1];
        String grantId = objGroup.Grant_Solicitation_Round__r?.Solicitation__c;
        List<Grant_Solicitation_Group_Member__c> lstExistingGroupMembers = New List<Grant_Solicitation_Group_Member__c>();
        for(Grant_Solicitation_Group_Member__c objGroupMember :[Select Id,Name,Grant_Solicitation_Group__c,Grant_Solicitation_Group__r.Grant_Solicitation_Round__c,Grant_Solicitation_Group__r.Grant_Solicitation_Round__r.Solicitation__c,Grant_Solicitation_Review_Team__c,Grant_Solicitation_Review_Team__r.Member__c,Grant_Solicitation_Review_Team__r.Member__r.Name
                                                                from Grant_Solicitation_Group_Member__c 
                                                                where Grant_Solicitation_Group__c=:groupId and Grant_Solicitation_Review_Team__r.Member__c!=null]){
            lstExistingGroupMembers.add(objGroupMember);
            setOfMemebers.add(objGroupMember.Grant_Solicitation_Review_Team__r?.Member__c);
            setOfGrants.add(objGroupMember.Grant_Solicitation_Group__r?.Grant_Solicitation_Round__r?.Solicitation__c);
        }
        lstToReturn.add(JSON.serialize(lstExistingGroupMembers));
        
        List<Grants_Review_Team__c> lstReviewTeamMembers = new List<Grants_Review_Team__c>();
        if(setOfMemebers.isEmpty()) {
            lstReviewTeamMembers = [Select Id,Name,Member__r.Name,Scoring_Committee__c from Grants_Review_Team__c where Solicitation__c =:grantId and Member__c!=null];
        } else {
            lstReviewTeamMembers = [Select Id,Name,Member__r.Name,Scoring_Committee__c from Grants_Review_Team__c where Solicitation__c =:grantId and Member__c !=:setOfMemebers and Member__c!=null];
        }
        
        lstToReturn.add(JSON.serialize(lstReviewTeamMembers));
        return lstToReturn;
    }
    //This method delete a group member with the passed member id and returns the list of group members and reveiew team members
    @AuraEnabled
    public static List<String> deleteGroupMember(String groupId,String groupMemberId){
        delete new Grant_Solicitation_Group_Member__c(Id=groupMemberId);
        return fetchGroupMembersInfo(groupId);
    }
    
    //This method add a group member with the passed review team member id and returns the list of group members and reveiew team members
    @AuraEnabled
    public static List<String> addGroupMember(String groupId,String reviewTeamMemberId){
        insert new Grant_Solicitation_Group_Member__c(Grant_Solicitation_Group__c=groupId,Grant_Solicitation_Review_Team__c=reviewTeamMemberId);
        return fetchGroupMembersInfo(groupId);
    }
}