/*created by: pranay reddy cheruku
Purpose : for grants_Budgetlandingscreen
*/
public class BudgetAndBudgetLineItem {
@AuraEnabled(cacheable=true)
    // this method is to retrieve the parent(Budget__c) and child(Budget_Line_Items__c)
     public static List<Budget__c> ForParentChildRecords(string recordId) {
          return 
              [SELECT Id,Name,
             (select Id,Name,Grant_Funded__c ,Match_Funds__c ,Match_Percent_Calculated__c ,Match_Percent_Required__c,Other_Funds__c   from Budget_Line_Items__r ) 
             FROM Budget__c WHERE Budget__c.Proposal__c =:recordId];
     }
}