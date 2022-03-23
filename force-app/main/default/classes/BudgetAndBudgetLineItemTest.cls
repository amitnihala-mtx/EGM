@isTest
public class BudgetAndBudgetLineItemTest {
@testsetup
static void setup(){
   // List<Proposal__c> ListtestP=[select id,name from Proposal__c where id='a0L8c00000TLaFcEAL'];

}
          static testmethod void TestForParentChildRecords(){
           test.startTest();
  
         List<Budget__c> newList =new List<Budget__c>();
        newList.addAll(BudgetAndBudgetLineItem.ForParentChildRecords('a0L8c00000TLaFcEAL'));
              
              test.stopTest();
              
              System.assertEquals(true,newList!=NULL);
        
      }
 
    
}