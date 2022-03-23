import { LightningElement, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import {showMessage, getNestedAttrOut} from 'c/grants_Utility';
import getSolicitationRoundRecords from '@salesforce/apex/Grants_ProposalReviewController.getSolicitationRoundRecords';

import grantstheme from '@salesforce/resourceUrl/Grants_Design'; 
import { loadStyle, loadScript } from 'lightning/platformResourceLoader'; 

export default class Grants_LandingScreen extends LightningElement{
    columns = [
        { label: 'Grants Opportunities Name', fieldName: 'GrantName', type: 'text', cellAttributes: { alignment: 'left' }},
        { label: 'Round', fieldName: 'Name', type: 'text', cellAttributes: { alignment: 'left' } },
        { label: 'No. of Proposals', fieldName: 'ProposalCount', type: 'number', cellAttributes: { alignment: 'left' } },
        { label: 'End Date', fieldName: 'EndDate', type: 'date', cellAttributes: { alignment: 'left' } },
        { label: 'Proposal Review', type: 'button', typeAttributes: {iconName: 'utility:chevronright', name:'View', variant: 'container', label:'View', iconPosition: 'right'}}
    ];
    currUserName;
    grantsArr = [];
    grantsNotFound;
    grantId;
    grantName;
    solRoundId;

    connectedCallback(){
        loadStyle(this, grantstheme + '/styles/main.css');
    } 

    @wire(getRecord, {recordId: USER_ID, fields: [NAME_FIELD]}) 
    wireUser({error,data}){
        if(error){
            showMessage(this,'Error occured while fetching user details', error.message.body, 'error', 'pester'); 
        }else if(data){
            this.currUserName = data.fields.Name.value;
        }
    }

    @wire(getSolicitationRoundRecords)
    wiredSolRoundRecords({error, data}){
        if(error){
            showMessage(this,'Error occured while fetching Grants', error.message.body, 'error', 'pester'); 
        }else if(data){
            let tempGrantsArr = [];
            tempGrantsArr = (!Array.isArray(data)) ? tempGrantsArr.push(data) : data;

            if(tempGrantsArr.length > 0){
                tempGrantsArr = getNestedAttrOut([...tempGrantsArr],'GrantName', 'Solicitation__r', 'Name');
                tempGrantsArr = getNestedAttrOut([...tempGrantsArr],'EndDate', 'Solicitation__r', 'End_Date__c');
                //this.grantsArr = getNestedAttrOut([...tempGrantsArr],'ProposalCount', 'Solicitation__r', 'No_of_Proposals_to_review__c');
                tempGrantsArr.forEach(row=>{
                    if(row.Projects__r && row.Projects__r.length > 0){
                        row.ProposalCount = row.Projects__r.length;
                    } else {
                        row.ProposalCount = 0;
                    }
                });
                this.grantsArr = tempGrantsArr;
                this.grantsNotFound = false;
            }else{
                this.grantsNotFound = true;
            }
        }
    }

    handleRowAction(event){
        this.grantId = event.detail.row.Solicitation__c;
        this.grantName = event.detail.row.GrantName;
        this.solRoundId = event.detail.row.Id;
    }

    goToHomePage(){
        eval("$A.get('e.force:refreshView').fire();");
    }
}