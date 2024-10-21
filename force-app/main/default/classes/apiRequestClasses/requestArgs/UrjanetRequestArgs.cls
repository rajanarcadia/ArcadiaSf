/****************************************************************************************
Name            : UrjanetRequestArgs
Revision Log    : 2022-04-19 Abhi Tangudu - CodeScience
                :
                :
Use             :  Request args holds the type of request, API callout type and params
*****************************************************************************************/
public with sharing class UrjanetRequestArgs {
    public UrjanetEnums.RequestType requestType;
    public String apiMethod;
    public List<String> requestParams {
        get {
            if (requestParams == null) {
                return new List<String>();
            } else {
                return requestParams;
            }
        }
        set;
    }
}