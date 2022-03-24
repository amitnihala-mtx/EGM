import { LightningElement, api, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createDelegatedAdmin from '@salesforce/apex/GrantsEnableOrganizationController.createDelegatedAdminForOrganization';
import grantstheme from '@salesforce/resourceUrl/Grants_Design'; 
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';  
const fields = [
    'Account.Name',
    'Account.IsNewOrganization__c'
];
export default class Grants_EnableOrganization extends LightningElement {
    @api recordId;
    showConfrimation=false;

    @wire(getRecord, { recordId: '$recordId', fields })
    accountRec({error, data}){
        if(error){  
            this.showNotification('Error occured while fetching account details',error.message.body,'error');
        }else if(data){
            if(data.fields.IsNewOrganization__c.value==true){
                this.showConfrimation=true;
            } else {
                this.showNotification('Error!','This organization is approved already','error');
                this.closeModal();
            }
        }
    }

    connectedCallback(){
        loadStyle(this, grantstheme + '/styles/main.css');
    } 
    handleConfirm(){
        createDelegatedAdmin({recordId:this.recordId}).then(data=>{
            if(data.startsWith("Error")){
                this.showNotification('Error!',data,'error');
            } else {
                this.showNotification('Success!',data,'success');
            }
            this.closeModal();
        }).catch(error=>{
            console.log(JSON.stringify(error));
            this.closeModal();
        })
        
    }
    closeModal(){
        eval("$A.get('e.force:refreshView').fire();");
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    showNotification(title,message,variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}