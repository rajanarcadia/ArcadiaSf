@IsTest
public with sharing class PostBulkCredentialsResponseMock implements HttpCalloutMock {
    public enum Mock {
        LOGIN,
        BULK_CREDNETIALS
    }

    public HTTPResponse respond(HTTPRequest req) {
        String testResponse;
        switch on req.getHeader('mock') {
            when 'LOGIN' {
                testResponse = getLoginResponseString();
            }
            when 'BULK_CREDNETIALS' {
                testResponse = getPostBulkCredentialsResponseString();
            }
        }
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        res.setBody(testResponse);
        res.setStatusCode(202);
        return res;
    }

    public String getLoginResponseString() {
        return '{' +
            '    "status": 200,' +
            '    "message": "Authentication Successful",' +
            '    "type": "Bearer",' +
            '    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJqdGkiOiI2ZjJlMzM5NC00YzJhLTQzNWQtODQ0OC1hMjVmZTg5MDRkNDUiLCJpYXQiOjE2NTA2MDI1MzIsImV4cCI6MTY1MDYwNjEzMiwic3ViIjoiY3MuZ2lsZGFzIiwib3JnYW5pemF0aW9uSWQiOjYzNSwib3JnYW5pemF0aW9uSWQyIjoiMWVjYTNkYmYtMzI2OS1kNTE3LTliZmItMmUwYTBlNTA1N2U4Iiwib3JnYW5pemF0aW9uTmFtZSI6IkNvZGVTY2llbmNlIFRlc3QiLCJvcmdhbml6YXRpb25TdXBlciI6ZmFsc2UsIm9yZ2FuaXphdGlvblRlc3QiOmZhbHNlLCJhbGxvd2VkVXNlQ2FzZXMiOlsiVVRJTElUWSJdLCJkZWZhdWx0VXNlQ2FzZSI6IlVUSUxJVFkiLCJpZCI6NDQ1MSwiaWQyIjoiMWVjYTNkZGEtN2UwMC1kOGNiLWJiNWMtZDJiY2UwYWU4MzBhIiwibmFtZSI6IkdpbGRhIFNwZW5jZXIiLCJlbWFpbCI6ImdpbGRhQGNvZGVzY2llbmNlLmNvbSIsInVzZXJfbmFtZSI6ImNzLmdpbGRhcyIsImF1dGhvcml0aWVzIjpbIlBFUk1fQkxEUl9VUERBVEVfQ1JFREVOVElBTCIsIlBFUk1fT0RJTl9DUkVBVEVfQ1JFREVOVElBTCIsIlBFUk1fT0RJTl9XUklURV9BQ0NPVU5UIiwiUEVSTV9PRElOX1JFQURfQUNDT1VOVCIsIlJPTEVfQ1VTVE9NRVJfQURNSU4iLCJQRVJNX0JMRFJfUkVBRF9BQ0NPVU5UIiwiUEVSTV9IRExSX1JXX09SR19QVUJMSUMiLCJQRVJNX0JMRFJfUkVBRF9GSUxFIiwiUEVSTV9PRElOX1JFQURfT1JHQU5JWkFUSU9OIiwiUEVSTV9CTERSX1JXX09SR0FOSVpBVElPTiIsIlBFUk1fT0RJTl9VUERBVEVfU0lURSIsIlBFUk1fT0RJTl9SRUFEX1NUQVRFTUVOVCIsIlBFUk1fQklMTF9SV19QQVlNRU5UIiwiUEVSTV9GU1RJX1JFQURfU09VUkNFIiwiUEVSTV9PRElOX1JFQURfUEFTU1dPUkQiLCJQRVJNX0ZTVElfUldfUERSIiwiUEVSTV9PRElOX1JFQURfVEFSSUZGIiwiUEVSTV9IRExSX1JFQURfUk9MRSIsIlBFUk1fSERMUl9SV19VU0VSX1BVQkxJQyIsIlBFUk1fT0RJTl9SRUFEX01FVEVSIiwiUEVSTV9PRElOX1JFQURfU0lURSIsIlBFUk1fQkxEUl9SRUFEX0NSRURFTlRJQUwiLCJQRVJNX09ESU5fVVBEQVRFX01FVEVSIiwiUEVSTV9CTERSX0RFTEVURV9BQ0NPVU5UIiwiUEVSTV9CTERSX0NSRUFURV9DUkVERU5USUFMIiwiUEVSTV9PRElOX1JFQURfQ1JFREVOVElBTCIsIlBFUk1fT0RJTl9SV19PUkdBTklaQVRJT04iLCJQRVJNX09ESU5fVVBEQVRFX0NSRURFTlRJQUwiLCJQRVJNX0JMRFJfREVMRVRFX0NSRURFTlRJQUwiLCJQRVJNX0JMRFJfUkVBRF9PUkdBTklaQVRJT04iLCJQRVJNX1BJQl9SRUFEX1BST1ZJREVSIiwiUEVSTV9CTERSX1dSSVRFX0FDQ09VTlQiLCJQRVJNX0JMRFJfUldfRklMRSIsIlBFUk1fQkxEUl9SRUFEX1BBU1NXT1JEIl0sInByb2plY3RzIjpbXSwic2NvcGUiOiJBTlkiLCJwYXltZW50QXNzb2NpYXRlZCI6ZmFsc2UsIm9yZ2FuaXphdGlvblR5cGUiOiJMSVZFIiwiYXBpS2V5IjoiMWVjYTNkYmYzMjY5ZDUxODliZmIyZTBhMGU1MDU3ZTgifQ.j46sjfu9oixsnlL84--50oz-nxxIVJqIoV4FDOya7U-UX7ZL2nk8-i9h45Im5XnThRWigPekLdPfv--5N4HhNkak3q-GVTWtLyCWHh3eVlhZJ5MVpnYikugQC7kSIPLcSB4MD3qpiW0siQxdVs_QkmsgMlmqxgE7hJ9FeqQqt5fDnLCoyxJ1ehCdKIo0TWc7nwXf-HaX_FWM12_Jn_OKWJxtWqIPgmPl_92kf-eQVAmV7AUphqZbCRHbbDdXqSEYVSpn9Amx4Bqmk05F3B9OIFtLFdUpPqpXaWQMkA4ih7SywPsj531p2a6cRBAZAJQ2s4hCXXLeNIyuXONVdG4Xog",' +
            '    "expires": "1650606132" ' +
            '  }';
    }

    public String getPostBulkCredentialsResponseString() {
        return '{' +
            '"jobType": "BULK_CREDENTIAL_UPLOAD",' +
            '"status": "SCHEDULED",' +
            '"statusDetail": null,' +
            '"jobResults": null,' +
            '"_links": {' +
            '"self": {' +
            '"href": "https://api.urjanet.com/utility/asyncJobs/1edc1ca8-732c-d7ee-86b5-5632ef5980a2"' +
            '}' +
            '}' +
            '}';
    }
}