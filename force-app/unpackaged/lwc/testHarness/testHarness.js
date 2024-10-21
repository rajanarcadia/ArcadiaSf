import { LightningElement } from 'lwc';
import getAccessToken from '@salesforce/apex/TestHarnessController.getAccessToken';
import getCredentialsResponse from '@salesforce/apex/TestHarnessController.getCredentialsResponse';
import getAccountsByCredsResponse from '@salesforce/apex/TestHarnessController.getAccountsByCredsResponse';
import getUpdateUrlByCredResponse from '@salesforce/apex/TestHarnessController.getUpdateUrlByCredResponse';
import retrieveMeterDetailsResponse from '@salesforce/apex/TestHarnessController.retrieveMeterDetailsResponse';
import getMetersByAccountResponse from '@salesforce/apex/TestHarnessController.getMetersByAccountResponse';

export default class TestHarness extends LightningElement {
    accessToken;
    response;
    responseType;
    inputId;
    requestParams = [];

    sendAccessTokenRequest() {
        this.response = 'Sending...';
        getAccessToken()
            .then(result => {
                console.log(result);
                this.response = result;
                this.responseType = 'Authentication';
                this.accessToken = JSON.parse(result).token;
            })
            .catch(error => {
                console.error(error);
                this.response = error;
            });
    }

    sendCredentialsRequest() {
        this.response = 'Sending...';
        getCredentialsResponse({ requestParams: this.requestParams })
            .then(result => {
                console.log(result);
                this.response = result;
                this.responseType = 'Get Credentials by Correlation Id';
            })
            .catch(error => {
                console.error(error);
                this.response = JSON.stringify(error);
            });
    }

    sendAccountsByCredsRequest() {
        console.log('coming in here');
        this.response = 'Sending...';
        console.log('the value of requestParams' + this.requestParams);
        getAccountsByCredsResponse({ requestParams: this.requestParams })
            .then(result => {
                console.log(result);
                this.response = result;
                this.responseType = 'Get Accounts by Creds';
            })
            .catch(error => {
                console.error(error);
                this.response = error;
            });
    }

    sendMetersByAccountRequest() {
        this.response = 'Sending...';
        getMetersByAccountResponse({ requestParams: this.requestParams })
            .then(result => {
                console.log(result);
                this.response = result;
                this.responseType = 'Get Meters by Account';
            })
            .catch(error => {
                console.error(error);
                this.response = JSON.stringify(error);
            });
    }

    sendMeterDetailsRequest() {
        this.response = 'Sending...';
        retrieveMeterDetailsResponse({ requestParams: this.requestParams })
            .then(result => {
                console.log(result);
                this.response = result;
                this.responseType = 'Retrieve Meter details';
            })
            .catch(error => {
                console.error(error);
                this.response = JSON.stringify(error);
            });
    }

    sendUpdateUrlByCredRequest() {
        this.response = 'Sending...';
        getUpdateUrlByCredResponse({ requestParams: this.requestParams })
            .then(result => {
                console.log(result);
                this.response = result;
                this.responseType = 'Get Update Url by site Id';
            })
            .catch(error => {
                console.error(error);
                this.response = JSON.stringify(error);
            });
    }

    handleInputChange(event) {
        this.requestParams = [];
        this.inputId = event.detail.value;
        this.requestParams.push(this.inputId);
    }
}
