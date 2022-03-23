import { LightningElement, api, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord } from "lightning/uiRecordApi";
import {showMessage, refreshPage} from 'c/grants_Utility';
import createDisbursementRec from '@salesforce/apex/Grants_DisbursementsController.createDisbursementRec';
import CON_FIELD from '@salesforce/schema/Proposal__c.Applying_Contact__r.Name';
import PAID_DISB_FIELD from '@salesforce/schema/Proposal__c.Paid_Disbursements__c';
import AWARDED_AMT_FIELD from '@salesforce/schema/Proposal__c.Awarded_Amount__c';
import AVAIL_DISB_FIELD from '@salesforce/schema/Proposal__c.Available_for_Disbursement__c';

import grantstheme from '@salesforce/resourceUrl/Grants_Design'; 
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';  

const   fields = [CON_FIELD, PAID_DISB_FIELD, AWARDED_AMT_FIELD, AVAIL_DISB_FIELD];
 
export default class Grants_CreateDisbursements extends LightningElement {
    @api recordId;
    @track disbursementsArr = [];
    fundsNotAvailable = false;
    contactName;
    paidDisbursements;
    awardedAmt;
    availForDisbursement;

    connectedCallback(){
        loadStyle(this, grantstheme + '/styles/main.css');
    }  

    
    columns = [
        { label: 'Amount', fieldName: 'Amount__c', type: 'currency', editable: true, cellAttributes: { alignment: 'left' } },
        { label: 'Scheduled Date', fieldName: 'Scheduled_Date__c', type: 'date-local', editable: true,
           typeAttributes: { year: 'numeric', month: 'numeric', day: 'numeric'}
        }
    ];

    inputData = {
        "DisbursementsCnt" : 1,
        "Interval" : 1,
        "Period" : "Month"
    };

    @wire(getRecord, {recordId: "$recordId", fields})
    proposalRec({error, data}){
        if(error){  
            showMessage(this,'Error occured while fetching proposal details', error.message.body, 'error', 'pester');
        }else if(data){
            this.contactName = data.fields.Applying_Contact__r.displayValue;
            this.paidDisbursements = data.fields.Paid_Disbursements__c.displayValue;
            this.awardedAmt = data.fields.Awarded_Amount__c.displayValue;
            this.availForDisbursement = data.fields.Available_for_Disbursement__c.displayValue;
            this.inputData.TotalDisbursementAmount = data.fields.Available_for_Disbursement__c.value;
            this.fundsNotAvailable = data.fields.Available_for_Disbursement__c.value <= 0 ? true : false;
        }
    }
    

    handleInput(event){
        let valToStore;
        if(event.target.name == 'DisbursementsCnt' || event.target.name == 'Interval'){
            valToStore = parseInt(event.target.value);
        }else if(event.target.name == 'TotalDisbursementAmount'){
            valToStore = parseFloat(event.target.value).toFixed(2);
        }else{
            valToStore = event.target.value;
        }
        this.inputData[event.target.name] = valToStore;
    }

    calculateDisbursements(){
        this.disbursementsArr = [];
        let installmentAmount;
        let interimDisbDate = this.inputData.FirstDate;
        if(this.inputData.DisbursementsCnt == 1){
            installmentAmount = this.inputData.TotalDisbursementAmount;
            this.disbursementsArr.push({
                "Amount__c":installmentAmount,
                "Scheduled_Date__c":interimDisbDate,
                "idx":this.recordId+'-'+0,
                "Proposal__c":this.recordId
            });
        }else{
            installmentAmount = (this.inputData.TotalDisbursementAmount / this.inputData.DisbursementsCnt).toFixed(2);
            this.disbursementsArr.push({
                "Amount__c":installmentAmount,
                "Scheduled_Date__c":interimDisbDate,
                "idx":this.recordId+'-'+0,
                "Proposal__c":this.recordId
            });
            if(this.inputData.Period == 'Week'){
                this.calculateWeeklyDisbursements(installmentAmount);
            }else if(this.inputData.Period == 'Month'){
                this.calculateMonthlyDisbursements(installmentAmount);
            }else if(this.inputData.Period == 'Year'){
                this.calculateYearlyDisbursements(installmentAmount);
            }
        }
    }

