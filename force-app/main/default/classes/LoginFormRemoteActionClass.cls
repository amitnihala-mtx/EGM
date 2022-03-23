/*
# Created By : Mounika Thamarana
# Description : This apex class is used to get login details and forget Password details.
This class is used in RemoteActionLoginPage remote action of grants/loginPage omniscript as remote action
and used in RemoteAction1ForgetPassword remote action of grants/forgetPage omniscript.
*/
global without sharing class LoginFormRemoteActionClass implements vlocity_ins.VlocityOpenInterface {    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        Boolean result = false;
        try {
            if (methodName.equals('getLoginPageDetails')) {
                return getLoginDetails(inputMap, outMap, options );
            }
            else if (methodName.equals('getForgetPasswordDetails')) {
                getForgotPasswordDetails(inputMap, outMap, options );
            } 
            else {
                result = false;
            }
        } catch (Exception e) {
            result = false;
        }
        return result;
    } 
    
    public boolean getLoginDetails(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options){
        Map <String,object> loginStepInfo = (Map <String,object> )inputMap.get('login');
        String userName = (String)loginStepInfo.get('username'); 
        String userPassword = (String)loginStepInfo.get('password');
        //outMap.put('returnurl',Site.login(username,userPassword,null).getUrl());

        try{
            outMap.put('returnurl',Site.login(username, userPassword,null).getUrl());
            //system.debug('RETURN URL'+outMap.get('returnurl'));
            outMap.put('loginError',false);
            return true;
        }
        Catch(Exception e){
            outMap.put('loginError',true);
            return false;
        }
    }
    
    public void getForgotPasswordDetails(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options){
        Map <String,object> forgetStepInfo = (Map <String,object> )inputMap.get('forgetStep');
        String userId = (String)forgetStepInfo.get('userId'); 
        Site.forgotPassword(userId);
    }
}