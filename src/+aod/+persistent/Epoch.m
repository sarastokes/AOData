classdef Epoch < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% An Epoch within an HDF5 file
%
% Description:
%   Represents a persisted Epoch in an HDF5 file
%
% Parent:
%   aod.persistent.Entity, matlab.mixin.Heterogeneous, dynamicprops
%
% Constructor:
%   obj = aod.persistent.Epoch(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Epoch

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        ID(1,1)
        startTime(1,1)                  datetime 

        Source 
        System 

        DatasetsContainer
        RegistrationsContainer
        ResponsesContainer
        StimuliContainer
        Timing
    end

    methods
        function obj = Epoch(hdfFile, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end

    % Addition methods
    methods (Sealed)
        function addDataset(obj, dataset)
            % ADDDATASET
            %
            % Description:
            %   Add a Dataset to the Epoch and HDF5 file
            %
            % Syntax:
            %   addDataset(obj, dataset)
            % -------------------------------------------------------------
            arguments
                obj
                dataset        {mustBeA(dataset, 'aod.core.Dataset')}
            end
            warning('addDataset:Deprecated', 'This function will be removed soon');

            dataset.addParent(obj);
            obj.addEntity(dataset);
        end

        function addRegistration(obj, registration)
            % ADDREGISTRATION
            %
            % Description:
            %   Add a Registration to the Epoch and HDF5 file
            %
            % Syntax:
            %   addRegistration(obj, registration)
            % -------------------------------------------------------------
            arguments
                obj 
                registration    {mustBeA(registration, 'aod.core.Registration')}
            end
            warning('addRegistration:Deprecated', 'This function will be removed soon');

            registration.addParent(obj);
            obj.addEntity(registration);
        end

        function addResponse(obj, response)
            % ADDRESPONSE
            %
            % Description:
            %   Add a Response to the Epoch and HDF5 file
            %
            % Syntax:
            %   addResponse(obj, response)
            % -------------------------------------------------------------
            arguments
                obj 
                response        {mustBeA(response, 'aod.core.Response')}
            end
            warning('addResponse:Deprecated', 'This function will be removed soon');

            response.addParent(obj);
            obj.addEntity(response);
        end

        function addStimuli(obj, stimulus)
            % ADDSTIMULI
            %
            % Description:
            %   Add a Stimulus to the Epoch and HDF5 file
            %
            % Syntax:
            %   addStimuli(obj, stimulus)
            % -------------------------------------------------------------
            arguments
                obj 
                stimulus        {mustBeA(stimulus, 'aod.core.Stimulus')}
            end
            warning('addStimulus:Deprecated', 'This function will be removed soon');

            stimulus.addParent(obj);
            obj.addEntity(stimulus);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);
            
            % DATASETS
            obj.ID = obj.loadDataset("ID");
            obj.startTime = obj.loadDataset("startTime");
            obj.Timing = obj.loadDataset("Timing");
            obj.setDatasetsToDynProps();

            % LINKS
            obj.Source = obj.loadLink("Source");
            obj.System = obj.loadLink("System");
            obj.setLinksToDynProps();

            % CONTAINERS
            obj.DatasetsContainer = obj.loadContainer('Datasets');
            obj.RegistrationsContainer = obj.loadContainer('Registrations');
            obj.ResponsesContainer = obj.loadContainer('Responses');
            obj.StimuliContainer = obj.loadContainer('Stimuli');
        end
    end
    
    % Container abstraction methods
    methods (Sealed)
        function out = Datasets(obj, idx)
            if nargin < 2 
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).DatasetsContainer(idx));
            end
        end

        function out = Registrations(obj, idx, propName)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).RegistrationsContainer(idx));
            end
            if nargin > 2
                if isscalar(out(1).(propName))
                    out = cat(1, out.(propName));
                end
            end
        end

        function out = Responses(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).ResponsesContainer(idx));
            end
        end

        function out = Stimuli(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).StimuliContainer(idx));
            end
        end
    end

    % Heterogeneous methods
    methods (Sealed, Static)
        function obj = empty()
            obj = aod.persistent.Epoch([], [], []);
        end
    end
end 