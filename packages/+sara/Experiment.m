classdef Experiment < aod.core.Experiment
% EXPERIMENT
%
% Description:
%   Experiment subclass tailored to Primate 1P system experiments
%
% Methods:
%   getFileHeader(obj)
%   initParameters(obj, varargin)
%   loadTransforms(obj, fName)
%   clearRigidTransforms(obj)
%
% Inherited public methods:
%   setHomeDirectory(obj, filePath)
%   id = id2epoch(obj, epochID)
%   idx = id2idx(obj, epochID)
%   imStack = getStacks(obj, epochIDs)
%   data = getRegionResponses(obj, epochIDs)  
% -------------------------------------------------------------------------
    properties (SetAccess = protected)
        sampleRate = 25  % Hz
    end

    methods
        function obj = Experiment(homeDirectory, expDate, varargin)
            obj = obj@aod.core.Experiment(homeDirectory, expDate, varargin{:});
        end

        function value = getFileHeader(obj)
            % GETFILEHEADER
            %
            % Description:
            %   All files within our experiments begin with ID_YYYYMMDD
            %
            % Syntax:
            %   value = obj.getFileHeader()
            % -------------------------------------------------------------
            value = [num2str(obj.Sources(1).getParentID()), '_', ...
                char(obj.experimentDate)];
        end
        
        function fPath = getAnalysisFolder(obj)
            % GETANALYSISFOLDER
            % 
            % Syntax:
            %   fPath = getAnalysisFolder(obj)
            % -------------------------------------------------------------
            fPath = [obj.homeDirectory, filesep, 'Analysis', filesep];
        end
    end

    methods 
        function clearAllCachedVideos(obj)
            % CLEARALLCACHEDVIDEOS
            %
            % Syntax:
            %   clearAllCachedVideos(obj)
            % -------------------------------------------------------------
            for i = 1:numel(obj.Epochs)
                obj.Epochs(i).clearVideoCache();
            end
        end

        function clearRigidTransforms(obj)
            % CLEARRIGIDTRANSFORMS
            %
            % Syntax:
            %   clearRigidTransforms(obj)
            % -------------------------------------------------------------
            for i = 1:numel(obj.Epochs)
                obj.Epochs(i).clearRigidTransform();
            end
        end

        function loadTransforms(obj, tforms, epochIDs, varargin)
            % LOADTRANSFORMS
            %
            % Syntax:
            %   loadTransforms(obj, tforms, epochIDs, varargin)
            % -------------------------------------------------------------
            ip = inputParser();
            addParameter(ip, 'TransformType', 'rigid', @ischar);
            addParameter(ip, 'ReferenceEpoch', [], @isnumeric);
            addParameter(ip, 'WhichTforms', [], @isnumeric);
            parse(ip, varargin{:});

            whichTforms = ip.Results.whichTforms;

            if ischar(tforms)
                TR = ao.builtin.RigidTransformReader(tforms);
                tforms = tformReader.read();
                if ~isempty(whichTforms)
                    tforms = tforms(:, :, whichTforms);
                end
                assert(TR.Count == numel(epochIDs), ...
                    'Epoch IDs does not match number of transforms');
            end

            for i = 1:numel(epochIDs)
                reg = aod.builtin.registrations.RigidRegistration(...
                    squeeze(tforms(:,:,i)));
                reg.addParameter('TransformType', ip.Results.TransformType);
                reg.addParameter('ReferenceEpoch', ip.Results.ReferenceEpoch);
                if ~isempty(whichTforms)
                    reg.addParameter('WhichTforms', whichTforms);
                else
                    reg.addParameter('WhichTforms', 1:numel(epochIDs));
                end
                obj.Epochs(obj.idx2epoch(epochIDs(i))).addRegistration(reg);
            end
        end

        function makeStackSnapshots(obj, epochIDs)
            % MAKESTACKSNAPSHOTS
            %
            % Syntax:
            %   makeStackSnapshots(obj, epochIDs)
            % -------------------------------------------------------------
            if nargin < 2
                epochIDs = obj.epochIDs;
            end
            for i = 1:numel(epochIDs)
                epoch = obj.id2epoch(epochIDs(i));
                epoch.makeStackSnapshots();
            end
        end
    end
end
