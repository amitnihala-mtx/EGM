import { LightningElement, api, track, wire } from 'lwc';
import {showMessage} from 'c/grants_Utility';
import getScorecards from '@salesforce/apex/Grants_ProposalReviewController.getScorecards';

import grantstheme from '@salesforce/resourceUrl/Grants_Design'; 
import { loadStyle, loadScript } from 'lightning/platformResourceLoader'; 

export default class Grants_DisplayScorecardsForProposal extends LightningElement {
    @api proposalRecId;
    @track scorecardsArr = [];
    avgScore=0;
    openModal = false;
    scorecardRecId;
    scorecardsNotFound;

    connectedCallback(){
        loadStyle(this, grantstheme + '/styles/main.css');
        this.loadScorecards();
    }  

    /*@wire(getScorecards, {proposalRecId : '$proposalRecId'})
    wiredScorecards({data, error}){
        if(error){
            this.scorecardsNotFound = false;
            showMessage(this,'Error occured while fetching Scorecards', error.message.body, 'error', 'pester');
        }else if(data){
            this.scorecardsArr = (!Array.isArray(data)) ? this.scorecardsArr.push(data) : data;
            let totalscore = 0;
            this.scorecardsArr.forEach(score=>{
                if(score.Scored_Points__c) {
                    totalscore += score.Scored_Points__c;
                } else {
                    totalscore += 0;
                }
            });
            this.avgScore = this.scorecardsArr.length == 0 ? 0 : (totalscore==0 ? 0 : (totalscore/this.scorecardsArr.length).toFixed(2));
            this.scorecardsNotFound = this.scorecardsArr.length == 0 ? true : false;
        }
    }*/

    openScorecardModal(event){
        this.scorecardRecId = event.target.dataset.recordId;
        this.openModal = true;
    }

    closeScorecardModal(){
        this.openModal = false;
        this.scorecardRecId = null;
    }
    handleSuccess(event){
        this.openModal = false;
        this.scorecardRecId = null;
        this.loadScorecards();
        if(event.detail.proposalupdated==true){
            this.dispatchEvent(new CustomEvent('successscore'));
        }
    }
    loadScorecards(){
        getScorecards({proposalRecId : this.proposalRecId}).then(data => {
            this.scorecardsArr = (!Array.isArray(data)) ? this.scorecardsArr.push(data) : data;
            let totalscore = 0;
            this.scorecardsArr.forEach(score=>{
                if(score.Scored_Points__c) {
                    totalscore += score.Scored_Points__c;
                } else {
                    totalscore += 0;
                }
            });
            this.avgScore = this.scorecardsArr.length == 0 ? 0 : (totalscore==0 ? 0 : (totalscore/this.scorecardsArr.length).toFixed(2));
            this.scorecardsNotFound = this.scorecardsArr.length == 0 ? true : false;
        })
        .catch(error => {
            this.scorecardsNotFound = false;
            showMessage(this,'Error occured while fetching Scorecards', error.message.body, 'error', 'pester');
        })
    }
    /*get avgScore(){
        return (this.scorecardsArr.length > 0 && this.scorecardsArr[0].Proposal__r 
            && this.scorecardsArr[0].Proposal__r.Proposal_Average_Score__c) ? this.scorecardsArr[0].Proposal__r.Proposal_Average_Score__c : '';
    }*/
}