global class grants_BudgetController implements vlocity_ins.VlocityOpenInterface {

    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        
        if(methodName == 'getBudgetDetail'){
            String data = getBudgets((String)inputMap.get('proposal'));
            outMap.put('budgetInfo', data);
        }
        if(methodName == 'upsertLineItem'){
            upsertLineItem((String)options.get('lineitem'));
        }
        return true;
    }

    @AuraEnabled
    public static void upsertLineItem(String budgetLineItem){
        upsert (Budget_Line_Item__c)JSON.deserialize(budgetLineItem, Budget_Line_Item__c.class);
    }

    @AuraEnabled
    public static String getBudgets(Id recordId){
        try {
            Proposal__c proposal = [SELECT ID,Status__c FROM Proposal__c WHERE Id=:recordId];
            List<Budget__c> budgetList = [SELECT Id, Name, Total_Grant_Funded__c, Total_Match_Funds__c, Budget_Template__c,
                                    Total_Match_calculated__c, Total_Match_Required__c, Total_Other_Funds__c, Total_Budgeted__c,
                                    (SELECT Id, Name, Grant_Funded__c, Match_Funds__c, Match_Percent_Calculated__c, 
                                    Match_Percent_Required__c, Other_Funds__c, Total_Budget__c FROM Budget_Line_Items__r ORDER BY Name) FROM Budget__c
                                    WHERE Proposal__c = :recordId];
            Map<Id, List<Budget__c>> mapOfBudgetTemplateIdToBudgetList = new Map<Id,List<Budget__c>>();
            for(Budget__c budget : budgetList){
                if(mapOfBudgetTemplateIdToBudgetList.containsKey(budget.Budget_Template__c)){
                    List<Budget__c> budgetL = mapOfBudgetTemplateIdToBudgetList.get(budget.Budget_Template__c);
                    budgetL.add(budget);
                    mapOfBudgetTemplateIdToBudgetList.put(budget.Budget_Template__c , budgetL);
                } else{
                    mapOfBudgetTemplateIdToBudgetList.put(budget.Budget_Template__c, new List<Budget__c>{budget});
                }
            }
            Map<Id, Budget_Template__c> mapOfBudgetTemplate = new Map<Id, Budget_Template__c>([SELECT ID,Budget_Template_Type__c FROM Budget_Template__c WHERE ID IN :mapOfBudgetTemplateIdToBudgetList.keySet()]);
            Map<Budget_Template__c, List<Budget__c>> mapOfBudgetTemplateToBudgetList = new Map<Budget_Template__c, List<Budget__c>>();
            for(Budget_Template__c budgetTemplate : mapOfBudgetTemplate.values()){
                mapOfBudgetTemplateToBudgetList.put(budgetTemplate, mapOfBudgetTemplateIdToBudgetList.get(budgetTemplate.Id));
            }

            List<BudgetWrapper> budgetWrapperList = new List<BudgetWrapper>();
            for(Budget_Template__c template : mapOfBudgetTemplateToBudgetList.keyset()){
                BudgetWrapper wrapper = new BudgetWrapper();
                wrapper.templateName = template.Budget_Template_Type__c;
                wrapper.templateId = template.Id;
                wrapper.budgetList = mapOfBudgetTemplateIdToBudgetList.get(template.Id);
                wrapper.isActionAvailable = (proposal.Status__c == 'Draft' || proposal.Status__c == 'Assign Back To Grantee') ? true : false;
                budgetWrapperList.add(wrapper);
            }

            return JSON.serialize(budgetWrapperList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public class BudgetWrapper{
        @AuraEnabled public String templateName;
        @AuraEnabled public String templateId;
        @AuraEnabled public Boolean isActionAvailable;
        @AuraEnabled public List<Budget__c> budgetList;
    }
}