import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import {showMessage, getNestedAttrOut} from 'c/grants_Utility';
import getProposalsByStatus from '@salesforce/apex/Grants_ProposalReviewController.getProposalsByStatus';

import Proposal_Number from '@salesforce/schema/Proposal__c.Proposal_Number__c';
import Proposal_Name from '@salesforce/schema/Proposal__c.Name';
import Proposal_Rank from '@salesforce/schema/Proposal__c.Proposal_Rank__c';
import Impacts_Benefits from '@salesforce/schema/Proposal__c.Impacts_Benefits__c';
import Proposal_Strengths from '@salesforce/schema/Proposal__c.Proposal_Strengths__c';
import Proposal_Weaknesses from '@salesforce/schema/Proposal__c.Proposal_Weaknesses__c';
import Proposal_Risks from '@salesforce/schema/Proposal__c.Proposal_Risks__c';
import Contingencies_Recommendations from '@salesforce/schema/Proposal__c.Contingencies_Recommendations__c';
import Add_Info from '@salesforce/schema/Proposal__c.Additional_Information_for_Award_Letter__c';
import Recommended_Funding from '@salesforce/schema/Proposal__c.Recommended_Funding__c';
import Grant_Solicitation_Group from '@salesforce/schema/Proposal__c.Grant_Solicitation_Group__c';
import STATUS from '@salesforce/schema/Proposal__c.Status__c';
import APPLYING_CONTACT from '@salesforce/schema/Proposal__c.Applying_Contact__c';
import Request_Amount from '@salesforce/schema/Proposal__c.Requested_Amount__c';
import GrantRound from '@salesforce/schema/Proposal__c.Grant_Solicitation_Rounds__c';
export default class Grants_DisplayProposals extends LightningElement {
    @api  grantId;
    @api grantName;
    @api solRoundId;
    @track proposalsArr = [];
    wiredProposalsRes;
    status = 'All';
    proposalsNotFound;
    openCorrectiveActionModal = false;
    /*columns = [
        { label: 'Proposal Number', fieldName: 'Proposal_Number__c', type: 'text', cellAttributes: { alignment: 'left' }},
        { label: 'Proposal Amount', fieldName: 'Total_Proposal_Cost__c', type: 'amount', typeAttributes: { currencyCode: 'USD', step: '0.001' }, cellAttributes: { alignment: 'left' } },
        { label: 'Account Name', fieldName: 'AccountName', type: 'text', cellAttributes: { alignment: 'left' }},
        { label: 'End Date', fieldName: 'Proposal_Completion_Date__c', type: 'date-local', cellAttributes: { alignment: 'left' } },
        { label: 'Status', fieldName: 'Status__c', type: 'text', cellAttributes: { alignment: 'left' } },
        { type: 'button-icon', typeAttributes: {iconName: 'utility:chevronright', name:'Open', variant: 'container'}}
    ];*/
    get columns() { 
        let arr = [];
        // arr.push({ label: 'Proposal Number', fieldName: 'Proposal_Number__c', type: 'text', cellAttributes: { alignment: 'left' }});
        arr.push({ label: 'Proposal Number', fieldName: 'Proposal_Number__c', type: 'button', cellAttributes: { alignment: 'left' },typeAttributes: {
            label: { fieldName: 'Proposal_Number__c' },
            name: 'Proposal Number'
        },});
        arr.push({ label: 'Proposal Amount', fieldName: 'Requested_Amount__c', type: 'currency', typeAttributes: { currencyCode: 'USD', step: '0.001' }, cellAttributes: { alignment: 'left' } });
        /*arr.push({ label: 'Account Name', fieldName: 'AccountName', type: 'text', cellAttributes: { alignment: 'left' }});
        arr.push({ label: 'End Date', fieldName: 'Completed_Date__c', type: 'date-local', cellAttributes: { alignment: 'left' } });*/
        if(this.status == 'All') {
            arr.push({ label: 'Status', fieldName: 'Status__c', type: 'text', cellAttributes: { alignment: 'left' } });
        }
        if(this.status == 'Under Review') {
            arr.push({ label: 'Group Assigned', fieldName: 'GroupName', type: 'text', cellAttributes: { alignment: 'left' } });
        }
        // arr.push({ type: 'button-icon', typeAttributes: {iconName: 'utility:chevronright', name:'Open', variant: 'container'}});
        return arr;
    }
    proposalRecId;
    proposalNumber;

