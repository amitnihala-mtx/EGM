@isTest
public class Grants_ProposalControllerTest {
    
    @isTest
    public static void testSubmitFinalReport() {
        
        Grants_ProposalController.FinalReportWrapper  frw = new Grants_ProposalController.FinalReportWrapper();
        frw.approvedBudgetOther = 2300;
        frw.approvedBudgetPC =  2300;
        frw.approvedBudgetStipend = 2300;
        frw.approvedBudgetSupervisor = 2300;
        frw.balanceUnexpendedOther = 2300;
        frw.balanceUnexpendedPC = 2300;
     	frw.balanceUnexpendedStipend = 2300;
        frw.balanceUnexpendedSupervisor = 2300;
        frw.fundsExpendedOther = 2300;
        frw.fundsExpendedPC = 2300;
        frw.fundsExpendedStipend = 2300;
        frw.fundsExpendedSupervisor = 2300;
        frw.checkEnclosedAmount = 2300;
        frw.userEmail = 'testnotapply321456543@gmail.com';
        frw.userName = 'testnotapply3';
        frw.userTitle = 'supervisor';
        frw.status = 'Submitted';
        String str = JSON.serialize(frw); 
        System.assertEquals('Successfull Submission',
                            Grants_ProposalController.submitFinalReport(str),
                            'Expected Output Does not match with Actual Output');     
    }

}