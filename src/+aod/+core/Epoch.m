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
% Public methods:
%   addDataset(obj, dataset)
%   addResponse(obj, response)
%   addRegistration(obj, registration)
%   addStimulus(obj, stim)
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
        Registrations               aod.core.Registration
        Responses                   aod.core.Response  
        Stimuli                     aod.core.Stimulus
        Datasets                    aod.core.Dataset
        Timing                      % aod.core.Timing
    end

    % Entity link properties
    properties (SetAccess = protected)
        Source                      = aod.core.Source.empty()
        System                      = aod.core.System.empty()
    end

    properties (Hidden, Access = protected)
        allowableParentTypes = {'aod.core.Experiment'}
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
    end

    % Timing methods
    methods
        function setTiming(obj, timing)
            % SETTIMING
            %
            % Description:
            %   Set Epoch timing
            %
            % Syntax:
            %   setTiming(obj, timing)
            % -------------------------------------------------------------
            assert(isSubclass(timing, 'aod.core.Timing'),...
                'Input must be subclass of aod.core.Timing');
            
            timing.setParent(obj);
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

            resp.addParent(obj);
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