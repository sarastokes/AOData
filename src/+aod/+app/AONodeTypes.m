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
        LOGICAL

        % Specific AOData types
        PARAMETERMANAGER
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
            import aod.app.AONodeTypes;

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

            import aod.app.AONodeTypes;

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
            import aod.app.AONodeTypes;

            if obj.isTextDisplay()
                out = 'Text';
            elseif obj.isTableDisplay()
                out = 'Table';
            else
                out = [];
            end
        end

        function out = getIconPath(obj)
            import aod.app.AONodeTypes;

            switch obj 
                case AONodeTypes.ENTITY 
                    out = 'icons8-folder-40.png';
                case AONodeTypes.CONTAINER
                    out = 'icons8-new-product-40.png';
                case {AONodeTypes.NUMERIC, AONodeTypes.TRANSFORM}
                    out = 'icons8-grid-40.png';
                case AONodeTypes.LINK
                    out = 'icons8-link-40.png';
                case AONodeTypes.TEXT 
                    out = 'icons8-new-document-40.png';
                case AONodeTypes.DATETIME 
                    out = 'icons8-calendar-40.png';
                case [AONodeTypes.TABLE, AONodeTypes.TIMETABLE]
                    out = 'icons8-data-sheet-40.png';
                case [AONodeTypes.STRUCTURE, AONodeTypes.MAP]
                    out = 'icons8-tree-structure-40.png';
                case AONodeTypes.ENUM
                    out = 'icons8-list-40.png';
                case AONodeTypes.LOGICAL
                    out = 'icon8-binary-file-40.png';
                case AONodeTypes.FILES 
                    out = 'filecabinet.png';
                case AONodeTypes.NOTES
                    out = 'icons8-making-notes-40.png';
                case AONodeTypes.NAME 
                    out = 'icons8-contact-details-40.png';
                case AONodeTypes.DESCRIPTION
                    out = 'icons8-info-40.png';
                case AONodeTypes.CODE 
                    out = 'icons8-code-40.png';
                case AONodeTypes.HOMEDIRECTORY 
                    out = 'icons8-home-page-40.png';
                case AONodeTypes.PARAMETERMANAGER
                    out = 'icons8-settings-40.png';
                case AONodeTypes.QUERYMANAGER
                    out = 'icons8-search-40.png';
                otherwise
                    out = 'icons8-grid-40.png';
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
                    case 'description'
                        obj = AONodeTypes.DESCRIPTION;
                    case 'homedirectory'
                        obj = AONodeTypes.HOMEDIRECTORY;
                    case 'filereader'
                        obj = AONodeTypes.FILEREADER;
                    case 'expectedparameters'
                        obj = AONodeTypes.PARAMETERMANAGER;
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
            if isa(nodeName, 'aod.app.AONodeTypes')
                obj = nodeName;
                return 
            end

            import aod.app.AONodeTypes;

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