public without sharing class DECDScorecardController {
    
    @AuraEnabled
    public static List<Scorecard_Metric__c> fetchScoreMetrics(String scorecardId, String userId){
        try {
            
            List<Scorecard_Metric__c> metricsToReturn = [SELECT Id, Scorecard__c,
                                                         Field_Type__c, Answer__c, Layout_Type__c, Question_Description__c, 
                                                         Sequence_Order__c, Points__c, Maximum_Points__c, Scorecard__r.OwnerId, Scorecard__r.Status__c
                                                         FROM Scorecard_Metric__c 
                                                         WHERE 
                                                         // ScoreCard__r.OwnerId = :userId AND
                                                         // AND 
                                                         Scorecard__c = :scorecardId 
                                                         WITH SECURITY_ENFORCED
                                                         ORDER BY Sequence_Order__c];
            return metricsToReturn;
            
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }
    
    @AuraEnabled
    public static void saveScoreMetrics(List<Scorecard_Metric__c> recordsToUpdate, String scorecardId){
        try {
            System.debug('recordsT '+recordsToUpdate);
            update recordsToUpdate;
            
            Scorecard__c sc = new Scorecard__c(Id=scorecardId, Status__c = 'In Progress');
            update sc;
            
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }
    
    @AuraEnabled
    public static boolean submitScorecard(String recordId){
        try {
            Scorecard__c sc = new Scorecard__c(Id=recordId, Status__c = 'Completed');
            update sc;
            return updateStatusOnProposal(recordId);
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }
    
    @AuraEnabled
    public static void createscorecard(Scorecard__c scorecardToCreate){
        try {
            insert scorecardToCreate;
            
            List<User> lst = [SELECT Id, Email FROM User WHERE Id = :scorecardToCreate.Assign_To_User__c];
            
            // update owner to Assigned Person
            //scorecardToCreate.OwnerId = scorecardToCreate.Assign_To_User__c;
            //update scorecardToCreate;
            
            /*if(lst != null && lst.size()>0){
Messaging.SingleEmailMessage message = new        Messaging.SingleEmailMessage();
message.setTargetObjectId(lst[0].Id); 
//message.setSenderDisplayName(‘Company Support’); 
//message.setReplyTo(‘no-reply@company.com’);
message.setUseSignature(false); 
message.setBccSender(false); 
message.setSaveAsActivity(false); 
EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Notify Scoring Team on Funding Request  Reviewed'];
message.setTemplateID(emailTemplate.Id); 
message.setWhatId(scorecardToCreate.Id); //This is important for the merge fields in template to work
message.toAddresses = new String[] { lst[0].email};
Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

if (results[0].success) 
{
System.debug('The email was sent successfully.');
} else {
System.debug('The email failed to send: ' +results[0].errors[0].message);
}
}*/
            
            scorecardToCreate.OwnerId = scorecardToCreate.Assign_To_User__c;
            update scorecardToCreate;
            
            List<Scorecard__Share> shareRecords = new List<Scorecard__Share>();
            
            // Query share records
            List<Scorecard__Share> existingShareRecords = [SELECT AccessLevel, ParentId, UserOrGroupId
                                                           FROM Scorecard__Share 
                                                           WHERE ParentId = :scorecardToCreate.Id
                                                           AND UserOrGroupId =:UserInfo.getUserId()];
            if(existingShareRecords == null || existingShareRecords.size() <= 0){
                shareRecords.add(new Scorecard__Share(AccessLevel = 'edit',
                                                      ParentId = scorecardToCreate.Id,
                                                      UserOrGroupId = UserInfo.getUserId()));
                insert shareRecords;
            }
            
            /*List<outfunds__funding_request__Share> shareFRRecords = new List<outfunds__funding_request__Share>();
            
            // Query share records
            List<outfunds__funding_request__Share> existingFRShareRecords = [SELECT AccessLevel, ParentId, UserOrGroupId
                                                                             FROM outfunds__funding_request__Share 
                                                                             WHERE ParentId = :scorecardToCreate.Funding_Request__c
                                                                             AND UserOrGroupId =:scorecardToCreate.Assign_To_User__c];
            if(existingFRShareRecords == null || existingFRShareRecords.size() <= 0){
                shareFRRecords.add(new outfunds__funding_request__Share(AccessLevel = 'read',
                                                                        ParentId = scorecardToCreate.Funding_Request__c,
                                                                        UserOrGroupId = scorecardToCreate.Assign_To_User__c));
                insert shareFRRecords;
            }*/
            
        } catch (Exception e) {throw new AuraHandledException(e.getMessage()+ ' ===== ' +e.getStackTraceString());}
    }
    
    public static boolean updateStatusOnProposal(String scorecardId){
        Scorecard__c objScorecard = [Select Id, Proposal__c from Scorecard__c where Id=:scorecardId limit 1];
        if(objScorecard.Proposal__c==null) {
            return false;
        }
        Proposal__c objProposal = [Select Id, Pass_Score__c ,(Select Id, Status__c, Scored_Points__c , Total_Points__c from Scorecard__r) from Proposal__c where Id=:objScorecard.Proposal__c];
        Boolean allScorecardsSubmitted = true;
        Decimal totalPoints = 0;
        Decimal scoredPoints = 0;
        for(Scorecard__c proposalScore : objProposal.Scorecard__r) {
            if(proposalScore.Status__c!='Completed') {
                allScorecardsSubmitted = false;
                break;
            }
            if(proposalScore.Total_Points__c!=null) {
                totalPoints +=proposalScore.Total_Points__c;
            }
            if(proposalScore.Scored_Points__c!=null) {
                scoredPoints +=proposalScore.Scored_Points__c;
            }
        }
        if(!allScorecardsSubmitted){
           return false; 
        }
        Decimal avg = (scoredPoints/totalPoints)*100;
        if(avg>=objProposal.Pass_Score__c){
            objProposal.Status__c='Awarded';
        } else{
            objProposal.Status__c='Not Awarded';
        }
        update objProposal;
        return true;
    }
}