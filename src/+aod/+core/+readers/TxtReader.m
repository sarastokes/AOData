classdef (Abstract) TxtReader < aod.core.FileReader
% TEXTREADER (abstract)
%
% Description:
%   Superclass for text reader classes, useful methods for robust code
%
% Parent:
%   obj = aod.core.FileReader
%
% Constructor:
%   obj = TxtReader(varargin)
%
% Protected methods:
%   txt = readProperty(obj, header, N)
% -------------------------------------------------------------------------

    methods
        function obj = TxtReader(varargin)
            obj = obj@aod.core.FileReader(varargin{:});
            obj.validExtensions = '*.txt';
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
 
        function out = readText(obj, header)
            out = obj.strtrim(obj.readProperty(header));
        end

        function out = readNumber(obj, header)
            out = str2double(obj.strtrim(obj.readProperty(header)));
        end

        function out = readYesNo(obj, header)
            out = convertYesNo(obj.strtrim(obj.readProperty(header)));
        end

        function out = strtrim(obj, txt)
            % STRTRIM 
            %
            % Description:
            %   Identical to builtin version but no error for empty txt
            % -------------------------------------------------------------
            if isempty(txt)
                out = [];
            else
                out = strtrim(txt);
            end
        end
    end
end