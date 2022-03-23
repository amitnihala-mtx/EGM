@isTest
private class DeliverablesAndMilestonesTest {
    @TestSetup
    static void makeData(){
        Program__c program = new Program__c();
        program.Name = 'TestProg';
        insert program;

        Grant_Solicitation__c grant = new Grant_Solicitation__c();
        grant.Name = 'TestGrant';
        grant.Program__c = program.Id;
        grant.Solicitation_Manager__c = UserInfo.getUserId();
        grant.Program_Manager__c = UserInfo.getUserId();

        insert grant;

        Grant_Solicitation_Rounds__c grantRound = new Grant_Solicitation_Rounds__c(Name = 'TestGrantRound',Solicitation__c = grant.Id);
        insert grantRound;

        Grant_Solicitation_Group__c grantGroup = new Grant_Solicitation_Group__c(Name = 'TestGrantGroup',Grant_Solicitation_Round__c = grantRound.Id);
        insert grantGroup;

        List<Program_Content__c> programCont =  new List<Program_Content__c>();
        Id deliverablesId = Schema.SObjectType.Program_Content__c.getRecordTypeInfosByName().get('Deliverables').getRecordTypeId();
        Id milestonesId = Schema.SObjectType.Program_Content__c.getRecordTypeInfosByName().get('Milestones').getRecordTypeId();
        Id tasksId = Schema.SObjectType.Program_Content__c.getRecordTypeInfosByName().get('Tasks').getRecordTypeId();

        programCont.add(new Program_Content__c(Object_Name__c = 'TestProgram deliverables', Grant_Solicitation__c = grant.Id, RecordTypeId = deliverablesId));
        programCont.add(new Program_Content__c(Object_Name__c = 'TestProgram milestones', Grant_Solicitation__c = grant.Id, RecordTypeId = milestonesId));
        programCont.add(new Program_Content__c(Name__c = 'TestProgram tasks', Grant_Solicitation__c = grant.Id, RecordTypeId = tasksId));
        insert programCont;

        //Proposal
        Proposal__c proposal = new Proposal__c(Name = 'TestProposal',Grant_Solicitation__c = grant.Id,Grant_Solicitation_Rounds__c = grantRound.Id ,Grant_Solicitation_Group__c =grantGroup.Id);
        insert proposal;

        //Invoice
        Proposal_Invoice__c proposalInvoice = new Proposal_Invoice__c(Name__c = 'TestInvoice',Proposal__c = proposal.Id,Proposal_Content__c = [SELECT Id FROM Proposal_Content__c WHERE Name__c = 'TestProgram milestones'].Id);
        insert proposalInvoice;

        //Budget 
        Budget__c budget = new Budget__c(Name = 'TestBudget', Proposal__c = proposal.Id);
        insert budget;

        //Document insert
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion'); 
            
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='TestDocument', 
            PathOnClient ='Test.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                        FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = [SELECT Id FROM Proposal_Content__c WHERE Name__c = 'TestProgram deliverables'].Id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
    }   
    //Get proposal data
    @isTest
    static void retriveProposalcontentsTest(){
        Proposal__c testData = [SELECT Id FROM Proposal__c Where Name = 'TestProposal' LIMIT 1];
        List<Proposal_Content__c> proposalTest = DeliverablesAndMilestones.retriveProposalcontents(testData.Id);
        
        System.assertEquals('TestProgram milestones',proposalTest[0].Name__c);
    }
    //Get budgget of proposal
    @isTest
    static void getBudgetofProposalTest(){
        Proposal__c testData = [SELECT Id FROM Proposal__c Where Name = 'TestProposal' LIMIT 1];
        List<Budget__c> budgetTest = DeliverablesAndMilestones.getBudgetofProposal(testData.Id);
        
        System.assertEquals('TestBudget',budgetTest[0].Name);
    }
    //Get Invoice
    @isTest
    static void getInvoicesTest(){
        Proposal_Content__c testData = [SELECT Id FROM Proposal_Content__c WHERE Name__c = 'TestProgram milestones' LIMIT 1];

        String invoicesString = DeliverablesAndMilestones.getInvoices(testData.Id);
        List<InvoiceWrapper> invoicesTest = (List<InvoiceWrapper>)JSON.deserialize(invoicesString, List<InvoiceWrapper>.class);
        
        System.assertEquals(1,invoicesTest.size());
    }
    //Document 
    @isTest
    static void getDocumentDataTest(){
        Proposal_Content__c testData = [SELECT Id FROM Proposal_Content__c WHERE Name__c = 'TestProgram deliverables' LIMIT 1];
        String documnetString = JSON.serialize(DeliverablesAndMilestones.getDocumentData(testData.Id));
        List<DocumentUploadsWrapper> documnetTest = (List<DocumentUploadsWrapper>)JSON.deserialize(documnetString, List<DocumentUploadsWrapper>.class);
        
        System.assertEquals('TestDocument.JPG',documnetTest[0].fileName);
    }
    //Submitted proposal 
    @isTest
    static void setSumbittedDateProposalContentTest(){
        Proposal_Content__c newProposalContent = [SELECT Id,Status__c,Submitted_Date__c FROM Proposal_Content__c Where Name__c = 'TestProgram deliverables' LIMIT 1];

        DeliverablesAndMilestones.setSumbittedDateProposalContent(newProposalContent.Id);
        List<Proposal_Content__c> testPc = [SELECT Id,Status__c,Submitted_Date__c FROM Proposal_Content__c Where Name__c = 'TestProgram deliverables' LIMIT 1];
        
        System.assertEquals('Submitted',testPc[0].Status__c);
        System.assertEquals(date.today(),testPc[0].Submitted_Date__c);
    }
    //Update invoice
    @isTest
    static void updateInvoiceTest(){
        Proposal_Invoice__c newProposalInvoice = [SELECT Id FROM Proposal_Invoice__c Where Name__c = 'TestInvoice' LIMIT 1];
        InvoiceWrapper invoiceWrapper = new InvoiceWrapper();
        invoiceWrapper.Id = newProposalInvoice.Id;
        invoiceWrapper.Name = 'Test Invoice Change';
        invoiceWrapper.Amount = 200;
        String invoiceWrapperString = JSON.serialize(DeliverablesAndMilestones.updateInvoice(JSON.serialize(invoiceWrapper)));
        InvoiceWrapper invoiceWrapperTest = (InvoiceWrapper)JSON.deserialize(invoiceWrapperString, InvoiceWrapper.class);
        
        System.assertEquals('Test Invoice Change',invoiceWrapperTest.Name);
        System.assertEquals(200,invoiceWrapperTest.Amount);

    }

    public class DocumentUploadsWrapper {
        @AuraEnabled Public String key;
        @AuraEnabled Public String title;
        @AuraEnabled Public String fileName;
        @AuraEnabled Public Date CreatedDate;
        @AuraEnabled Public String ContentDocId;
        @AuraEnabled Public String ContentVerId;
        @AuraEnabled Public Boolean showFiles;
    }

  public class InvoiceWrapper {
      @AuraEnabled Public String Id;
      @AuraEnabled Public String AutoNumber;
      @AuraEnabled Public String Name;
      @AuraEnabled Public Decimal Amount;
      @AuraEnabled Public Date Invoice_Date;
      @AuraEnabled Public String Status;
      @AuraEnabled Public Boolean showEdit;
      @AuraEnabled Public String Proposal;
      @AuraEnabled Public String Proposal_Content;
      @AuraEnabled Public String Budget_Name;
      @AuraEnabled Public String Budget_Id;
  }
}