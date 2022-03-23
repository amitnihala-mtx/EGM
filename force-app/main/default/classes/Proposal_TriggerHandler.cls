public without sharing class Proposal_TriggerHandler {
   	
    public static void beforeInsert(List<Proposal__c> triggerNew){
        //autoPopulateIntakeForm(triggerNew);
    }
	public static void afterInsert(Proposal__c[] newList){
     	//copyProgramTemplate(newList);
        copyProgramContent(newList);
        createProposalRoleFromProgram(newList);
        autoPopulateIntakeForm(newList);
        createBudgetForProposal(newList);
	}
    public static void afterUpdate(){
        Proposal_TriggerHandler_Helper.copyScorecardOnUnderReview((List<Proposal__c>)trigger.new,(Map<Id,Proposal__c>)trigger.oldMap);
        sendEmailForReReview((List<Proposal__c>)trigger.new,(Map<Id,Proposal__c>)trigger.oldMap);
    }
    
    public static void copyProgramTemplate(List<Proposal__c> newProposalList) {
        // Fetch project records from database an set proposalMap (project id to project record map)
        Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>([SELECT Grant_Solicitation__c , Grant_Solicitation__r.Program__c,
                                                                  Concept_Paper__c, Proposal__c
                                                                  FROM Proposal__c where Id IN :newProposalList]);
        
        List<Id> programIdList = new List<Id>();
        Map<Id, List<Id>> programIdToProjectRecIdsMap = new Map<Id, List<Id>>();
        
        // Iterate over project records and conditionally add them to different list collections
        for(Proposal__c propRec : proposalMap.values()) {
            if(propRec.Grant_Solicitation__c != null && propRec.Grant_Solicitation__r.Program__c != null) {
                programIdList.add(propRec.Grant_Solicitation__r.Program__c);
                if(!programIdToProjectRecIdsMap.containsKey(propRec.Grant_Solicitation__r.Program__c)) {
                    programIdToProjectRecIdsMap.put(propRec.Grant_Solicitation__r.Program__c, new List<Id>{propRec.Id});
                } else {
                    List<Id> existingProjIdList = programIdToProjectRecIdsMap.get(propRec.Grant_Solicitation__r.Program__c);
                    existingProjIdList.add(propRec.Id);
                }
            }
        }
        
        // Fetch Program Template records and their child records - Program Template Pages and set programTemplateList list
        List<Program_Template__c> programTemplateList = [select Name, Description__c, Program__c, Status__c, Template_Type__c, Solicitation__c,
                                                         (select Page_Name__c, Name, Page_Type__c, Program_Template__c, Sequence__c,Page_Description__c from Program_Template_Pages__r)
                                                         from Program_Template__c
                                                         Where Program__c IN :programIdList
                                                         AND (Template_Type__c = 'Application Intake'
                                                              OR Template_Type__c = 'Proposal Application') AND Status__c = 'Active'];
        
        
        if(programTemplateList.size() == 0) {
            return;
        }
        List<Proposal_Template__c> proposalTemplateListToInsert = new List<Proposal_Template__c>();
        Map<Id,List<Proposal_Template__c>> programTemplateIdToProposalTemplateMap = new Map<Id,List<Proposal_Template__c>>();
        Map<Id, Id> proposalTemplateIdToProgramTemplateId = new Map<Id,Id>();
        
        // Process program template records and set proposal record
        Proposal__c proposal;
        for(Program_Template__c progTemplateRec : programTemplateList) {
            for(Id proposalId : programIdToProjectRecIdsMap.get(progTemplateRec.Program__c)) {
                proposal = proposalMap.get(proposalId);
                if(((proposal.Concept_Paper__c || proposal.Proposal__c) && progTemplateRec.Template_Type__c == 'Proposal Application'
                    && progTemplateRec.Solicitation__c == proposal.Grant_Solicitation__c)
                   || (!proposal.Concept_Paper__c && !proposal.Proposal__c && progTemplateRec.Template_Type__c == 'Application Intake')) {
                       // Create Wizard Template record and set its fields and then add it to proposalTemplateListToInsert list
                       Proposal_Template__c proposalTemplateRec = new Proposal_Template__c();
                       proposalTemplateRec.Description__c = progTemplateRec.Description__c;
                       proposalTemplateRec.Program__c = progTemplateRec.Program__c;
                       proposalTemplateRec.Proposal__c = proposalId;
                       proposalTemplateRec.Solicitation__c = progTemplateRec.Solicitation__c;
                       proposalTemplateRec.Status__c = progTemplateRec.Status__c;
                       proposalTemplateRec.Template_Type__c = progTemplateRec.Template_Type__c;
                       proposalTemplateListToInsert.add(proposalTemplateRec);
                       // Make sure wizard page is linked to right program template page
                       if(!programTemplateIdToProposalTemplateMap.containsKey(progTemplateRec.Id)) {
                           programTemplateIdToProposalTemplateMap.put(progTemplateRec.Id, new List<Proposal_Template__c>());
                       }
                       programTemplateIdToProposalTemplateMap.get(progTemplateRec.Id).add(proposalTemplateRec);
                       // EndOf: Make sure wizard page is linked to right program template page
                   }
            }
        }
        
        if(proposalTemplateListToInsert.size() > 0) {
            insert proposalTemplateListToInsert; // Insert Wizard Template records
            // Make sure wizard page is linked to right program template page
            for(Id progTemplateId : programTemplateIdToProposalTemplateMap.keySet()) {
                for(Proposal_Template__c objWizard : programTemplateIdToProposalTemplateMap.get(progTemplateId)) {
                    proposalTemplateIdToProgramTemplateId.put(objWizard.Id, progTemplateId);
                }
            }
            programTemplateIdToProposalTemplateMap.clear(); // Clear
        }
        
        List<Proposal_Template_Page__c > proposalTempPageList = new List<Proposal_Template_Page__c>();
        // Process program template records
        for(Program_Template__c progTemplateRec : programTemplateList) {
            // Process program template page records
            for(Program_Template_Page__c programTempPageRec : progTemplateRec.Program_Template_Pages__r) {
                for(Proposal_Template__c proposalTemplateRec : proposalTemplateListToInsert) {
                    
                    if(((proposal.Concept_Paper__c || proposal.Proposal__c) && progTemplateRec.Template_Type__c == 'Proposal Application' &&
                        progTemplateRec.Solicitation__c == proposalTemplateRec.Solicitation__c)
                       ||
                       (!proposal.Concept_Paper__c && !proposal.Proposal__c && progTemplateRec.Template_Type__c != 'Proposal Application' &&
                        proposalTemplateIdToProgramTemplateId.get(proposalTemplateRec.Id) == progTemplateRec.Id)
                      ) {
                          // Create Wizard Template page record and set its fields and then add it to proposalTempPageList list
                          Proposal_Template_Page__c proposalTempPageRec = new Proposal_Template_Page__c();
                          proposalTempPageRec.Page_Name__c = programTempPageRec.Page_Name__c;
                          proposalTempPageRec.Page_Type__c = programTempPageRec.Page_Type__c;
                          proposalTempPageRec.Proposal_Template__c  = proposalTemplateRec.Id;
                          proposalTempPageRec.Sequence__c = programTempPageRec.Sequence__c;
                          proposalTempPageRec.Name = programTempPageRec.Name;
                          proposalTempPageRec.Page_Description__c = programTempPageRec.Page_Description__c;
                          proposalTempPageRec.Status__c = 'Draft';
                          proposalTempPageList.add(proposalTempPageRec);
                      }
                }
            }
        }
        
        if(proposalTempPageList.size() > 0) {
            insert proposalTempPageList; // Insert Wizard Template page records
        }
    }
    
    public static void copyProgramContent(List<Proposal__c> newProposalList) {
        try{
            List<Id> grantsIdList = new List<Id>();
            // Iterate over project records and add them to grantsIdList list
            for(Proposal__c proposalRec : newProposalList) {
                grantsIdList.add(proposalRec.Grant_Solicitation__c);
            }
            
            // Fetch program content records from database
            List<Program_Content__c> programContentList = [select Id, Name, Document_Title__c, Mandatory_by_default__c, Grant_Solicitation__c, RecordType.DeveloperName,Validation_Error_Message__c,
                                                           Validation_Logic__c, Conditionally_Required__c, Type__c, Sub_Type__c, Document_Placement__c, Value__c, Picklist_Value__c, Explanation_Required_On__c,
                                                           CheckList_Name__c, Display_Label__c, Active__c, Sequence__c, Description__c, Concept_Paper__c,Upload_Document__c,Question_Type__c,Help_Text__c, Document_Group__c,
                                                           Hide_From_External_Reviewer__c, Is_Restricted__c ,Milestone_Amount_Percentage__c, Milestone_Due_Date__c, Name__c,Object_Name__c,Responsible_Party__c
                                                           from Program_Content__c
                                                           where Grant_Solicitation__c IN :grantsIdList];
            
            // Iterate over program content records and conditionally add them to different collection grantsIdToProgramContentsMap or existingProgContentList list
            Map<Id, List<Program_Content__c>> grantIdToProgramContentsMap = new Map<Id, List<Program_Content__c>>();
            for(Program_Content__c progContentRec : programContentList) {
                if(!grantIdToProgramContentsMap.containsKey(progContentRec.Grant_Solicitation__c)) {
                    grantIdToProgramContentsMap.put(progContentRec.Grant_Solicitation__c, new List<Program_Content__c>{progContentRec});
                } else {
                    List<Program_Content__c> existingProgContentList = grantIdToProgramContentsMap.get(progContentRec.Grant_Solicitation__c);
                    existingProgContentList.add(progContentRec);
                }
            }
            
            String documentRecTypeId = Utility_RecordType_Helper.getRecordType('Proposal_Content__c', 'Documents').Id;
            String RTEMRecTypeId = Utility_RecordType_Helper.getRecordType('Proposal_Content__c', 'Due_Diligence').Id;
            String proposalRecordTypeID = Utility_RecordType_Helper.getRecordType('Proposal_Content__c', 'Proposal').Id;
            String proposalMilestonesRecordTypeID = Utility_RecordType_Helper.getRecordType('Proposal_Content__c', 'Milestones').Id;
            String proposalDeliverablesRecordTypeID = Utility_RecordType_Helper.getRecordType('Proposal_Content__c', 'Deliverables').Id;
            String proposalTasksRecordTypeID = Utility_RecordType_Helper.getRecordType('Proposal_Content__c', 'Tasks').Id;
            
            // Iterate over project and  program content records and conditionally set program content record fields and them to proposalContentListToInsert list
            List<Proposal_Content__c> proposalContentListToInsert = new List<Proposal_Content__c>();
            for(Proposal__c projRec : newProposalList) {
                if(grantIdToProgramContentsMap.get(projRec.Grant_Solicitation__c) != null) {
                    for(Program_Content__c progContentRec : grantIdToProgramContentsMap.get(projRec.Grant_Solicitation__c)) {
                        Proposal_Content__c propContentRec = new Proposal_Content__c();
                        
                        if(progContentRec.RecordType.DeveloperName == 'Document' && progContentRec.Type__c == 'Project Application') {   
                           if((projRec.Concept_Paper__c && progContentRec.Concept_Paper__c)
                             || (projRec.Proposal__c && progContentRec.Upload_Document__c)
                             || (!projRec.Proposal__c && !projRec.Concept_Paper__c && !progContentRec.Concept_Paper__c)) {
                                 propContentRec.RecordTypeId = documentRecTypeId;
                                 propContentRec.Document_Title__c = progContentRec.Document_Title__c;
                                 propContentRec.Mandatory_by_default__c = progContentRec.Mandatory_by_default__c;
                                 propContentRec.Validation_Logic__c = progContentRec.Validation_Logic__c;
                                 propContentRec.Conditionally_Required__c = progContentRec.Conditionally_Required__c;
                                 propContentRec.Proposal__c = projRec.Id;
                                 propContentRec.Type__c = progContentRec.Type__c;
                                 propContentRec.Sub_Type__c = progContentRec.Sub_Type__c;
                                 propContentRec.Sequence__c = progContentRec.Sequence__c;
                                 propContentRec.Help_Text__c = progContentRec.Help_Text__c;
                                 propContentRec.Concept_Paper__c = progContentRec.Concept_Paper__c;
                                 propContentRec.Document_Placement__c = progContentRec.Document_Placement__c;
                                 propContentRec.Document_Group__c = progContentRec.Document_Group__c;
                                 propContentRec.Description__c = progContentRec.Description__c;
                                 propContentRec.Name__c = progContentRec.Object_Name__c;
                                 propContentRec.Hide_From_External_Reviewer__c = progContentRec.Hide_From_External_Reviewer__c;
                                 propContentRec.Configured_From_Solicitation__c = true; // just to distinguish, whether the program content is copied from project content or not.
                                 propContentRec.Is_Restricted__c = progContentRec.Is_Restricted__c;
                                 proposalContentListToInsert.add(propContentRec);
                          }
                        } else if(progContentRec.RecordType.DeveloperName == 'Due_Diligence') {
                            propContentRec.RecordTypeId = RTEMRecTypeId;
                            propContentRec.Proposal__c = projRec.Id;
                            propContentRec.Status__c = 'Assigned'; 
                            propContentRec.Active__c = progContentRec.Active__c;
							propContentRec.Name__c = progContentRec.Object_Name__c;   
                            propContentRec.Sequence__c = progContentRec.Sequence__c;
                            propContentRec.Responsible_Party__c = progContentRec.Responsible_Party__c;
                            proposalContentListToInsert.add(propContentRec);
                         } else if(progContentRec.RecordType.DeveloperName == 'Proposal') {
                             propContentRec.RecordTypeId = proposalRecordTypeID;
                             propContentRec.Display_Label__c = progContentRec.Display_Label__c;
                             propContentRec.Active__c = progContentRec.Active__c;
                             propContentRec.Type__c = progContentRec.Type__c;
                             propContentRec.Question_Type__c = progContentRec.Question_Type__c;
                             propContentRec.Proposal__c = projRec.Id;
                             propContentRec.Sequence__c = progContentRec.Sequence__c;
                             propContentRec.Help_Text__c = progContentRec.Help_Text__c;
                             propContentRec.Picklist_Value__c = progContentRec.Picklist_Value__c; // used in new construction T-03097
                             propContentRec.Explanation_Required_On__c = progContentRec.Explanation_Required_On__c;
                             propContentRec.Mandatory_by_Default__c = progContentRec.Mandatory_by_Default__c; // T-03212
                             propContentRec.Validation_Error_Message__c = progContentRec.Validation_Error_Message__c;
                             proposalContentListToInsert.add(propContentRec);
                         } else if(progContentRec.RecordType.DeveloperName == 'Milestones' || progContentRec.RecordType.DeveloperName == 'Deliverables') {
                             propContentRec.RecordTypeId = progContentRec.RecordType.DeveloperName == 'Milestones'?proposalMilestonesRecordTypeID:progContentRec.RecordType.DeveloperName == 'Deliverables'?proposalDeliverablesRecordTypeID:proposalTasksRecordTypeID;
                             propContentRec.Grant_Program_Content__c = progContentRec.Id;
                             propContentRec.Proposal__c = projRec.Id;
                             propContentRec.Milestone_Amount_Percentage__c =  progContentRec.Milestone_Amount_Percentage__c;
                            if (projRec.Awarded_Amount__c != null && progContentRec.Milestone_Amount_Percentage__c != null ) {
                                propContentRec.Cost_Per_Unit__c =  (progContentRec.Milestone_Amount_Percentage__c / 100) * projRec.Awarded_Amount__c ;      
                            }
                            else{
                                propContentRec.Cost_Per_Unit__c = 0;
                            }
                             propContentRec.Milestone_Due_Date__c =progContentRec.Milestone_Due_Date__c;
                             propContentRec.Status__c = 'In Progress';
                            // added
                             propContentRec.Name__c = progContentRec.Object_Name__c;
                             propContentRec.Description__c = progContentRec.Description__c;
                            
                             proposalContentListToInsert.add(propContentRec);
                         }
                         else if(progContentRec.RecordType.DeveloperName == 'Tasks'){
                            propContentRec.RecordTypeId = proposalTasksRecordTypeID;
                            propContentRec.Status__c = 'Unsubmitted';
                            propContentRec.Grant_Program_Content__c = progContentRec.Id;
                            propContentRec.Proposal__c = projRec.Id;
                            propContentRec.Milestone_Amount_Percentage__c =  progContentRec.Milestone_Amount_Percentage__c;
                            propContentRec.Milestone_Due_Date__c =progContentRec.Milestone_Due_Date__c;
                            propContentRec.Name__c = progContentRec.Name__c;
                           // added
                            propContentRec.Description__c = progContentRec.Description__c;
                           
                            proposalContentListToInsert.add(propContentRec);
                         }
                    }
                }
            }
            
            if(proposalContentListToInsert.size() > 0) {
                insert proposalContentListToInsert; // Insert project content records
            }
        } catch(DMLException e) {
            
        }
    }
    
    public static void createProposalRoleFromProgram(List<Proposal__c> newProposalList) {
        
        Set<Id> recordIds_createProposalRoleFromProgramIds = new Set<Id>();
        for(Proposal__c proposal : newProposalList){
            recordIds_createProposalRoleFromProgramIds.add(proposal.Id);
        }
        if(recordIds_createProposalRoleFromProgramIds.size() > 0){
            if(System.isFuture()){
                createProposalRole_ProjectCoordinator_FromProgram_NonFuture(recordIds_createProposalRoleFromProgramIds);
            }else{
                createProposalRole_ProjectCoordinator_FromProgram_future(recordIds_createProposalRoleFromProgramIds);
            }
        }
    }
    
    @future
    public static void createProposalRole_ProjectCoordinator_FromProgram_future(Set<Id> proposalIdsForProjectRoleIds){
        createProjectRole_ProjectCoordinator_FromProgram(proposalIdsForProjectRoleIds);
    }
    
    public static void createProposalRole_ProjectCoordinator_FromProgram_NonFuture(Set<Id> proposalIdsForProjectRoleIds){
        createProjectRole_ProjectCoordinator_FromProgram(proposalIdsForProjectRoleIds);
    }
    
    public static void createProjectRole_ProjectCoordinator_FromProgram(Set<Id> proposalIdsForProjectRoleIds) {
        
        List<Proposal__c> otherProjectList = new List<Proposal__c>();
        
        List<Proposal__c> newProjectList = [SELECT Grant_Solicitation__r.Default_Project_Coordinator__c,RecordTypeId,
                                           Grant_Solicitation__r.Default_Project_Coordinator__r.FirstName,
                                           Grant_Solicitation__r.Default_Project_Coordinator__r.LastName,
                                           Grant_Solicitation__r.Default_Project_Coordinator__r.CompanyName,
                                           Grant_Solicitation__r.Default_Project_Coordinator__r.Email,
                                           Grant_Solicitation__r.Default_Project_Coordinator__r.MobilePhone
                                           FROM Proposal__c WHERE Id IN :proposalIdsForProjectRoleIds];
        
        
        for(Proposal__c projectRec : newProjectList) {
        	otherProjectList.add(projectRec);
        }
        
        if(otherProjectList.size() > 0) {
            
            // Fetch project record from database and set proposalIdToProposalMap map (project id to project record map)
            Map<Id, Proposal__c> proposalIdToProposalMap = new Map<Id, Proposal__c>([select Grant_Solicitation__r.Default_Project_Coordinator__c,RecordTypeId,
                                                                                 Grant_Solicitation__r.Default_Project_Coordinator__r.FirstName,
                                                                                 Grant_Solicitation__r.Default_Project_Coordinator__r.LastName,
                                                                                 Grant_Solicitation__r.Default_Project_Coordinator__r.CompanyName,
                                                                                 Grant_Solicitation__r.Default_Project_Coordinator__r.Email,
                                                                                 Grant_Solicitation__r.Default_Project_Coordinator__r.MobilePhone
                                                                                 from Proposal__c where Id IN :otherProjectList]);
            List<Proposal_Role__c> proposalRoleList = new List<Proposal_Role__c>();
            
            // Process project records in otherProjectList, create project role record, set its fields and add it to proposalRoleList list
            for(Proposal__c proposalObj : otherProjectList){
                if(proposalIdToProposalMap.containsKey(proposalObj.Id) && proposalIdToProposalMap.get(proposalObj.Id).Grant_Solicitation__r.Default_Project_Coordinator__c != null){
                       Proposal_Role__c proposalRoleObj = new Proposal_Role__c();
                       proposalRoleObj.User__c = proposalIdToProposalMap.get(proposalObj.Id).Grant_Solicitation__r.Default_Project_Coordinator__c;
                       proposalRoleObj.FirstName__c = proposalIdToProposalMap.get(proposalObj.Id).Grant_Solicitation__r.Default_Project_Coordinator__r.FirstName;
                       proposalRoleObj.LastName__c = proposalIdToProposalMap.get(proposalObj.Id).Grant_Solicitation__r.Default_Project_Coordinator__r.Lastname;
                       proposalRoleObj.Phone__c = proposalIdToProposalMap.get(proposalObj.Id).Grant_Solicitation__r.Default_Project_Coordinator__r.MobilePhone;
                       proposalRoleObj.Email__c = proposalIdToProposalMap.get(proposalObj.Id).Grant_Solicitation__r.Default_Project_Coordinator__r.Email;
                       proposalRoleObj.Company_Name__c = proposalIdToProposalMap.get(proposalObj.Id).Grant_Solicitation__r.Default_Project_Coordinator__r.CompanyName;
                       proposalRoleObj.Role__c = 'NYSERDA Project Coordinator';
                       proposalRoleObj.Proposal__c = proposalObj.Id;
                       proposalRoleList.add(proposalRoleObj);
                   }
            }
            if(proposalRoleList.size() > 0){
                Database.insert(proposalRoleList,false); // Insert project role records in proposalRoleList list
            }
            
        }
    }
    
    public static void autoPopulateIntakeForm(List<Proposal__c> triggerNew){
        Set<Id> setOfGrantsId = new Set<Id>();
        Map<Id,Id> mapOfProposalToGrants = new Map<Id,Id>();
        for(Proposal__c objProposal: triggerNew) {
            setOfGrantsId.add(objProposal.Grant_Solicitation__c);
            mapOfProposalToGrants.put(objProposal.Id,objProposal.Grant_Solicitation__c);
        }
        //this method will update the intake form and url in future method becuase in after insert context we can't 
        //update the same record and in before insert the Id is not present which is used in intake url
        updateIntakeFormAsync(mapOfProposalToGrants,setOfGrantsId);
    }
    @future
    public static void updateIntakeFormAsync(Map<Id,Id> mapOfProposalToGrants,Set<Id> setOfGrantsId){
        Map<Id,Grant_Solicitation__c> mapOfGrants = new Map<Id,Grant_Solicitation__c>([Select Id,Intake_Form__c,Intake_Form_URL__c from Grant_Solicitation__c where Id=:setOfGrantsId]);
        List<Proposal__c> lstToUpdate = new List<Proposal__c>();
        for(Id idProposal: mapOfProposalToGrants.keySet()) {
            lstToUpdate.add(new Proposal__c(Id=idProposal,Intake_Form__c = mapOfGrants.get(mapOfProposalToGrants.get(idProposal)).Intake_Form__c,Intake_Form_URL__c = mapOfGrants.get(mapOfProposalToGrants.get(idProposal)).Intake_Form_URL__c + '&c__ProposalId='+idProposal));
        }
        update lstToUpdate;
    }

    public static void createBudgetForProposal(List<Proposal__c> triggerNew){
        Set<Id> setOfGrantId = new Set<Id>();
        for(Proposal__c proposal : triggerNew){
            setOfGrantId.add(proposal.Grant_Solicitation__c);
        }

        Map<Id, List<Grants_Budget_Template__c>> mapOfGrantIdToBudgetList = new Map<Id, List<Grants_Budget_Template__c>>();
        Set<Id> setOfBudgetTemplate = new Set<Id>();
        List<Grants_Budget_Template__c> budgetTemplateList = [SELECT ID, Grant_Solicitation__c, Budget_Template__c FROM Grants_Budget_Template__c WHERE Grant_Solicitation__c IN : setOfGrantId AND Status__c = 'Active'];
        if(budgetTemplateList==null || budgetTemplateList.isEmpty()) {
            return;
        }
        for(Grants_Budget_Template__c gbt : budgetTemplateList){
            setOfBudgetTemplate.add(gbt.Budget_Template__c);
            if(mapOfGrantIdToBudgetList.containsKey(gbt.Grant_Solicitation__c)){
                mapOfGrantIdToBudgetList.get(gbt.Grant_Solicitation__c).add(gbt);
            } else{
                mapOfGrantIdToBudgetList.put(gbt.Grant_Solicitation__c, new List<Grants_Budget_Template__c>{gbt});
            }
        }

        Map<Id, Budget_Template__c> mapOfBudgetTemplate = new Map<Id, Budget_Template__c>([SELECT ID,(SELECT ID,Name FROM Budget_Template_Categories__r) FROM Budget_Template__c WHERE ID IN :setOfBudgetTemplate]);
        List<Budget__c> budgetListToInsert = new List<Budget__c>();
        for(Proposal__c proposal : triggerNew){
            List<Grants_Budget_Template__c> grantsBudgetList = mapOfGrantIdToBudgetList.get(proposal.Grant_Solicitation__c);
            for(Grants_Budget_Template__c gbt : grantsBudgetList){
                List<Budget_Template_Category__c> budgetTemCateList = mapOfBudgetTemplate.get(gbt.Budget_Template__c).Budget_Template_Categories__r;
                for(Budget_Template_Category__c budgetCategory : budgetTemCateList){
                    Budget__c newBudget = new Budget__c();
                    newBudget.Proposal__c = proposal.Id;
                    newBudget.Status__c = 'Active';
                    newBudget.Name = budgetCategory.Name;
                    newBudget.Budget_Template__c = gbt.Budget_Template__c;
                    newBudget.Budget_Category__c = budgetCategory.Id;
                    budgetListToInsert.add(newBudget);
                }
            }
        }

        insert budgetListToInsert;

    }

    public static void sendEmailForReReview(List<Proposal__c> proposalList,Map<Id,Proposal__c> oldMap){
        Set<Id> proposalIdSet = oldMap.keySet();
        List<ScoreCard__c> scoreCardList = [SELECT ID,Assign_To_User__r.Email,Proposal__c,Assign_To_User__c FROM ScoreCard__c WHERE Proposal__c IN :proposalIdSet];
        Map<Id, List<String>> mapOfProposalToUserId = new Map<Id, List<String>>();
        for(ScoreCard__c sc : scoreCardList){
            if(mapOfProposalToUserId.containsKey(sc.Proposal__c)){
                mapOfProposalToUserId.get(sc.Proposal__c).add(sc.Assign_To_User__r.Email);
            } else{
                mapOfProposalToUserId.put(sc.Proposal__c, new List<String>{sc.Assign_To_User__r.Email});
            }
        }
        EmailTemplate template = [SELECT ID FROM EmailTemplate WHERE DeveloperName = 'Proposal_Re_Submitted_Email_For_Reviewer'];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage semail;
        for(Proposal__c proposal : proposalList){
            if(proposal.Status__c == 'Re-Submitted' && oldMap.get(proposal.Id).Status__c == 'Assign Back To Grantee' && mapOfProposalToUserId.containsKey(proposal.Id)){
                // for(String userId : mapOfProposalToUserId.get(proposal.Id)){
                    semail = new Messaging.SingleEmailMessage();
                    semail.setToAddresses(mapOfProposalToUserId.get(proposal.Id));
                    semail.setTemplateID(template.Id);
                    semail.setUseSignature(false);
                    semail.setBccSender(false);
                    semail.setSaveAsActivity(false);
                    semail.setTreatTargetObjectAsRecipient(false);
                    semail.setTargetObjectId(proposal.Applying_Contact__c);
                    semail.setWhatId(proposal.Id);
                    emailList.add(semail);
                    if(emailList.size()==10){
                        Messaging.sendEmail(emailList);
                        emailList = new List<Messaging.SingleEmailMessage>();
                    }
                // }
            }
        }
        if(emailList.size()>0){
            System.debug('Test ----' + JSON.serialize(emailList));
            try{
                Messaging.sendEmail(emailList);
            }
            catch(Exception e){
                System.debug(e.getMessage());
            }
        }
    }
}