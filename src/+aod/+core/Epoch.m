classdef Epoch < aod.core.Entity & matlab.mixin.Heterogeneous
% A period of data acquision during an experiment
%
% Description:
%   A continuous period of data acquisition within an experiment
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.core.Epoch(ID)
%
% Properties:
%   ID                              Epoch identifier (integer)
%   startTime                       Time when epoch began (datetime)
%   Datasets                        Container for epoch's datasets
%   Registrations                   Container for epoch's registrations
%   Responses                       Container for epoch's responses
%   Stimuli                         Container for epoch's stimuli
%   Source                          Link to Source used during the epoch
%   System                          Link to System used during the epoch
%
% Public methods:
%   add(obj, entity)
%   remove(obj, entityType, ID)
%   out = get(obj, entityType, varargin)
%
% See Also:
%   aod.persistent.Epoch, aod.core.Entity

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        ID (1,1)            double          {mustBeInteger}
    end

    properties (SetAccess = {?aod.core.Epoch, ?aod.core.Experiment})
        startTime (1,1)     datetime
        Timing (1,:)        double      
        Registrations       aod.core.Registration
        Responses           aod.core.Response
        Stimuli             aod.core.Stimulus
        Datasets            aod.core.Dataset
    end

    % Entity link properties
    properties (SetAccess = protected)
        Source          {mustBeEntityType(Source, 'Source')} = aod.core.Source.empty()
        System          {mustBeEntityType(System, 'System')} = aod.core.System.empty()
    end
    
    methods 
        function obj = Epoch(ID, varargin)
            obj = obj@aod.core.Entity();
            obj.ID = ID;
            
            ip = aod.util.InputParser();
            addParameter(ip, 'Source', [], @(x) isSubclass(x, 'aod.core.Source'));
            addParameter(ip, 'System', [], @(x) isSubclass(x, 'aod.core.System'));
            parse(ip, varargin{:});

            obj.setSource(ip.Results.Source);
            obj.setSystem(ip.Results.System);
        end
    end 

    methods
        function add(obj, entity)
            % ADD 
            %
            % Description:
            %   Add a new entity to the epoch
            %
            % Syntax:
            %   add(obj, entity)
            %
            % Notes: Only entities contained by Epoch can be added:
            %   Dataset, Response, Registration, Stimulus
            % ------------------------------------------------------------- 
            import aod.core.EntityTypes

            entityType = EntityTypes.get(entity);

            switch entityType
                case EntityTypes.DATASET
                    entity.setParent(obj);
                    obj.Datasets = cat(1, obj.Datasets, entity);
                case EntityTypes.REGISTRATION 
                    entity.setParent(obj);
                    obj.Registrations = cat(1, obj.Registrations, entity);
                case EntityTypes.RESPONSE 
                    entity.setParent(obj);
                    obj.Responses = cat(1, obj.Responses, entity);
                case EntityTypes.STIMULUS
                    entity.setParent(obj);
                    obj.Stimuli = cat(1, obj.Stimuli, entity);
                otherwise
                    error("Epoch:AddedInvalidEntity",...
                        "Entity must be Dataset, Registration, Response or Stimulus");
            end
        end

        function remove(obj, entityType, ID)

            if ~isscalar(obj)
                arrayfun(@(x) remove(x, entityType, ID), obj);
                return 
            end

            import aod.core.EntityTypes

            entityType = aod.core.EntityTypes.init(entityType);

            ID = convertCharsToStrings(ID);
            if isstring(ID) && strcmpi(ID, "all")
                obj.(entityType.parentContainer()) = entityType.empty();
                return
            elseif isnumeric(ID)
                mustBeInteger(ID);
                mustBeInRange(ID, 1, numel(obj.(entityType.parentContainer())));
                ID = sort(ID, "descend");
            else
                error('remove:InvalidID',...
                    'ID must be "all" or integer index of entities to remove');
            end

            switch entityType 
                case entityType.DATASET
                    obj.Datasets(ID) = []; 
                case entityType.REGISTRATION
                    obj.Registrations(ID) = [];
                case entityType.RESPONSE
                    obj.Responses(ID) = [];
                case entityType.STIMULUS 
                    obj.Stimuli(ID) = [];
                otherwise
                    error('remove:NonChildEntity',...
                        'Entity must be Dataset, Registration, Response or Stimulus');
            end
        end

        function out = get(obj, entityType, queries)
            % Search Epoch's child entities
            %
            % Description:
            %   Search all entities of a specific type that match the given
            %   criteria (described below in examples)
            %
            % Inputs:
            %   entityType          char or aod.core.EntityTypes
            % -------------------------------------------------------------
            
            import aod.core.EntityTypes

            entityType = EntityTypes.init(entityType);

            switch entityType
                case EntityTypes.DATASET 
                    group = obj.Datasets;
                case EntityTypes.REGISTRATION 
                    group = obj.Registrations;
                case EntityTypes.RESPONSE
                    group = obj.Responses;
                case EntityTypes.STIMULUS 
                    group = obj.Stimuli;
                otherwise
                    error('search:InvalidEntityType',...
                        'Only Dataset, Registration, Response and Stimulus can be searched from Epoch');
            end

            if nargin > 2 && ~isempty(group)
                out = aod.core.EntitySearch.go(group, queries);
            else
                out = group;
            end
        end
    end

    % Linked entity methods
    methods (Sealed)  
        function setSource(obj, source)
            % SETSOURCE
            %
            % Description:
            %   Set the Source for this epoch
            %
            % Syntax:
            %   obj.setSource(source)
            % -------------------------------------------------------------
            if isempty(source)
                return
            end
            
            assert(isSubclass(source, 'aod.core.Source'),...
                'source must be subclass of aod.core.Source');
            obj.Source = source;
        end

        function setSystem(obj, system)
            % SETSYSTEM
            % 
            % Description:
            %   Set the System used during this epoch
            %
            % Syntax:
            %   obj.setSystem(system)
            % -------------------------------------------------------------
            if isempty(system)
                return
            end

            assert(isSubclass(system, 'aod.core.System'),...
                'System must be a subclass of aod.core.System');
            obj.System = system;
        end
    end

    % Timing methods
    methods (Sealed)
        function setStartTime(obj, startTime)
            % SETSTARTTIME
            %
            % Description:
            %   Set the time the epoch began
            %
            % Syntax:
            %   setStartTime(obj, startTime)
            % -------------------------------------------------------------
            obj.startTime = startTime;
        end

        function tf = hasTiming(obj)
            % SETTIMING
            %
            % Description:
            %   Whether the epoch has timing or not
            %
            % Syntax:
            %   setTiming(obj, timing)
            % -------------------------------------------------------------
            tf = ~isempty(obj.Timing);
        end

        function setTiming(obj, timing)
            % SETTIMING
            %
            % Description:
            %   Set Epoch timing
            %
            % Syntax:
            %   setTiming(obj, timing)
            % -------------------------------------------------------------
            assert(isnumeric(timing), 'Timing must be numeric');
            obj.Timing = timing;
        end

        function clearTiming(obj)
            % CLEARTIMING
            %
            % Description:
            %   Remove Epoch timing
            %
            % Syntax:
            %   clearTiming(obj)
            % -------------------------------------------------------------
            obj.Timing = [];
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)  
            if isempty(obj.Parent)
                value = ['Epoch', int2fixedwidthstr(obj.ID, 4)];
            else
                value = sprintf('Epoch%u_%s', obj.ID, obj.Parent.label);
            end
        end
    end
end 