    calculateWeeklyDisbursements(installmentAmount){
        let interimDisbDate = new Date(this.inputData.FirstDate);
       
        for(let cnt = 1; cnt < this.inputData.DisbursementsCnt; cnt++){
            interimDisbDate.setDate(interimDisbDate.getDate() + (parseInt(this.inputData.Interval) * 7));
            
            if(cnt + 1 == this.inputData.DisbursementsCnt){
                installmentAmount = this.inputData.TotalDisbursementAmount - (installmentAmount * cnt).toFixed(2);
            }
            
            this.disbursementsArr.push({
                "Amount__c":installmentAmount,
                "Scheduled_Date__c":new Date(interimDisbDate).toISOString().split('T')[0],
                "idx":this.recordId+'-'+cnt,
                "Proposal__c":this.recordId
            });
        }
    }

    calculateMonthlyDisbursements(installmentAmount){
        let interimDisbDate = new Date(this.inputData.FirstDate);

        for(let cnt = 1; cnt < this.inputData.DisbursementsCnt; cnt++){
            interimDisbDate.setMonth(interimDisbDate.getMonth() + parseInt(this.inputData.Interval));
            
            if(cnt + 1 == this.inputData.DisbursementsCnt){
                installmentAmount = this.inputData.TotalDisbursementAmount - (installmentAmount * cnt).toFixed(2);
            }
            
            this.disbursementsArr.push({
                "Amount__c":installmentAmount,
                "Scheduled_Date__c":new Date(interimDisbDate).toISOString().split('T')[0],
                "idx":this.recordId+'-'+cnt,
                "Proposal__c":this.recordId
            });
        }
    }

    calculateYearlyDisbursements(installmentAmount){
        let interimDisbDate = new Date(this.inputData.FirstDate);

        for(let cnt = 1; cnt < parseInt(this.inputData.DisbursementsCnt); cnt++){
            interimDisbDate.setFullYear(interimDisbDate.getFullYear() + parseInt(this.inputData.Interval));
            
            if(cnt + 1 == this.inputData.DisbursementsCnt){
                installmentAmount = this.inputData.TotalDisbursementAmount - (installmentAmount * cnt).toFixed(2);
            }
            
            this.disbursementsArr.push({
                "Amount__c":installmentAmount,
                "Scheduled_Date__c":new Date(interimDisbDate).toISOString().split('T')[0],
                "idx":this.recordId+'-'+cnt,
                "Proposal__c":this.recordId
            });
        }
    }

    createDisbursements(event){
        let editedVals = this.template.querySelector("lightning-datatable").draftValues;
        if(editedVals.length > 0){
            for(let cnt = 0; cnt < editedVals.length; cnt++){
                let obj = editedVals[cnt];
                let reqIndex = parseInt(obj.idx.split('-')[1]);
                let editedValKeys = Object.keys(obj);
                for(let keysCnt = 0; keysCnt < editedValKeys.length; keysCnt++){
                    if(editedValKeys[keysCnt] != 'idx'){
                        this.disbursementsArr[reqIndex][editedValKeys[keysCnt]] = obj[editedValKeys[keysCnt]];
                    }
                }
            }
        }

        createDisbursementRec({disbursementRecLst : this.disbursementsArr}).then(() => {
            showMessage(this,'Disbursements created successfully', '', 'success', 'pester');
            this.closeModal();
            refreshPage();
        }).catch((error) => {
            showMessage(this,'Error occured while creating disbursements', error.message.body, 'error', 'pester');
        })
    }

    closeModal(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    get disbursementValue(){
        return this.inputData.DisbursementsCnt != null ? this.inputData.DisbursementsCnt : '';
    }

    get firstDate(){
        let firstDateStr = new Date().toISOString().split('T')[0];
        this.inputData.FirstDate = firstDateStr;
        return firstDateStr;
    }

    get intervalValue(){
        return this.inputData.Interval != null ? this.inputData.Interval : '';
    }

    get options(){
        return [
            { label: 'Week', value: 'Week' },
            { label: 'Month', value: 'Month' },
            { label: 'Year', value: 'Year' },
        ];
    }

    get periodValue(){
        return this.inputData.Period != null ? this.inputData.Period : '';
    }

    get amount(){
        return (this.inputData.hasOwnProperty('TotalDisbursementAmount')) ? this.inputData.TotalDisbursementAmount : '';
    } 

    get disbursementsRecordsAvailable(){
        return this.disbursementsArr.length > 0 ? true : false;
    }
}