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
        FILES
    end

    properties (Hidden, Constant)
        ICON_DIR = [fileparts(mfilename('fullpath')), filesep, ...
                    '+icons', filesep];
    end
    
    methods 
        function out = getIconPath(obj)
            import aod.app.AONodeTypes;

            switch obj 
                case AONodeTypes.ENTITY 
                    out = 'folder.png';
                case AONodeTypes.CONTAINER
                    out = 'folder_container.png';
                case {AONodeTypes.NUMERIC, AONodeTypes.TRANSFORM}
                    out = 'data.png';
                case AONodeTypes.LINK
                    out = 'link.png';
                case AONodeTypes.TEXT 
                    out = 'document.png';
                case AONodeTypes.FILES 
                    out = 'filecabinet.png';
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
                otherwise
                    warning('AONodeTypes_get:UnrecognizedInput',...
                        'Node name %s was not recognized', nodeName);
                    obj = AONodeTypes.UNKNOWN;
            end
        end
    end
end