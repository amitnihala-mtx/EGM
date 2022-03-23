@isTest
public class LoginFormRemoteActionClassTest {
    public static testmethod void invokeMethod(){
        LoginFormRemoteActionClass classObj = new LoginFormRemoteActionClass();      
        Map<String,Object> inputMap = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();
        Map<String,Object> options = new  Map<String,Object>();
        classObj.invokeMethod('getLoginPageDetails',inputMap,outMap,options);
        classObj.invokeMethod('getForgetPasswordDetails',inputMap,outMap,options);
        classObj.invokeMethod('',inputMap,outMap,options);
        
    }
    public static testmethod void testgetLoginDetails(){
        Map<String, Object> m1 = new Map<String, Object>();
        Map<String, Object> m2 = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> inputMap1 = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        LoginFormRemoteActionClass classObj = new LoginFormRemoteActionClass();
        m1.put('username','Test@gmail.com');
        m1.put('password','TestPassword');
        inputMap.put('login', m1) ;
        m2.put('username','mounika.thamarana@mtxb2b.com.egm');
        m2.put('password','Mouni@123');
        inputMap1.put('login', m2) ;
        classObj.getLoginDetails(inputMap,outputMap,options);
        classObj.getLoginDetails(inputMap1,outputMap,options);
        
    }
    static testmethod void testgetForgotPasswordDetails(){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> m1 = new Map<String, Object>();
        LoginFormRemoteActionClass classObj = new LoginFormRemoteActionClass();
        m1.put('userId','527764');
        inputMap.put('forgetStep', m1) ;
        classObj.getForgotPasswordDetails(inputMap,outputMap,options);
    }
}