classdef TReadAll < matlab.unittest.TestCase
  %TReadAll
  % example:
  % import matlab.unittest.TestSuite
  % suiteFolder = TestSuite.fromFolder('tests');
  % result = run(suiteFolder);
  
  properties
    cnvFilename
    ncFilename
    cnvObj
    ncObj
  end
  
  % Each method in that block is identified as a method responsible for setting 
  % up a test fixture that is shared over all test methods in that class.
  methods(TestClassSetup )
    
    % setup read seadird cnv file and save result in mat and netcdf files
    % used inside methods test
    % -------------------------------------------------------------------
    function setup(testCase)
      pathStr = fileparts(mfilename('fullpath'));
      
      % construct test filename
      testCase.cnvFilename = fullfile(pathStr, 'test.cnv');
      testCase.cnvObj = readCnv(testCase.cnvFilename, false);
      saveNc(testCase.cnvObj);
      saveObj(testCase.cnvObj);
      testCase.ncFilename = fullfile(pathStr, 'test.nc');
      testCase.ncObj = readNc(testCase.ncFilename);
      msg = sprintf('can''t locate %s file', testCase.cnvFilename);
      testCase.verifyEqual(testCase.cnvObj.fileName, testCase.cnvFilename , msg);
    end
  end
  
  % Each method in that block is identified as a method of that block is 
  % identified as a method responsible for tearing down over all test methods 
  % in that class.
  methods(TestClassTeardown)
    %     function teardown(testCase)
    %     end
  end
  
  % method block to contain test methods
  % ------------------------------------
  methods (Test)
    
    % test and compare cnv file read with readCnv class with hardcoded value
    % ---------------------------------------------------------------------
    function testProperties( testCase )
      testCase.verifyEqual(testCase.cnvObj.Plateforme, 'THALASSA');
      testCase.verifyEqual(testCase.cnvObj.Cruise, 'PIRATA-FR26');
      testCase.verifyEqual(testCase.cnvObj.Profile, '1');
      testCase.verifyEqual(testCase.cnvObj.Julian, testCase.ncObj.root('TIME'))
      testCase.verifyEqual(testCase.cnvObj.Date, testCase.ncObj.root('TIME') + ...
        datenum(1950, 1, 1));
      testCase.verifyEqual(testCase.cnvObj.Latitude, testCase.ncObj.root('LATITUDE'));
      testCase.verifyEqual(testCase.cnvObj.Longitude, testCase.ncObj.root('LONGITUDE'));
      testCase.verifyEqual(testCase.cnvObj.CtdType, 'SBE 9');
      testCase.verifyEqual(testCase.cnvObj.SeasaveVersion, '3.2');
      testCase.verifyEqual(testCase.cnvObj.Header(1), '* Sea-Bird SBE 9 Data File:')
      testCase.verifyEqual(testCase.cnvObj.Header(302), '# file_type = ascii');
    end
    
    % test and compare cnv file read with readCnv class with hardcoded value
    % ---------------------------------------------------------------------
    function testVarNames(testCase)
      theKeys = {'scan','timeJ','prDM','depSM','t090C','t190C','c0Sm','c1Sm',...
        'sbeox0V','sbeox1V','sbox1dVdT','sbox0dVdT','latitude','longitude',...
        'timeS','flECO-AFL','CStarTr0','sbox0MmKg','sbox1MmKg','sal00','sal11',...
        'sigma-00','sigma-11','svCM','svCM1','nbin','flag'};
      theValues = {'Scan Count','Julian Days','Pressure, Digiquartz [db]','Depth [salt water, m]',...
        'Temperature [ITS-90, deg C]','Temperature, 2 [ITS-90, deg C]','Conductivity [S/m]',...
        'Conductivity, 2 [S/m]','Oxygen raw, SBE 43 [V]','Oxygen raw, SBE 43, 2 [V]',...
        'Oxygen, SBE 43, 2 [dov/dt]','Oxygen, SBE 43 [dov/dt]','Latitude [deg]',...
        'Longitude [deg]','Time, Elapsed [seconds]','Fluorescence, WET Labs ECO-AFL/FL [mg/m^3]',...
        'Beam Transmission, WET Labs C-Star [%]','Oxygen, SBE 43 [umol/kg], WS = 2',...
        'Oxygen, SBE 43, 2 [umol/kg], WS = 2','Salinity, Practical [PSU]',...
        'Salinity, Practical, 2 [PSU]','Density [sigma-theta, kg/m^3]',...
        'Density, 2 [sigma-theta, kg/m^3]','Sound Velocity [Chen-Millero, m/s]',...
        'Sound Velocity, 2 [Chen-Millero, m/s]','number of scans per bin','flag'};
      
      theMap = containers.Map( theKeys, theValues,'UniformValues',true);
      
      for k = keys(theMap)
        key = char(k);
        testCase.assumeTrue(isKey(testCase.cnvObj.varNames,key), ...
          sprintf('The specified key: (%s) is not present in this container.',key));
        testCase.verifyEqual(theMap(key), testCase.cnvObj.varNames(key), ...
          sprintf('Value: (%s) is not equal for key: (%s) in this container.',...
          key, theMap(key)));
      end
    end
    
    % test and compare cnv file read with readCnv class with hardcoded value
    % ---------------------------------------------------------------------
    function testSensors(testCase)
      theKeys = {'Frequency 0, Temperature','Frequency 1, Conductivity',...
        'Frequency 2, Pressure, Digiquartz with TC',...
        'Frequency 3, Temperature, 2','Frequency 4, Conductivity, 2',...
        'A/D voltage 0, Oxygen, SBE 43','A/D voltage 1, Oxygen, SBE 43, 2',...
        'A/D voltage 2, Transmissometer, WET Labs C-Star',...
        'A/D voltage 3, Fluorometer, WET Labs ECO-AFL/FL','A/D voltage 4, Altimeter'};
      theValues = {'6083','4509','1263','6086','4510','3261','3265','CTS1210DR',...
        'FLRTD-1367','61768'};
      
      theMap = containers.Map( theKeys, theValues,'UniformValues',true);
      
      for k = keys(theMap)
        key = char(k);
        testCase.assumeTrue(isKey(testCase.cnvObj.sensors, key), ...
          sprintf('The specified key: (%s) is not present in this container.',key));
        testCase.verifyEqual(theMap(key), testCase.cnvObj.sensors(key), ...
          sprintf('Value: (%s) is not equal for key: (%s) in this container.',...
          key, theMap(key)));
      end
    end
    
    % test inherited keys/values
    % --------------------------
    function testData(testCase)
      data = testCase.cnvObj;
      for k = keys(data)
        key = char(k);
        % test notations: data.sal00 and data('sal00')
        testCase.verifyEqual(size(data.(key)), size(data(key)),...
          sprintf('Invalid size for key: (%s).',key));
      end
      % test logical indexing
      testCase.verifyEqual(data.scan(1:4),[-234;504;2324;2723]);
    end
    
    % test and compare netcdf file read with native Matlab netcdf functions
    % with hardcoded value
    % ---------------------------------------------------------------------
    function testGlobalAttributes( testCase )
      testCase.verifyEqual(ncreadatt(testCase.ncFilename,'/', 'ctdtype'), 'SBE 9');
      testCase.verifyEqual(ncreadatt(testCase.ncFilename,'/', 'plateforme'), 'THALASSA');
      testCase.verifyEqual(ncreadatt(testCase.ncFilename,'/', 'cruise'), 'PIRATA-FR26');
      testCase.verifyEqual(ncreadatt(testCase.ncFilename,'/', 'date_type'), 'OceanSITES profile data');
      testCase.verifyEqual(ncreadatt(testCase.ncFilename,'/', 'created_by'), 'jgrelet');
      testCase.verifyEqual(ncreadatt(testCase.ncFilename,'/', 'format_version'), '1.2');
      testCase.verifyEqual(ncreadatt(testCase.ncFilename,'/', 'netcdf_version'), netcdf.inqLibVers);
      testCase.verifyEqual(ncreadatt(testCase.ncFilename,'/', 'Conventions'), 'CF-1.6, OceanSITES-1.2');
      testCase.verifyEqual(ncreadatt(testCase.ncFilename,'/', 'comment'), 'Data read from readCnv program');
      header = ncreadatt(testCase.ncFilename,'/', 'header');
      testCase.verifyTrue(logical(strfind(header, '* Sea-Bird SBE 9 Data File:')));
    end
    
     % test and compare netcdf file read with native Matlab netcdf
     % functions with result from readNc class 
     % -------------------------------------------------------------
    function testRawData(testCase)
      info = ncinfo(testCase.ncFilename, 'raw');
      for i = 1: length(info.Variables)
        n = ncread(testCase.ncFilename, sprintf('raw/%s', info.Variables(i).Name));
        v = testCase.cnvObj.(info.Variables(i).Name);
        testCase.verifyEqual(n, v);
      end
    end
    
    
  end
  
end
