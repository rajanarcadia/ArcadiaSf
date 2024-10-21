/****************************************************************************************
Name            : GetMetersByAccountResponse
Revision Log    : 2022-06-07 Alagu Chellappa - CodeScience
                :
                :
Use             :  Urjanet API Callout Response - Get Meters By Account
*****************************************************************************************/
public with sharing class GetMetersByAccountResponse extends UrjanetResponse {
    public GetMetersByAccountResponse() {
    }
    public Embedded embedded { get; set; }

    public class Embedded {
        public List<Meter> meters { get; set; }
    }

    public class Meter {
        public String entityId;
        public List<String> accountIds;
        public List<String> accountNumbers;
        public String lastModifiedDate;
        public String createdDate;
        public String createdBy;
        public String lastModifiedBy;
        public String providerName;
        public String meterNumber;
        public String normalizedMeterNumber;
        public String previousMeterNumber;
        public String normalizedPreviousMeterNumber;
        public String podNumber;
        public String normalizedPodNumber;
        public String meterConstantMultiplier;
        public String previousMeterConstantMultiplier;
        public String serviceDescription;
        public Address serviceAddress;
        public String serviceType;
        public String bulbType;
        public String pipeType;
        public String nextExpectedPostDate;
        public String meterStatus;
        //public Site site;
        public Links links;
        public Provider provider;
    }
    public class Provider {
        public String entityId;
        public String country;
        public String providerName;
        public String supportsCredentialValidation;
        public String website;
    }

    public class Site {
        public String entityId;
        public String lastModifiedDate;
        public String createdDate;
        public String createdBy;
        public String lastModifiedBy;
        public String siteNumber;
        public String siteName;
        public String siteCode;
        public String region;
        public String subRegion;
        public String facilityType;
        public String currentTariffs;
        public Address serviceAddress;
        public Links links;
    }

    public class Links {
        public Href self { get; set; }
        public Href provider { get; set; }
        public Href events { get; set; }
        public Href meters { get; set; }
        public Href sites { get; set; }
        public Href site { get; set; }
        public Href accounts { get; set; }
        public Href accountData { get; set; }
        public Href meterData { get; set; }
        public Href payments { get; set; }
        public Href credentials { get; set; }
        public Href statements { get; set; }
        public Href customData { get; set; }
    }
}