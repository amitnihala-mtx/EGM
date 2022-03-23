@isTest
Private class Proposal_ProposalRoleControllerTest {
    static void setup(){
   // List<Proposal__c> ListtestP=[select id,name from Proposal__c where id='a0L8c00000TLaFcEAL'];

}
    @isTest static void TestFetchProposalRoles(){
        test.startTest();
       // List<String> TestlistToreturn =new List<String>();
		List<String> ProposalRolesTest = Proposal_ProposalRoleController.FetchProposalRoles('a0L8c00000TLaFcEAL');
        //System.assertEquals(1,ProposalRolesTest.size(),'Test not passed');
        System.assertEquals(true,ProposalRolesTest[0]!=NULL);
        System.assertEquals(true,ProposalRolesTest[1]!=NULL);
        test.stopTest();
    }
       @isTest static void TestdeleteProposalRole(){
        test.startTest();
           
  List<Proposal_Role__c> PR = [select id,name from Proposal_Role__c where Proposal__c='a0L8c00000TLaFcEAL' LIMIT 1 ];
  Proposal_Role__c PRrecord = [select id,name from Proposal_Role__c where Proposal__c='a0L8c00000TLaFcEAL' LIMIT 1 ];         
          System.assertEquals(true, Proposal_ProposalRoleController.deleteProposalRole('a0L8c00000TLaFcEAL', PRrecord.id)!=NULL);  
        test.stopTest();
    }
        @isTest static void TestaddProposalRole(){
        test.startTest();
            Proposal__c ptest =[select id from Proposal__c where Id ='a0L8c00000TLaFcEAL'];
            
            System.assertEquals(true, Proposal_ProposalRoleController.addProposalRole(ptest.id,'0038c00002ivMlIAAU')!=NULL);  
        test.stopTest();
    }
}