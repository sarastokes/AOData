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
%   obj = Epoch(ID, sampleRate)
%   obj = Epoch(ID, sampleRate, 'Source', source, 'System', system)
%
% Parameters:
%   sampleRate                      Rate data was acquired (Hz)
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
% Abstract methods:
%   videoName = getCoreVideoName(obj)
% 
% Public methods:
%   imStack = getStack(obj, varargin)
%   clearVideoCache(obj)
%   addRegistration(obj, reg, overwrite)
%   addResponse(obj, resp)
%   clearResponses(obj)
%   addStimulus(obj, stim)
%
% Inherited public methods:
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
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
        Registrations               aod.core.Registration
        Responses                   aod.core.Response  
        Stimuli                     aod.core.Stimulus
        Datasets                    aod.core.Dataset
    end

    % Entity link properties
    properties (SetAccess = protected)
        Source                      = aod.core.Source.empty()
        System                      = aod.core.System.empty()
    end

    properties (Hidden, Transient, Access = protected)
        cachedVideo
    end

    properties (Hidden, Access = protected)
        allowableParentTypes = {'aod.core.Experiment'}
    end

    % Methods for subclasses to overwrite
    methods (Abstract, Access = protected)
        % Main analysis video name
        videoName = getCoreVideoName(obj);
    end

    methods 
        function obj = Epoch(ID, sampleRate, varargin)
            obj = obj@aod.core.Entity();
            obj.ID = ID;
            obj.setParam('SampleRate', sampleRate);
            
            ip = aod.util.InputParser();
            addParameter(ip, 'Source', [], @(x) isSubclass(x, 'aod.core.Source'));
            addParameter(ip, 'System', [], @(x) isSubclass(x, 'aod.core.System'));
            parse(ip, varargin{:});

            obj.setSource(ip.Results.Source);
            obj.setSystem(ip.Results.System);
        end
    end

    methods (Sealed)
        function clearVideoCache(obj)
            % CLEARVIDEOCACHE
            %
            % Syntax:
            %   obj.clearVideoCache()
            % -------------------------------------------------------------
            obj.cachedVideo = [];
        end
    end

    % Access methods
    methods (Sealed)
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
            stim = getByClass(obj.Stimuli, char(stimClassName));
        end
      
        function resp = getResponse(obj, responseClassName, varargin)
            % SETRESPONSE
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

            %ip = inputParser();
            %ip.KeepUnmatched = true;
            %addOptional(ip, 'Keep', false, @islogical);
            %parse(ip, varargin{:});
            %keepResponse = ip.Results.Keep;
            keepResponse = false;

            if isempty(obj.Parent.Region)
                error('Experiment must contain Regions');
            end
            resp = getByClass(obj.Responses, responseClassName);
            if isempty(resp)
                constructor = str2func(responseClassName);
                resp = constructor(obj, varargin{:});
                resp.setParent(obj);
                % if keepResponse
                %     obj.addResponse(resp);
                % end
            end
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
            assert(~isempty(findByUUID(obj.Parent.Sources, source.UUID)),... 
                'Source be part of the same Experiment');
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
            assert(~isempty(findByUUID(obj.Parent.Systems, system.UUID)),... 
                'System be part of the same Experiment');
            obj.System = system;
        end

        function addDataset(obj, dataset)
            % ADDDATASET
            %
            % Syntax:
            %   obj.addDataset(dataset)
            % -------------------------------------------------------------
            assert(isSubclass(dataset, 'aod.core.Dataset'),...
                'Must be a subclass of aod.core.Dataset');
            dataset.addParent(obj);
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

        function addStimulus(obj, stim, overwrite)
            % ADDSTIMULUS
            %
            % Syntax:
            %   obj.addStimulus(stim, overwrite)
            % -------------------------------------------------------------

            assert(isSubclass(stim, 'aod.core.Stimulus'),... 
                'stim must be subclass of aod.core.Stimulus');
            stim.setParent(obj);

            obj.Stimuli = cat(1, obj.Stimuli, stim);
        end

        function addRegistration(obj, reg)
            % ADDREGISTRATION
            %
            % Syntax:
            %   obj.addRegistration(reg)
            % -------------------------------------------------------------
            assert(isSubclass(reg, 'aod.core.Registration'),...
                'addRegistration: input was not a subclass of aod.core.Registration');

            reg.setParent(obj);
            obj.Registrations = cat(1, obj.Registrations, reg);
        end

        function addResponse(obj, resp)
            % ADDRESPONSE
            %
            % Syntax:
            %   obj.addResponse(reg, overwrite)
            % -------------------------------------------------------------
            arguments 
                obj
                resp(1,1)           {mustBeA(resp, 'aod.core.Response')}
            end

            resp.addParent(obj);
            obj.Responses = cat(1, obj.Responses, resp);
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)  
            if isempty(obj.Parent)
                value = obj.shortLabel;
            else
                value = sprintf("Epoch%u_%s", obj.ID, obj.Parent.label);
            end
        end

        function value = getShortLabel(obj)
            value = sprintf('Epoch%u', obj.ID);
        end
    end
end 