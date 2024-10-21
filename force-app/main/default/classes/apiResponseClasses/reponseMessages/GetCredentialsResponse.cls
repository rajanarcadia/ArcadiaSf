/****************************************************************************************
Name            : GetCredentialsResponse
Revision Log    : 2022-04-28 Abhi Tangudu - CodeScience
                :
                :
Use             :  Urjanet API Callout Response - Get Credential Response
*****************************************************************************************/
public class GetCredentialsResponse extends UrjanetResponse {
    public GetCredentialsResponse() {
    }

    public Embedded embedded { get; set; }

    public class Credentials {
        public String entityId { get; set; }
        public String username { get; set; }
        public String username2 { get; set; }
        public String username3 { get; set; }
        public String username4 { get; set; }
        public String correlationId { get; set; }
        public String status { get; set; }
        public String statusDetail { get; set; }
        public Boolean enabled { get; set; }
        public String nextScheduledRun { get; set; }
        public String providerName { get; set; }
        public Boolean runHistory { get; set; }
        public Boolean mock { get; set; }
        public String customData { get; set; }
        public Integer totalAccounts { get; set; }
        public String createdDate { get; set; }
        public String createdBy { get; set; }
        public String lastModifiedDate { get; set; }
        public String lastModifiedBy { get; set; }
        public Provider provider { get; set; }
        public InnerLinks links { get; set; }

        public UtilityCredential__c toRecord() {
            UtilityCredential__c credential = new UtilityCredential__c();
            credential.CorrelationID__c = this.correlationId;
            credential.CreatedByInUrjanet__c = this.createdBy;
            credential.CreatedDateInUrjanet__c = UrjanetUtils.getDateTime(this.createdDate);
            credential.Enabled__c = this.enabled;
            credential.LastModifiedByInUrjanet__c = this.lastModifiedBy;
            credential.LastModifiedInUrjanet__c = UrjanetUtils.getDateTime(this.lastModifiedDate);
            credential.LastUrjanetSyncDateTime__c = Datetime.now();
            credential.NextScheduledRun__c = UrjanetUtils.getDateTime(this.nextScheduledRun);
            credential.Status__c = this.status;
            credential.StatusDetail__c = this.statusDetail;
            credential.urjanetId__c = this.entityId;
            credential.Username__c = this.username;
            credential.Username2__c = this.username2;
            credential.Username3__c = this.username3;
            credential.Username4__c = this.username4;
            credential.ArcadiaServiceProviderId__c = this.provider?.entityId;
            return credential;
        }
    }

    public class InnerLinks {
        public Href self { get; set; }
        public Href accounts { get; set; }
        public Href consent { get; set; }
        public Href events { get; set; }
        public Href passwords { get; set; }
        public Href provider { get; set; }
        public Href updateUrl { get; set; }
    }

    public class Embedded {
        public List<Credentials> credentials { get; set; }
    }

    public class Provider {
        public String entityId { get; set; }
    }
}