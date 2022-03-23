import { LightningElement, track } from 'lwc';
import getManageAccountEmployerDetails from '@salesforce/apex/ManageAccountController.getManageAccountEmployerDetails';
import updateManageAccountEmployer from '@salesforce/apex/ManageAccountController.updateManageAccountEmployer';
import fetchUserDetail from '@salesforce/apex/ManageAccountController.fetchUserDetail';
import uploadProilePhoto from '@salesforce/apex/ManageAccountController.uploadProilePhoto';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import desetheme from '@salesforce/resourceUrl/DESE_Design';

export default class GrantsMyProfile extends LightningElement {
    @track showSpinner;
    @track flag = false;
    @track getData = {
        FirstName: "",
        LastName: "",
        EmergencyPhoneNumber: "",
        StreetAddress: "",
        City: "",
        Province: "",
        PostalCode: "",
        DateofBirth: "",
        PhoneNumber: "",
        Email: "",
        OrganizationID: "",
        OrganizationName: "",
        OrganizationType: "",
        OrganizationEmail: "",
        OrganizationWebsite: "",
        OrganizationAddressLine1: "",
        OrganizationAddressLine2: "",
        OrganizationCity: "",
        OrganizationState: "",
        OrganizationPostalCode: "",
        OrganizationPhoneNumber: ""
    };
    @track profileUrl;

    @track profileUpload = desetheme + '/theme/images/profile-upload.svg';

    get acceptedFormats() {
        return [".jpg", ".png", ".jpeg"];
    }

    handleChange(event) {
        this.flag = true;
        let changeName = event.target.name;
        let changeValue = event.target.value;
        this.getData[changeName] = changeValue;
    }
    connectedCallback() {
        this.showSpinner = true;
        this.getProfileData();
        this.getProfilePicture();
    }
    getProfileData() {
        getManageAccountEmployerDetails().then(data => {
            var result = JSON.parse(data);
            this.getData = result;
            console.log('result :>> ', JSON.stringify(this.getData));
            this.showSpinner = false;
        })
            .catch(error => {
                console.log('error :>> ', error);
                this.showSpinner = false;
            });
    }

    getProfilePicture() {
        fetchUserDetail().then(result => {
            this.profileUrl = result.FullPhotoUrl;
            this.showSpinner = false;
        }).catch(
            error => {
                console.log("Error", error);
                this.showSpinner = false;
            }
        );
    }

    handleFileUpload(event) {
        const uploadedFiles = event.detail.files;
        uploadProilePhoto({
            documentId: uploadedFiles[0].documentId
        });
        location.reload();
    }

    handleSave() {
        console.log('getData :>> ', JSON.stringify(this.getData));
        if (this.flag) {
            this.showSpinner = true;
            updateManageAccountEmployer({
                manageAccData: JSON.stringify(this.getData)
            }).then(data => {
                console.log('data :>> ', data);
                this.showToast("Success", "Details updated successfully", "success");
                location.reload();
                this.getProfileData();
                this.showSpinner = false;
            })
                .catch(error => {
                    console.log('error :>> ', error);
                    this.showSpinner = false;
                });
        }
        else{
            this.showToast("Warning", "No values changed", "warning");

        }
    }

    // show toast
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}