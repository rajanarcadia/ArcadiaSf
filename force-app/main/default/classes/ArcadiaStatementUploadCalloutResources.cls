public class ArcadiaStatementUploadCalloutResources {
    @testVisible
    private ArcadiaMultiPartBodyHelper helper = new ArcadiaMultiPartBodyHelper();

    public Blob getUploadStatementBody(String jsonFileDetails, String fileName) {
        //  Compose the form
        List<String> lstBodyDetails = new List<String>();
        lstBodyDetails.add(helper.WriteBoundary());
        lstBodyDetails.add(helper.WriteBodyParameter('name', fileName));
        lstBodyDetails.add(helper.WriteBoundary());
        lstBodyDetails.add(helper.WriteBlobBodyParameter('files', jsonFileDetails));
        lstBodyDetails.add(helper.WriteEndingBoundary(ArcadiaMultiPartBodyHelper.EndingType.CrLf));

        Blob bodyBlob = EncodingUtil.base64Decode(String.join(lstBodyDetails, '')); //text (header) , binary (content), text (footer)
        return bodyBlob;
    }

    public UploadStatementResponse getFileResponseDetails(String fileResponseJSON, Integer statusCode) {
        fileResponseJSON = fileResponseJSON.replace('_embedded', 'embedded');
        fileResponseJSON = fileResponseJSON.replace('_links', 'links');
        return (UploadStatementResponse) JSON.deserialize(fileResponseJSON, UploadStatementResponse.class);
    }

    public class UploadStatementResponse {
        public Embedded embedded;

        public UtilityStatementFile__c toUtilityStatementRecord() {
            UtilityStatementFile__c utilityStatementObj = new UtilityStatementFile__c();
            utilityStatementObj.Name = this.embedded.files[0].fileName.abbreviate(80);
            utilityStatementObj.EntityId__c = this.embedded.files[0].id;
            utilityStatementObj.Status__c = this.embedded.files[0].fileStatus;
            utilityStatementObj.CreatedDateInArcadia__c = UrjanetUtils.getDateTime(this.embedded.files[0].createdDate);
            if (
                this.embedded.files[0].links != null &&
                this.embedded.files[0].links.statement != null &&
                !String.isEmpty(this.embedded.files[0].links.statement.href) &&
                !String.isEmpty(this.embedded.files[0].links.statement.href.substringAfter('/statements/'))
            ) {
                utilityStatementObj.StatementId__c = this.embedded.files[0]
                    .links.statement.href.substringAfter('/statements/');
            }
            return utilityStatementObj;
        }
    }

    public class Embedded {
        public List<FileResponseDetails> files;
    }

    public class FileResponseDetails {
        public String createdDate;
        public String createdBy;
        public String entityId;
        public String fileName;
        public String fileStatus;
        public String id;
        public InnerLinks links;
    }

    public class InnerLinks {
        public Href statement { get; set; }
    }

    public class Href {
        public String href { get; set; }
    }
}