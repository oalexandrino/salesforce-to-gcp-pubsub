/***
* @author: Olavo Alexandrino <oalexandrino@gmail.com>
*/  
@isTest
global class MockForPubSub implements HttpCalloutMock 
{
    global HTTPResponse respond(HTTPRequest request) 
    {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"messageIds":["6102798701179734"]}');
        response.setStatusCode(200);
        response.setStatus('OK');
        return response; 
    }
}