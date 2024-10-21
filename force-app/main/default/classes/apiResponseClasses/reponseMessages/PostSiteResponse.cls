/****************************************************************************************
Name            : PostSiteResponse
Revision Log    : 2022-06-09 Abhi Tangudu - CodeScience
                :
                :
Use             :  Urjanet API Callout Response - Post Site
*****************************************************************************************/
public with sharing class PostSiteResponse extends UrjanetResponse {
    public PostSiteResponse() {
    }

    public String entityId { get; set; }
    public String siteCode { get; set; }
    public String siteName { get; set; }
    public String region { get; set; }
    public String siteNumber { get; set; }
    public String subRegion { get; set; }
    public String lastModifiedBy { get; set; }
    public String facilityType { get; set; }
    public String createdBy { get; set; }
    public Address serviceAddress { get; set; }
    public String createdDate { get; set; }
    public InnerLinks links { get; set; }
    public String lastModifiedDate { get; set; }

    public class InnerLinks {
        public Href self { get; set; }
        public Href credentials { get; set; }
        public Href events { get; set; }
        public Href meters { get; set; }
        public Href statements { get; set; }
        public Href accounts { get; set; }
    }
}