function [d,response] = submit(c,requestdata)
%SUBMIT National Center for Atmospheric Research data request submission.
%   [DATA,RESPONSE] = SUBMIT(C,REQUESTDATA) sends a data request given the 
%   request data structure or json string, REQUESTDATA.  C is the RENCAR object.
%
%   For example,
%   
%   x.dataset="ds083.2"
%   x.date="201103020000/to/201103151200"
%   x.param="TMP/R H/ABS V\nlevel=ISBL:850/700/500"
%   x.noformat="netCDF"
%   x.nnlat=30
%   x.nslat=-25
%   x.nwlon=-150
%   x.nelon=-30
%   x.("n_groupindex") = 2
%   x.ntargetdir="/glade/scratch\n"
%
%   [data,response] = submit(c,x)
%
%   returns
%
%   data = 
%   
%     "123456"
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
method = "POST";

% Create url
urlString = strcat(c.URL,"/request/");

% Create URI object
HttpURI = matlab.net.URI(strcat(urlString));

% Message body
HttpBody = matlab.net.http.MessageBody(requestdata);

% Create request
% Basic authentication header
authString = strcat("Basic ",matlab.net.base64encode(strcat(c.Username,":",c.Password)));
HttpHeader = matlab.net.http.HeaderField("Content-Type",c.MediaType,"Authorization",authString);
RequestMethod = matlab.net.http.RequestMethod(method);
Request = matlab.net.http.RequestMessage(RequestMethod,HttpHeader,HttpBody);

options = matlab.net.http.HTTPOptions("ConnectTimeout",c.TimeOut,"Debug",c.DebugModeValue);

% Send Request
response = send(Request,HttpURI,options);

% Parse response
try
  d = string(jsondecode(response.Body.Data).result.request_id);
catch
  d = response;
end
