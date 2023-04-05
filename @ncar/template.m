function [d,response] = template(c,id)
%TEMPLATE National Center for Atmospheric Research example control file for a given dataset.
%   [DATA,RESPONSE] = TEMPLATE(C,ID) returns an example control file for a 
%   given dataset identifier, ID.  C is the NCAR object.
%
%   For example,
%   
%   [data,response] = template(c,"083.2")
%
%   returns
%
%   data = 
%   
%     struct with fields:
%   
%                 template: 
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
method = "GET";

if nargin < 2
  id = "";
end

% Create url
urlString = strcat(c.URL,"request/template/",id);

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

% Save warning state
w = warning;
warning("off","MATLAB:table:RowsAddedExistingVars")

% Parse response
try
  if strcmp(string(response.StatusCode),"200")

    % Get result data
    d = response.Body.Data.result;

    % Convert unstructured data into table
    d.data = ncar.parseResponse(d);

  else
  
    d = response;

  end

catch

    d = response;

end

% Restore warning state
warning(w);