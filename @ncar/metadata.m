function [d,response] = metadata(c,id)
%METADATA National Center for Atmospheric Research dataset metadata.
%   [DATA,RESPONSE] = METADATA(C,ID) returns the metadata information for a 
%   given dataset identifier, ID.  C is the NCAR object.
%
%   For example,
%   
%   [data,response] = metadata(c,"083.2")
%
%   returns
%
%   data = 
%
%    struct with fields:
%
%                      dsid: '083.2'
%      subsetting_available: 1
%                      data: [192x14 table]
%  
%  
%  response = 
%  
%    ResponseMessage with properties:
%  
%      StatusLine: 'HTTP/1.1 200 OK'
%      StatusCode: OK
%          Header: [1x6 matlab.net.http.HeaderField]
%            Body: [1x1 matlab.net.http.MessageBody]
%       Completed: 0
%  
%   See also ncar, paramsummary. 

%   Copyright 2023 The MathWorks, Inc. 

% Request type
method = "GET";

% Create url
urlString = strcat(c.URL,"/metadata/",id);

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

    % Convert output structure into table
    d = struct2table(d,"AsArray",true);

  else
  
    d = response;

  end

catch

    d = response;

end

% Restore warning state
warning(w);