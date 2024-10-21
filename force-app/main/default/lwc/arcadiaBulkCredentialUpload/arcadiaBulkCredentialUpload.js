import { LightningElement } from 'lwc';
import { showToast, exportCSVFile, parseErrorMessage, csvToArray, formatString } from 'c/arcadiaUtils';

import labels from 'c/arcadiaLabelService';

//static resources
import ArcadiaBulkCredentialTemplate from '@salesforce/resourceUrl/ArcadiaBulkCredentialTemplate';

import uploadBulkCredentials from '@salesforce/apex/ArcadiaBulkCredentialUploadCtrl.uploadBulkCredentials';
import getArcadiaProviders from '@salesforce/apex/ArcadiaBulkCredentialUploadCtrl.getArcadiaProviders';
import createSalesforceCredentials from '@salesforce/apex/ArcadiaBulkCredentialUploadCtrl.createSalesforceCredentials';
import deleteSalesforceCredentials from '@salesforce/apex/ArcadiaBulkCredentialUploadCtrl.deleteSalesforceCredentials';

const PROVIDERS_FILENAME = 'ArcadiaServiceProviders';
export default class ArcadiaBulkCredentialUpload extends LightningElement {
    ////////////////////////Start Variable///////////////////
    ArcadiaBulkCredentialTemplateFile = ArcadiaBulkCredentialTemplate;
    labels = labels; // using CS label service
    isLoading = false;
    ////////////////////////Stop Variable///////////////////

    //////////Start Event Handling////////////
    handleFileChange(event) {
        this.isLoading = true;
        this.parseCSVFile(event.target.files[0]);
    }

    downloadArcadiaProviders() {
        this.isLoading = true;
        getArcadiaProviders()
            .then(results => {
                exportCSVFile(results, PROVIDERS_FILENAME);
            })
            .catch(error => {
                showToast(this, '', labels.Arcadia_ServiceProviders_DownloadError, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    //////////End Event Handling////////////

    /////////////Start Helper Methods/////////////

    //helper method used to parse the CSV file and convert it to an array of object
    parseCSVFile(file) {
        let freader = new FileReader();

        freader.onload = fr => {
            const text = freader.result;
            const data = csvToArray(text);

            //to remove the empty rows
            var cleanedData = [];
            for (let i = 0; i < data.length; i++) {
                if (JSON.stringify(data[i]) !== '{}') {
                    cleanedData.push(data[i]);
                }
            }
            this.createSfCredentials(cleanedData);
        };

        freader.readAsText(file);
    }

    //helper method called to create the array of credentials from the CSV file to SF
    createSfCredentials(arrFileData) {
        createSalesforceCredentials({ jsonCredentialDetails: JSON.stringify(arrFileData) })
            .then(result => {
                if (!result.isValidCsv) {
                    if (result.strEmptyRows !== '')
                        showToast(
                            this,
                            '',
                            formatString(labels.Arcadia_BulkCredential_Invalid_Empty_ColumnsMsg, result.strEmptyRows),
                            'error'
                        );
                    if (result.strInvalidSupplierRows !== '')
                        showToast(
                            this,
                            '',
                            formatString(
                                labels.Arcadia_BulkCredential_Invalid_SupplierMsg,
                                result.strInvalidSupplierRows
                            ),
                            'error'
                        );
                    if (result.strInvalidProviderRows !== '')
                        showToast(
                            this,
                            '',
                            formatString(
                                labels.Arcadia_BulkCredential_Invalid_ProviderMsg,
                                result.strInvalidProviderRows
                            ),
                            'error'
                        );
                    this.isLoading = false;
                } else {
                    if (result.lstCredentials && result.lstCredentials.length > 0) {
                        this.uploadCredentialsToArcadia(result.lstCredentials);
                    }
                    this.isLoading = false;
                    if (result.strDuplicateRows !== '')
                        showToast(
                            this,
                            '',
                            formatString(labels.Arcadia_BulkCredential_DuplicateMsg, result.strDuplicateRows),
                            'info'
                        );
                }
            })
            .catch(error => {
                showToast(this, '', labels.Arcadia_BulkCredential_FailureMsg, 'error');
                this.isLoading = false;
            });
    }

    //method called to upload the credentials to Arcadia after being created in SF
    uploadCredentialsToArcadia(lstCredentials) {
        uploadBulkCredentials({ jsonCredentialDetails: JSON.stringify(lstCredentials) })
            .then(isBulkUploaded => {
                if (!isBulkUploaded) {
                    showToast(this, '', labels.Arcadia_BulkCredential_FailureMsg, 'error');
                    this.deleteSfCredentials(lstCredentials);
                } else {
                    showToast(this, '', labels.Arcadia_BulkCredential_SuccessMsg, 'success');
                    this.isLoading = false;
                }
            })
            .catch(error => {
                showToast(this, '', labels.Arcadia_BulkCredential_FailureMsg, 'error');
                this.deleteSfCredentials(lstCredentials);
            });
    }

    //method called to delete the created SF credentials
    deleteSfCredentials(lstCredentials) {
        deleteSalesforceCredentials({ jsonCredentialDetails: JSON.stringify(lstCredentials) })
            .then(() => {})
            .catch(error => {
                showToast(this, '', labels.Arcadia_BulkCredential_FailureMsg, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    /////////////End Helper Methods/////////////
}
