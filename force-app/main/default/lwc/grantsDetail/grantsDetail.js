import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getGrantDetails from '@salesforce/apex/Grants_ProposalController.getGrantDetails';
import createNewProposal from '@salesforce/apex/Grants_ProposalController.createNewProposal';
import desetheme from '@salesforce/resourceUrl/DESE_Design';
import isGuestU from '@salesforce/user/isGuest';
import { NavigationMixin } from "lightning/navigation";


export default class GrantsDetail extends NavigationMixin(LightningElement) {
    grantId
    @track grant = {};
    showSpinner = true;
    isGuestUser = isGuestU;
    @track grantsdashboard = desetheme + '/theme/images/grant.png';
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log(currentPageReference.state.grantId)
            this.grantId = currentPageReference.state.grantId
            this.getInfo();
        }
    }

    getInfo() {
        console.log('getInfo');
        this.showSpinner = true;
        if (!this.grantId) return;
        getGrantDetails({ grantId: this.grantId })
            .then(result => {
                this.grant = result
                this.showSpinner = false;
            })
            .catch(error => {
                console.log(error)
                this.showSpinner = false;
            })
    }

    
    handleApplyOnline(){
        this.showSpinner = true;
        if(this.isGuestUser) {
            window.open('/s/login','_self');
        } else {
            createNewProposal({
                grantId : this.grantId
            })
            .then(data=>{
                this[NavigationMixin.Navigate]({
                    type: "standard__webPage",
                    attributes: {
                        url: data
                    }
                });
            })
            .catch(error=>{
                console.log(JSON.stringify(error));
            })
        }        
    }

    get grantName(){
        return  this.grant && this.grant.Name  //? this.grant.Name + ' ( ' + this.grant.Solicitation_Number__c + ' )' : '';
    }
    handleback(){
        window.history.back();
    }
}