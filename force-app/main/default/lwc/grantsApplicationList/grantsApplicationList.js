import { LightningElement, track, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import getAllProposals from "@salesforce/apex/Grants_ProposalController.getAllProposals";
import createNewProposal from "@salesforce/apex/Grants_ProposalController.createNewProposal";
//import getReport from "@salesforce/apex/Grants_ProposalController.getReport";

export default class GrantsApplicationList extends LightningElement {
    @track applications = [];
    grantId;
    grantName;
    taskAndDeliverable = false;
    tdRecordId;
    // connectedCallback(){

    // }
    isLoaded = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log(currentPageReference.state.grantId);
            this.grantId = currentPageReference.state.grantId;
            this.getInfo();
        }
    }

    handleNewSubmission() {
        this.isLoaded = false;
        createNewProposal({
            grantId: this.grantId,
        })
            .then((response) => {
                window.open(
                    "/dese/s/grant-application?projectId=" + response,
                    "_self"
                );
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
                this.isLoaded = true;
            })
            .finally(() => {
                //this.showSpinner = false;
            });
    }

    getInfo() {
        getAllProposals({
            grantId: this.grantId,
        })
            .then((result) => {
                if (result.projectList.length == 0) {
                    //window.open('/dese/s/grant-application?projectId='+response,'_self');
                    createNewProposal({
                        grantId: this.grantId,
                    })
                        .then((response) => {
                            window.open(
                                "/dese/s/grant-application?projectId=" +
                                    response,
                                "_self"
                            );
                        })
                        .catch((error) => {
                            console.log(JSON.stringify(error));
                        })
                        .finally(() => {
                            //this.showSpinner = false;
                        });
                } else {
                    console.log("getAllProposals result", result);
                    var projectListTemp = result.projectList;
                    var proposalToFinalReport = result.proposalToFinalReport;
                    projectListTemp.forEach((row) => {
                        row.editLink =
                            "/dese/s/grant-application?projectId=" + row.Id;
                        row.isTandDDisabled =
                            row.Status__c == "Awarded" ? false : true;
                        if (row.Project_Roles__r) {
                            row.primaryContact =
                                row.Project_Roles__r[0].FirstName__c +
                                " " +
                                row.Project_Roles__r[0].LastName__c;
                            console.log(row.primaryContact);
                        }
                        if (row.Status__c == "Draft") {
                            row.statusStyle =
                                "slds-truncate slds-text-color_weak";
                            row.showEditLink = true;
                        } else if (row.Status__c == "Submitted") {
                            row.statusStyle =
                                "slds-truncate slds-text-color_success";
                            row.showEditLink = true;
                        } else if (
                            row.Status__c == "Rejected" ||
                            row.Status__c == "Not Awarded" ||
                            row.Status__c == "Cancelled"
                        ) {
                            row.statusStyle =
                                "slds-truncate slds-text-color_destructive";
                            row.showEditLink = true;
                        } else if (
                            row.Status__c == "Under Review" ||
                            row.Status__c == "Pending Review" ||
                            row.Status__c == "Pending Approval" ||
                            row.Status__c == "Approved" ||
                            row.Status__c == "Awarded" ||
                            row.Status__c == "Payment Processed" ||
                            row.Status__c == "Completed"
                        ) {
                            row.statusStyle =
                                "slds-truncate slds-text-color_success";
                            row.showEditLink = true;
                        }
                        if (row.Status__c == "Completed") {
                            row.showSubmitButton = true;
                            row.isTandDDisabled = false;
                        } else {
                            row.showSubmitButton = false;
                        }
                        row.showSubmittedFinalReportButton = false;
                        if (proposalToFinalReport[row.Id] != "") {
                            row.showSubmitButton = false;
                            row.showSubmittedFinalReportButton = true;
                        }

                        //return row;
                    });
                    this.applications = projectListTemp;
                    this.grantName = result.fundingName;
                    this.isLoaded = true;
                }
            })
            .catch((error) => {
                this.isLoaded = true;
                console.log(error);
            });
    }

    openTandD(event) {
        console.log("In Open Chatter", event.target.dataset.appid);
        // this.caseId = event.target.dataset.caseid;
        this.tdRecordId = event.target.dataset.appid;
        this.taskAndDeliverable = true;
    }
    // goToFinalReportSubmission(event) {
    //     console.log("Project/Proposal ID: ", event.target.dataset.appid);
    //     let projectId = event.target.dataset.appid;
    //     this.isLoaded = false;
    //     getReport({proposalID: projectId})
    //     .then(result => {
    //             window.open("/dese/s/final-report?projectId=" + result, "_self");
    //             this.isLoaded = true;
    //     })
    //     .catch(error => {
    //         console.log(error)
    //         this.isLoaded = true;

    //     })
    // }

    closeModal() {
        this.taskAndDeliverable = false;
    }

    handleback(){
        window.history.back();
    }
}