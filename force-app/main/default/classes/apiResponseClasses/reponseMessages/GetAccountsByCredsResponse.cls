/****************************************************************************************
Name            : GetAccountsByCredsResponse
Revision Log    : 2022-04-28 Abhi Tangudu - CodeScience
                :
                :
Use             :  Urjanet API Callout Response - Get Accounts By Credentials
*****************************************************************************************/
public with sharing class GetAccountsByCredsResponse extends UrjanetResponse {
    public GetAccountsByCredsResponse() {
    }

    public Embedded embedded { get; set; }

    public class Embedded {
        public List<Account> accounts { get; set; }
    }
    public class Account {
        public String entityId { get; set; }
        public Links links { get; set; }
        public String accountNumber { get; set; }
        public String createdDate { get; set; }
        public String createdBy { get; set; }
        public String lastModifiedDate { get; set; }
        public String lastModifiedBy { get; set; }
        public Boolean enabled { get; set; }
        public Boolean prepaid { get; set; }
        public String normalizedAccountNumber { get; set; }
        public String latestNewStatement { get; set; }
        public String latestStatementDate { get; set; }
        public String providerName { get; set; }
        public String status { get; set; }
        public String statusDetail { get; set; }
        public String type { get; set; }
    }

    public class Links {
        public Href self { get; set; }
        public Href provider { get; set; }
        public Href events { get; set; }
        public Href meters { get; set; }
        public Href sites { get; set; }
        public Href accountData { get; set; }
        public Href payments { get; set; }
        public Href credentials { get; set; }
        public Href statements { get; set; }
    }
}