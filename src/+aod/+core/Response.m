classdef Response < aod.core.Entity & matlab.mixin.Heterogeneous
% A response extracted from data acquired during an epoch
%
% Description:
%   A response extracted from data acquired during an Epoch
%
% Parent: 
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.core.Response(name, fileName, fileReader)
%
% Properties:
%   Data 
%   dateCreated
%
% Methods:
%   setData(obj, data)
%   addTiming(obj, timing)
%   clearTiming(obj)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Data                             
        Timing (1,:)                            

        fileName            string
        fileReader          % aod.util.FileReader

        Dataset             aod.core.Dataset 
    end

    methods
        function obj = Response(name, fileName, reader)
            arguments
                name        char
                fileName    char        = []
                reader                  = []
            end
            
            obj@aod.core.Entity(name);
            obj.fileName = fileName;
            obj.setFileReader(reader);
        end
    end

    methods (Sealed)
        function setFileReader(obj, reader)
            if nargin == 1 || isempty(reader)
                return
            end
            assert(isSubclass(reader, 'aod.util.FileReader'),...
                'Input must be a subclass of aod.util.FileReader');
            obj.fileReader = reader;
        end
    end

    methods (Sealed)
        function setData(obj, data)
            % SETDATA
            %
            % Syntax:
            %   setData(obj, data)
            % -------------------------------------------------------------
            obj.Data = data;
        end

        function setTiming(obj, timing)
            % SETTIMING
            %
            % Syntax:
            %   addTiming(obj, timing)
            % -------------------------------------------------------------
            assert(isnumeric(timing) || isduration(timing),...
                'Timing must be numeric or duration');
            obj.Timing = timing;
        end

        function clearTiming(obj)
            % CLEARTIMING
            %
            % Syntax:
            %   clearTiming(obj)
            % -------------------------------------------------------------
            obj.Timing = [];
        end
    end

    methods (Access = protected)
        function sync(obj)
            sync@aod.core.Entity(obj);
            if isempty(obj.Timing) && ~isempty(obj.Parent.Timing)
                obj.Timing = obj.Parent.Timing;
            end
        end
    end
end