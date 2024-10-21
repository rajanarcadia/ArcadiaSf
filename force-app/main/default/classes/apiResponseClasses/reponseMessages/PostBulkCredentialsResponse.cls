public with sharing class PostBulkCredentialsResponse extends UrjanetResponse {
    public PostBulkCredentialsResponse() {

    }

    public String jobType { get; set; }
	public String status { get; set; }
	public String statusDetail { get; set; }
	public String jobResults { get; set; }
}