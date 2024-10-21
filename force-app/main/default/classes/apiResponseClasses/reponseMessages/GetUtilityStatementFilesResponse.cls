public with sharing class GetUtilityStatementFilesResponse extends UrjanetResponse {
    public GetUtilityStatementFilesResponse() {
    }

    public Embedded embedded { get; set; }

    public class Embedded {
        public List<Files> files;
    }

    public class Files {
        public String createdDate;
        public String createdBy;
        public String entityId;
        public List<String> fileDetails;
        public String fileName;
        public String fileStatus;
        public String id;
        public Provider provider;
        public String providerName;
        public InnerLinks links;

        public UtilityStatementFile__c toRecord() {
            UtilityStatementFile__c utilityStatementObj = new UtilityStatementFile__c();
            utilityStatementObj.Name = this.fileName.abbreviate(80);
            utilityStatementObj.EntityId__c = this.id;
            utilityStatementObj.Status__c = this.fileStatus;
            utilityStatementObj.CreatedDateInArcadia__c = UrjanetUtils.getDateTime(this.createdDate);
            utilityStatementObj.StatementId__c = '';

            if (
                this.links != null &&
                this.links.statement != null &&
                !String.isEmpty(this.links.statement.href) &&
                !String.isEmpty(this.links.statement.href.substringAfter('/statements/'))
            ) {
                utilityStatementObj.StatementId__c = this.links.statement.href.substringAfter('/statements/');
            }
            return utilityStatementObj;
        }
    }

    public class InnerLinks {
        public Href self { get; set; }
        public Href source { get; set; }
        public Href statement { get; set; }
        public Href accounts { get; set; }
        public Href meters { get; set; }
    }

    public class Provider {
        public String country;
        public String entityId;
        public String providerName;
        public Boolean supportsCredentialValidation;
        public String website;
    }
}