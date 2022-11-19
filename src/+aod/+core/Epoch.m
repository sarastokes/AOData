classdef Epoch < aod.core.Entity & matlab.mixin.Heterogeneous
% EPOCH
%
% Description:
%   A continuous period of data acquisition within an experiment
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = Epoch(ID)
%
% Properties:
%   ID                              Epoch identifier (integer)
%   startTime                       Time when epoch began
%   Registrations                   Container for epoch's registrations
%   Responses                       Container for epoch's responses
%   Stimuli                         Container for epoch's stimuli
%   Datasets                        Container for epoch's datasets
%   Source                          Link to Source used during the epoch
%   System                          Link to System used during the epoch
%
% Public methods:
%   add(obj, entity)
%   clearDatasets(obj)
%   clearRegistrations(obj)
%   clearResponses(obj)
%   clearStimuli(obj)
%
% Notes:
%   Inheritance from matlab.mixin.Heterogeneous allows forming arrays of 
%   multiple Epoch subclasses
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        ID(1,1)                     double
    end

    properties (SetAccess = {?aod.core.Epoch, ?aod.core.Experiment})
        startTime(1,1)              datetime
        Timing                      
        Registrations               aod.core.Registration
        Responses                   aod.core.Response  
        Stimuli                     aod.core.Stimulus
        Datasets                    aod.core.Dataset
    end

    % Entity link properties
    properties (SetAccess = protected)
        Source                      = aod.core.Source.empty()
        System                      = aod.core.System.empty()
        Segmentation                = aod.core.Segmentation.empty()
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
    end

    % Access methods
    methods (Sealed)
        function dset = getDataset(obj, datasetClassName)
            % GETDATASET
            %
            % Syntax:
            %   dset = getDataset(obj, datasetClassName)
            %
            % Inputs:
            %   dsetClassName       char, class of dataset to retrieve
            % Ouputs:
            %   dset                aod.core.Dataset or subclass
            % -------------------------------------------------------------
            if ~isscalar(obj)
                dset = [];
                for i = 1:numel(obj)
                    dset = cat(1, dset, obj(i).getDataset(datasetClassName));
                end
                return
            end
            dset = getByClass(obj.Datasets, char(datasetClassName));
        end

        function reg = getRegistration(obj, regClassName)
            % GETREGISTRATION
            %
            % Syntax:
            %   dset = getRegistration(obj, regClassName)
            %
            % Inputs:
            %   regClassName        char, class of dataset to retrieve
            % Ouputs:
            %   reg                 aod.core.Registration or subclass
            % -------------------------------------------------------------
            if ~isscalar(obj)
                reg = [];
                for i = 1:numel(obj)
                    reg = cat(1, reg, obj(i).getRegistration(regClassName));
                end
                return
            end
            reg = getByClass(obj.Registrations, char(regClassName));
        end

        function stim = getStimulus(obj, stimClassName)
            % GETSTIMULUS
            %
            % Syntax:
            %   stim = obj.getStimulus(stimClassName)
            %
            % Inputs:
            %   stimClassName       char, class of stimulus to retrieve
            % Ouputs:
            %   stim                aod.core.Stimulus or subclass
            % ----------------------------------------------------------
            if ~isscalar(obj)
                stim = [];
                for i = 1:numel(obj)
                    stim = cat(1, stim, obj(i).getStimulus(stimClassName));
                end
                return
            end
            stim = getByClass(obj.Stimuli, char(stimClassName));
        end
      
        function resp = getResponse(obj, responseClassName, varargin)
            % GETRESPONSE
            %
            % Syntax:
            %   resp = getResponse(obj, responseClassName, varargin)
            %   resp = getResponse(obj, responseClassName, Keep, varargin)
            %
            % Inputs:
            %   responseClassName    response name to compute
            % Optional inputs:
            %   keep                 Add to Epoch (default = false)
            % Additional key/value inputs are sent to response constructor
            % -------------------------------------------------------------
            if ~isscalar(obj)
                resp = [];
                for i = 1:numel(obj)
                    resp = cat(1, resp, obj(i).getResponse(stimClassName, varargin{:}));
                end
                return
            end
            % TODO: Update
            if isempty(obj.Parent.Segmentations)
                error('Experiment must contain Segmentations');
            end
            resp = getByClass(obj.Responses, responseClassName);
            if isempty(resp)
                constructor = str2func(responseClassName);
                resp = constructor(obj, varargin{:});
                resp.setParent(obj);
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

    % Dataset methods
    methods
        function addDataset(obj, dataset)
            % ADDDATASET
            %
            % Syntax:
            %   obj.addDataset(dataset)
            % -------------------------------------------------------------
            assert(isSubclass(dataset, 'aod.core.Dataset'),...
                'Must be a subclass of aod.core.Dataset');
                
            warning('addDataset:Deprecated', 'This function will be removed soon');
            dataset.setParent(obj);
            obj.Datasets = cat(1, obj.Datasets, dataset);
        end

        function removeDataset(obj, ID)
            % REMOVEDATASET
            %
            % Syntax:
            %   removeDataset(obj, ID)
            %
            % Inputs:
            %   ID can be index or dataset name
            % -------------------------------------------------------------
            if istext(ID)
                ID = find(vertcat(obj.Datasets.Name) == ID);
                if isempty(ID)
                    error("removeDataset:InvalidName",...
                        "Dataset named %s not found", ID);
                end
            elseif isnumeric(ID)
                assert(ID > 0 & ID <= numel(obj.Datasets),...
                    "Invalid dataset number, only %u are present", ID);                
            end
            obj.Datasets(ID) = [];
        end

        function clearDatasets(obj)
            % CLEARDATASETS
            %
            % Syntax:
            %   clearDatasets(obj)
            % -------------------------------------------------------------
            obj.Datasets = aod.core.Dataset.empty();
        end
    end

    % Registration methods
    methods
        function addRegistration(obj, reg)
            % ADDREGISTRATION
            %
            % Syntax:
            %   obj.addRegistration(reg)
            % -------------------------------------------------------------
            assert(isSubclass(reg, 'aod.core.Registration'),...
                'addRegistration: input was not a subclass of aod.core.Registration');

            warning('addRegistration:Deprecated', 'This function will be removed soon');
            reg.setParent(obj);
            obj.Registrations = cat(1, obj.Registrations, reg);
        end

        function removeRegistration(obj, ID)
            % REMOVEREGISTRATION
            %
            % Description:
            %   Remove a specific registration from the Epoch
            %
            % Syntax:
            %   removeRegistration(obj, ID)
            % -------------------------------------------------------------
            assert(ID > 0 & ID < numel(obj.Registrations),...
                'Invalid ID %u, must be between 1-%u', ID, numel(obj.Registrations));
                
            obj.Registrations(ID) = [];
        end

        function clearRegistrations(obj)
            % CLEARRESPONSES
            %
            % Description:
            %   Clear all registrations associated with the epoch
            %
            % Syntax:
            %   obj.clearRegistrations()
            % -------------------------------------------------------------
            obj.Registrations = aod.core.Registration.empty();
        end
    end

    % Response methods
    methods
        function addResponse(obj, resp)
            % ADDRESPONSE
            %
            % Syntax:
            %   addResponse(obj, response)
            % -------------------------------------------------------------
            arguments 
                obj
                resp(1,1)           {mustBeA(resp, 'aod.core.Response')}
            end
            
            warning('addResponse:Deprecated', 'This function will be removed soon');
            resp.setParent(obj);
            obj.Responses = cat(1, obj.Responses, resp);
        end

        function removeResponse(obj, ID)
            % REMOVERESPONSE
            %
            % Description:
            %   Remove a specific response from the Epoch
            %
            % Syntax:
            %   removeResponse(obj, ID)
            % -------------------------------------------------------------
            assert(ID > 0 & ID < numel(obj.Responses),...
                'Invalid ID %u, must be between 1-%u', ID, numel(obj.Responses));
                
            obj.Responses(ID) = [];
        end

        function clearResponses(obj)
            % CLEARRESPONSES
            %
            % Syntax:
            %   obj.clearResponses()
            % -------------------------------------------------------------
            obj.Responses = aod.core.Response.empty();
        end
    end

    % Stimulus methods
    methods 
        function addStimulus(obj, stim)
            % ADDSTIMULUS
            %
            % Syntax:
            %   obj.addStimulus(stim)
            % -------------------------------------------------------------

            assert(isSubclass(stim, 'aod.core.Stimulus'),... 
                'stim must be subclass of aod.core.Stimulus');

            warning('addStimulus:Deprecated', 'This function will be removed soon');
            stim.setParent(obj);
            obj.Stimuli = cat(1, obj.Stimuli, stim);
        end

        function removeStimulus(obj, ID)
            % REMOVESTIMULUS
            %
            % Description:
            %   Remove a specific stimulus from the Epoch
            %
            % Syntax:
            %   removeStimulus(obj, ID)
            % -------------------------------------------------------------
            assert(ID > 0 & ID < numel(obj.Stimuli),...
                'Invalid ID %u, must be between 1-%u', ID, numel(obj.Stimuli));

            obj.Stimuli(ID) = [];
        end

        function clearStimuli(obj)
            % ADDSTIMULUS
            %
            % Syntax:
            %   obj.addStimulus(stim, overwrite)
            % -------------------------------------------------------------
            obj.Stimuli = aod.core.Stimulus.empty();
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