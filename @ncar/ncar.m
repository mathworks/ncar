classdef ncar < handle
%NCAR National Center for Atmospheric Research connection.
%   C = NCAR(USERNAME,PASSWORD) creates a NCAR connection object using the 
%   USERNAME and PASSWORD.  USERNAME and PASSWORD can be input as string 
%   scalars or character vectors.  TIMEOUT is the request value in 
%   milliseconds and input as a numeric value. The default value is 
%   200 milliseconds. C is an ncar object.
%
%   For example,
%   
%   c = ncar("username","password")
%
%   returns
%
%   c = 
%   
%     ncar with properties:
%   
%       TimeOut: 200.00

%   Copyright 2023 The MathWorks, Inc. 

  properties
    TimeOut
  end
  
  properties (Hidden = true)
    DebugModeValue
    MediaType
    URL   
  end
  
  properties (Access = 'private')
    Username 
    Password
  end
  
  methods (Access = 'public')
  
      function c = ncar(username,password,timeout,url,mediatype,debugmodevalue)
         
        %  Registered noaa users will have an authentication token
        if nargin < 2
          error("datafeed:ncar:missingToken","NCAR username and password required for data requests.");
        end
        
        % Timeout value for requests
        if exist("timeout","var") && ~isempty(timeout)
          c.TimeOut = timeout;
        else
          c.TimeOut = 200;
        end
        
        % Set URL
        if exist("url","var") && ~isempty(url)
          c.URL = url;
        else
          c.URL = "https://rda.ucar.edu/json_apps/";
        end

        % Specify HTTP media type i.e. application content to deal with
        if exist("mediatype","var") && ~isempty(mediatype)
          HttpMediaType = matlab.net.http.MediaType(mediatype);
        else
          HttpMediaType = matlab.net.http.MediaType("application/json"); 
        end
        c.MediaType = string(HttpMediaType.MediaInfo);
       
        % Debug value for requests
        if exist("debugmodevalue","var") && ~isempty(debugmodevalue)
          c.DebugModeValue = debugmodevalue;
        else
          c.DebugModeValue = 0;
        end

        % Authenticate credentials
        authenticate(c,username,password)

        % Store credentials in object
        c.Username = username;
        c.Password = password;

      end
  end

  methods (Access = 'private')
  
      function authenticate(c,username,password)

        % Set request parameters
        method = "POST";
        
        HttpURI = matlab.net.URI("https://rda.ucar.edu/cgi-bin/login");

        HttpBody = matlab.net.http.MessageBody();
        HttpBody.Payload = strcat("email=",username,"&passwd=",password,"&action=login");
            
        HttpHeader = matlab.net.http.HeaderField("Content-Type",c.MediaType);
      
        RequestMethod = matlab.net.http.RequestMethod(method);
        Request = matlab.net.http.RequestMessage(RequestMethod,HttpHeader,HttpBody);
        options = matlab.net.http.HTTPOptions('ConnectTimeout',c.TimeOut,'Debug',c.DebugModeValue);

        % Send Request
        response = send(Request,HttpURI,options);

        % Check for response error
        switch response.StatusCode

          case "NotFound"
          
            error("datafeed:ncar:invalidURL",strcat("URL not found. Status code: ", string(response.StatusCode)))

          case "OK"

            % Valid connection response

          otherwise
            error("datafeed:ncar:connectFailure",strcat(response.Body.Data," Status code: ", string(response.StatusCode)))
        
        end

      end

  end
  

  methods (Static, Access = 'private')

    function data = parseResponse(d)

      tmpData = [];

      for i = 1:length(d.data)

        try

          tmpData = vertcat(tmpData,struct2table(d.data{i},"AsArray",true)); %#ok

        catch

          tmpTable = struct2table(d.data{i},"AsArray",true);
          tmpTableVars = tmpTable.Properties.VariableNames;
          for j = 1:length(tmpTableVars)
            if isstruct(tmpTable.(tmpTableVars{j}))
              tmpData.(tmpTableVars{j}){i,1} = tmpTable.(tmpTableVars{j});
            else
              tmpData.(tmpTableVars{j})(i,1) = tmpTable.(tmpTableVars{j});
            end
          end

        end

      end

      data = tmpData;

    end

  end

end