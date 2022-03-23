import { LightningElement, track, api } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import grantstheme from '@salesforce/resourceUrl/Grants_Design'; 
import NAME_FIELD from '@salesforce/schema/Amendment__c.Name';
import TYPE_FIELD from '@salesforce/schema/Amendment__c.Amendment_Type__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Amendment__c.Description__c';
import AMENDMENT_OBJECT from '@salesforce/schema/Amendment__c';

export default class Grants_amendments_form extends LightningElement {
    @api recordId;
    
    Amendment_obj = AMENDMENT_OBJECT;
    fields = {
        name : NAME_FIELD,
        type : TYPE_FIELD,
        description : DESCRIPTION_FIELD
    }

     //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
     @track isModalOpen = false;
     openModal() {
         // to open modal set isModalOpen tarck value as true
         this.isModalOpen = true;
     }
     closeModal() {
         // to close modal set isModalOpen tarck value as false
         this.isModalOpen = false;
     }
     submitDetails(event) {
        event.preventDefault(); // stop the form from submitting
        let fieldList = event.detail.fields;
        fieldList.Proposal__c = this.recordId; // modify a field
        this.template.querySelector('lightning-record-edit-form').submit(fieldList);
        this.isModalOpen = false;
     }

    connectedCallback(){
        loadStyle(this, grantstheme + '/styles/main.css');
    }


    handleSuccess(event) {
        console.log('onsuccess event recordEditForm',event.detail.id)
    }
    handleSubmit(event) {
        console.log('onsubmit event recordEditForm'+ event.detail.fields);
    }
}