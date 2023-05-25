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
%   obj = aod.core.Epoch(ID, varargin)
%
% Properties:
%   ID                              Epoch identifier (integer)
%   startTime                       Time when epoch began (datetime)
%   EpochDatasets                   Container for epoch's datasets
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
        % Epoch ID number in Experiment
        ID (1,1)            double          {mustBeInteger}
    end

    properties (SetAccess = {?aod.core.Epoch, ?aod.core.Experiment})
        % Time the Epoch (i.e. data acquisition) began
        startTime           datetime        {mustBeScalarOrEmpty} = datetime.empty()                          
        % The timing of samples during Epoch                             
        Timing (:,1)        duration = seconds([])
    end


    % Entity link properties
    properties (SetAccess = protected)
        % The Source of data acquired during the Epoch
        Source              {mustBeScalarOrEmpty, aod.util.mustBeEntityType(Source, 'Source')} = aod.core.Source.empty()
        % The System used for data acquisition during the Epoch
        System              {mustBeScalarOrEmpty, aod.util.mustBeEntityType(System, 'System')} = aod.core.System.empty()
    end
    
    % Containers for child entities
    properties (SetAccess = private)
        % Container for Epoch's Registrations
        Registrations       aod.core.Registration
        % Container for Epoch's Responses
        Responses           aod.core.Response 
        % Container for Epoch's Stimuli
        Stimuli             aod.core.Stimulus
        % Container for Epoch's Datasets
        EpochDatasets       aod.core.EpochDataset
    end

    methods 
        function obj = Epoch(ID, varargin)
            obj = obj@aod.core.Entity([], varargin{:});
            obj.ID = ID;
            
            ip = aod.util.InputParser();
            addParameter(ip, 'Source', [], @(x) isSubclass(x, 'aod.core.Source'));
            addParameter(ip, 'System', [], @(x) isSubclass(x, 'aod.core.System'));
            parse(ip, varargin{:});

            obj.setSource(ip.Results.Source);
            obj.setSystem(ip.Results.System);
        end
    end 

    methods (Sealed)
        function add(obj, entity)
            % Add an entity to the Epoch 
            %
            % Description:
            %   Add a new entity to the epoch
            %
            % Syntax:
            %   add(obj, entity)
            %
            % Notes: Only entities contained by Epoch can be added:
            %   EpochDataset, Response, Registration, Stimulus
            % ------------------------------------------------------------- 
            import aod.common.EntityTypes

            entityType = EntityTypes.get(entity);
            if ~ismember(entityType, obj.entityType.validChildTypes())
                error('add:InvalidEntityType',...
                    'Entity must be EpochDataset, Registration, Response and Stimulus');
            end

            entity.setParent(obj);

            switch entityType
                case EntityTypes.EPOCHDATASET
                    obj.EpochDatasets = cat(1, obj.EpochDatasets, entity);
                case EntityTypes.REGISTRATION 
                    obj.Registrations = cat(1, obj.Registrations, entity);
                case EntityTypes.RESPONSE 
                    obj.Responses = cat(1, obj.Responses, entity);
                case EntityTypes.STIMULUS
                    obj.Stimuli = cat(1, obj.Stimuli, entity);
            end
        end

        function remove(obj, entityType, varargin)
            % Remove an entity from the Epoch
            %
            % Syntax:
            %   remove(obj, entityType, ID)
            %
            % Inputs:
            %   ID          integer(s), "all" or query cell
            %       Which entities to remove
            %
            % Notes: Only entities contained by Epoch can be added:
            %   Dataset, Response, Registration, Stimulus
            % ------------------------------------------------------------- 

            if ~isscalar(obj)
                arrayfun(@(x) remove(x, entityType, varargin{:}), obj);
                return 
            end

            import aod.common.EntityTypes

            entityType = aod.common.EntityTypes.get(entityType);
            if ~ismember(entityType, obj.entityType.validChildTypes())
                error('remove:InvalidEntityType',...
                    'Entity must be EpochDataset, Registration, Response and Stimulus');
            end

            % Remove all entities?
            if istext(varargin{1}) && strcmpi(varargin{1}, 'all')
                obj.(entityType.parentContainer()) = entityType.empty();
                return
            end  

            % Remove specific entities, by ID or by query
            if isnumeric(varargin{1})
                mustBeInteger(varargin{1});
                mustBeInRange(varargin{1}, 0, numel(obj.(entityType.parentContainer())));
                idx = varargin{1};
            elseif iscell(varargin{1})
                % Get the indices of entities matching query
                [~, idx] = aod.common.EntitySearch.go(obj.get(entityType), varargin{:});
                if isempty(idx)
                    warning('remove:NoQueryMatches',...
                        'The query returned no matches, no entities removed.');
                    return
                end
            else
                error('remove:InvalidID',...
                    'ID must be "all", query or integer index of entities to remove');
            end
    
            switch entityType 
                case EntityTypes.EPOCHDATASET
                    removeParent(obj.EpochDatasets(idx));
                    obj.EpochDatasets(idx) = []; 
                case EntityTypes.REGISTRATION
                    removeParent(obj.Registrations(idx));
                    obj.Registrations(idx) = [];
                case EntityTypes.RESPONSE
                    removeParent(obj.Responses(idx));
                    obj.Responses(idx) = [];
                case EntityTypes.STIMULUS 
                    removeParent(obj.Stimuli(idx));
                    obj.Stimuli(idx) = [];
            end
        end

        function out = get(obj, entityType, varargin)
            % Search Epoch's child entities and return matches
            %
            % Description:
            %   Search all entities of a specific type that match the given
            %   criteria (described below in examples)
            %
            % Inputs:
            %   entityType          char or aod.common.EntityTypes
            % Optional inputs:
            %   One or more cells containing queries (TODO: doc)
            % -------------------------------------------------------------
            
            import aod.common.EntityTypes

            entityType = EntityTypes.get(entityType);
            if ~ismember(entityType, obj.entityType.validChildTypes())
                error('get:InvalidEntityType',...
                    'Entity must be EpochDataset, Registration, Response and Stimulus');
            end

            group = obj.(entityType.parentContainer());

            if nargin > 2 && ~isempty(group)
                out = aod.common.EntitySearch.go(group, varargin{:});
            else
                out = group;
            end
        end

        function tf = has(obj, entityType, varargin)
            % Search Epoch's child entities and return if matches exist
            %
            % Description:
            %   Search all entities of a specific type that match the given
            %   criteria (see Epoch.get) and return whether matches exist
            %
            % Syntax:
            %   tf = has(obj, entityType, varargin)
            %
            % Inputs:
            %   entityType          char or aod.common.EntityTypes
            % Optional inputs:
            %   One or more cells containing queries (TODO: doc)
            % -------------------------------------------------------------
            out = obj.get(entityType, varargin{:});
            tf = ~isempty(out);
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
            if ~isscalar(obj)
                arrayfun(@(x) x.setSource(source), obj);
                return
            end

            if isempty(source)
                obj.Source = aod.core.Source.empty();
                return
            end

            if ~aod.util.isEntitySubclass(source, 'Source')
                error('setSource:InvalidEntityType',...
                    'Must be a core or persistent Source');
            end
            
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

            if ~isscalar(obj)
                arrayfun(@(x) x.setSystem(system), obj);
                return
            end

            if isempty(system)
                obj.System = aod.core.System.empty();
                return
            end

            if ~aod.util.isEntitySubclass(system, 'System')
                error('setSystem:InvalidEntityType',...
                    'Must be a core or persistent System');
            end

            obj.System = system;
        end
    end

    % Timing methods
    methods (Sealed)
        function setStartTime(obj, startTime)
            % SETSTARTTIME
            %
            % Description:
            %   Set the time the epoch began. If input is empty, existing 
            %   startTime will be erased
            %
            % Syntax:
            %   setStartTime(obj, startTime)
            %
            % Inputs:
            %   startTime           datetime
            % -------------------------------------------------------------
            if ~isscalar(obj)
                arrayfun(@(x) setStartTime(x, startTime), obj);
                return
            end

            if isempty(startTime)
                obj.startTime = datetime.empty();
            end

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
            if ~isscalar(obj)
                tf = arrayfun(@(x) x.hasTiming(), obj);
                return
            end

            tf = ~isempty(obj.Timing);
        end

        function setTiming(obj, timing)
            % Set Epoch "Timing", the time each sample was acquired 
            %
            % Syntax:
            %   addTiming(obj, timing)
            %
            % Inputs:
            %   timing      vector, numeric or duration
            %       The timing for each sample in Response. If empty, the 
            %       contents of Timing will be cleared.
            %
            % Examples:
            %   % Set numeric timing
            %   obj.setTiming(1:4)
            %
            %   % Set duration timing
            %   obj.setTiming(seconds(1:4))
            %   
            %   % Clear timing
            %   obj.setTiming([])
            % -------------------------------------------------------------

            if ~isscalar(obj)
                arrayfun(@(x) setTiming(x, timing), obj);
                return 
            end

            if ~isempty(timing)
                assert(isvector(timing), 'Timing must be a vector');
                timing = timing(:);  % Columnate
            else
                timing = seconds([]);
            end

            obj.Timing = timing;
        end
    end

    methods (Access = protected)
        function value = getLabel(obj) 
            % Set the label to the epochID (with up to 3 leading zeros to
            % ensure alphabetical sorting doesn't get it out of order)
            value = int2fixedwidthstr(obj.ID, 4);
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Entity();

            value.add('SampleRate', [], @isnumeric,...
                'Rate of data acquisition (Hz)');
        end

        function mngr = specifyDatasets(mngr)
            mngr.set('ID',... 
                'Description', 'Epoch ID in the Experiment');
        end
    end
end 