import { LightningElement, track, wire,api } from "lwc";
import { loadStyle } from 'lightning/platformResourceLoader';
import grantstheme from '@salesforce/resourceUrl/Grants_Design'; 
import { getRecord } from "lightning/uiRecordApi";
import Id from "@salesforce/user/Id";
import UserName from "@salesforce/schema/User.Name";
import UserTitle from "@salesforce/schema/User.Title";
import UserEmail from "@salesforce/schema/User.Email";
import submitFinalReport from "@salesforce/apex/Grants_ProposalController.submitFinalReport";
import grantDesign from '@salesforce/resourceUrl/GRANT_Design';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';



export default class GrantsFinalReport extends LightningElement {
    notebook = grantDesign + '/theme/images/notebook.png';
    @api recordId;
    @track approvedBudgetSupervisor = 0;
    @track approvedBudgetPC = 0;
    @track approvedBudgetStipend = 0;
    @track approvedBudgetOther = 0;
    @track fundsExpendedSupervisor = 0;
    @track fundsExpendedPC = 0;
    @track fundsExpendedStipend = 0;
    @track fundsExpendedOther = 0;
    @track balanceUnexpendedSupervisor = 0;
    @track balanceUnexpendedPC = 0;
    @track balanceUnexpendedStipend = 0;
    @track balanceUnexpendedOther = 0;
    @track checkEnclosedAmount = 0;
    @track userName = "";
    @track userTitle = "";
    @track userEmail = "";
    @track showSpinner = true;
    @track projectId = "";
    @track disableSubmit = true;
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
    

    get balanceUnexpendedSubTotal() {
        return (
            this.balanceUnexpendedOther +
            this.balanceUnexpendedPC +
            this.balanceUnexpendedStipend +
            this.balanceUnexpendedSupervisor
        );
    }
    get fundsExpendedSubTotal() {
        return (
            this.fundsExpendedOther +
            this.fundsExpendedPC +
            this.fundsExpendedStipend +
            this.fundsExpendedSupervisor
        );
    }
    get approvedBudgetSubTotal() {
        return (
            this.approvedBudgetOther +
            this.approvedBudgetPC +
            this.approvedBudgetStipend +
            this.approvedBudgetSupervisor
        );
    }
    get options() {
        return [
            { label: "Check Enclosed", value: "Check Enclosed" },
            { label: "Funds Not Requested", value: "Funds Not Requested" },
        ];
    }

    @wire(getRecord, { recordId: Id, fields: [UserName, UserTitle, UserEmail] })
    userDetails({ error, data }) {
        if (data) {
            this.userName = data.fields.Name.value;
            this.userTitle = data.fields.Title.value;
            this.userEmail = data.fields.Email.value;
            this.showSpinner = false;
        } else if (error) {
            console.log("Wire method error: ", error);
            this.showSpinner = false;
        }
    }

    connectedCallback() {
        this.projectId = this.recordId;
        loadStyle(this, grantstheme + '/styles/main.css');
    }

    handleTableFields(event) {
        let fieldName = event.target.name;
        let value = event.target.value;
        this[fieldName] = parseInt(value);
    }
    
   
    handleCancel() {
        window.open("/s", "_self");
    }


    handleFinalSubmit(){
        this.showSpinner = true;
        let data = {
            approvedBudgetSupervisor: this.approvedBudgetSupervisor,
            approvedBudgetPC: this.approvedBudgetPC,
            approvedBudgetStipend: this.approvedBudgetStipend,
            approvedBudgetOther: this.approvedBudgetOther,
            fundsExpendedSupervisor: this.fundsExpendedSupervisor,
            fundsExpendedPC: this.fundsExpendedPC,
            fundsExpendedStipend: this.fundsExpendedStipend,
            fundsExpendedOther: this.fundsExpendedOther,
            balanceUnexpendedSupervisor: this.balanceUnexpendedSupervisor,
            balanceUnexpendedPC: this.balanceUnexpendedPC,
            balanceUnexpendedStipend: this.balanceUnexpendedStipend,
            balanceUnexpendedOther: this.balanceUnexpendedOther,
            checkEnclosedAmount: this.checkEnclosedAmount,
            userName: this.userName,
            userTitle: this.userTitle,
            userEmail: this.userEmail,
            projectId: this.projectId,
            status : 'Submitted'
        };
        submitFinalReport({
            data: JSON.stringify(data),
        })
            .then((result) => {
                console.log("SubmitFinalReport result: ", result);
                const toastevent = new ShowToastEvent({
                    title: 'Success',
                    message:
                        'Final Report Submitted Successfully.',
                    variant : 'success',
                });
                this.dispatchEvent(toastevent);
                window.open("/s", "_self");
               
            })
            .catch((error) => {
                console.log("SubmitFinalReport error: ", error);
            })
            .finally(()=>{
                this.showSpinner = false;
            });
    }


    handleClick(event){
        console.log("handle click",this.disableSubmit);
        this.disableSubmit = !this.disableSubmit;
    }
}