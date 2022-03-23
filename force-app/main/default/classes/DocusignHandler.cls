/*
# Created By : Mounika Thamarana
# Description : This apex class is to send a docusign document to the Owner and Contact user and this class called in proposalContractGenerator.
*/
public class DocusignHandler {   
    @future(callout=true)
    public static void sendEnvelopeMethod(String mySourceId) {        
        dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
            new dfsle.Entity(mySourceId));        
        Proposal_Contract__c myContact = [SELECT Id, Proposal__r.Applying_Contact__r.Email,
                                          Proposal__r.Applying_Contact__r.Name 
                                          from Proposal_Contract__c  WHERE Id =: mySourceId];        
        dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(            
            myContact.Proposal__r.Applying_Contact__r.Name ,          
            myContact.Proposal__r.Applying_Contact__r.Email,           
            null,         
            'Signer 1',        
            new dfsle.Entity(myContact.Id)); 
            System.debug(myContact.Proposal__r.Applying_Contact__r.Name);
            System.debug(myContact.Proposal__r.Applying_Contact__r.Email);       
        myEnvelope = myEnvelope.withRecipients(new List<dfsle.Recipient> { myRecipient });
        dfsle.UUID myTemplateId = dfsle.UUID.parse('03d9c274-3d3b-48d3-a48f-be98f6c885bf');        
        dfsle.Document myDocument = dfsle.Document.fromTemplate(
            myTemplateId,'myTemplate');    
        myEnvelope = myEnvelope.withDocuments(new List<dfsle.Document> { myDocument });
        myEnvelope = dfsle.EnvelopeService.sendEnvelope(myEnvelope,true);
    }
}