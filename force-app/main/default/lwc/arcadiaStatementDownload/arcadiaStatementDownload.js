import { LightningElement, api, wire } from 'lwc';
import { showToast, b64toBlob } from 'c/arcadiaUtils';

import labels from 'c/arcadiaLabelService';

import getAccessToken from '@salesforce/apex/arcadiaStatementDownloadCtrl.getAccessToken';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import STATEMENT_ID_FIELD from '@salesforce/schema/UtilityMeterUsage__c.Arcadia_Statement_id__c';

const fields = [STATEMENT_ID_FIELD];

export default class arcadiaStatementDownload extends LightningElement {
    @api recordId;
    isLoading = false;
    labels = labels; // using CS label service

    @wire(getRecord, { recordId: '$recordId', fields })
    usage;

    async downloadStatement(event) {
        this.isLoading = true;

        const statementId = getFieldValue(this.usage.data, STATEMENT_ID_FIELD);
        if (statementId == null || statementId == '') {
            showToast(this, '', labels.Arcadia_StatementDownload_DownloadError, 'error');
            this.isLoading = false;
            return;
        }

        await getAccessToken()
            .then(async token => {
                if (token == null || token == '') {
                    showToast(this, '', labels.Arcadia_Login_Failure_Error_Message, 'error');
                    return;
                }

                await fetch('https://api.urjanet.com/utility/statements/' + statementId + '/source', {
                    method: 'GET',
                    headers: {
                        authorization: 'Bearer ' + token
                    }
                })
                    .then(resp => {
                        if (resp.ok) {
                            return resp.arrayBuffer();
                        } else {
                            showToast(this, '', labels.Arcadia_StatementDownload_DownloadError, 'error');
                            throw new Error('Network response was not ok.');
                        }
                    })
                    .then(resp => {
                        // set the blob type to final pdf
                        const file = new Blob([resp], { type: 'application/pdf' });

                        // process to auto download it
                        const fileURL = URL.createObjectURL(file);
                        const link = document.createElement('a');
                        link.href = fileURL;
                        link.download = statementId + '.pdf';
                        link.click();
                        showToast(this, '', labels.Arcadia_StatementDownload_DownloadSuccess, 'success');
                    })
                    .catch(error => {
                        showToast(this, '', labels.Arcadia_StatementDownload_DownloadError, 'error');
                    });
            })
            .catch(error => {
                showToast(this, '', labels.Arcadia_StatementDownload_DownloadError, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}
