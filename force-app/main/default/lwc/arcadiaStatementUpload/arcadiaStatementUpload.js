import { LightningElement,api,track } from 'lwc';
import {showToast,parseErrorMessage} from 'c/arcadiaUtils';

import labels from 'c/arcadiaLabelService';

import uploadFile from '@salesforce/apex/ArcadiaStatementUploadCtrl.uploadFile';
import { RefreshEvent } from 'lightning/refresh';


export default class ArcadiaStatementUpload extends LightningElement {
    MAX_FILE_SIZE = 2621440; //2.5mb in bytes

    @api recordId;
    isLoading = false;
    fileName = '';
    @track fileDetails = {};

    labels = labels; // using CS label service

    handleFileChange(event){
        this.isLoading = true;
       
        if (event.target.files.length > 0) {
            let file = event.target.files[0];
            let reader = new FileReader();
            
            //validata that file size is less than or equal the maximum file size
            if(file.size>this.MAX_FILE_SIZE){
                showToast(this,'',labels.Arcadia_StatementUpload_LargeFileError,'error');
                this.isLoading = false;
                return;
            }

            //event to be fired once readAsDataURL is complete
            reader.onload = e => {
                //extract the file base64 content from the url generate from the readAsDataURL
                let base64 = 'base64,';
                let content = reader.result.indexOf(base64) + base64.length;
                let fileContents = reader.result.substring(content); //get the file content by getting the substring from the position after the comma 

                //call apex to publish the file content to arcadia
                this.fileDetails={fileName: file.name, fileContent: fileContents};
                uploadFile({fileDetails:this.fileDetails,supplierId:this.recordId,fileName:file.name}).then(status=>{
                    showToast(this,'',labels.Arcadia_StatementUpload_UploadSuccess,'success');
                    this.dispatchEvent(new RefreshEvent());
                }).catch(error=>{
                    showToast(this,'',labels.Arcadia_StatementUpload_UploadError,'error');
                }).finally(()=>{
                    this.isLoading=false; 
                })
            };
            reader.readAsDataURL(file);
        }
    }
}