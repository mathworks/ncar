classdef ncar < handle
%NCAR National Center for Atmospheric Research connection.
%   C = NCAR(ORCID,TOKEN) creates a NCAR connection object using the 
%   ORCID and TOKEN.  ORCID and TOKEN can be input as string 
%   scalars or character vectors.  TIMEOUT is the request value in 
%   seconds and input as a numeric value. The default value is 
%   200 seconds. C is an ncar object.
%
%   For example,
%   
%   c = ncar("orcid","token")
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
    ORCID 
    Token
  end
  
  methods (Access = 'public')
  
      function c = ncar(orcid,token,timeout,url,mediatype,debugmodevalue)
         
        %  Registered noaa users will have an authentication token
        if nargin < 2
          error("datafeed:ncar:missingToken","NCAR orcid and token required for data requests.");
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
          c.URL = "https://rda.ucar.edu/api/";
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
        authenticate(c,orcid,token)

        % Store credentials in object
        c.ORCID = orcid;
        c.Token = token;

      end
  end

  methods (Access = 'private')
  
      function authenticate(c,orcid,token)

        % Set request parameters
        method = "POST";
        
        HttpURI = matlab.net.URI("https://rda.ucar.edu/cgi-bin/login");

        HttpBody = matlab.net.http.MessageBody();
        HttpBody.Payload = strcat("orcid_id=",orcid,"&api_token=",token,"&action=tokenlogin");
            
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