import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import STATUS from "@salesforce/schema/Proposal_Content__c.Status__c";
import getDueDiligenceRecords from '@salesforce/apex/grantsDueDiligenceController.getDueDiligenceRecords';
import updateDueDiligenceRecords from '@salesforce/apex/grantsDueDiligenceController.updateDueDiligenceRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class GrantsDueDiligence extends LightningElement {
    // @track Manualdata = [{
    //     id: 'a',
    //     Name__c: 'Applicant submits application',
    //     // Responsible_Party__c: 'Applicant',
    //     Status__c: 'In Progress'
    // }
    // ];

    @api container;
    @api recordId;

    @track data = [];
    @track urlValue;
    @track openVModal = false;
    @track showEdit = true;
    @track showNotes = false;
    @track completedDate = '03/29/2021';
    @track dataMapToUpdate = new Map();
    @track isTableEmpty = false;
    @track showSpinner = false;

    @wire(getPicklistValues, {
        recordTypeId: "012000000000000AAA",
        fieldApiName: STATUS,
    })
    statusOptions;

    get showCombobox() {
        if (this.statusOptions.data != undefined &&
            this.statusOptions.data.values != undefined)
            return true;
        return false;
    }

    handleCancelClick() {
        this.showEdit = true;
    }

    handleEditClick() {
        this.showEdit = false;
    }

    handleSaveClick(event) {
        this.showEdit = true;
        console.log('data>' + JSON.stringify(this.data));
        updateDueDiligenceRecords({
            jsonMap: JSON.stringify(this.data)
        })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Status Updated',
                        variant: 'success'
                    })
                );
                this.refreshTableData();
            })
            .catch(error => {
                // console.log("error occured>> " + JSON.stringify(error));
                //showAjaxErrorMessage(this, error);
                const event = new ShowToastEvent({
                    title: 'Error!',
                    variant: 'error',
                    message: error,
                });
                this.dispatchEvent(event);
            });
    }

    handleChange(event) {
        var indexClicked = event.currentTarget.getAttribute("data-index");
        if (event.target.name == 'status') {
            this.data[indexClicked].status = event.detail.value;
        } else if (event.target.name == 'notes') {
            this.data[indexClicked].notes = event.target.value;
        }
    }

    connectedCallback() {
        if (this.container == 'Inspection') {
            this.showNotes = true;
        }

        // fetchPicklist({
        //     objectName: 'Due_Diligence__c',
        //     fieldName: 'Status__c'
        // })
        //     .then(result => {
        //         this.statusOptions = result;
        //     })
        //     .catch(error => {
        //         // console.log('errorrr picklist>' + JSON.stringify(error));
        //         //showAjaxErrorMessage(this, error);
        //         const event = new ShowToastEvent({
        //             title: 'Error!',
        //             variant: 'error',
        //             message: error,
        //         });
        //         this.dispatchEvent(event);
        //     });
        this.loadColumns();
        this.refreshTableData();
        // this.data = this.Manualdata;
    }

    loadColumns() {
        this.columnConfiguration = [];

        this.columnConfiguration.push({
            heading: 'DUE DILLIGENCE NAME',
            fieldApiName: 'Name__c"',
            style: 'width:40%;'
        });
        this.columnConfiguration.push({
            heading: 'RESPONSIBLE PARTY',
            fieldApiName: 'Responsible_Party__c',
            style: 'width:15%;'
        });
        this.columnConfiguration.push({
            heading: 'STATUS',
            fieldApiName: 'Status__c',
            style: 'width:15%;'
        });
        // if (this.showNotes) {
        //     this.columnConfiguration.push({
        //         heading: 'NOTES',
        //         fieldApiName: 'Notes__c',
        //         style: 'width:15%;'
        //     });
        // }
        this.columnConfiguration.push({
            heading: 'COMPLETED DATE',
            fieldApiName: 'Start_Date__c',
            style: 'width:15%;'
        });
        this.columnConfiguration.push({
            heading: 'COMPLETED BY',
            fieldApiName: 'LastModifiedBy.Name',
            style: 'width:15%;'
        });
    }

    refreshTableData() {
        // console.log('refreshTableDataCalled>>' + this.recordId);
        this.data = [];
        this.showSpinner = true;
        console.log('idField ', this.recordId);
        getDueDiligenceRecords({
            idField: this.recordId
        })
            .then(result => {
                this.data = result;
                let i;
                for (i = 0; i < result.length; i++) {
                    if (this.data[i].status == 'Assigned' || this.data[i].status == 'In Progress' || this.data[i].status == '' || this.data[i].status == null) {
                        this.data[i].lastModifiedByName = '';
                    }
                }
                console.log('data@@@' + JSON.stringify(this.data));
                this.isTableEmpty = result.length === 0 ? true : false;
                this.showSpinner = false;

            })
            .catch(error => {
                // console.log("error occured>> " + JSON.stringify(error));
                //showAjaxErrorMessage(this, error);
                const event = new ShowToastEvent({
                    title: 'Error!',
                    variant: 'error',
                    message: error,
                });
                this.dispatchEvent(event);
                this.showSpinner = false;

            });
    }

    handleOpenReferenceLink(event) {
        this.urlValue = event.currentTarget.getAttribute('data-url');
        window.open(this.urlValue, '_blank');
    }

}