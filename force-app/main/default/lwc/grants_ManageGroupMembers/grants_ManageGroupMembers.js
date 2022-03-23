import { LightningElement,track,api } from 'lwc';
import grantstheme from '@salesforce/resourceUrl/Grants_Design'; 
import { loadStyle, loadScript } from 'lightning/platformResourceLoader'; 
import fetchGroupMembersInfo  from '@salesforce/apex/Grants_ManageGroupMembersController.fetchGroupMembersInfo';
import deleteGroupMember  from '@salesforce/apex/Grants_ManageGroupMembersController.deleteGroupMember';
import addGroupMember  from '@salesforce/apex/Grants_ManageGroupMembersController.addGroupMember';
export default class Grants_ManageGroupMembers extends LightningElement {
    @api recordId;
    @track existingmembers=[];
    @track newmembers=[];
    connectedCallback(){
        loadStyle(this, grantstheme + '/styles/main.css');
        this.fetchInfo();

    } 
       

    fetchInfo(){
        fetchGroupMembersInfo({groupId:this.recordId}).then(result => {
            if(result[0]){
                this.existingmembers = JSON.parse(result[0]);
            }
            if(result[1]) {
                this.newmembers = JSON.parse(result[1]);
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    handleDeleteClick(event){
        deleteGroupMember({groupId:this.recordId,groupMemberId:event.target.title}).then(result => {
            if(result[0]){
                this.existingmembers = JSON.parse(result[0]);
            }
            if(result[1]) {
                this.newmembers = JSON.parse(result[1]);
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    handleAddClick(event){
        addGroupMember({groupId:this.recordId,reviewTeamMemberId:event.target.title}).then(result => {
            if(result[0]){
                this.existingmembers = JSON.parse(result[0]);
            }
            if(result[1]) {
                this.newmembers = JSON.parse(result[1]);
            }
        })
        .catch(error => {
            this.error = error;
        });
    }
}