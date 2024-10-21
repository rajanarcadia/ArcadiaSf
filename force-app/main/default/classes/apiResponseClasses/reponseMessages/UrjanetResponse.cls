/****************************************************************************************
Name            : UrjanetResponse
Revision Log    : 2022-04-19 Abhishek Tangudu- CodeScience
                :
                :
Use             :  Urjanet API Callout Common Response
*****************************************************************************************/
@namespaceAccessible
public virtual class UrjanetResponse {
    @namespaceAccessible
    public UrjanetResponse() {
    }

    @namespaceAccessible
    public Pages page { get; set; }
    @namespaceAccessible
    public Links links { get; set; }
    @namespaceAccessible
    public String responseBody;
    @namespaceAccessible
    public String responseType;
    @namespaceAccessible
    public String endpoint;
    @namespaceAccessible
    public String errorMsg;
    @namespaceAccessible
    public Integer status;
    @namespaceAccessible
    public Exception ex;
    @namespaceAccessible
    public String message;
    @namespaceAccessible
    public Blob blobBody;

    @namespaceAccessible
    public class Address {
        @namespaceAccessible
        public String fullAddress { get; set; }
        @namespaceAccessible
        public String addressType { get; set; }
        @namespaceAccessible
        public String postalCode { get; set; }
        @namespaceAccessible
        public String city { get; set; }
        @namespaceAccessible
        public String streetLine2 { get; set; }
        @namespaceAccessible
        public String state { get; set; }
        @namespaceAccessible
        public String streetLine1 { get; set; }
        @namespaceAccessible
        public String country { get; set; }
        @namespaceAccessible
        public String recipient { get; set; }
    }

    @namespaceAccessible
    public class Links {
        @namespaceAccessible
        public Href self { get; set; }
        @namespaceAccessible
        public Href last { get; set; }
        @namespaceAccessible
        public Href next { get; set; }
        @namespaceAccessible
        public Href prev { get; set; }
    }

    @namespaceAccessible
    public class Pages {
        @namespaceAccessible
        public Integer totalElements { get; set; }
        @namespaceAccessible
        public Integer totalPages { get; set; }
        @namespaceAccessible
        public Integer numbers { get; set; }
        @namespaceAccessible
        public Integer size { get; set; }
    }

    @namespaceAccessible
    public class Href {
        @namespaceAccessible
        public String href { get; set; }
    }
}