public with sharing class GetArcadiaServiceProvidersResponse extends UrjanetResponse{
    public GetArcadiaServiceProvidersResponse() {}

    public Embedded embedded { get; set; }

    public class Embedded {
	    public List<ProviderDetails> providers;
	}

    public class ProviderDetails{
        @AuraEnabled public String providerName {get;set;}
        @AuraEnabled public String providerId   {get;set;}
        @AuraEnabled public String website      {get;set;}
    }
}