/*Created By: Pranay reddy cheruku
Purpose: this class is called from flow with apex action and that flow is called with and action button (Generated PDF) on proposal records*/
public class ProposalContractGenerator {
    
    //this method created a proposal contract record when the generate pdf button is clicked
    @InvocableMethod
    public static List<Proposal_Contract__c> CreateProposalContractRecord(List<ID> ProposalRecId){
        Proposal__c Prec = [select id from Proposal__c where id IN:(ProposalRecId)];
        Proposal_Contract__c  PcRecord = new Proposal_Contract__c ();       
        PcRecord.Proposal__c=Prec.Id;
        insert PcRecord;
        GeneratePdf(PcRecord.Id,Prec.id);
        DocusignHandler.sendEnvelopeMethod(PcRecord.Id);
        list<Proposal_Contract__c> pc=[select id,name from Proposal_Contract__c where id=:PcRecord.Id];
        return pc;
        
    }
    //this method generates a pdf with proposal,grant,contract template field details and attaches it to the proposal contract record which is created in CreateProposalContractRecord method
    public static void GeneratePdf(Id ProposalContractId,id ProposalId) {
        Proposal__c ProposalRecordInfo =[ SELECT Id, Applying_Contact__c , Proposal_Site__c ,Proposal_Number__c , Grant_Solicitation__c,CreatedDate,CreatedBy.FirstName,CreatedBy.LastName,Awarded_Amount__c,Requested_Amount__c   
                                         FROM Proposal__c WHERE Id =:ProposalId];
        Grant_Solicitation__c GrantRecordInfo =[select id,Name from Grant_Solicitation__c where Grant_Solicitation__c.Id =: ProposalRecordInfo.Grant_Solicitation__c];
        Contract_Template__c ContractTemplateInfo=[SELECT id,Name ,Header__c ,Introduction__c,Proposal_Details__c,Status__c, Term_and_Conditions__c, Date_Signature__c, Grant_Solicitation__c, Disclaimer__c,Contact_Information__c  
                                                   from   Contract_Template__c where Grant_Solicitation__c = :ProposalRecordInfo.Grant_Solicitation__c AND Status__c='Active'];
        
      
        list<Contract_Template__c> checkContractTemplatelList = [select id,Name from Contract_Template__c where Grant_Solicitation__c = :ProposalRecordInfo.Grant_Solicitation__c AND Status__c='Active'];
        
        if(checkContractTemplatelList.isEmpty()){
             List<Proposal_Contract__c> delRecord =[select id,Name from Proposal_Contract__c where id=:ProposalContractId];
            delete delRecord;
        }
        else{
            PageReference pdf = new PageReference('/apex/MergePDF?id=' + ProposalContractId);
            Attachment attach = new Attachment();
            Proposal_Contract__c pc = [select Name from Proposal_Contract__c where Id = :ProposalContractId];
            Blob bodyData;
            try {
                String pdfContents = '<html>';
                pdfContents = '<title>';
                pdfContents = 'Contract and Details';
                pdfContents = '</title>';
                pdfContents = '<head>';
                pdfContents = '<h1>';
                pdfContents = 'Propsal Contract for Proposal';
                pdfContents += '</h1>';
                pdfContents = '</head>';
                pdfContents = '<body>';
                pdfContents = '<p>';
                pdfContents += 'Grant Name: ' + GrantRecordInfo.Name;
                pdfContents += '<br><br>';
                pdfContents += 'Proposal No: '+ProposalRecordInfo.Proposal_Number__c;
                pdfContents += '<br><br>';
                pdfContents += 'Applied Date: '+ProposalRecordInfo.CreatedDate;
                pdfContents += '<br><br>';
                pdfContents += 'Requested Amount: '+ProposalRecordInfo.Requested_Amount__c;
                pdfContents +='<br><br>' ;
                pdfContents += 'Awarded Amount: '+ProposalRecordInfo.Awarded_Amount__c;
                pdfContents += '<br><br>';
                pdfContents += 'Applied by: '+ProposalRecordInfo.CreatedBy.FirstName+' '+ProposalRecordInfo.CreatedBy.LastName;
                pdfContents += '<br><br>';
                pdfContents += 'Org Name: '+ProposalRecordInfo.Proposal_Site__c;
                pdfContents += '<br><br>';
                pdfContents += 'Header ';
                pdfContents += '<br><br>';
                pdfContents += ContractTemplateInfo.Header__c;
                pdfContents += '<br><br>';
                pdfContents += 'Introduction ';
                pdfContents += '<br><br>';
                pdfContents += ContractTemplateInfo.Introduction__c;
                pdfContents += '<br><br>';
                pdfContents += 'Proposal Details';
                pdfContents += '<br><br>';
                pdfContents += ContractTemplateInfo.Proposal_Details__c;
                pdfContents += '<br><br>';
                pdfContents += 'Contact Information ';
                pdfContents += '<br><br>';
                pdfContents += ContractTemplateInfo.Contact_Information__c;
                pdfContents += '<br><br>';
                pdfContents += 'Disclaimer ';
                pdfContents += '<br><br>';
                pdfContents += ContractTemplateInfo.Disclaimer__c;
                pdfContents += '<br><br>';
                pdfContents += 'Terms & Conditions ';
                pdfContents += '<br><br>';
                pdfContents += ContractTemplateInfo.Term_and_Conditions__c;
                pdfContents += '<p>';
                pdfContents +=' </body>';
                pdfContents +=' </html>';
                
                String pdfContents1 = pdfContents.stripHtmlTags();
                
                bodyData = Blob.valueOf(pdfContents1);
            } catch (VisualforceException e) {
                throw new VisualforceException('The following exception has occurred: ' + e.getMessage());
            }
            String fileName = pc.Name;
            attach.Body = bodyData;
            attach.Name =  fileName + '.pdf';
            attach.IsPrivate = false;
            attach.contentType = 'pdf';
            attach.ParentId = ProposalContractId;
            insert attach;
          

        
        }
    }
    
    
}