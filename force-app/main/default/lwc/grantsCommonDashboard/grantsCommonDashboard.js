import { LightningElement, track } from 'lwc';
import getGrants from '@salesforce/apex/Grants_ProposalController.getAllGrants';
import { NavigationMixin } from 'lightning/navigation';
import deseDesign from '@salesforce/resourceUrl/DESE_Design';

export default class GrantsCommonDashboard extends NavigationMixin(LightningElement) {
    @track grantsList;
    @track grantsListCpy=[];

    grantImage = deseDesign + '/theme/images/grant.png';

    connectedCallback(){
        this.fetchAllGrants();
    }

    fetchAllGrants(){
        getGrants().then(data => {
            console.log(data);
            this.grantsList = JSON.parse(data);
            this.grantsListCpy = this.grantsList;
            // this.grantsList.forEach(grant => {
            //     grant.Name = grant.Name + ' ( ' + grant.Solicitation_Number__c + ' ) ';
            // });
        }).catch(error => {console.log(error)});
    }

    handleViewDetails(event){
        var grantid = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/s/grants-detail?grantId=' + grantid
            }
        });
    }

    handleSearchGrants(event){
        let value = event.detail.value;
        if(value.length >=3){
            console.log(value);
            let tempList = [];
            this.grantsList.forEach(row=>{
                if(row.Name.toLowerCase().includes(value.toLowerCase())){
                    tempList.push(row);
                }
            });
            this.grantsList = tempList;
        } else{
            this.grantsList = this.grantsListCpy;
        }
    }
}