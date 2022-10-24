classdef AONodeTypes 
% AONODETYPES
%
% Description:
%   Enumerated type for uitreenodes representing specific AOData components
%
% Methods:
%   out = getIconPath(obj)
%
% Static methods:
%   obj = get(txt)
% -------------------------------------------------------------------------

    enumeration
        UNKNOWN

        % Link types
        LINK  

        % Group types
        ENTITY 
        CONTAINER

        % Dataset types
        TEXT 
        NUMERIC 
        TABLE 
        TIMETABLE 
        DATETIME 
        STRUCTURE
        MAP 
        ENUM 
        TRANSFORM

        % System types
        FILES
        NOTES
    end

    properties (Hidden, Constant)
        ICON_DIR = [fileparts(mfilename('fullpath')), filesep, ...
                    '+icons', filesep];
    end
    
    methods 
        function [displayType, data] = displayInfo(obj, data)
            displayType = obj.getDisplayType();
            data = obj.processDataForDisplay(data);
            if obj == aod.app.AONodeTypes.NUMERIC && ischar(data)
                displayType = 'Text';
            end
        end

        function out = processDataForDisplay(obj, data)
            if nargin < 2
                out = [];
                return;
            end

            import aod.app.AONodeTypes;

            switch obj
                case AONodeTypes.DATETIME
                    out = datestr(data); %#ok<DATST> 
                case AONodeTypes.ENUM
                    out = char(data);
                case AONodeTypes.TRANSFORM
                    out = data.T;
                case AONodeTypes.NUMERIC
                    if ~ismatrix(data)
                        out = sprintf('Data size = %u', size(data,1));
                        for i = 2:ndims(data)
                            out = [out, sprintf('x %u', size(data,i))]; %#ok<AGROW> 
                        end
                    else
                        out = data;
                    end
                otherwise
                    out = data;
            end
        end

        function out = getDisplayType(obj)
            import aod.app.AONodeTypes;

            switch obj
                case {AONodeTypes.TEXT, AONodeTypes.DATETIME, AONodeTypes.ENUM}
                    out = 'Text';
                case {AONodeTypes.TABLE, AONodeTypes.TIMETABLE}
                    out = 'Table';
                case {AONodeTypes.NUMERIC, AONodeTypes.TRANSFORM}
                    out = 'Table';
                otherwise
                    out = [];
            end
        end

        function out = getIconPath(obj)
            import aod.app.AONodeTypes;

            switch obj 
                case AONodeTypes.ENTITY 
                    out = 'folder.png';
                case AONodeTypes.CONTAINER
                    out = 'container.png';
                case {AONodeTypes.NUMERIC, AONodeTypes.TRANSFORM}
                    out = 'data.png';
                case AONodeTypes.LINK
                    out = 'chain.png';
                case AONodeTypes.TEXT 
                    out = 'text.png';
                case AONodeTypes.FILES 
                    out = 'filecabinet.png';
                case AONodeTypes.NOTES
                    out = 'notepad.png';
                case AONodeTypes.DATETIME 
                    out = 'time.png';
                case {AONodeTypes.TABLE, AONodeTypes.TIMETABLE}
                    out = 'table.png';
                case {AONodeTypes.STRUCTURE, AONodeTypes.MAP}
                    out = 'structure.png';
                case AONodeTypes.ENUM
                    out = 'list.png';
                otherwise
                    out = 'data.png';
            end
            out = [obj.ICON_DIR, out];
        end
    end

    methods (Static)
        function obj = getFromData(data)
            import aod.app.AONodeTypes

            if isenum(data)
                obj = AONodeTypes.ENUM;
            else
                obj = AONodeTypes.get(class(data));
            end
        end

        function obj = get(nodeName)
            if isa(nodeName, 'aod.app.AONodeTypes')
                obj = nodeName;
                return 
            end

            import aod.app.AONodeTypes;

            switch lower(nodeName)
                case {'logical', 'double'}
                    obj = AONodeTypes.NUMERIC;
                case {'char', 'string'}
                    obj = AONodeTypes.TEXT;
                case 'entity'
                    obj = AONodeTypes.ENTITY;
                case 'container'
                    obj = AONodeTypes.CONTAINER;
                case 'link'
                    obj = AONodeTypes.LINK;
                case 'datetime'
                    obj = AONodeTypes.DATETIME;
                case 'table'
                    obj = AONodeTypes.TABLE;
                case 'timetable'
                    obj = AONodeTypes.TIMETABLE;
                case 'timeseries'
                    obj = AONodeTypes.TIMESERIES;
                case 'enum'
                    obj = AONodeTypes.ENUM;
                case 'struct'
                    obj = AONodeTypes.STRUCTURE;
                case {'aod.util.parameters', 'files'}
                    obj = AONodeTypes.FILES;
                case 'affine2d'
                    obj = AONodeTypes.TRANSFORM;
                case 'files'
                    obj = AONodeTypes.FILES;
                case 'notes'
                    obj = AONodeTypes.NOTES;
                otherwise
                    warning('AONodeTypes_get:UnrecognizedInput',...
                        'Node name %s was not recognized', nodeName);
                    obj = AONodeTypes.UNKNOWN;
            end
        end
    end
end