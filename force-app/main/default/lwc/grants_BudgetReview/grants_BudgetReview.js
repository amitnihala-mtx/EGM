import { LightningElement, api, track } from 'lwc';
import getBudgetDetail from '@salesforce/apex/grants_BudgetController.getBudgets';
import upsertLineItem from '@salesforce/apex/grants_BudgetController.upsertLineItem';
import {showMessage} from 'c/grants_Utility';

import grantstheme from '@salesforce/resourceUrl/Grants_Design'; 
import { loadStyle, loadScript } from 'lightning/platformResourceLoader'; 

export default class Grants_BudgetReview extends LightningElement {
    @api recordId;
    @track budgetDetails = [];
    budgetDetailsCpy = [];
    @track isLoaded = false;
    @track newBudgetDetails = [];
    @track totalGrantFunded = 0;
    @track totalMatchFunds = 0;
    @track totalMatchPercent = 0;
    @track totalMatchPercentRequired = 0;
    @track totalOtherFunds = 0;
    @track totalBudgeted = 0;

    connectedCallback(){
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const product = urlParams.get('recordId')
        this.recordId = product;
        this.getBudgetDeatils();
        loadStyle(this, grantstheme + '/styles/main.css');
    }

    getBudgetDeatils(){
        getBudgetDetail({
            recordId : this.recordId
        })
        .then(data=>{
            console.log(JSON.parse(data));
            let tempData = JSON.parse(data);
            tempData.forEach(row=>{
                row.totalGrantFunded = 0;
                row.totalMatchFunds = 0;
                row.totalMatchPercent = 0;
                row.totalMatchPercentRequired=0;
                row.totalOtherFunds = 0;
                row.totalBudgeted = 0;
                row.budgetList.forEach(row1=>{
                    if(!row1.Budget_Line_Items__r){
                        row1.Budget_Line_Items__r = {records:[]};
                    }
                    row.totalGrantFunded = row1.Total_Grant_Funded__c + row.totalGrantFunded;
                    row.totalMatchFunds = row.totalMatchFunds + row1.Total_Match_Funds__c;
                    row.totalMatchPercent = row.totalMatchPercent + row1.Total_Match_calculated__c;
                    row.totalMatchPercentRequired = row.totalMatchPercentRequired + row1.Total_Match_Required__c;
                    row.totalOtherFunds = row.totalOtherFunds + row1.Total_Other_Funds__c;
                    row.totalBudgeted = row.totalBudgeted + row1.Total_Budgeted__c;
                })
            })
            this.newBudgetDetails = tempData;
            console.log('tempData :>> ', data);
        })
        .catch(error=>{
            console.log(error);
        })
    }

    addBudgetLineItem(event){
        let budgetRecIndex = parseInt(event.target.dataset.budgetIndex);
        let templateRecIndex = parseInt(event.target.dataset.templateIndex);
        let budgetId = event.target.dataset.budgetId;
        let obj = {
            'Name' : '',
            'Grant_Funded__c':0,
            'Match_Funds__c':0,
            'Match_Percent_Calculated__c':0,
            'Match_Percent_Required__c':0,
            'Other_Funds__c': 0,
            'Total_Budget__c':0,
            'Budget__c':budgetId,
            'editMode': true,
            'showCancel' : true
        }
        let lineItemsArr = this.newBudgetDetails[templateRecIndex]['budgetList'][budgetRecIndex]['Budget_Line_Items__r']['records'];
        lineItemsArr.push(obj);
        this.newBudgetDetails[templateRecIndex]['budgetList'][budgetRecIndex]['Budget_Line_Items__r']['records'] = lineItemsArr;
    }

    handleInput(event){
        let budgetRecIndex = parseInt(event.target.dataset.budgetIndex);
        let templateRecIndex = parseInt(event.target.dataset.templateIndex);
        let lineItemIndex = parseInt(event.target.dataset.lineItemIndex);
        let objAttr = event.target.dataset.fieldApiName;
        this.newBudgetDetails[templateRecIndex]['budgetList'][budgetRecIndex]['Budget_Line_Items__r']['records'][lineItemIndex][objAttr] = event.target.value;
    }

    upsertBudgetLineItem(event){
        let budgetRecIndex = parseInt(event.target.dataset.budgetIndex);
        let templateRecIndex = parseInt(event.target.dataset.templateIndex);
        let lineItemIndex = parseInt(event.target.dataset.lineItemIndex);
        let lineItemToUpsert = this.newBudgetDetails[templateRecIndex]['budgetList'][budgetRecIndex]['Budget_Line_Items__r']['records'][lineItemIndex];
        console.log('Upsert :>> ', this.newBudgetDetails);
        upsertLineItem({budgetLineItem : JSON.stringify(lineItemToUpsert)}).then(() => {
            // this.newBudgetDetails[templateRecIndex]['budgetList'][budgetRecIndex]['Budget_Line_Items__r']['records'][lineItemIndex]['editMode'] = false;
            // let totalBudget = (parseFloat(lineItemToUpsert.Grant_Funded__c) + parseFloat(lineItemToUpsert.Match_Funds__c) + parseFloat(lineItemToUpsert.Other_Funds__c)).toFixed(2);
            // this.newBudgetDetails[templateRecIndex]['budgetList'][budgetRecIndex]['Budget_Line_Items__r']['records'][lineItemIndex]['Total_Budget__c'] = totalBudget;
            this.getBudgetDeatils();
            showMessage(this,'Data Saved Successfully.', '', 'success', 'pester');
        }).catch((error) => {
            showMessage(this,'Error occured while Saving.', error.body.message, 'error', 'pester');
        });
    }

    editBudgetLineItems(event){
        let budgetRecIndex = parseInt(event.target.dataset.budgetIndex);
        let templateRecIndex = parseInt(event.target.dataset.templateIndex);
        this.newBudgetDetails[templateRecIndex]['budgetList'][budgetRecIndex]['Budget_Line_Items__r']['records'].forEach(function(item){
            item['editMode'] = true;
            item['showCancel'] = true;
        });
    }

    handleCancel(event){
        let budgetRecIndex = parseInt(event.target.dataset.budgetIndex);
        let templateRecIndex = parseInt(event.target.dataset.templateIndex);
        let lineItemIndex = parseInt(event.target.dataset.lineItemIndex);
        let obj = this.newBudgetDetails[templateRecIndex]['budgetList'][budgetRecIndex]['Budget_Line_Items__r']['records'][lineItemIndex];
        if(obj.Id == undefined){
            this.newBudgetDetails[templateRecIndex]['budgetList'][budgetRecIndex]['Budget_Line_Items__r']['records'].splice(lineItemIndex, 1); 
        } else{
            this.newBudgetDetails[templateRecIndex]['budgetList'][budgetRecIndex]['Budget_Line_Items__r']['records'][lineItemIndex]['editMode'] = false;
        }

    }
}