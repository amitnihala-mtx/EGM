import { LightningElement, track,wire } from 'lwc';
import desetheme from '@salesforce/resourceUrl/DESE_Design';
import isGuestU from '@salesforce/user/isGuest';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import { NavigationMixin } from 'lightning/navigation';
import basePath from "@salesforce/community/basePath";
export default class Grants_header extends NavigationMixin(LightningElement) {
   isGuestUser = isGuestU;
   name;
   @track headerlogo = desetheme + '/theme/images/logo.jpg';
   @track avatar    = desetheme + '/theme/images/Avatar.png';
   @track vector    = desetheme + '/theme/images/Vector.png';
   @track warning   = desetheme + '/theme/images/warning.png';
   @track dropdown  = desetheme + '/theme/images/dropdown.png';
   @track translate = desetheme + '/theme/images/translate.png';
   @track newlogo = desetheme + '/theme/images/newLogo.png';
   @wire(getRecord, {
         recordId: USER_ID,
         fields: [NAME_FIELD]
   }) wireuser({
         error,
         data
   }) {
         if (error) {
         } else if (data) {
            this.name = data.fields.Name.value;
         }
   }
   newDate = new Date();

   value = 'English';

    get options() {
        return [
            { label: 'English', value: 'English' },
            { label: 'Hindi', value: 'Hindi' },
            { label: 'Tamil', value: 'Tamil' },
            { label: 'Telugu', value: 'Telugu' },
            { label: 'Spanish', value: 'Spanish' },
            { label: 'French', value: 'French' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

      navigateToHome() {
            // this[NavigationMixin.Navigate]({
            //       type: 'standard__webPage',
            //       attributes: {
            //             url: '/dese/s/grants-dashboard'
            //       },
            // });
            window.open('/s','_self');
      }

      
      handleLogin(){
            window.open('/s/login','_self');
      }
      handleRegister(){
            window.open('/s/login/SelfRegister','_self');
      }

      handleLogout(){
            
            const sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the site base path without the trailing "/s"
            window.open(sitePrefix + "/secur/logout.jsp",'_self');
              
      }

      handleMyProfile(){
            window.open('/s/my-profile','_self');
      }

      openApplication(){
            //window.open("/dese/s/grant-application?projectId=a3i030000008QfoAAE", "_self");
      }

      handleSubmitReport(){
            //window.open('https://desedemo-demo-lp.cs196.force.com/dese/s/final-report?projectId=a4c03000000V070AAC','_self');
      }

      navigateToSupport() {
            //window.open('/dese/s/psrtechnicalsupportpage','_self');
      }
}