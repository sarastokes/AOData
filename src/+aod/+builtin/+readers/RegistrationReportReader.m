classdef RegistrationReportReader < aod.core.FileReader
% REGISTRATIONREPORTREADER
%
% Description:
%   Reads in registration report from Qiang's ImageReg software
%
% Constructor:
%   obj = ao.builtin.RegistrationReportReader(fileName)
%   obj = ao.builtin.RegistrationReportReader(experimentDir, epochID)
%
% History:
%   09Mar2022 - SSP - from ao.core.Dataset/checkRegistrationReports
% -------------------------------------------------------------------------

    methods
        function obj = RegistrationReportReader(varargin)
            obj@aod.core.FileReader(varargin{:});
        end

        function getFileName(obj, experimentDir, epochID)
            obj.Path = [experimentDir, filesep, 'Ref'];
            refFiles = ls(obj.Path);
            refFiles = deblank(string(refFiles));
            refFiles = refFiles(contains(refFiles, 'motion') & endsWith(refFiles, 'csv'));
            ind = find(contains(refFiles, ['ref_', int2fixedwidthstr(epochID, 4)]));
            
            if isempty(ind)
                warning('Epoch %u - no registration file found!', epochID);
            elseif numel(ind) > 1
                warning('Epoch %u - %u registration files found!', epochID, numel(ind));
                disp(refFiles(ind));
            else
                obj.Name = char(refFiles(ind));
            end
        end

        function out = read(obj)
            warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
            obj.Data = readtable(obj.fullFile);
            warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
            out = obj.Data;
        end
    end
end