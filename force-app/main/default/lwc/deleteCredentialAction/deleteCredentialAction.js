import { LightningElement, api, wire } from 'lwc';
import isBatchExecutionCompleted from '@salesforce/apex/UtilityCredentialSyncBatchController.isBatchExecutionCompleted';
import deleteCredential from '@salesforce/apex/DeleteCredentialApiController.deleteCredentialMethod';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import LABEL_SUCCESS from '@salesforce/label/c.Success';
import LABEL_HANDLE_RETRIEVE_DATA_ERROR from '@salesforce/label/c.HandleRetrieveDataErrorMsg';
import getDevelopmentOrg from '@salesforce/apex/UrjanetUtils.getDevelopmentOrg';

export default class DeleteCredentialAction extends NavigationMixin(LightningElement) {
    label = {
        LABEL_SUCCESS,
        LABEL_HANDLE_RETRIEVE_DATA_ERROR
    };
    deletionErrorMessage = 'Error in Deleting Credentials !! Please contact system administrator';
    @api recordId; //credentialId
    showLoading = false;

    @wire(getDevelopmentOrg)
    developmentOrgData;

    handleCancel() {
        this.closeQuickAction();
    }

    handleDeleteOnlyinSfdc() {
        this.callDeletionApi('DELETE_IN_SFDC');
    }

    handleProceed() {
        this.callDeletionApi('DELETE_IN_BOTH');
    }

    async callDeletionApi(actionParam) {
        this.showLoading = true;
        const result = await isBatchExecutionCompleted({ isTesting: false });
        if (!result) {
            this.closeQuickAction();
            this.showLoading = false;
            this.showToastMethod('Error', this.label.LABEL_HANDLE_RETRIEVE_DATA_ERROR, 'error');
        } else {
            this.deleteCredentialMethod(actionParam);
        }
    }

    deleteCredentialMethod(actionParam) {
        deleteCredential({ credentialId: this.recordId, actionParameter: actionParam })
            .then(result => {
                if (result.statusCode === 'SUCCESS') {
                    this.showToastMethod(this.label.LABEL_SUCCESS, result.message, 'success');
                    this.closeQuickAction();
                    this.navigateToCredentialListView();
                } else {
                    this.showToastMethod('Error', result.message, 'error');
                    this.closeQuickAction();
                }
                this.showLoading = false;
            })
            .catch(error => {
                this.showToastMethod('Error', this.deletionErrorMessage, 'error');
                this.closeQuickAction();
                this.showLoading = false;
            });
    }

    showToastMethod(titleVar, messageVar, variantVar) {
        const event = new ShowToastEvent({
            title: titleVar,
            message: messageVar,
            variant: variantVar
        });
        this.dispatchEvent(event);
    }

    navigateToCredentialListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName:
                    this.developmentOrgData.data === true ? 'UtilityCredential__c' : 'urjanet__UtilityCredential__c',
                actionName: 'list'
            },
            state: {
                filterName: this.developmentOrgData.data === true ? 'All' : 'urjanet__All'
            }
        });
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
