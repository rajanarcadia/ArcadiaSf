import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Import the URL for the static resource named 'UrjanetNZCAssets'
import URJANET_NZC_ASSETS from '@salesforce/resourceUrl/UrjanetNZCAssets';

// Import custom labels
import LABEL_PUSH_SITES_TO_URJANET from '@salesforce/label/c.PushSitesToUrjanet';
import LABEL_SYNC_ACTION_HEADER from '@salesforce/label/c.SyncActionsHeader';
import LABEL_REFRESH_URJANET_DATA from '@salesforce/label/c.RefreshUrjanetData';
import LABEL_REFRESH_URJANET_DATA_DESC from '@salesforce/label/c.RefreshUrjanetDataDesc';
import LABEL_PUSH_SITES_TO_URJANET_DESC from '@salesforce/label/c.PushSitesToUrjanetDesc';
import LABEL_SUCCESS from '@salesforce/label/c.Success';
import LABEL_URJANET_NAME from '@salesforce/label/c.CompanyName';
import LABEL_HANDLE_PUSH_SITES_SUCCESS from '@salesforce/label/c.HandlePushSitesSuccess';
import LABEL_HANDLE_RETRIEVE_DATA_SUCCESS from '@salesforce/label/c.HandleRetrieveDataSuccess';
import LABEL_HANDLE_RETRIEVE_DATA_ERROR from '@salesforce/label/c.HandleRetrieveDataErrorMsg';
//import controllers
import pushSitesToUrjanet from '@salesforce/apex/UtilityCredentialSyncBatchController.pushSitesToUrjanet';
import executeBatchJob from '@salesforce/apex/UtilityCredentialSyncBatchController.executeBatchJob';
import isBatchExecutionCompleted from '@salesforce/apex/UtilityCredentialSyncBatchController.isBatchExecutionCompleted';
export default class UrjanetSyncActions extends LightningElement {
    // URL for Urjanet Logo
    URJANET_LOGO = URJANET_NZC_ASSETS + '/UrjanetNZCAssets/img/arcadiaLogo.svg';
    disableRefreshButton = false;

    // Expose the labels to use in the template.
    label = {
        LABEL_URJANET_NAME,
        LABEL_SYNC_ACTION_HEADER,
        LABEL_PUSH_SITES_TO_URJANET,
        LABEL_PUSH_SITES_TO_URJANET_DESC,
        LABEL_REFRESH_URJANET_DATA,
        LABEL_REFRESH_URJANET_DATA_DESC,
        LABEL_SUCCESS,
        LABEL_HANDLE_PUSH_SITES_SUCCESS,
        LABEL_HANDLE_RETRIEVE_DATA_SUCCESS,
        LABEL_HANDLE_RETRIEVE_DATA_ERROR
    };

    handlePushSites() {
        try {
            pushSitesToUrjanet();
            const event = new ShowToastEvent({
                title: LABEL_SUCCESS,
                message: LABEL_HANDLE_PUSH_SITES_SUCCESS,
                variant: 'success'
            });
            this.dispatchEvent(event);
        } catch (error) {
            const event = new ShowToastEvent({
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(event);
        }
    }

    async handleRetrieveData() {
        try {
            this.disableRefreshButton = true;
            const result = await isBatchExecutionCompleted({ isTesting: false });
            if (result) {
                await executeBatchJob({ isTesting: false });
                const event = new ShowToastEvent({
                    title: LABEL_SUCCESS,
                    message: LABEL_HANDLE_RETRIEVE_DATA_SUCCESS,
                    variant: 'success'
                });
                this.dispatchEvent(event);
            } else {
                const event = new ShowToastEvent({
                    message: LABEL_HANDLE_RETRIEVE_DATA_ERROR,
                    variant: 'error'
                });
                this.dispatchEvent(event);
            }
        } catch (error) {
            const event = new ShowToastEvent({
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(event);
        }
        this.disableRefreshButton = false;
    }
}
