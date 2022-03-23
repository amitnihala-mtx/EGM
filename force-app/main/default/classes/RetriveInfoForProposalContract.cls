public class RetriveInfoForProposalContract {
  public Proposal__c ProposalRecordInfo { get; set; }
      public Grant_Solicitation__c  GrantSolicitationInfo { get; set; }
    public Contract_Template__c   ContractTemplateInfo { get; set; }
    //public List<Allegation__c> allegVar { get; set; }
    
    public RetriveInfoForProposalContract(){
        ProposalRecordInfo = [SELECT Id,Proposal_Number__c , Grant_Solicitation__c,CreatedDate,CreatedBy.FirstName,CreatedBy.LastName,Awarded_Amount__c   FROM Proposal__c WHERE Id =: ApexPages.currentPage().getParameters().get('id')];     
        ContractTemplateInfo = [SELECT Id,Name, Grant_Solicitation__c   FROM Contract_Template__c];
        
        
    }
}