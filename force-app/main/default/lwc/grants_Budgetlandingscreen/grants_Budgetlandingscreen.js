import { LightningElement, wire,api,track } from "lwc";
import ForParentChildRecords from "@salesforce/apex/BudgetAndBudgetLineItem.ForParentChildRecords";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import BudgetLineItemId from '@salesforce/schema/Budget_Line_Item__c.Id';
import BudgetLineItemName from '@salesforce/schema/Budget_Line_Item__c.Name';
import Grant_Fund from '@salesforce/schema/Budget_Line_Item__c.Grant_Funded__c';
import Match_Funds from '@salesforce/schema/Budget_Line_Item__c.Match_Funds__c';
import Match_Percent_Cal from '@salesforce/schema/Budget_Line_Item__c.Match_Percent_Calculated__c';
import Match_Percent_Require from '@salesforce/schema/Budget_Line_Item__c.Match_Percent_Required__c';
import Other_Funds from '@salesforce/schema/Budget_Line_Item__c.Other_Funds__c';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
const actions = [
    { label: 'Edit', name: 'edit_record' }
];
const BudgetLineItem_COLS = [
    {
        label: "Budget Line Item Name",
        fieldName: "Name"
    },
    {
        label: "Grant Funded",
        fieldName: "Grant_Funded__c",
        type: "currency"
    },
    {
        label: "Match Funds",
        fieldName: "Match_Funds__c",
        type: "currency"
    },
    { label: "Match Percent Calculated", type: "percent", fieldName: "Match_Percent_Calculated__c" },
    { label: "Match Percent Required", type:"percent", fieldName: "Match_Percent_Required__c" },
    { label: "Other Funds", type:"currency", fieldName: "Other_Funds__c" }
];
export default class Grants_Budgetlandingscreen extends NavigationMixin(LightningElement) {
    @api recordId;
    data=[];
    BudgetLineItem_COLS=BudgetLineItem_COLS;
    @track Budget;
    draftValues = [];

    @wire(ForParentChildRecords, {recordId:'$recordId'})
    wirebudget({ error, data }) {
        
       if(data) {
        console.log('datadata',data);
        var response = JSON.parse(JSON.stringify(data));
        response.forEach(element => {
                let tempBudgetLineItems=[];

                if(element.Budget_Line_Items__r) {
                    element.Budget_Line_Items__r.forEach(LineItems=>{

                            tempBudgetLineItems.push(LineItems);
                        
                    });
                }
                element.BudgetLineItems = tempBudgetLineItems;

            });
            this.Budget = response;
            this.error = undefined;
           
        }
        else if(error) {
            this.error = error;
            this.Budget = undefined;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: error.message,
                    variant: 'error',
                }),
            );
        }
    }

    handleSave(event) {
       
        /*if (event.detail.action.name === "editBudgetLineItem") {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: event.detail.row.Id,
                    actionName: "edit"
                }
            }).then((url) => {
                window.open(url, "https://mtxgrantsproduct.lightning.force.com/lightning/action/quick/Proposal__c.Budget_Review?objectApiName&context=RECORD_DETAIL&recordId=a0L8c00000TLPimEAH&backgroundContext=%2Flightning%2Fr%2FProposal__c%2Fa0L8c00000TLPimEAH%2Fview");
            });
        }

        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'edit_record':
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Budget_Line_Item__c',
                        actionName: 'edit',
                        recordId: row.Id
                    }
                });
                break;
        }
*/

const fields = {}; 
fields[BudgetLineItemId.fieldApiName] = event.detail.draftValues[0].Id;
fields[BudgetLineItemName.fieldApiName] = event.detail.draftValues[0].Name;
fields[Grant_Fund.fieldApiName] = event.detail.draftValues[0].Grant_Funded__c;
fields[Match_Funds.fieldApiName] = event.detail.draftValues[0].Match_Funds__c;
fields[Match_Percent_Cal.fieldApiName] = event.detail.draftValues[0].Match_Percent_Calculated__c;
fields[Match_Percent_Require.fieldApiName] = event.detail.draftValues[0].Match_Percent_Required__c;
fields[Other_Funds.fieldApiName] = event.detail.draftValues[0].Other_Funds__c;

const recordInput = {fields};

updateRecord(recordInput)
.then(() => {
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Success',
            message: 'Budget Line Item updated',
            variant: 'success'
        })
    );
    // Display fresh data in the datatable
    return refreshApex(this.tempBudgetLineItems).then(() => {

        // Clear all draft values in the datatable
        this.draftValues = [];

    });
}).catch(error => {
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error updating or reloading record',
            message: error.body.message,
            variant: 'error'
        })
    );
});
    }

}