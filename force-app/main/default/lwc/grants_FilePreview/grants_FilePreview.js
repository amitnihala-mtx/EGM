import { LightningElement, api, track, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { showMessage } from 'c/grants_Utility';

import grantstheme from '@salesforce/resourceUrl/Grants_Design'; 
import { loadStyle, loadScript } from 'lightning/platformResourceLoader'; 

import getRelatedFilesByRecordId from '@salesforce/apex/Grants_ProposalReviewController.getRelatedFilesByRecordId';

export default class Grants_FilePreview extends NavigationMixin(LightningElement){

    connectedCallback(){
        loadStyle(this, grantstheme + '/styles/main.css');
    }  

    @api recordId;
    @track filesList = [];
    filesNotFound;
    columns = [
        { label: 'File Name', fieldName: 'label', type: 'text', cellAttributes: { alignment: 'left' }},
        { label: '', type: 'button', typeAttributes: {iconName: 'utility:preview', name:'Preview', variant: 'container', label:'Preview', iconPosition: 'right'}, cellAttributes: { alignment: 'center' }}
    ];

    @wire(getRelatedFilesByRecordId, {recordId: '$recordId'})
    wiredResult({data, error}){
        if(data){ 
            this.filesList = Object.keys(data).map(item=>({"label":data[item],
             "value": item
            }))
            this.filesNotFound = this.filesList.length > 0 ? false : true;

        }
        if(error){ 
            showMessage(this, 'Error occured while fetching files', error.body.message, 'error', 'pester');
        }
    }

    previewHandler(event){
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: event.detail.row.value
            }
        })
    }
}