import { LightningElement,track } from 'lwc';
import isPageAccessible from '@salesforce/apex/GrantsManageMemberController.isPageAccessible';
import getMembersList from '@salesforce/apex/GrantsManageMemberController.getMembersList';
import updateContactDetails from '@salesforce/apex/GrantsManageMemberController.updateContactDetails';
import activateUser from '@salesforce/apex/GrantsManageMemberController.activateUser';
import deactivateUser from '@salesforce/apex/GrantsManageMemberController.deactivateUser';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GrantsManageMember extends LightningElement {

    showSpinner = false;
    showPageAccessError = false;
    @track membersList=[];
    @track membersListCpy=[];
    editContactIndex;
    @track editContactRecord = {};
    showEditModal = false;
    connectedCallback(){
        this.showSpinner = true;
        this.loadDetails();
    }

    get contactRoleOptions(){
        return [
            {
                label : 'Grantee Administrator',
                value : 'Grantee Administrator'
            },
            {
                label : 'Grantee Payment Signatory Fiscal Agent',
                value : 'Grantee Payment Signatory Fiscal Agent'
            },
            {
                label : 'Grantee Contributor',
                value : 'Grantee Contributor'
            }
        ]
    }

    loadDetails(){
        isPageAccessible()
        .then(data=>{
            if(data==true){
                this.loadMembersList();
            } else{
                this.showSpinner = false;
                this.showPageAccessError = true;
            }
        })
        .catch(error=>{
            console.log(JSON.stringify(error));
        });
        this.showSpinner= false;
    }

    loadMembersList(){
        getMembersList()
        .then(data=>{
            console.log(data);
            this.membersList = JSON.parse(data);
            this.membersListCpy = JSON.parse(data);
        })
        .catch(error=>{
            console.log(JSON.stringify(error));
        });
        this.showSpinner = false;
    }

    handleEdit(event){
        this.showSpinner = true;
        this.editContactIndex = event.target.dataset.index;
        this.editContactRecord = this.membersList[event.target.dataset.index];
        this.showSpinner = false;
        this.showEditModal = true;
    }
    handleActivate(event){
        let contactRecId = event.target.dataset.contactid;
        let contactRecIndex = event.target.dataset.index;
        this.showSpinner = true;
        activateUser({
            contactId : contactRecId
        })
        .then(data=>{
            if(data=='SUCCESS'){
                this.membersList[contactRecIndex].isActive = 'Active';
                this.membersList[contactRecIndex].isUserActive = true;
                this.showToast('Success','Member '+this.membersList[contactRecIndex].contactName+' Activated Successfully','success');
            }
        })
        .catch(error=>{
            console.log(JSON.stringify(error));
        })
        this.showSpinner = false;
    }
    handleDeactivate(event){
        let contactRecId = event.target.dataset.contactid;
        let contactRecIndex = event.target.dataset.index;
        this.showSpinner = true;
        deactivateUser({
            contactId : contactRecId
        })
        .then(data=>{
            if(data=='SUCCESS'){
                this.membersList[contactRecIndex].isActive = 'Inactive';
                this.membersList[contactRecIndex].isUserActive = false;
                this.showToast('Success','Member '+this.membersList[contactRecIndex].contactName+' Deactivated Successfully','success');
            }
        })
        .catch(error=>{
            console.log(JSON.stringify(error));
        })
        this.showSpinner = false;
    }

    handleEditChange(event){
        let changeName = event.target.name;
        //alert(changeName);
        if(changeName == 'FirstName'){
            this.editContactRecord.contactFirstName = event.detail.value;
        } else if(changeName =='LastName'){
            this.editContactRecord.contactLastName = event.detail.value;
        } else if(changeName == 'Email'){
            this.editContactRecord.contactEmail = event.detail.value;
        } else if(changeName == 'ContactNumber'){
            this.editContactRecord.contactNumber = event.detail.value;
        } else if(changeName == 'Role'){
            this.editContactRecord.contactRole = event.detail.value;
        } 

        this.editContactRecord.contactName = this.editContactRecord.contactFirstName + ' ' + this.editContactRecord.contactLastName;
    }

    closeEditModal(){
        this.showEditModal = false;
    }

    saveContactDetails(){
        console.log(JSON.parse(JSON.stringify(this.editContactRecord)));
        this.showSpinner = true;
        updateContactDetails({
            wrapperStr : JSON.stringify(this.editContactRecord)
        })
        .then(data=>{
            if(data){
                if(!this.editContactRecord.contactId){
                    this.editContactRecord.contactId = data;
                    this.editContactRecord.isUserActive = false;
                    this.editContactRecord.contactName = this.editContactRecord.contactFirstName + ' ' + this.editContactRecord.contactLastName;
                    this.editContactRecord.isActive = 'Inactive';
                    this.membersList.push(this.editContactRecord);
                } else{
                    this.membersList[this.editContactIndex] = this.editContactRecord;
                }
                console.log(JSON.parse(JSON.stringify(this.membersList)));
                this.editContactRecord = {};
            }
        })
        .catch(error=>{
            console.log(JSON.stringify(error));
        })
        this.showEditModal = false;
        this.showSpinner = false;
    }

    handleNewMember(event){
        this.editContactRecord = {};
        this.showEditModal = true;
    }

    handleSearchMembersInput(event){
        let value = event.detail.value;
        if(value.length>=3){
            //console.log(value);
            let tempList = [];
            this.membersList.forEach(row=>{
                //console.log(row.contactName);
                if(row.contactName.toLowerCase().includes(value.toLowerCase())){
                    tempList.push(row);
                }
            });
            this.membersList = tempList;
        } else{
            this.membersList = this.membersListCpy;
        }
    }

    showToast(title, msg, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}