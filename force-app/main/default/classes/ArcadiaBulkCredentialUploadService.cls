public with sharing class ArcadiaBulkCredentialUploadService {
    ////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////Start Public Methods//////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////
    public List<GetArcadiaServiceProvidersResponse.ProviderDetails> getArcadiaProviders() {
        List<GetArcadiaServiceProvidersResponse.ProviderDetails> lstProviders = new List<GetArcadiaServiceProvidersResponse.ProviderDetails>();
        Integer PAGE_SIZE = 800; //to avoid heap memory issue
        Integer pageNumber = 0;
        Boolean hasNext = true;

        while (hasNext) {
            List<String> lstReqParams = new List<String>{ String.valueOf(PAGE_SIZE), String.valueOf(pageNumber) };
            GetArcadiaServiceProvidersResponse response = (GetArcadiaServiceProvidersResponse) new UrjanetApiClient()
                .getUrjanetResponse(UrjanetEnums.RequestType.LIST_PROVIDERS, UrjanetEnums.ApiMethod.GET, lstReqParams);
            if (response.errorMsg == null) {
                if (response.embedded != null && response.embedded.providers != null) {
                    lstProviders.addAll(response.embedded.providers);
                }

                pageNumber++;
                if (pageNumber < response.page.totalPages) {
                    hasNext = true;
                } else {
                    hasNext = false;
                }
            } else {
                Logger.getInstance()
                    .log(
                        ArcadiaBulkCredentialUploadService.class.getName(),
                        response.errorMsg + ' ' + response.message
                    );
                throw new ArcadiaCalloutServiceException(response.errorMsg + ' ' + response.message, response.status);
            }
        }
        return lstProviders;
    }

    //Method called to create CSV bulk credentials in Salesforce if no missing data , otherwise return the index of the rows with errors
    public BulkCredentialsCreationResponse createSalesforceCredentials(String jsonCredentialDetails) {
        BulkCredentialsCreationResponse response = new BulkCredentialsCreationResponse();

        //deserialize the csv credentials detials
        List<BulkCredentialDetails> lstCredentials = (List<BulkCredentialDetails>) JSON.deserialize(
            jsonCredentialDetails,
            List<BulkCredentialDetails>.class
        );

        //validate that CSV file Data are valid
        isValidCredentials(lstCredentials, response);

        //if no error found, insert the credentials in SF and get their correlation Ids
        if (response.isValidCsv) {
            response.isSuccess = true;
            response.lstCredentials = insertCredentials(lstCredentials, response);
        }
        return response;
    }

    //Method called to upload the bulk credentials to Arcadia
    public Boolean uploadBulkCredentials(String jsonCredentialDetails) {
        List<String> requestParams = new List<String>{ jsonCredentialDetails };
        PostBulkCredentialsResponse response = (PostBulkCredentialsResponse) new UrjanetApiClient()
            .getUrjanetResponse(
                UrjanetEnums.RequestType.CREATE_BULK_CREDENTIALS,
                UrjanetEnums.ApiMethod.POST,
                requestParams
            );
        if (response.errorMsg == null) {
            return true;
        } else {
            Logger.getInstance().log(ArcadiaBulkCredentialUploadService.class.getName(), response.errorMsg);
            throw new ArcadiaCalloutServiceException(response.errorMsg, response.status);
        }
    }

    //Method called to delete the SF credentials if calling the Bulk endpoint failed
    public void deleteSalesforceCredentials(String jsonCredentialDetails) {
        List<BulkCredentialDetails> lstCredentials = (List<BulkCredentialDetails>) JSON.deserialize(
            jsonCredentialDetails,
            List<BulkCredentialDetails>.class
        );
        List<UtilityCredential__c> lstDeleteCreds = new List<UtilityCredential__c>();
        for (BulkCredentialDetails bulkCredObj : lstCredentials) {
            lstDeleteCreds.add(bulkCredObj.utilityCredObj);
        }
        List<Database.DeleteResult> lstDeleteResults = data.remove(lstDeleteCreds, false, false, false);
        UrjanetUtils.logFailures(
            ArcadiaBulkCredentialUploadService.class.getName(),
            String.valueOf(UtilityCredential__c.SObjectType),
            lstDeleteResults
        );
    }
    ////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////End Public Methods////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////Start Private Methods/////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////

    //method called to validate that credentials are valid
    private void isValidCredentials(
        List<BulkCredentialDetails> lstCredentials,
        BulkCredentialsCreationResponse response
    ) {
        List<Integer> lstEmptyRowIndex = new List<Integer>();
        List<Integer> lstInvalidSupplierRowIndex = new List<Integer>();
        List<Integer> lstInvalidProviderRowIndex = new List<Integer>();

        set<String> setValidSupplierIds = getValidSupplierIds(lstCredentials);
        set<String> setValidProviderIds = getValidProviderIds(lstCredentials);
        Integer rowIndex = 2;
        for (BulkCredentialDetails credObj : lstCredentials) {
            if (
                string.isEmpty(credObj.credentialName) ||
                string.isEmpty(credObj.salesforceSupplierID) ||
                string.isEmpty(credObj.userName1) ||
                string.isEmpty(credObj.password1) ||
                string.isEmpty(credObj.arcadiaServiceProviderID)
            ) {
                lstEmptyRowIndex.add(rowIndex);
            }

            if (
                !String.isEmpty(credObj.salesforceSupplierID) &&
                !setValidSupplierIds.contains(credObj.salesforceSupplierID)
            ) {
                lstInvalidSupplierRowIndex.add(rowIndex);
            }

            if (
                !String.isEmpty(credObj.arcadiaServiceProviderID) &&
                !setValidProviderIds.contains(credObj.arcadiaServiceProviderID)
            ) {
                lstInvalidProviderRowIndex.add(rowIndex);
            }

            rowIndex++;
        }

        if (
            !lstEmptyRowIndex.isEmpty() ||
            !lstInvalidProviderRowIndex.isEmpty() ||
            !lstInvalidSupplierRowIndex.isEmpty()
        ) {
            response.isValidCsv = false;
            response.strEmptyRows = String.join(lstEmptyRowIndex, ', ');
            response.strInvalidProviderRows = String.join(lstInvalidProviderRowIndex, ', ');
            response.strInvalidSupplierRows = String.join(lstInvalidSupplierRowIndex, ', ');
        }
    }

    //method called to get the Valid Salesforce Supplier Ids
    private set<String> getValidSupplierIds(List<BulkCredentialDetails> lstCredentials) {
        set<String> setSupplierIds = new Set<String>();
        Set<String> setValidSupplierIds = new Set<String>();

        for (BulkCredentialDetails credObj : lstCredentials) {
            if (!String.isEmpty(credObj.salesforceSupplierID)) {
                setSupplierIds.add(credObj.salesforceSupplierID);
            }
        }

        if (!setSupplierIds.isEmpty()) {
            for (Supplier supplierObj : new SupplierSelector().getSuppliersByIds(setSupplierIds)) {
                setValidSupplierIds.add(supplierObj.id);
            }
        }

        return setValidSupplierIds;
    }

    //method called to get the Valid Arcadia Provider Ids
    private Set<String> getValidProviderIds(List<BulkCredentialDetails> lstCredentials) {
        set<String> setProviderIds = new Set<String>();
        Set<String> setValidProviderIds = new Set<String>();

        for (BulkCredentialDetails credObj : lstCredentials) {
            if (!String.isEmpty(credObj.arcadiaServiceProviderID)) {
                setProviderIds.add(credObj.arcadiaServiceProviderID);
            }
        }

        list<GetArcadiaServiceProvidersResponse.ProviderDetails> allValidProviderIds = getArcadiaProviders();

        for (GetArcadiaServiceProvidersResponse.ProviderDetails provider : allValidProviderIds) {
            if (setProviderIds.contains(provider.providerId)) {
                setValidProviderIds.add(provider.providerId);
            }
        }

        return setValidProviderIds;
    }

    private List<BulkCredentialDetails> insertCredentials(
        List<BulkCredentialDetails> lstCredentials,
        BulkCredentialsCreationResponse response
    ) {
        List<UtilityCredential__c> lstCreateSfCredentials = new List<UtilityCredential__c>();
        Set<String> setUniqueCorrelationsIds = new Set<String>();
        UtilityCredentialSelector credentialSelector = new UtilityCredentialSelector();
        List<BulkCredentialDetails> validCredentials = new List<BulkCredentialDetails>();
        Set<String> existingFingerPrints = new Set<String>();
        Set<String> existingCorrelationIds = new Set<String>();
        for (UtilityCredential__c credObj : credentialSelector.getAllUtilityCredentials()) {
            existingFingerPrints.add(credObj.ArcadiaServiceProviderId__c + '|' + credObj.Username__c);
            existingCorrelationIds.add(credObj.CorrelationID__c);
        }
        List<Integer> duplicateRowIndex = new List<Integer>();
        Integer rowIndex = 2;

        for (BulkCredentialDetails csvCredentialObj : lstCredentials) {
            csvCredentialObj.toRecord();
            String fingerPrint = csvCredentialObj.arcadiaServiceProviderID + '|' + csvCredentialObj.userName1.trim();
            if (
                existingFingerPrints.contains(fingerPrint) ||
                existingCorrelationIds.contains(csvCredentialObj.correlationID)
            ) {
                duplicateRowIndex.add(rowIndex);
                rowIndex++;
                continue;
            }
            existingFingerPrints.add(fingerPrint);
            if (String.isNotBlank(csvCredentialObj.correlationID)) {
                existingCorrelationIds.add(csvCredentialObj.correlationID);
            }
            lstCreateSfCredentials.add(csvCredentialObj.utilityCredObj);
            validCredentials.add(csvCredentialObj);

            rowIndex++;
        }

        if (!duplicateRowIndex.isEmpty()) {
            response.strDuplicateRows = String.join(duplicateRowIndex, ',');
        }

        if (!lstCreateSfCredentials.isEmpty()) {
            Database.DMLOptions option = new Database.DMLOptions();
            option.OptAllOrNone = false;
            Logger.getInstance()
                .log(
                    ArcadiaBulkCredentialUploadService.class.getName(),
                    UrjanetUtils.getSObjectName(Schema.UtilityCredential__c.SObjectType),
                    Data.create(lstCreateSfCredentials, option, false, false, false, null)
                );
        }

        if (!lstCreateSfCredentials.isEmpty()) {
            Set<Id> setCredentials = new Set<Id>();
            map<Id, String> mapCredentialCorrelations = new Map<Id, String>();
            for (UtilityCredential__c credObj : lstCreateSfCredentials) {
                setCredentials.add(credObj.Id);
            }
            for (
                UtilityCredential__c credObj : new UtilityCredentialSelector()
                    .getUtilityCredentialsByIds(setCredentials)
            ) {
                mapCredentialCorrelations.put(credObj.Id, credObj.correlationId__c);
            }
            List<BulkCredentialDetails> nonDuplicateRecords = new List<BulkCredentialDetails>();
            for (BulkCredentialDetails bulkCredObj : validCredentials) {
                if (mapCredentialCorrelations.containsKey(bulkCredObj.utilityCredObj.id)) {
                    bulkCredObj.correlationID = mapCredentialCorrelations.get(bulkCredObj.utilityCredObj.id);
                    nonDuplicateRecords.add(bulkCredObj);
                }
            }
            return nonDuplicateRecords;
        }

        return null;
    }
    ////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////End Private Methods///////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////

    public class BulkCredentialsCreationResponse {
        @AuraEnabled
        public List<BulkCredentialDetails> lstCredentials { get; set; }
        @AuraEnabled
        public String strEmptyRows { get; set; }
        @AuraEnabled
        public String strInvalidSupplierRows { get; set; }
        @AuraEnabled
        public String strInvalidProviderRows { get; set; }

        public String status { get; set; }
        public String errorMsg { get; set; }

        @AuraEnabled
        public String strDuplicateRows { get; set; }

        @AuraEnabled
        public Boolean isSuccess { get; set; }
        @AuraEnabled
        public Boolean isValidCsv { get; set; }

        public BulkCredentialsCreationResponse() {
            lstCredentials = new List<BulkCredentialDetails>();
            strEmptyRows = '';
            strInvalidProviderRows = '';
            strInvalidSupplierRows = '';
            strDuplicateRows = '';
            isSuccess = false;
            isValidCsv = true;
        }
    }

    public class BulkCredentialDetails {
        @AuraEnabled
        public String credentialName { get; set; }
        @AuraEnabled
        public String userName1 { get; set; }
        @AuraEnabled
        public String userName2 { get; set; }
        @AuraEnabled
        public String userName3 { get; set; }
        @AuraEnabled
        public String userName4 { get; set; }
        @AuraEnabled
        public String password1 { get; set; }
        @AuraEnabled
        public String password2 { get; set; }
        @AuraEnabled
        public String password3 { get; set; }
        @AuraEnabled
        public String password4 { get; set; }
        @AuraEnabled
        public String correlationID { get; set; }
        @AuraEnabled
        public String arcadiaServiceProviderID { get; set; }
        @AuraEnabled
        public String salesforceSupplierID { get; set; }
        @AuraEnabled
        public String websiteURL { get; set; }
        @AuraEnabled
        public UtilityCredential__c utilityCredObj { get; set; }

        public void toRecord() {
            this.utilityCredObj = new UtilityCredential__c();
            this.utilityCredObj.Status__c = UrjanetConstants.CREDENTIAL_STATUS;
            this.utilityCredObj.Username__c = this.userName1;
            this.utilityCredObj.Username2__c = (!String.isEmpty(this.username2) ? this.username2 : '');
            this.utilityCredObj.Username3__c = (!String.isEmpty(this.username3) ? this.username3 : '');
            this.utilityCredObj.Username4__c = (!String.isEmpty(this.username4) ? this.username4 : '');
            this.utilityCredObj.Name = this.credentialName;
            this.utilityCredObj.ProviderName__c = this.salesforceSupplierID;
            this.utilityCredObj.CorrelationID__c = (!String.isEmpty(this.correlationID) ? this.correlationID : '');
            this.utilityCredObj.ArcadiaServiceProviderId__c = this.arcadiaServiceProviderID;
        }
    }
}