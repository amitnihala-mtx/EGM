import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import Name from '@salesforce/schema/Proposal__c.Name';
import Proposal_Number__c from '@salesforce/schema/Proposal__c.Proposal_Number__c';
import { showMessage, getNestedAttrOut } from 'c/grants_Utility';
import retriveProposalcontents from '@salesforce/apex/DeliverablesAndMilestones.retriveProposalcontents';
import grantstheme from '@salesforce/resourceUrl/Grants_Design';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getInvoices from '@salesforce/apex/DeliverablesAndMilestones.getInvoices';
import getDocumnetData from '@salesforce/apex/DeliverablesAndMilestones.getDocumnetData';
import updateInvoice from '@salesforce/apex/DeliverablesAndMilestones.updateInvoice';
import { CurrentPageReference } from 'lightning/navigation';
import STATUS from "@salesforce/schema/Proposal_Invoice__c.Status__c";

export default class Grants_LandingScreen_milestone extends LightningElement {
    @track invoiceData = [];
    @track invoiceId = [];
    @track recordTypeId = '';
    @track proposalId = '';
    @track fileData = [];
    @track filePopup = false;
    @api caseId;
    @api helpText;
    @track showFiles = false;
    @track fileName;
    @track uploadedFiles;
    @track updateInvoiceData = [];
    data = [];
    currUserName;
    @api recordId;
    @track Tasks;
    @api objectName;
    isModalOpen = false;
    isModal2Open = false;
    isModal1Open = false;
    @track Proposal = this.recordId;

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

    get recFields() {
        return ['Name', 'Id'];
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.pdf', '.JPEG', '.jpg'];
    }

    handleChange(event) {
        let value = event.target.value;
        let name = event.target.name;
        let indexInvoice = parseInt(event.target.dataset.templateIndex);
        let index = parseInt(event.target.dataset.invoiceIndex);
        this.updateInvoiceData[index][indexInvoice][name] = value;
    }
    //Upsert Invoice
    upsertInvoiceLineItem(event) {
        this.showSpinner = true;
        let indexInvoice = parseInt(event.target.dataset.templateIndex);
        let index = parseInt(event.target.dataset.invoiceIndex);
        var updateObj = this.updateInvoiceData[index][indexInvoice];

        updateInvoice({
            updateData: JSON.stringify(updateObj)
        }).then(data => {
            this.Tasks[index].invoiceData[indexInvoice] = data;
            this.updateInvoiceData[index][indexInvoice] = data;
            this.showSpinner = false;
        })
            .catch(error => {
                console.log('error upsertInvoiceLineItem :>> ', error);
                this.showSpinner = false;
            });
    }

    handleDelete(event) {
        let indexInvoice = parseInt(event.target.dataset.templateIndex);
        let index = parseInt(event.target.dataset.invoiceIndex);
        var temp = this.updateInvoiceData[index][indexInvoice];
        if (temp.Id === '') {
            this.updateInvoiceData[index].splice(indexInvoice, 1);
            this.Tasks[index].invoiceData.splice(indexInvoice, 1);
        }
        else {
            this.Tasks[index].invoiceData[indexInvoice].showEdit = false;
            this.updateInvoiceData[index][indexInvoice] = this.Tasks[index].invoiceData[indexInvoice];
        }
    }
    createInvoice(event) {
        let invoiceParentId = event.target.dataset.templateIndex;
        let index = parseInt(event.target.dataset.invoiceIndex);
        var data = {
            Id: '',
            Proposal: this.recordId,
            Proposal_Content: invoiceParentId,
            AutoNumber: '',
            Name: '',
            Amount: 0,
            Status: '',
            Invoice_Date: null,
            showEdit: true
        };
        this.Tasks[index].invoiceData.push(data);
        this.updateInvoiceData[index].push(data);
        console.log('this.updateInvoiceData[index] :>> ', JSON.stringify(this.updateInvoiceData[index]));
    }
    handleUploadFinished(event) {
    }

    handlePreviewFile(event) {
        let baseURL = "https://" + location.host + "/";
        var docId = event.target.dataset.id;
        let fileURL = baseURL +
            "/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=" +
            docId;
        window.open(fileURL, "_blank");
    }

    connectedCallback() {
        loadStyle(this, grantstheme + '/styles/main.css');
        this.retriveProposal();
    }

