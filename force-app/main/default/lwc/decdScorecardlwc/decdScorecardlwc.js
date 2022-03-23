import { api, LightningElement, track } from 'lwc';
import fetchScoreMetrics from "@salesforce/apex/DECDScorecardController.fetchScoreMetrics";
import saveScoreMetrics from "@salesforce/apex/DECDScorecardController.saveScoreMetrics";
import submitScorecard from "@salesforce/apex/DECDScorecardController.submitScorecard";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import uId from '@salesforce/user/Id';


import grantstheme from '@salesforce/resourceUrl/Grants_Design'; 
import { loadStyle, loadScript } from 'lightning/platformResourceLoader'; 

export default class DecdScorecardlwc extends LightningElement {

    connectedCallback(){
        loadStyle(this, grantstheme + '/styles/main.css');
    } 
    
    @api recordId;


    @track scoremetrics = [];
    @track showSpinner = false;
    userId = uId;
    @track isLoaded = false;
    @track scorestatus = '';

    connectedCallback() {
        this.fetchmetrics();
    }

    fetchmetrics() {
        this.showSpinner = true;
        fetchScoreMetrics({ scorecardId: this.recordId, userId: this.userId })
            .then(result => {

                // this.scoremetrics = [];
                this.scoremetrics = [...result];

                console.log(' ' + JSON.stringify(this.scoremetrics));

                if (this.scoremetrics.length > 0) {
                    if (this.scorestatus === '') {
                        this.scorestatus = this.scoremetrics[0].Scorecard__r.Status__c;
                    }

                    for (let i = 0; i < this.scoremetrics.length; i++) {

                        this.scoremetrics[i]['isNumber'] = false;
                        this.scoremetrics[i]['isTextArea'] = false;
                        this.scoremetrics[i].indval = i;

                        if (this.scoremetrics[i]['Points__c'] === null || this.scoremetrics[i]['Points__c'] === undefined) {
                            this.scoremetrics[i]['Points__c'] = 0;

                        }

                        this.scoremetrics[i]['questionclass'] = "test";

                        if (this.scoremetrics[i]['Layout_Type__c'] === 'Information') {
                            this.scoremetrics[i]['questionclass'] = 'info'
                        } else if (this.scoremetrics[i]['Layout_Type__c'] === 'Section') {
                            this.scoremetrics[i]['questionclass'] = 'section'
                        } else {
                            this.scoremetrics[i]['questionclass'] = 'field'
                        }

                        if (this.scoremetrics[i].Field_Type__c === 'Number') {
                            this.scoremetrics[i]['isNumber'] = true;
                        }
                        if (this.scoremetrics[i].Field_Type__c === 'TextArea') {
                            this.scoremetrics[i]['isTextArea'] = true;
                        }


                    }
                }

                this.scoremetrics = JSON.parse(JSON.stringify(this.scoremetrics));

                console.log('records ' + JSON.stringify(this.scoremetrics));

                this.showSpinner = false;
                this.isLoaded = true;
            })
    }

    renderedCallback() {
        if (this.showButtons !== undefined && this.showButtons !== null && this.showButtons === false) {

            var inp = this.template.querySelectorAll('lightning-slider');
            for (let i = 0; i < inp.length; i++) {
                inp[i].disabled = true;
            }

            var inp2 = this.template.querySelectorAll('lightning-textarea');
            for (let i = 0; i < inp2.length; i++) {
                inp2[i].disabled = true;
            }
        }
    }

    get showButtons() {
        return (this.scoremetrics !== undefined && this.scoremetrics !== null &&
            this.scoremetrics.length > 0 && this.scoremetrics[0].Scorecard__r.OwnerId === this.userId &&
            this.scoremetrics[0].Scorecard__r.Status__c !== 'Completed');
    }

    get showOwnerMessage() {
        console.log('getttt ' + JSON.stringify(this.scoremetrics.length));
        return this.isLoaded === true && (this.scoremetrics === undefined || this.scoremetrics === null ||
            this.scoremetrics.length <= 0);
    }

    get OwnerError() {
        return 'Something went wrong. Please contact System Admistrator.';
    }

    handleSaveClick() {

        this.showSpinner = true;

        console.log('JSON.stringify(this.scoremetrics)   ' + JSON.stringify(this.scoremetrics));

        let records = [];
        for (let i = 0; i < this.scoremetrics.length; i++) {
            records.push({
                Id: this.scoremetrics[i].Id,
                Points__c: this.scoremetrics[i].Points__c,
                Answer__c: this.scoremetrics[i].Answer__c,
            })
        }

        saveScoreMetrics({ recordsToUpdate: records, scorecardId: this.recordId })
            .then(result => {
                console.log('Result', result);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Scorecard is saved succesfully!',
                    message: '',
                    variant: 'success'
                }));
                this.refreshlwc();
                this.showSpinner = false;
            })
            .catch(error => {
                console.error('Error:', error);
                this.showSpinner = false;
            })
    }

    handleSliderChange(event) {
        let index = event.target.dataset.indval;
        this.scoremetrics[index]['Points__c'] = event.detail.value;
    }

    handleTextAreaChange(event){
        let index = event.target.dataset.indval;
        this.scoremetrics[index]['Answer__c'] = event.detail.value;
    }

    handleSubmitClick(event) {
        this.showSpinner = true;

        console.log('handleSubmitClick   ' + JSON.stringify(this.scoremetrics));

        let records = [];
        for (let i = 0; i < this.scoremetrics.length; i++) {
            records.push({
                Id: this.scoremetrics[i].Id,
                Points__c: this.scoremetrics[i].Points__c,
                Answer__c: this.scoremetrics[i].Answer__c,
            })
        }

        saveScoreMetrics({ recordsToUpdate: records,  scorecardId: this.recordId  })
            .then(result => {
                console.log('Result', result);
                this.makeSubmitCall();
            })
            .catch(error => {
                console.error('Error:', error);
                this.showSpinner = false;
            })
    }

    makeSubmitCall() {
        submitScorecard({ recordId: this.recordId })
            .then(result => {
                console.log('Result', result);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Scorecard is submitted succesfully!',
                    message: '',
                    variant: 'success'
                }));
                this.fetchmetrics();
                this.refreshlwc(result);
            })
            .catch(error => {
                console.error('Error:', error);
                this.showSpinner = false;
            })
    }

    refreshlwc(result){
        this.dispatchEvent(new CustomEvent('success',{ detail: { proposalupdated: result } }));
        //eval("$A.get('e.force:refreshView').fire();");
    }

}