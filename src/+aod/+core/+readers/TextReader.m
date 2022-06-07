classdef (Abstract) TextReader < aod.core.FileReader
% TEXTREADER
%
% Description:
%   Superclass for text reader classes, useful methods for robust code
%
% Protected methods:
%   txt = readProperty(obj, header, N)
% -------------------------------------------------------------------------

    properties (Hidden, SetAccess = protected)
        validExtensions = '*.txt';
    end

    methods
        function obj = TextReader(varargin)
            obj = obj@aod.core.FileReader(varargin{:});
        end
    end

    methods (Access = protected)
        function lineValue = readProperty(obj, headerText, N)
            % READPROPERTY
            % 
            % Description:
            %   Read a line from parameter file based on starting text
            % 
            % Syntax:
            %   lineValue = obj.readProperty(headerText, N)
            % -------------------------------------------------------------
            if nargin < 3
                N = 1;
            end
            fid = open(obj.fullFile, 'r');
            if fid == -1
                error('File %s count not be opened', obj.fullFile);
            end
    
            counter = 0;
            lineValue = [];
            tline = fgetl(fid);
            while ischar(tline)
                ind = strfind(tline, headerText);
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
end