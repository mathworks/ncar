function [d,response] = status(c,id)
%STATUS National Center for Atmospheric Research request index status.
%   [DATA,RESPONSE] = STATUS(C,ID) returns the data request status for a 
%   given request index identifier, ID.  C is the NCAR object.
%
%   For example,
%   
%   [data,response] = status(c,"123456")
%
%   returns
%
%   data = 
%   
%     1×9 table
%
%               status               date_ready     request_index                                                                                 rinfo                                                                                      NCAR_contact            request_id        date_purge       date_rqst       subset_info
%      _________________________    ____________    _____________    ________________________________________________________________________________________________________________________________________________________________    _____________________    ________________    ____________    ______________    ___________
%
%      {'Queued for Processing'}    {0×0 double}     {'123456'}      {'dsnum=083.2;startdate=2011-03-02 00:00;enddate=2011-03-15 12:00;parameters=1!7-0.1:11,1!7-0.2:11,3!7-0.2-1:0.0.0,1!7-0.1:52,3!7-0.2-1:0.1.1;product=1;level='}    {'username@ucar.edu'}    {'USER123456'}    {0×0 double}    {'2022-12-06'}    1×1 struct 
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
  d = response;
end