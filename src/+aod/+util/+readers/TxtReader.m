classdef (Abstract) TxtReader < aod.common.FileReader
% Text file reader (abstract)
%
% Description:
%   Superclass for text reader classes with useful methods for robust code
%
% Parent:
%   obj = aod.common.FileReader
%
% Constructor:
%   obj = aod.util.readers.TxtReader(varargin)
%
% Protected methods:
%   out = readText(obj, header)
%   out = readNumber(obj, header)
%   out = readTrueFalse(obj, header)
%   out = readYesNo(obj, header)
%   txt = readProperty(obj, header, N)
%
% Use:
%   Assumes the lines of interest in the txt file are identified by some
%   header text. For example:
%       FieldOfView = 3.69, 2.70
%   The header is "FieldOfView =". Trailing and leading whitespace will be 
%   ignored & '3.69, 2.70' is extracted by readProperty('FieldOfView =')
%   Use readNumber() to extract and then convert to a double [3.69 2.70]
%
%   readProperty() is the basis for all read methods - use this if you 
%   need to write your own function to extract data with a header
%
% Notes:
%   Using the headers to extract data rather than going line by line means
%   the code will be robust to small changes in the data file (e.g. adding 
%   a field) and only small changes will be necessary for the removal or 
%   change of a field (remove the line from the code or change the header)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = TxtReader(fileName)
            obj = obj@aod.common.FileReader(fileName);
        end
    end

    methods (Access = protected)
        function out = readText(obj, header)
            % Extract text and remove leading/trailing whitespace
            %
            % Syntax:
            %   out = readText(obj, header)
            % -------------------------------------------------------------
            out = obj.strtrim(obj.readProperty(header));
        end

        function out = readNumber(obj, header)
            % Extract one or more numbers (either integers or with decimals)
            %
            % Syntax:
            %   out = readNumber(obj, header)
            %
            % Notes:
            %   Numbers must be separated by some non-numeric character
            %   but otherwise any separation is accepted (e.g. "2.5 1.2", 
            %   "2.5, 1.2", "2.5/1.2", "2.5/1.2,3" etc.)
            % -------------------------------------------------------------
            out = obj.strtrim(obj.readProperty(header));
            if isempty(out)
                return
            end
            pat = digitsPattern + "." + digitsPattern | digitsPattern;
            out = str2double(extract(out, pat))';
        end

        function out = readTrueFalse(obj, header)
            % Extract "true" or "false" and convert to logical
            %
            % Syntax:
            %   out = readTrueFalse(obj, header)
            %
            % Notes: 
            %   Case-insensitive so "True", "true" and "TRUE" are all okay
            % -------------------------------------------------------------
            out = obj.strtrim(obj.readProperty(header));

            if isempty(out)
                out = NaN;
            end

            switch lower(out)
                case 'true'
                    out = true;
                case 'false'
                    out = false;
                otherwise
                    warning('readTrueFalse: Unrecognized input: %s', out);
                    out = NaN;
            end
        end

        function out = readYesNo(obj, header)
            % Extract "yes" or "no" and convert to logical
            %
            % Syntax:
            %   out = readYesNo(obj, header)
            %
            % Notes: 
            %   Case-insensitive so "Yes", "yes" and "YES" are all okay
            % -------------------------------------------------------------
            out = obj.strtrim(obj.readProperty(header));
            if isempty(out)
                out = NaN;
            end
            
            switch lower(out)
                case 'yes'
                    out = true;
                case 'no'
                    out = false;
                otherwise
                    warning('readYesNo: Unrecognized input: %s', out);
                    out = NaN;
            end
        end
    end

    methods (Access = protected)
        function lineValue = readProperty(obj, header, N)
            % READPROPERTY
            % 
            % Description:
            %   Read a line from parameter file based on starting text
            % 
            % Syntax:
            %   lineValue = readProperty(obj, header, N)
            %
            % Inputs:
            %   header          char
            %       Text used to identify the line containing the parameter
            %       of interest. Will be omitted from the returned value
            % Optional inputs:
            %   N               double (default = 1)
            %       If there are multiple uses of the same header, specify
            %       which one to return. Default returns the first.
            % -------------------------------------------------------------
            if nargin < 3
                N = 1;
            end
            
            fid = fopen(obj.fullFile, 'r');
            if fid == -1
                warning('File %s could not be opened', obj.fullFile);
                lineValue = 'NaN'; 
                return
            end
            
            counter = 0;
            lineValue = [];
            tline = fgetl(fid);
            while ischar(tline)
                ind = strfind(tline, header);
                if ~isempty(ind)
                    counter = counter + 1;
                    if counter == N
                        lineValue = tline(ind + numel(header) : end);
                        break
                    else
                        tline = fgetl(fid);
                    end
                else
                    tline = fgetl(fid);
                end
            end
            fclose(fid);
        end
    end

    methods (Static, Access = protected)
        function out = strtrim(txt)
            % Identical to MATLAB strtrim but no error for empty txt
            %
            % Syntax:
            %   out = strtrim(txt)
            %
            % Notes:
            %   If input text is empty, instead of throwing an error, the 
            %   value for out will be empty as well
            % -------------------------------------------------------------
            if isempty(txt)
                out = [];
            else
                out = strtrim(txt);
            end
        end
    end

    methods (Static)
        function out = read(fName)
            obj = aod.util.readers.TxtReader(fName);
            out = obj.readFile();
        end
    end
end