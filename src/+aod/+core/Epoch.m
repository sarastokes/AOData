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
%   fName = getFilePath(obj, whichFile)
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

    properties (SetAccess = protected)
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

    properties (Dependent, Hidden)
        homeDirectory
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
            obj.sampleRate = obj.setParam('SampleRate', sampleRate);
            
            ip = aod.util.InputParser();
            addParameter(ip, 'Source', [], @(x) isSubclass(x, 'aod.core.Source'));
            addParameter(ip, 'System', [], @(x) isSubclass(x, 'aod.core.System'));
            parse(ip, varargin{:});

            obj.setSource(ip.Results.Source);
            obj.setSystem(ip.Results.System);
        end

        function value = get.homeDirectory(obj)
            if ~isempty(obj.Parent)
                value = obj.Parent.homeDirectory;
            else
                value = [];
            end
        end
    end

    methods (Sealed)
        function fName = getFilePath(obj, whichFile)
            % GETFILEPATH
            %
            % Syntax:
            %   fName = obj.getFilePath(whichFile)
            % -------------------------------------------------------------
            if ~isKey(obj.files, whichFile)
                warning('File named %s not found', whichFile);
                fName = [];
                return
            end
            fName = obj.files(whichFile);
            % TODO: This might be an issue for Mac
            if ~contains(fName, ':\')
                fName = obj.Parent.homeDirectory + fName;
            end
        end

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

    methods (Sealed)%(Sealed, Access = {?aod.core.Epoch, ?aod.core.Creator})       
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

        function addDataset(obj, dataset, overwrite)
            % ADDDATASET
            %
            % Syntax:
            %   obj.addDataset(dataset, overwrite)
            % -------------------------------------------------------------
            assert(isSubclass(dataset, 'aod.core.Dataset'),...
                'Must be a subclass of aod.core.Dataset');
            
            if ~isempty(obj.Datasets)
                idx = find(findByClass(obj.Datasets, dataset));
                % TODO check name
                if ~isempty(idx)
                    if ~overwrite
                        warning('Set overwrite=true to replace existing datasets');
                        return
                    end
                else
                    obj.Datasets(idx) = dataset;
                end
            end
            obj.Datasets = cat(1, obj.Datasets, dataset);
        end

        function addStimulus(obj, stim, overwrite)
            % ADDSTIMULUS
            %
            % Syntax:
            %   obj.addStimulus(stim, overwrite)
            % -------------------------------------------------------------
            if nargin < 3
                overwrite = false;
            end

            assert(isSubclass(stim, 'aod.core.Stimulus'),... 
                'stim must be subclass of aod.core.Stimulus');
            stim.setParent(obj);

            if ~isempty(obj.Stimuli)
                idx = find(findByClass(obj.Stimuli, stim));
                if ~isempty(idx) 
                    if ~overwrite
                        warning('Set overwrite=true to replace existing stimuli');
                        return
                    else
                        obj.Stimuli(idx) = stim;
                        return
                    end
                end
            end
            obj.Stimuli = cat(1, obj.Stimuli, stim);
        end

        function addRegistration(obj, reg, overwrite)
            % ADDREGISTRATION
            %
            % Syntax:
            %   obj.addRegistration(reg, overwrite)
            % -------------------------------------------------------------
            if nargin < 3
                overwrite = false;
            end

            assert(isSubclass(reg, 'aod.core.Registration'),...
                'addRegistration: input was not a subclass of aod.core.Registration')
            reg.setParent(obj);

            if ~isempty(obj.Registrations)
                idx = find(findByClass(obj.Registrations, class(reg)));
                if ~isempty(idx) 
                    if ~overwrite
                        warning('Set overwrite=true to replace existing registration');
                        return
                    else % overwrite existing
                        if numel(obj.Registrations) == 1
                            obj.Registrations = reg;
                        else
                            obj.Registrations(idx) = reg;
                        end
                        return
                    end
                end
            end
            obj.Registrations = cat(1, obj.Registrations, reg);
        end

        function addResponse(obj, resp, overwrite)
            % ADDRESPONSE
            %
            % Syntax:
            %   obj.addResponse(reg, overwrite)
            % -------------------------------------------------------------
            arguments 
                obj
                resp(1,1)           {mustBeA(resp, 'aod.core.Response')}
                overwrite(1,1)      logical                             = false 
            end

            resp.addParent(obj);

            if ~isempty(obj.Responses)
                idx = find(findByClass(obj.Responses, class(resp)));
                if ~isempty(idx)
                    if ~overwrite
                        warning('Set overwrite=true to replace existing %s', class(resp));
                        return
                    else  % Overwrite existing
                        if numel(obj.Responses) == 1
                            obj.Responses = resp;
                        else
                            obj.Responses(idx) = resp;
                        end
                        return
                    end
                end
            end
            obj.Responses = cat(1, obj.Responses, resp);
        end
    end

    % Overwritten methods from Entity
    methods
        function setFile(obj, fileName, filePath)
            % ADDFILE
            %
            % Description:
            %   Adds to files prop, stripping out homeDirectory and
            %   trailing/leading whitespace, if needed
            %
            % Syntax:
            %   obj.addFile(fileName, filePath)
            % -------------------------------------------------------------
            filePath = erase(filePath, obj.Parent.homeDirectory);
            filePath = strtrim(filePath);
            obj.files(fileName) = filePath;
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