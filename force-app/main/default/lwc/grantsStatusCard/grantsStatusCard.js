import { LightningElement, wire, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
// import chatterLogo from "@salesforce/resourceUrl/chatterLogo";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
// import { utility } from "c/pubsub";

import getProposalRecords from "@salesforce/apex/Grants_DashboardController.getProposalRecords";
import getFinalReport from "@salesforce/apex/Grants_DashboardController.getFinalReport";

export default class GrantsStatusCard extends NavigationMixin(LightningElement) {
    @api
    get status() {
        return this._status;
    }
    set status(value) {
        this.setAttribute('status', value);
        this._status = value;
        this.loadRecords();
    }
    @track _status = '';
    @track isChatterLogo = false;
    @track showReUploadDocs = false;
    @track divCss;
    @track ecr;
    @track isChatter = false;
    @track currentEvId = "";
    @track isLoading = false;
    @track response;
    @track modalHeader;
    @track isModal = false;
    @track selectedEcrRecord;

    get isDraft(){
        return this._status == 'Draft';
    }
    get isSubmitted(){
        return this._status == 'Submitted';
    }
    get isUnderReview(){
        return this._status == 'Under Review';
    }
    get isAssignBackToGrantee(){
        return this._status == 'Assign Back To Grantee';
    }
    get isAwarded(){
        return this._status == 'Awarded';
    }
    get isCompleted(){
        return this._status == 'Completed';
    }

    get finalReport(){
        this.selectedEcrRecord.Status__c == 'Completed';
    }

    get taskDeliverable(){
        this.selectedEcrRecord.Status__c == 'Awarded' && this.selectedEcrRecord.isReimbursement == true;
    }

    get recertification(){
        this.selectedEcrRecord.Status__c == 'Awarded' && this.selectedEcrRecord.isDisbursement == true;
    }


    get fullUrl() {
        let url0 = window.location.protocol + "//" + window.location.hostname;
        let url = "/apex/ChatterPage?id=";
        let completeURL = url0 + url + this.currentEvId;
        return completeURL;
    }
    
    get isAwarded(){
        return this._status == 'Awarded'
    }

    connectedCallback() {
        this.loadRecords();
    }
    loadCSS() {
        if (this._status == "Draft") {
            this.divCss = "slds-col card-sidecolor-orange";
            this.showReUploadDocs = true;
        } else if (this._status == "Under Review") {
            this.divCss = "slds-col card-sidecolor-pink";
            this.isChatterLogo = true;
            this.showReUploadDocs = true;
        } else if (this._status == "Approved" || this._status == "Completed") {
            this.divCss = "slds-col card-sidecolor-blue";
            this.isChatterLogo = true;
        } else if (this._status == "Pending Approval") {
            this.divCss = "slds-col card-sidecolor-purple";
            this.isChatterLogo = true;
        } else if (this._status == "Submitted") {
            this.divCss = "slds-col card-sidecolor-green";
            this.isChatterLogo = true;
            this.showReUploadDocs = true;
        }
    }
    loadRecords() {
        this.isLoading = true;
        this.ecr = [];
        getProposalRecords({
            status: this._status,
        })
            .then((result) => {
                console.log("getProposalRecods Result: ", result);
                var tempList = JSON.parse(result);
                tempList.forEach(row=>{
                    if(row.RecordType.DeveloperName == 'Disbursement'){
                        row.isDisbursement = true;
                    }
                    if(row.RecordType.DeveloperName == 'Reimbursement'){
                        row.isReimbursement = true;
                    }
                })
                this.ecr = tempList;
                this.loadCSS();
                this.isLoading = false;
            })
            .catch((error) => {
                console.log("getProposalRecords Error: ", error);
                this.isLoading = false;
            });
    }
    redirectToChatter(event) {
        this.currentEvId = event.currentTarget.getAttribute("data-id");
        this.isChatter = true;
        console.log("URL: " + this.fullUrl);
    }

    redirectToPermit(event) {
        let proposalId = event.currentTarget.getAttribute("data-id");
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Proposal_Request__c'
            },
            state:
            {
                proposalId: proposalId
            }
        });
    }

    redirectToGrant(event){
        let grantId = event.currentTarget.getAttribute("data-id");
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Grants_Detail__c'
            },
            state:
            {
                grantId: grantId
            }
        });
    }

   
    handleCloseModal() {
        this.isModal = false;
        this.selectedEcrRecord = {};
    }

    handleResume(event){
        let intakeUrl = event.target.dataset.url;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: intakeUrl
            }
        });
    }

    handleDownloadPDF(event){
        let recordid = event.target.dataset.recordid;
        window.open('https://mtxenterprisegrantsproduct.force.com/apex/ProposalReviewAndGeneratePDF?id='+recordid);
    }

    handleAmendment(event){

    }

    handleTaskDeliverable(event){
        let recordid = event.target.dataset.recordid;
        // this.ecr.forEach(row=>{
        //     if(row.Id == recordid){
        //         this.selectedEcrRecord = row;
        //     }
        // });
        // this.isModal = true;
        window.open('/s/task-deliverable?proposalId='+recordid,'_blank');
    }

    handleReCertification(event){
        let recordid = event.target.dataset.recordid;
        // this.ecr.forEach(row=>{
        //     if(row.Id == recordid){
        //         this.selectedEcrRecord = row;
        //     }
        // });
        // this.isModal = true;
        window.open('/s/re-certification?proposalId='+recordid,'_blank');
    }

    handleFinalReport(event){
        let recordid = event.target.dataset.recordid;
        getFinalReport({
            proposalId : recordid
        })
        .then(data=>{
            if(data.length > 30){
                this.showToast('Info',data,'info');
            } else{
                window.open('/s/final-report?proposalId='+data,'_blank');
            }
            
        })
        .catch(error=>{
            console.log(JSON.stringify(error));
        })

        
    }

    handleLinkMember(event){
        let recordid = event.target.dataset.recordid;
        window.open('/s/link-member?proposalId='+recordid,'_blank');
    }

    showToast(title, msg, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    
}