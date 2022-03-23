public with sharing class Grants_DisbursementsController {
   
    @AuraEnabled
    public static void createDisbursementRec(List<Disbursement__c> disbursementRecLst){
        insert disbursementRecLst;
    }
}