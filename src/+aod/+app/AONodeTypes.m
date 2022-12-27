classdef AONodeTypes 
% Node types in AODataViewer display tree
%
% Description:
%   Enumerated type for uitreenodes representing specific AOData components
%
% Methods:
%   out = aod.app.AONodeTypes.getIconPath(obj)
%       Gets the node-specific icon type
%
% Static methods:
%   obj = aod.app.AONodeTypes.get(data, datasetName)
%       Matches AOData system names if dataset name is provided, then 
%       passes the data to init()
%   obj = aod.app.AONodeTypes.init(nodeName);
%       Returns the node type given the text name which can often be 
%       extracted from the data with class()
%
% Notes:
%   Might have gone a bit overboard with the icons but it looks cool

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    enumeration
        % Group types
        ENTITY 
        CONTAINER

        % Dataset types
        TEXT 
        NUMERIC 
        TABLE 
        TIMETABLE 
        TIMESERIES
        DATETIME 
        STRUCTURE
        MAP 
        ENUM 
        TRANSFORM

        % Specific AOData types
        HOMEDIRECTORY
        FILEREADER
        FILES
        NOTES
        NAME
        CODE

        % Link types
        LINK

        % Error prevention type
        UNKNOWN
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
                case [AONodeTypes.TEXT, AONodeTypes.DATETIME, AONodeTypes.ENUM, AONodeTypes.NAME, AONodeTypes.DESCRIPTION]
                    out = 'Text';
                case [AONodeTypes.TABLE, AONodeTypes.TIMETABLE, AONodeTypes.CODE, AONodeTypes.NOTES]
                    out = 'Table';
                case [AONodeTypes.NUMERIC, AONodeTypes.TRANSFORM]
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
                case AONodeTypes.DATETIME 
                    out = 'time.png';
                case [AONodeTypes.TABLE, AONodeTypes.TIMETABLE]
                    out = 'table.png';
                case [AONodeTypes.STRUCTURE, AONodeTypes.MAP]
                    out = 'structure.png';
                case AONodeTypes.ENUM
                    out = 'list.png';
                case AONodeTypes.FILES 
                    out = 'filecabinet.png';
                case AONodeTypes.NOTES
                    out = 'notepad.png';
                case AONodeTypes.NAME 
                    out = 'card.png';
                case AONodeTypes.CODE 
                    out = 'code.png';
                case AONodeTypes.HOMEDIRECTORY 
                    out = 'home.png';
                otherwise
                    out = 'data.png';
            end
            out = [obj.ICON_DIR, out];
        end
    end

    methods (Static)
        function obj = get(data, name)
            % Get AONodeType by data class or dataset name
            %
            % Syntax:
            %   obj = aod.app.AONodeTypes.get(data, name)
            % -------------------------------------------------------------
            
            import aod.app.AONodeTypes

            obj = [];

            % First chec dataset name, if provided, to see if it is a 
            % special AOData dataset.
            if nargin > 1
                switch lower(name) 
                    case 'name'
                        obj = AONodeTypes.NAME;
                    case 'files'
                        obj = AONodeTypes.FILES;
                    case 'notes'
                        obj = AONodeTypes.NOTES;
                    case 'code'
                        obj = AONodeTypes.CODE;
                    case 'homedirectory'
                        obj = AONodeTypes.HOMEDIRECTORY;
                    case 'filereader'
                        obj = AONodeTypes.FILEREADER;
                end
            end

            % Was obj identified by dataset name?
            if ~isempty(obj)
                return
            end

            % Is the node type in the dataset itself
            if istext(data) && strcmp(data, 'FileReader')
                obj = AONodeTypes.FILEREADER;
                return
            end

            % Then try identifying by data type
            if isenum(data)
                obj = AONodeTypes.ENUM;
            else
                obj = AONodeTypes.init(class(data));
            end
        end

        function obj = init(nodeName)
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
                case 'containers.map'
                    obj = AONodeTypes.MAP;
                case 'struct'
                    obj = AONodeTypes.STRUCTURE;
                case {'aod.util.parameters', 'files'}
                    obj = AONodeTypes.FILES;
                case 'aod.util.FileReader'
                    obj = AONodeTypes.FILEREADER;
                case 'affine2d'
                    obj = AONodeTypes.TRANSFORM;
                case 'notes'
                    obj = AONodeTypes.NOTES;
                case 'homedirectory'
                    obj = AONodeTypes.HOMEDIRECTORY;
                otherwise
                    warning('AONodeTypes_get:UnrecognizedInput',...
                        'Node name %s was not recognized', nodeName);
                    obj = AONodeTypes.UNKNOWN;
            end
        end
    end
end