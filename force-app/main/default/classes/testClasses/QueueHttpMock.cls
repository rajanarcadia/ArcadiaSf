/**
 *  This class is used for creating group of mocks in a single transaction
 */
@isTest
public class QueueHttpMock implements HttpCalloutMock {
    List<HttpResponse> responses = new List<HttpResponse>();
    public void addResponse(HttpResponse response) {
        responses.add(response);
    }
    public HttpResponse respond(HttpRequest request) {
        return responses.remove(0);
    }
}