    getInvoicesData(getInvoiceId) {
        this.showSpinner = true;
        getInvoices({
            proposalId: getInvoiceId
        }).then(data => {
            let obj = this.Tasks.find((o, i) => {
                if (o.Id === getInvoiceId) {
                    this.Tasks[i].invoiceData = JSON.parse(data);
                    this.updateInvoiceData.push(JSON.parse(data));
                    return true;
                }
            });
            this.showSpinner = false;
        })
            .catch(error => {
                console.log('error getInvoicesData :>> ', error);
                this.showSpinner = false;
            });
    }

    handleEditClick(event) {
        var title = event.target.title;
        let indexInvoice = parseInt(event.target.dataset.templateIndex);
        let index = parseInt(event.target.dataset.invoiceIndex);
        var getId = event.target.dataset.id;
        if (title == 'invoice') {
            this.Tasks[index].invoiceData[indexInvoice].showEdit = true;
        }
        else {
            this.proposalId = getId;
            if (title == 'task') {
                this.recordTypeId = '0128c000001JNKZAA4';
                this.isModalOpen = true;
            }
            else {
                this.recordTypeId = '0128c000001JNKUAA4';
                this.isModal2Open = true;

            }
        }
    }

    async retriveProposal() {
        console.log('recordId :>> ', this.recordId);
        retriveProposalcontents({
            recordId: this.recordId
        }).then(data => {
            var response = JSON.parse(JSON.stringify(data));
            response.forEach(element => {
                let tempDeliverables = [];
                let tempFileDeliverables = [];
                let tempTasks = [];
                if (element.Proposal_Contents__r) {
                    element.Proposal_Contents__r.forEach(proposal => {
                        if (proposal.RecordType.Name == 'Tasks') {
                            if (proposal.Status__c === 'Submitted') {
                                proposal.editIcon = false;
                            }
                            else{
                                proposal.editIcon = true;
                            }
                            tempTasks.push(proposal);
                        } else {
                            tempDeliverables.push(proposal);
                            proposal.files = tempFileDeliverables;
                        }
                    });
                }
                element.deliverables = tempDeliverables;
                element.task = tempTasks;
                this.getInvoicesData(element.Id);

            });
            this.Tasks = response;
            this.error = undefined;

        })
            .catch(error => {
                console.log('error getInvoicesData :>> ', error);
                this.showSpinner = false;
            });
    }
    handleSubmitTask(event) {
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        fields.Status__c = 'Submitted';
        var today = new Date();
        var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        fields.Submitted_Date__c = date;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    handleSaveTask(){
        this.template.querySelector('lightning-record-edit-form').submit();
    }
    getFileData(event) {
        this.showSpinner = true;
        var getId = event.target.dataset.id;
        var title = event.target.title;
        this.filePopup = true;
        getDocumnetData({
            parentId: getId
        })
            .then((result) => {
                if (title == 'deliverables') {
                    this.Tasks.forEach(element => {
                        let obj = element.deliverables.find((o, i) => {
                            if (o.Id === getId) {
                                element.deliverables[i].files = result;
                                return true;
                            }
                        });
                    });
                }
                this.fileData = result;
                console.log('result :>> ', JSON.stringify(this.Tasks));
                this.showSpinner = false;

            })
            .catch((error) => {
                console.log("getUploadData Error: ", error);
                this.showSpinner = false;
            });
    }

    @wire(getRecord, { recordId: '$recordId', fields: [Name, Proposal_Number__c] })
    proposalName;

    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
    wireUser({ error, data }) {
        if (error) {
            showMessage(this, 'Error occured while fetching user details', error.message.body, 'error', 'pester');
        } else if (data) {
            this.currUserName = data.fields.Name.value;
        }
    }

    get ProposalNameAndNumber() {
        console.log('this.proposalName::', this.proposalName);
        if (this.proposalName && this.proposalName.data) {
            return this.proposalName.data.fields.Name.value + ' ' + this.proposalName.data.fields.Proposal_Number__c.value;
        } else {
            return '';
        }

    }

    close() {
        setTimeout(
            function () {
                window.history.back();
            },
            1000
        );
    }
    @track activeSections = [];

    expandAll() {
        this.activeSections = this.Tasks.map(Tasks => Tasks.Name);

    }

    closeModal() {
        this.isModalOpen = false;
        this.isModal2Open = false;
        this.filePopup = false;
    }

    handleCreated() {
        this.showSpinner = true;
        this.retriveProposal();
        this.showSpinner = false;
        this.closeModal();
    }
}