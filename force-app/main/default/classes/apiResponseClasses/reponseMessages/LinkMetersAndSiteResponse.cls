/****************************************************************************************
Name            : LinkMetersAndSiteResponse
Revision Log    : 2024-03-13 Vaibhav Chotlaiya
                :
                :
Use             :  Urjanet API Callout Response - Link meters and site
*****************************************************************************************/
@namespaceAccessible
public with sharing class LinkMetersAndSiteResponse extends UrjanetResponse {
    @namespaceAccessible
    public LinkMetersAndSiteResponse() {
    }
    @namespaceAccessible
    public Embedded embedded { get; set; }

    @namespaceAccessible
    public class Embedded {
        @namespaceAccessible
        public List<Meter> meters { get; set; }
    }

    @namespaceAccessible
    public class Meter {
        @namespaceAccessible
        public String entityId;
        @namespaceAccessible
        public List<String> accountNumbers;
        @namespaceAccessible
        public String lastModifiedDate;
        @namespaceAccessible
        public String createdDate;
        @namespaceAccessible
        public String createdBy;
        @namespaceAccessible
        public String lastModifiedBy;
        @namespaceAccessible
        public String providerName;
        @namespaceAccessible
        public String meterNumber;
        @namespaceAccessible
        public String normalizedMeterNumber;
        @namespaceAccessible
        public String previousMeterNumber;
        @namespaceAccessible
        public String normalizedPreviousMeterNumber;
        @namespaceAccessible
        public String podNumber;
        @namespaceAccessible
        public String normalizedPodNumber;
        @namespaceAccessible
        public String meterConstantMultiplier;
        @namespaceAccessible
        public String previousMeterConstantMultiplier;
        @namespaceAccessible
        public String serviceDescription;
        @namespaceAccessible
        public Address serviceAddress;
        @namespaceAccessible
        public String serviceType;
        @namespaceAccessible
        public String bulbType;
        @namespaceAccessible
        public String pipeType;
        @namespaceAccessible
        public String nextExpectedPostDate;
        @namespaceAccessible
        public String meterStatus;
        @namespaceAccessible
        public Site site;
        @namespaceAccessible
        public Links links;
    }

    @namespaceAccessible
    public class Site {
        @namespaceAccessible
        public String entityId;
        @namespaceAccessible
        public String lastModifiedDate;
        @namespaceAccessible
        public String createdDate;
        @namespaceAccessible
        public String createdBy;
        @namespaceAccessible
        public String lastModifiedBy;
        @namespaceAccessible
        public String siteNumber;
        @namespaceAccessible
        public String siteName;
        @namespaceAccessible
        public String siteCode;
        @namespaceAccessible
        public String region;
        @namespaceAccessible
        public String subRegion;
        @namespaceAccessible
        public String facilityType;
        @namespaceAccessible
        public String currentTariffs;
        @namespaceAccessible
        public Address serviceAddress;
        @namespaceAccessible
        public Links links;
    }

    @namespaceAccessible
    public class Links {
        @namespaceAccessible
        public Href self { get; set; }
        @namespaceAccessible
        public Href provider { get; set; }
        @namespaceAccessible
        public Href meters { get; set; }
        @namespaceAccessible
        public Href site { get; set; }
        @namespaceAccessible
        public Href accounts { get; set; }
        @namespaceAccessible
        public Href meterData { get; set; }
        @namespaceAccessible
        public Href credentials { get; set; }
        @namespaceAccessible
        public Href statements { get; set; }
    }
}