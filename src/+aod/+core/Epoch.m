classdef Epoch < aod.core.Entity & matlab.mixin.Heterogeneous & aod.common.mixins.ParentEntity
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

    properties (GetAccess = public, SetAccess = private)
        % Epoch ID number in Experiment
        ID (1,1)            double          {mustBeInteger}
        % Time the Epoch (i.e. data acquisition) began
        startTime           datetime        {mustBeScalarOrEmpty} = datetime.empty()   
    end

    properties (GetAccess = public, SetAccess = {?aod.core.Epoch, ?aod.core.Experiment})                       
        % The timing of samples during Epoch                             
        Timing (:,1)        duration = seconds([])
    end


    % Entity link properties
    properties (GetAccess = public, SetAccess = protected)
        % The Source of data acquired during the Epoch
        Source      {mustBeScalarOrEmpty, mustBeEntityType(Source, 'Source')} = aod.core.Source.empty()
        % The System used for data acquisition during the Epoch
        System      {mustBeScalarOrEmpty, mustBeEntityType(System, 'System')} = aod.core.System.empty()
    end
    
    % Containers for child entities
    properties (GetAccess = public, SetAccess = {?aod.common.mixins.ParentEntity, ?aod.core.Entity})
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

            if ~isscalar(entity)
                arrayfun(@(x) add(obj, x), entity);
                return
            end

            add@aod.common.mixins.ParentEntity(obj, entity);
            
            % Register the parent
            entity.setParent(obj);
            % Add to the parent's hierarchy
            parentContainer = entity.entityType.parentContainer;
            obj.(parentContainer) = cat(1, obj.(parentContainer), entity);
        end

        function remove(obj, childType, varargin)
            % Remove an entity from the Epoch
            %
            % Syntax:
            %   remove(obj, childType, ID)
            %
            % Inputs:
            %   ID          integer(s), "all" or query cell
            %       Which entities to remove
            %
            % Notes: Only entities contained by Epoch can be added:
            %   Dataset, Response, Registration, Stimulus
            % ------------------------------------------------------------- 

            childType = obj.validateChildType(childType);

            if ~isscalar(obj)
                arrayfun(@(x) remove(x, childType, varargin{:}), obj);
                return 
            end

            remove@aod.common.mixins.ParentEntity(obj, childType, varargin{:});
        end
    end

    % Linked entity methods
    methods (Sealed)  
        function setSource(obj, source)
            % Set the Source for this epoch
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
            % Set the System used during this epoch
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
            else
                obj.startTime = startTime;
            end
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
        function value = specifyLabel(obj) 
            % Set the label to the epochID (with up to 3 leading zeros to
            % ensure alphabetical sorting doesn't get it out of order)
            value = int2fixedwidthstr(obj.ID, 4);
        end
    end

    methods (Static)
        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Entity(value);

            %d.set('Timing',...
            %    'Class', 'duration',...
            %    'Description', 'The timing of samples acquired during th epoch');
            value.set('ID',... 
                'Size', '(1,1)',...
                'Description', 'Epoch ID in the Experiment');
            value.set('Source',...
                'Size', '(1,1)',...
                'Function', {@(x) aod.util.mustBeEntityType(x, 'Source')},...
                'Description', 'The source of data acquired during the Epoch');
        end
    end
end 