# Getting Started with National Center for Atmospheric Research (NCAR) Data in MATLAB&reg;

## Description

This interface allows users to access NCAR data directly from MATLAB.  Quantitative and climate risk analysts can use the available data to make investment decisions based on climate data and weather patterns.

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=mathworks/ncar)

## System Requirements

- MATLAB R2022a or later
- Web services credentials supplied by NCAR: https://rda.ucar.edu/login/
- User are responsible for complying with any terms governing their use of the National Center for Atmospheric Research Data.

## Features

Users can access NCAR data directly from MATLAB.   NCAR documentation for data set meta data, parameter summaries, summaries, templates, submission requests and request status and data set deletion can be found here: 

https://github.com/NCAR/rda-apps-clients

A valid NCAR connection is required for all requests.

## Create a NCAR connection.

```MATLAB
% Credentials in code
n = ncar("username","password");

% Example of credentials out of code as of R2023a
n = ncar(getenv("username"),getenv("password"));
```

### Get data set metadata information for a specific data set
```MATLAB
mdData = metadata(n,"ds083.2");
```

### Get data set parameter summary.
```MATLAB
psData = paramsummary(n,"ds083.2");
```

### Get data set summary.
```MATLAB
sData = summary(n,"ds083.2");
```

### Get data set control file.
```MATLAB
tData = template(n,"ds083.2");;
```

### Submit a data request.
```MATLAB
request.dataset="ds083.2";
request.date="202203020000/to/202203051200";
request.param="TMP/R H/ABS V\nlevel=ISBL:850/700/500";
request.oformat="netCDF";
request.nlat=30;
request.slat=-25;
request.wlon=-150;
request.elon=-30;
request.n_groupindex = 2;
requestx.targetdir="/glade/scratch\n";
requestid = submit(n,request);
```

### Check the status of a request.
```MATLAB
checkStatus = status(n,requestid);
```

### Download requested data.
#### Note that there is no API method to programmatically download the data.  Users can login to the NCAR site, https://rda.ucar.edu/login/, to access their data requests. From the website, choose User Dashboard and select the Show Requests option to access the requested data.

### Delete requested data.
```MATLAB
deleteStatus = delete(n,requestid);
```
## License

The license is available in the LICENSE.TXT file in this GitHub repository.

Community Support

MATLAB Central

Copyright 2023 The MathWorks, Inc.
