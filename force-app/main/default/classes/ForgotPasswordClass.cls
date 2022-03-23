global with sharing class ForgotPasswordClass implements vlocity_ins.VlocityOpenInterface {    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        Boolean result = false;
        try {
            if (methodName.equals('getForgetPasswordDetails')) {
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
    public void getForgotPasswordDetails(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options){
        Map <String,object> forgetStepInfo = (Map <String,object> )inputMap.get('forgetStep');
        String userId = (String)forgetStepInfo.get('userId'); 
        system.debug(userId);
        Site.forgotPassword(userId);
        }
}