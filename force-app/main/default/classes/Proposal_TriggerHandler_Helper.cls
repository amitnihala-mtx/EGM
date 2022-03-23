/*
Owner : MTX
Createddate : 15th Feb 2022
Modifieddate : 15th Feb 2022
Comments : this class is the helper of Proposal_TriggerHandler class.
*/
public class Proposal_TriggerHandler_Helper {
    
    //This method generates scorecards for group members on the proposal, when proposal is moved to Under Reveiw stage.
    public static void copyScorecardOnUnderReview(List<Proposal__c> newProjectList,Map<Id,Proposal__c> oldProjectMap) {
        Savepoint sp = Database.setSavepoint();
        try{
            Set<Id> setOfProposalIdsToGenerateScorecard = new Set<Id>();
            Set<Id> setOfGrantIdsToFetchScorecard = new Set<Id>();
            Set<Id> setOfGroupIdsToFetchMemeber = new Set<Id>();
            for(Proposal__c objProposal : newProjectList) {
                if(objProposal.Status__c != oldProjectMap.get(objProposal.Id).Status__c && objProposal.Status__c =='Under Review' && objProposal.Grant_Solicitation_Group__c!=null) {
                    setOfGrantIdsToFetchScorecard.add(objProposal.Grant_Solicitation__c);
                    setOfProposalIdsToGenerateScorecard.add(objProposal.Id);
                    setOfGroupIdsToFetchMemeber.add(objProposal.Grant_Solicitation_Group__c);
                }
            }
            if(setOfProposalIdsToGenerateScorecard.isEmpty()){
                return;
            }
            Map<Id,List<Scorecard__c>> mapOfGrantToScorecards = new Map<Id,List<Scorecard__c>>();
            for(Scorecard__c objScorecard : [Select Id ,Name ,Assign_To_User__c ,Description__c ,Grant_Solicitation__c ,IsActive__c ,
                                             Origin__c ,Proposal__c ,Scoring_Type__c ,Status__c,(Select Id,Answer__c ,Category__c ,Field_Type__c ,Layout_Type__c ,Maximum_Points__c ,Points__c ,Question_Description__c ,Scorecard__c ,Sequence_Order__c from Scorecard_Metric__r)  from Scorecard__c where Grant_Solicitation__c=:setOfGrantIdsToFetchScorecard and IsActive__c=true]) {
                                                 if(!mapOfGrantToScorecards.containskey(objScorecard.Grant_Solicitation__c)) {
                                                     mapOfGrantToScorecards.put(objScorecard.Grant_Solicitation__c,new List<Scorecard__c>());
                                                 }	    
                                                 mapOfGrantToScorecards.get(objScorecard.Grant_Solicitation__c).add(objScorecard);
                                             }
            System.debug('mapOfGrantToScorecards::'+mapOfGrantToScorecards);
            Map<Id,Grant_Solicitation_Group__c> mapGrantSolicitationGroup = New Map<Id,Grant_Solicitation_Group__c>([Select Id,(Select Id, Grant_Solicitation_Review_Team__c , Grant_Solicitation_Review_Team__r.Member__c from Grant_Solicitation_Group_Members__r where Grant_Solicitation_Review_Team__r.Scoring_Committee__c=true) from Grant_Solicitation_Group__c where Id=:setOfGroupIdsToFetchMemeber]);
            System.debug('mapGrantSolicitationGroup::'+mapGrantSolicitationGroup);
            Map<Id,List<Scorecard__c>> mapScoreToInsertForProposal = new Map<Id,List<Scorecard__c>>();
            List<Scorecard__c> listScoreToInsertForProposal = new List<Scorecard__c>();
            Map<Id,List<Scorecard_Metric__c>> mapIdToListScoreMatric = new Map<Id,List<Scorecard_Metric__c>>();
            for(Proposal__c objProposal : newProjectList) {
                if(setOfProposalIdsToGenerateScorecard.contains(objProposal.Id)) {
                    List<Scorecard__c> lstScore = mapOfGrantToScorecards.containskey(objProposal.Grant_Solicitation__c) ? mapOfGrantToScorecards.get(objProposal.Grant_Solicitation__c) : New List<Scorecard__c>();
                    System.debug('lstScore::'+lstScore);
                    for(Scorecard__c objScorecard : lstScore) {
                        Grant_Solicitation_Group__c objGrantSolicitationGroup = mapGrantSolicitationGroup.containskey(objProposal.Grant_Solicitation_Group__c) ? mapGrantSolicitationGroup.get(objProposal.Grant_Solicitation_Group__c) : New Grant_Solicitation_Group__c();
                        for(Grant_Solicitation_Group_Member__c objGSGM : objGrantSolicitationGroup.Grant_Solicitation_Group_Members__r) {
                            Id scoreId = objScorecard.Id;
                            Scorecard__c objScorecardToAdd = objScorecard.clone(false,false,false,false);
                            objScorecardToAdd.ParentScorecardId__c = objScorecard.Id;
                            objScorecardToAdd.Grant_Solicitation__c = null;
                            objScorecardToAdd.Proposal__c = objProposal.Id;
                            objScorecardToAdd.Scoring_Type__c = 'Score Answers';
                            objScorecardToAdd.OwnerId = objGSGM.Grant_Solicitation_Review_Team__r.Member__c;
                            objScorecardToAdd.Assign_To_User__c = objGSGM.Grant_Solicitation_Review_Team__r.Member__c;
                            listScoreToInsertForProposal.add(objScorecardToAdd);
                            /*if(!mapScoreToInsertForProposal.containskey(scoreId)) {
                                mapScoreToInsertForProposal.put(scoreId,new List<Scorecard__c>());
                            }
                            mapScoreToInsertForProposal.get(scoreId).add(objScorecardToAdd);*/
                        }
                        mapIdToListScoreMatric.put(objScorecard.Id,objScorecard.Scorecard_Metric__r);
                    }
                    System.debug('mapScoreToInsertForProposal::'+mapScoreToInsertForProposal);
                }
            }
            
            /*if(!mapScoreToInsertForProposal.isEmpty()){
                for(Id key: mapScoreToInsertForProposal.keySet()) {
                    listScoreToInsertForProposal.addAll(mapScoreToInsertForProposal.get(key));
                }
                insert listScoreToInsertForProposal;
            }*/
            if(!listScoreToInsertForProposal.isEmpty()) {
                insert listScoreToInsertForProposal;
            }
            
            Map<Id,Id> mapOfNewIdOldId = new Map<Id,Id>();
            for(Scorecard__c objScore : listScoreToInsertForProposal) {
                mapOfNewIdOldId.put(objScore.Id,objScore.ParentScorecardId__c); 
            }
            
            List<Scorecard_Metric__c> lstSCMToInsert = new List<Scorecard_Metric__c>();
            for(Id key:mapOfNewIdOldId.keySet()) {
                Id oldId = mapOfNewIdOldId.get(key);
                for(Scorecard_Metric__c objSCM : mapIdToListScoreMatric.get(oldId)){
                    Scorecard_Metric__c newRec = objSCM.clone(false,false,false,false);
                    newRec.Scorecard__c = key;
                    lstSCMToInsert.add(newRec);
                }
            }
            if(!lstSCMToInsert.isEmpty()) {
                insert lstSCMToInsert;
            }
            /*System.debug('listScoreMatricToInsert::'+listScoreMatricToInsert);
            for(Scorecard_Metric__c objSCM : listScoreMatricToInsert) {
                objSCM.Id=null;
                objSCM.Scorecard__c = mapScoreToInsertForProposal.get(objSCM.Scorecard__c).Id;
            }
            if(!listScoreMatricToInsert.isEmpty()){
                insert listScoreMatricToInsert;
            }*/
        } catch(Exception exp){
            Database.rollback(sp);
            newProjectList[0].addError('Failed to create Scorecard due to follwing reason: '+exp.getMessage());
        }
    }
}