    /*@wire(getProposalsByStatus, {status : '$status', grantId: '$grantId', solRoundId: '$solRoundId'})
    wiredProposals(retVal){
        this.wiredProposalsRes = retVal;
        const { data, error } = retVal;
        if(error){
            this.proposalsNotFound = false;
            this.proposalRecId = null;
            showMessage(this, 'Error occured while fetching Proposals', error.body.message, 'error', 'pester');
        }else if(data){
            let tempProposalsArr = [];
            tempProposalsArr = (!Array.isArray(data)) ? tempProposalsArr.push(data) : data;
            if(tempProposalsArr.length > 0){
                tempProposalsArr = getNestedAttrOut([...tempProposalsArr], 'GroupName', 'Grant_Solicitation_Group__r', 'Name');
                this.proposalsArr = getNestedAttrOut([...tempProposalsArr], 'AccountName', 'Primary_Contractor_Account__r', 'Name');
                this.proposalsNotFound = false;
            }else{
                this.proposalsNotFound = true;
                this.proposalRecId = null;
            }
        }else{
            this.proposalsNotFound = true;
            this.proposalRecId = null;
        }
    }*/
    connectedCallback(){
        this.fetchProposals();
    }

    fetchProposals(){
        getProposalsByStatus({status : this.status, grantId: this.grantId, solRoundId: this.solRoundId}).then(data => {
            let tempProposalsArr = [];
            tempProposalsArr = (!Array.isArray(data)) ? tempProposalsArr.push(data) : data;
            if(tempProposalsArr.length > 0){
                tempProposalsArr = getNestedAttrOut([...tempProposalsArr], 'GroupName', 'Grant_Solicitation_Group__r', 'Name');
                this.proposalsArr = getNestedAttrOut([...tempProposalsArr], 'AccountName', 'Primary_Contractor_Account__r', 'Name');
                this.proposalsNotFound = false;
            }else{
                this.proposalsNotFound = true;
                this.proposalRecId = null;
            }
        }).catch(error => {
            this.proposalsNotFound = false;
            this.proposalRecId = null;
            showMessage(this, 'Error occured while fetching Proposals', error.body.message, 'error', 'pester');
        });
    }

    handleActiveTab(event) {
        this.status = event.target.value;
        this.fetchProposals();
        //refreshApex(this.wiredProposalsRes);
    }

    handleRowAction(event){
        this.proposalRecId = event.detail.row.Id;
        this.proposalNumber = event.detail.row.Proposal_Number__c;
    }

    get getSfFieldsToDisplay(){
        let status = '';
        this.proposalsArr.forEach(proposal=>{
            if(proposal.Id==this.proposalRecId){
                status = proposal.Status__c;
            }
        });
        if(status=='Submitted') {
            return [Proposal_Number, Proposal_Name, Request_Amount,APPLYING_CONTACT,STATUS];
        }else if(status=='Pending Review') {
            return [Proposal_Number, Proposal_Name, Request_Amount,APPLYING_CONTACT,STATUS,GrantRound,Grant_Solicitation_Group];
        } else {
            return [Proposal_Number, Proposal_Name, Request_Amount,APPLYING_CONTACT,STATUS,GrantRound,Grant_Solicitation_Group,Recommended_Funding,Proposal_Rank, Impacts_Benefits, Proposal_Strengths, Proposal_Weaknesses,
                Proposal_Risks, Contingencies_Recommendations, Add_Info];
        }
    }

    get getReviewSectionHeading(){
        return `01 - #${this.proposalNumber} Review`;
    }

    handleSuccess(event){
        //refreshApex(this.wiredProposalsRes);
        if(event.detail.fields.Status__c.value == 'Corrective Action'){
            this.openCorrectiveActionModal = true;
        }
        this.fetchProposals();
    }

    closeCorrectiveActionModal(){
        this.openCorrectiveActionModal = false;
    }

    
}