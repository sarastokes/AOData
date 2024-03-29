classdef RegistrationReportReader < aod.common.FileReader
% REGISTRATIONREPORTREADER
%
% Description:
%   Reads in registration reports from Qiang's ImageReg software
%
% Parent:
%   aod.common.FileReader
%
% Constructor:
%   obj = RegistrationReportReader(fileName)
%
% Static instantiation:
%   obj = RegistrationReportReader.init(folderPath, ID)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = RegistrationReportReader(fileName)
            obj@aod.common.FileReader(fileName);
        end

        function out = readFile(obj)
            obj.Data = struct();

            opts = delimitedTextImportOptions();
            opts.Delimiter = ',';
            opts.DataLines = [1 1];            
            V = readtable(obj.fullFile, opts);
            V = string(V{1,:})';

            warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
            T = readtable(obj.fullFile);
            warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

            [~, colStripX] = extractMatches(V, "strip-" + digitsPattern + "x");
            if ~isempty(colStripX)                
                [~, colStripY] = extractMatches(V, "strip-" + digitsPattern + "y");
                try
                    obj.Data.stripX = T{:,colStripX};
                    obj.Data.stripY = T{:,colStripY};
                    obj.Data.hasStrip = true;
                catch 
                    warning("readFile:StripXYError",...
                        "Registration data could not be imported");
                    obj.Data.hasStrip = false;
                end
            else
                obj.Data.hasStrip = false;
            end

            try
                frameX = T{:, contains(V, "frame-x")};
                if isempty(frameX)
                    obj.Data.hasFrame = false;
                else
                    frameY = T{:, contains(V, "frame-y")};
                    obj.Data.frameXY = [frameX, frameY];
                    obj.Data.hasFrame = true;
                end
            catch
                warning("readFile:FrameXYError",...
                    "RegistrationData could not be imported");
                obj.Data.hasFrame = false;
            end

            if obj.Data.hasStrip || obj.Data.hasFrame
                obj.Data.correlationCoefficient = T{:, contains(V, "coef")};
                obj.Data.regFlag = T{:, contains(V, "flag")};
                obj.Data.regDescription = string(T{:, contains(V, "description")});
            end

            if numel(V) < numel(T)
                obj.Data.rotationAngle = T{:, end};
            end

            out = obj.Data;
        end
    end

    methods (Static)
        function out = read(fileName)
            obj = aod.builtin.readers.RegistrationReportReader(fileName);
            out = obj.readFile();
        end

        function obj = init(folderPath, ID)
            % CREATEBYID
            %
            % Description:
            %   Identify file name based on standardized registration 
            %   software naming and use it to instantiate the object
            %
            % Syntax:
            %   obj = RegistrationReportReader.init(folderPath, ID)
            %
            % Inputs:
            %   folderPath              path to folder containing report
            %   ID                      video number
            %
            % Note:
            %   If multiple registrations are found for the video ID, the 
            %   most recent registration will be used
            % -------------------------------------------------------------
            arguments
                folderPath      {mustBeFolder}
                ID              {mustBeInteger}
            end
            
            files = ls(folderPath);
            files = deblank(string(files));
            files = files(contains(files, 'motion') & endsWith(files, 'csv'));
            ind = find(contains(files, ['_', int2fixedwidthstr(ID, 4)]));

            if isempty(ind)
                error('File for ID %u not found in %s!', ID, folderPath);
            elseif numel(ind) > 1 
                warning('Epoch %u - %u registration files found! Using last',... 
                    ID, numel(ind));
                disp(files(ind));
                ind = ind(end);
            end

            obj = aod.builtin.readers.RegistrationReportReader(...
                fullfile(folderPath, char(files(ind))));
        end
    end
end