@isTest
public class Grants_DashboardControllerTest {
    
    static void testSetup(){
        Program__c newProgram = new Program__c();
        insert newProgram;

        Grant_Solicitation__c solicitation = new Grant_Solicitation__c();
        solicitation.Program__c = newProgram.Id;
        insert solicitation;


    }

}