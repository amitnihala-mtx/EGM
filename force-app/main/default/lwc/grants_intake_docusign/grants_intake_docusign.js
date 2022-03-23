import { LightningElement, api, track } from "lwc";
import sendEnvelope from "@salesforce/apex/EmbeddedSigningController.sendEnvelope";
import getEmbeddedSigningUrl from "@salesforce/apex/EmbeddedSigningController.getEmbeddedSigningUrl";

export default class Grants_intake_docusign extends LightningElement {
    @track showSpinner = false;

    template = "29dba4bc-a627-4819-9613-62c856a24974";
    description = "Embedded Signing";
    @api recordId;
    handleClick() {
        this.showSpinner = true;
        console.log(this.recordId);
        sendEnvelope({
            template: this.template,
            description: this.description,
            recordId: this.recordId,
        })
            .then((envelopeId) =>
                getEmbeddedSigningUrl({
                    envId: envelopeId,
                    url: window.location.href,
                    //url: new URL('http://www.docusign.com')
                })
            )
            .then((signingUrl) => {
                console.log(signingUrl);
                window.location.href = signingUrl;
                this.showSpinner = false;
                //window.open(signingUrl);
            })
            .catch((error) => {
                console.log("Error:");
                console.log(error);
                this.showSpinner = false;
            });
    }
}