public without sharing class DeliverablesAndMilestones {
     @AuraEnabled
     public static List<Proposal_Content__c> retriveProposalcontents(string recordId) {
     return [SELECT Id,Name__c,Name,RecordTypeId,RecordType.Name ,Description__c,Cost_Per_Unit__c,Date_Value__c,Due_date__c,Start_date__c,Status__c,Milestone_Due_Date__c,
             (select Id,Name,Name__c,RecordTypeId,RecordType.Name,Due_date__c,Status__c,Description__c,Submitted_Date__c,CreatedDate from Proposal_Contents__r WHERE RecordType.Name IN ('Deliverables','Tasks')) 
             FROM Proposal_Content__c WHERE Proposal_Content__c.Proposal__c =:recordId
            And RecordType.Name IN ('Milestones')
            And Parent__c=null];
     }
     @AuraEnabled
     public static void setSumbittedDateProposalContent(String submitId){
          try {
               Proposal_Content__c pcNew = new Proposal_Content__c();
               pcNew.Id = submitId;
               pcNew.Submitted_Date__c =  date.today();
               pcNew.Status__c = 'Submitted';
               update pcNew;
          } catch (Exception e) {
               throw new AuraHandledException(e.getMessage());
          }
     }
     @AuraEnabled
     public static InvoiceWrapper updateInvoice(String updateData){
          try {
               InvoiceWrapper invoiceWrapper= (InvoiceWrapper)JSON.deserialize(updateData, InvoiceWrapper.Class);
               Proposal_Invoice__c piNew = new Proposal_Invoice__c();
               if (invoiceWrapper.Id != '') {
                    piNew.Id = invoiceWrapper.Id;
               }
               else{
                    piNew.Proposal__c = invoiceWrapper.Proposal;
                    piNew.Proposal_Content__c = invoiceWrapper.Proposal_Content;
               }
               piNew.Name__c = invoiceWrapper.Name;
               piNew.Amount__c = invoiceWrapper.Amount;
               piNew.Status__c = invoiceWrapper.Status;
               piNew.Invoice_Date__c = invoiceWrapper.Invoice_Date;
               piNew.Budget__c = invoiceWrapper.Budget_Id;
               upsert piNew;

               Proposal_Invoice__c temp = [SELECT Id,Name,Name__c,Amount__c,Status__c,Invoice_Date__c,Budget__r.Name,Budget__c FROM Proposal_Invoice__c WHERE Id = :piNew.Id];
               InvoiceWrapper newIw = new InvoiceWrapper();
               newIw.Id = temp.Id;
               newIw.AutoNumber = temp.Name;
               newIw.Name = temp.Name__c;
               newIw.Amount = temp.Amount__c;
               newIw.Status = temp.Status__c;
               newIw.Budget_Name = temp.Budget__r.Name;
               newIw.Budget_Id = temp.Budget__c;
               newIw.Invoice_Date = temp.Invoice_Date__c;
               newIw.showEdit = false;
               return newIw;

          } catch (Exception e) {
               throw new AuraHandledException(e.getMessage());
          }
     }
     @AuraEnabled
     public static List<Budget__c> getBudgetofProposal(String proposalId){
          try {
               List<Budget__c> budgetList = [SELECT Id,Name from Budget__c Where Proposal__c = :proposalId];
               return budgetList;

          } catch (Exception e) {
               throw new AuraHandledException(e.getMessage());
          }
     }
     @AuraEnabled
     public static string getInvoices(String proposalId){
          try {
               List<Proposal_Invoice__c> pi = [SELECT Id,Name,Name__c,Proposal__c,Amount__c,Due_Date__c,Invoice_Date__c,Invoice_Paid_Date__c,State__c,City__c,Company_Name__c,Street__c,Status__c,Budget__r.Name,Budget__c FROM Proposal_Invoice__c Where Proposal_Content__c =: proposalId];
               List<InvoiceWrapper> invWapperList = new List<InvoiceWrapper>();
               for (Proposal_Invoice__c piData : pi) {
                    InvoiceWrapper invWapper = new InvoiceWrapper();
                    invWapper.Id = piData.Id;
                    invWapper.AutoNumber = piData.Name != null ? piData.Name : '';
                    invWapper.Name = piData.Name__c != null ? piData.Name__c : '';
                    invWapper.Amount = piData.Amount__c != null ? piData.Amount__c : 0;
                    invWapper.Status = piData.Status__c != null ? piData.Status__c : '';
                    invWapper.Budget_Name = piData.Budget__r.Name;
                    invWapper.Budget_Id = piData.Budget__c;
                    invWapper.Invoice_Date = piData.Invoice_Date__c != null ? piData.Invoice_Date__c : null;
                    invWapper.showEdit = false;
                    invWapperList.add(invWapper);
               }
               return JSON.serialize(invWapperList);
          } catch (Exception e) {
               throw new AuraHandledException(e.getMessage());
          }
     }
     @AuraEnabled
     public static List<DocumentUploadsWrapper> getDocumentData(String parentId){
          try {
               List<Id> entityIdsToDocumentId = new List<Id>();
               List<ContentDocumentLink> ContentDocumentLinkList = new List<ContentDocumentLink>([
                   SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:parentId]);
               for(ContentDocumentLink cd: ContentDocumentLinkList){
                   entityIdsToDocumentId.add(cd.ContentDocumentId);
               }
               List<ContentVersion> contentVersionList = [SELECT Id, ContentDocument.Title,ContentDocument.FileType,ContentDocument.CreatedDate, ContentDocumentId
               FROM   ContentVersion 
               WHERE  ContentDocumentId IN : entityIdsToDocumentId AND IsLatest =: true];
   
               List<DocumentUploadsWrapper> docWrapperList = new List<DocumentUploadsWrapper>();
               for (Integer i = 0; i < contentVersionList.size(); i++) {
                   DocumentUploadsWrapper doc = new DocumentUploadsWrapper();
                   String str = contentVersionList[i].ContentDocument.Title;
                    Datetime dT = contentVersionList[i].ContentDocument.CreatedDate;
                    Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                    doc.fileName = contentVersionList[i].ContentDocument.Title + '.' + contentVersionList[i].ContentDocument.FileType;
                    doc.showFiles = true;
                    doc.CreatedDate = myDate;
                    doc.ContentVerId = contentVersionList[i].Id;
                    doc.ContentDocId = contentVersionList[i].ContentDocumentId;
                    docWrapperList.add(doc);
               }
               return docWrapperList;
           } catch (Exception e) {
               throw new AuraHandledException(e.getMessage());
           }
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