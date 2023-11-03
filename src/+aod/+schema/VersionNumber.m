classdef VersionNumber < handle
% VERSIONNUMBER
%
% Description:
%   Represents a schema version number

% By Sara Patterson, 2023 (AOData)
% ------------------------------------------------------------------------

    properties
        Tag             {mustBeInteger} = 0
        Update          {mustBeInteger} = 0
        Patch           {mustBeInteger} = 0

        TagLog          string
    end

    methods
        function obj = VersionNumber(tag, update, patch)
            if istext(tag) && nargin == 1
                output = obj.parseTextVersion(tag);
                obj.Tag = output(1);
                obj.Update = output(2);
                obj.Patch = output(3);
            else
                obj.Tag = tag;
                obj.Patch = patch;
                obj.Update = update;
            end
        end
    end

    methods (Static)
        function data = parseTextVersion(input)
            arguments
                input   (1,1)       string
            end

            txt = strsplit(input);
            data = arrayfun(@(x) str2double(x), txt)';
        end
    end

end