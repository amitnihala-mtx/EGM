import { LightningElement,track,api,wire } from 'lwc';
import grantstheme from '@salesforce/resourceUrl/Grants_Design'; 
import { loadStyle, loadScript } from 'lightning/platformResourceLoader'; 
import fetchProposalRoleInfo  from '@salesforce/apex/Proposal_ProposalRoleController.FetchProposalRoles';
import deleteProposalRole  from '@salesforce/apex/Proposal_ProposalRoleController.deleteProposalRole';
import addProposalRole  from '@salesforce/apex/Proposal_ProposalRoleController.addProposalRole';
import { CurrentPageReference } from 'lightning/navigation';
export default class GrantProposal_proposalroles extends LightningElement {

    @api recordId;
    @track existingproposalroles=[];
    @track newproposalroles=[];
    connectedCallback(){
        loadStyle(this, grantstheme + '/styles/main.css');
        this.fetchInfo();

    } 

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


    fetchInfo(){
        fetchProposalRoleInfo({ProposalId:this.recordId}).then(result => {
            if(result[0]){
                this.existingproposalroles = JSON.parse(result[0]);
            }
            if(result[1]) {
                this.newproposalroles = JSON.parse(result[1]);
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    handleDeleteClick(event){
        deleteProposalRole({ProposalId:this.recordId,ProposalRoleId:event.target.title}).then(result => {
            if(result[0]){
                this.existingproposalroles = JSON.parse(result[0]);
            }
            if(result[1]) {
                this.newproposalroles = JSON.parse(result[1]);
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    handleAddClick(event){
        addProposalRole({ProposalId:this.recordId,ProposalContactId:event.target.title}).then(result => {
            if(result[0]){
                this.existingproposalroles = JSON.parse(result[0]);
            }
            if(result[1]) {
                this.newproposalroles = JSON.parse(result[1]);
            }
        })
        .catch(error => {
            this.error = error;
        });
    }
}