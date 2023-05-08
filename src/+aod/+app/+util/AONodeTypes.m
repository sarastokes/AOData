classdef AONodeTypes 
% Node types in AODataViewer display tree
%
% Description:
%   Enumerated type for uitreenodes representing specific AOData components
%
% Methods:
%   out = aod.app.util.AONodeTypes.getIconPath(obj)
%       Gets the node-specific icon type
%
% Static methods:
%   obj = aod.app.util.AONodeTypes.get(data, datasetName)
%       Matches AOData system names if dataset name is provided, then 
%       passes the data to init()
%   obj = aod.app.util.AONodeTypes.init(nodeName);
%       Returns the node type given the text name which can often be 
%       extracted from the data with class()
%
% Notes:
%   Might have gone a bit overboard with the icons but it looks cool

% By Sara Patterson, 2023 (AOData)
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
        LOGICAL

        % Specific AOData types
        PARAMETERMANAGER
        DATASETMANAGER
        HOMEDIRECTORY
        QUERYMANAGER
        FILEREADER
        DESCRIPTION
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
            if obj == aod.app.util.AONodeTypes.NUMERIC && ischar(data)
                displayType = 'Text';
            end
        end

        function out = processDataForDisplay(obj, data)
            if nargin < 2
                out = [];
                return;
            end

            import aod.app.util.AONodeTypes;

            switch obj
                case AONodeTypes.DATETIME
                    out = datestr(data); %#ok<DATST> 
                case AONodeTypes.ENUM
                    out = char(data);
                case AONodeTypes.TRANSFORM
                    out = data.T;
                case AONodeTypes.PARAMETERMANAGER
                    out = data.table();
                case AONodeTypes.NUMERIC
                    if ~ismatrix(data)
                        out = sprintf("Data size = %u", size(data,1));
                        for i = 2:ndims(data)
                            out = out + sprintf("x %u", size(data,i));
                        end
                    else
                        out = data;
                    end
                otherwise
                    out = data;
            end
        end

        function tf = isTextDisplay(obj)
            import aod.app.util.AONodeTypes;

            textNodes = [...
                AONodeTypes.TEXT,...
                AONodeTypes.DATETIME,...
                AONodeTypes.ENUM,...        % TODO: non-scalar
                AONodeTypes.NAME,...
                AONodeTypes.DESCRIPTION,...
                AONodeTypes.HOMEDIRECTORY,...
                AONodeTypes.QUERYMANAGER];

            tf = ismember(obj, textNodes);
        end

        function tf = isTableDisplay(obj)
            % Get nodes with non-scalar display

            import aod.app.util.AONodeTypes;

            tableNodes = [...
                AONodeTypes.TABLE,...
                AONodeTypes.TIMETABLE,...
                AONodeTypes.NUMERIC,...
                AONodeTypes.NOTES,...       % non-scalar string
                AONodeTypes.TRANSFORM,...
                AONodeTypes.PARAMETERMANAGER,...
                AONodeTypes.CODE];
            
            tf = ismember(obj, tableNodes);
        end

        function out = getDisplayType(obj)
            % Display type for HDF5 datasets
            import aod.app.util.AONodeTypes;

            if obj.isTextDisplay()
                out = 'Text';
            elseif obj.isTableDisplay()
                out = 'Table';
            else
                out = [];
            end
        end

        function out = getIconPath(obj)
            import aod.app.util.AONodeTypes;

            switch obj 
                case AONodeTypes.ENTITY 
                    out = 'folder.png';
                case AONodeTypes.CONTAINER
                    out = 'new-product.png';
                case {AONodeTypes.NUMERIC, AONodeTypes.TRANSFORM}
                    out = 'grid.png';
                case AONodeTypes.LINK
                    out = 'link.png';
                case AONodeTypes.TEXT 
                    out = 'new-document.png';
                case AONodeTypes.DATETIME 
                    out = 'calendar.png';
                case [AONodeTypes.TABLE, AONodeTypes.TIMETABLE]
                    out = 'data-sheet.png';
                case [AONodeTypes.STRUCTURE, AONodeTypes.MAP]
                    out = 'tree-structure.png';
                case AONodeTypes.ENUM
                    out = 'list.png';
                case AONodeTypes.LOGICAL
                    out = 'icon8-binary-file.png';
                case AONodeTypes.FILES 
                    out = 'filecabinet.png';
                case AONodeTypes.NOTES
                    out = 'making-notes.png';
                case AONodeTypes.NAME 
                    out = 'contact-details.png';
                case AONodeTypes.DESCRIPTION
                    out = 'info.png';
                case AONodeTypes.CODE 
                    out = 'code.png';
                case AONodeTypes.HOMEDIRECTORY 
                    out = 'home-page.png';
                case AONodeTypes.PARAMETERMANAGER
                    out = 'settings.png';
                case AONodeTypes.DATASETMANAGER 
                    out = 'settings.png';
                case AONodeTypes.QUERYMANAGER
                    out = 'search.png';
                otherwise
                    out = 'grid.png';
            end
            out = [obj.ICON_DIR, out];
        end
    end

    methods (Static)
        function obj = get(data, name)
            % Get AONodeType by data class or dataset name
            %
            % Syntax:
            %   obj = aod.app.util.AONodeTypes.get(data, name)
            % -------------------------------------------------------------
            
            import aod.app.util.AONodeTypes

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
                    case 'description'
                        obj = AONodeTypes.DESCRIPTION;
                    case 'homedirectory'
                        obj = AONodeTypes.HOMEDIRECTORY;
                    case 'filereader'
                        obj = AONodeTypes.FILEREADER;
                    case 'expectedparameters'
                        obj = AONodeTypes.PARAMETERMANAGER;
                    case 'expecteddatasets'
                        obj = AONodeTypes.DATASETMANAGER;
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
            elseif islogical(data)
                obj = AONodeTypes.LOGICAL;
            else
                obj = AONodeTypes.init(class(data));
            end
        end

        function obj = init(nodeName)
            if isa(nodeName, 'aod.app.util.AONodeTypes')
                obj = nodeName;
                return 
            end

            import aod.app.util.AONodeTypes;

            switch lower(nodeName)
                case 'double'
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
                case 'logical'
                    obj = AONodeTypes.LOGICAL;
                case {'aod.util.parameters', 'files'}
                    obj = AONodeTypes.FILES;
                case 'aod.util.filereader'
                    obj = AONodeTypes.FILEREADER;
                case 'affine2d'
                    obj = AONodeTypes.TRANSFORM;
                case 'notes'
                    obj = AONodeTypes.NOTES;
                case 'description'
                    obj = AONodeTypes.DESCRIPTION;
                case 'homedirectory'
                    obj = AONodeTypes.HOMEDIRECTORY;
                case {'parametermanager', 'aod.util.parametermanager'}
                    obj = AONodeTypes.PARAMETERMANAGER;
                case {'datasetmanager', 'aod.util.datasetmanager'}
                    obj = AONodeTypes.DATASETMANAGER;
                case {'querymanager', 'aod.api.querymanager'}
                    obj = AONodeTypes.QUERYMANAGER;
                otherwise
                    warning('AONodeTypes_get:UnrecognizedInput',...
                        'Node name %s was not recognized', nodeName);
                    obj = AONodeTypes.UNKNOWN;
            end
        end
    end
end