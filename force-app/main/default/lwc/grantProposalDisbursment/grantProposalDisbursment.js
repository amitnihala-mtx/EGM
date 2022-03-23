import { LightningElement, wire,api,track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from 'lightning/uiRecordApi';
import Disbursements  from '@salesforce/apex/RetrieveDisbursementRecordOfProposal.Disbursements';
import Disbursement__c_OBJECT from '@salesforce/schema/Disbursement__c';
import RecertificationByLegalName from '@salesforce/schema/Disbursement__c.Recertification_By_Legal_Name__c';
import RecertificationDate from '@salesforce/schema/Disbursement__c.Recertification_Date__c';
import DisbursementStatus from '@salesforce/schema/Disbursement__c.Status__c';
import { CurrentPageReference } from 'lightning/navigation';

import grantstheme from '@salesforce/resourceUrl/Grants_Design';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

const columnsDisbursement = [
   
    { label: 'NAME ', fieldName: 'Name',hideDefaultactions:true },
    { label: 'STATUS', fieldName: 'Status__c',hideDefaultactions:true },
    { label: 'SCHEDULEDDATE', fieldName: 'Scheduled_Date__c',hideDefaultactions:true,type:"Date" },
    { label: 'AMOUNT', fieldName: 'Amount__c',hideDefaultactions:true ,type:"currency"},
{type:"button",typeAttributes:{
    label:'Recertification',
    name:'Monthly Recertification',
    title:'Monthly Recertification',
disabled:{fieldName:'NotEligibleforRecertification__c'},
iconPosition: 'left' }}

];
export default class GrantProposalDisbursment extends LightningElement {


    connectedCallback() {
        loadStyle(this, grantstheme + '/styles/main.css');
        
    }
    
    columnsDisbursement=columnsDisbursement;
    @api recordId;
    @track disbursementrecords;
    @track record = {};
    accordianSection = '';
    isModalOpen = false;
    Disbursementobject=Disbursement__c_OBJECT;
    field1=RecertificationByLegalName;
    field2=RecertificationDate;
    field3=DisbursementStatus;
    @wire(Disbursements,{recordId:'$recordId'})
    wiredisbursements({ error, data }) {
        
       if (data) {
          this.disbursementrecords = data;
          console.log('datadata',data);
          /*var response = JSON.parse(JSON.stringify(data));
          if(response.data){
              for(var i=0;i<response.data.length;i++){
                  var obj=response.data[i];
                  if(obj.isEligibleforRecertification__c == 'true'){
                      var rowActions=[];
                      rowActions.push({"label":"Monthly Recertification"});
                  }
              }
          }*/

          
        } else if (error) {
            this.error = error;
        }
    }

    @wire(CurrentPageReference)
    getDetailsFromURL(currentPageReference) {
        if (currentPageReference && currentPageReference.state.proposalId) {
            console.log(
                "Applicant Id: ",
                currentPageReference.state.proposalId
            );
            this.recordId = currentPageReference.state.proposalId;
        }
    }

    handleToggleSection(event) {
          if(this.accordianSection.length === 0){
            this.accordianSection =''
        }

    }
    Monthlyrecertification(event){
        const row = event.detail.row;
        this.record = row;

        this.isModalOpen=true;


    }
    handleSubmit(event){
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        fields.Status__c = 'Scheduled';
        //fields.NotEligibleforRecertification__c='true';
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    handleSuccess(){

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Record Updated',
                variant: 'success',
            }),
        );
        const passEventr = new CustomEvent('dismisspopup')
           this.dispatchEvent(passEventr); 
           this.closeModal();
         }   
  
         closeModal() {
          
            this.isModalOpen = false;

        }

}