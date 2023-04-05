function [d,response] = delete(c,id)
%STATUS National Center for Atmospheric Research request deletion.
%   [DATA,RESPONSE] = DELETE(C,ID) deletes the data request denoted by a 
%   given request index identifier, ID.  C is the NCAR object.
%
%   For example,
%   
%   [data,response] = delete(c,"123456")
%
%   returns
%
%   data = 
%   
%     
%   
%   response = 
%   
%     ResponseMessage with properties:
%   
%       StatusLine: 'HTTP/1.1 200 OK'
%       StatusCode: OK
%           Header: [1x6 matlab.net.http.HeaderField]
%             Body: [1x1 matlab.net.http.MessageBody]
%        Completed: 0

%   Copyright 2023 The MathWorks, Inc. 

% Request type
method = "DELETE";

if nargin < 2
  id = "";
end

% Create url
urlString = strcat(c.URL,"request/",id);

% Create URI object
HttpURI = matlab.net.URI(strcat(urlString));

% Create request
% Basic authentication header
authString = strcat("Basic ",matlab.net.base64encode(strcat(c.Username,":",c.Password)));
HttpHeader = matlab.net.http.HeaderField("Content-Type",c.MediaType,"Authorization",authString);
RequestMethod = matlab.net.http.RequestMethod(method);
Request = matlab.net.http.RequestMessage(RequestMethod,HttpHeader);

options = matlab.net.http.HTTPOptions("ConnectTimeout",c.TimeOut,"Debug",c.DebugModeValue);

% Send Request
response = send(Request,HttpURI,options);

% Parse response into table
try
  d = struct2table(jsondecode(response.Body.Data).result,"AsArray",true);
catch
  d = jsondecode(response.Body.Data);
end