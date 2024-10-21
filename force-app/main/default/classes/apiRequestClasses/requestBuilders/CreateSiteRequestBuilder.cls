/****************************************************************************************
Name            : CreateSiteRequestBuilder
Revision Log    : 2022-06-09 Abhi Tangudu - CodeScience
                :
                :
Use             :  To build requests to create site on Urjanet via API
*****************************************************************************************/
public with sharing class CreateSiteRequestBuilder extends UrjanetRequestBuilder {
    public CreateSiteRequestBuilder(UrjanetRequestArgs args) {
        super(args);
    }

    /**
     * Generates a HttpRequest for POST callout to site API end point
     * @return   site POST HttpRequest
     */
    public override HttpRequest buildRequest() {
        this.request.setEndpoint(UrjanetConstants.POST_SITE_API_ENDPOINT);
        this.request.setMethod(UrjanetEnums.apiMethod.POST.name());
        this.request.setHeader('Content-Type', 'application/json');
        if (Test.isRunningTest()) {
            this.request.setHeader('mock', PostSiteResponseMock.Mock.SITE.name());
        }

        Map<String, String> siteMap = new Map<String, String>{
            'city' => args.requestParams[0],
            'country' => args.requestParams[1],
            'facilityType' => args.requestParams[2],
            'postalCode' => args.requestParams[3],
            'region' => args.requestParams[4],
            'siteCode' => args.requestParams[5],
            'siteName' => args.requestParams[6],
            'siteNumber' => args.requestParams[7],
            'subRegion' => args.requestParams[8],
            'state' => args.requestParams[9],
            'streetLine1' => args.requestParams[10],
            'streetLine2' => args.requestParams[11]
        };
        this.request.setBody(JSON.serialize(siteMap));
        return this.request;
    }
}