/*
Owner : MTX Group
Createddate : 14th March 2022
Comments : this class is the controller of ProposalReviewAndGeneratePDF visualforce page
*/
public class ProposalReviewAndGeneratePDFController {
    public Proposal__c proposal { get; set; }
    public String proposalId{get;set;}
    
    public ProposalReviewAndGeneratePDFController(ApexPages.StandardController controller)
    {
        proposalId=controller.getRecord().id;
        proposal = getProposal();
    } 
    
    public List<Schema.FieldSetMember> getFields() {
        String grantName = [Select Id, Grant_Solicitation__r.Name from Proposal__c where Id=:proposalId].Grant_Solicitation__r.Name;
        Map<String, Schema.FieldSet> FsMap = SObjectType.Proposal__c.FieldSets.getMap();
        String keyFs='';
        for(String objFsKey : FsMap.keySet()){
            Schema.FieldSet objFs = FsMap.get(objFsKey);
            if(objFs.getLabel()==grantName){
                keyFs = objFsKey;
            }
        }
        return String.isNotBlank(keyFs) ? SObjectType.Proposal__c.FieldSets.getMap().get(keyFs).getFields() : SObjectType.Proposal__c.FieldSets.getMap().get('PreviewProposal').getFields();
    }
    
    private Proposal__c getProposal() {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : getFields()) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id, Name FROM Proposal__c where Id=\''+proposalId+'\' LIMIT 1';
        return Database.query(query);
    }
}