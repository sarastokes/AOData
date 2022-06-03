classdef Dataset < aod.core.Dataset
% DATASET
%
% Description:
%   Dataset subclass tailored to Primate 1P system experiments
%
% Methods:
%   getFileHeader(obj)
%   initParameters(obj, varargin)
%   loadTransforms(obj, fName)
%
% Inherited public methods:
%   setHomeDirectory(obj, filePath)
%   id = id2epoch(obj, epochID)
%   idx = id2idx(obj, epochID)
%   imStack = getStacks(obj, epochIDs)
%   data = getRegionResponses(obj, epochIDs)  
% -------------------------------------------------------------------------
    properties (SetAccess = private)
        sampleRate = 25  % Hz
    end

    methods
        function obj = Dataset(homeDirectory, expDate)
            obj = obj@aod.core.Dataset(homeDirectory, expDate);
        end

        function initParameters(obj, varargin)
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'Administrator', '', @ischar);
            addParameter(ip, 'System', '1P Primate', @ischar);
            addParameter(ip, 'Purpose', '', @ischar);
            parse(ip, varargin{:});

            obj.addParameter('Administrator', ip.Results.Administrator);
            obj.addParameter('System', ip.Results.System);
            obj.addParameter('Purpose', ip.Results.Purpose);
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
            value = [num2str(obj.Source.Parent.ID), '_', char(obj.experimentDate)];
        end
        
        function fPath = getAnalysisFolder(obj)
            fPath = [obj.homeDirectory, filesep, 'Analysis', filesep];
        end
    end

    methods 
        function clearAllCachedVideos(obj)
            for i = 1:numel(obj.Epochs)
                obj.Epochs(i).clearVideoCache();
            end
        end

        function clearAllTransforms(obj)
            % CLEARALLTRANSFORMS
            for i = 1:numel(obj.Epochs)
                obj.Epochs(i).clearTransform();
            end
        end

        function loadTransforms(obj, tforms, epochIDs, varargin)
            ip = inputParser();
            addParameter(ip, 'TransformType', 'rigid', @ischar);
            addParameter(ip, 'ReferenceEpoch', [], @isnumeric);
            parse(ip, varargin{:});

            if ischar(tforms)
                TR = ao.builtin.RigidTransformReader(tforms);
                tforms = tformReader.read();
                assert(TR.Count == numel(epochIDs), ...
                    'Epoch IDs does not match number of transforms');
            end

            for i = 1:numel(epochIDs)
                reg = aod.builtin.registrations.SiftRegistration(...
                    squeeze(tforms(:,:,i)));
                reg.addParameter('TransformType', ip.Results.TransformType);
                reg.addParameter('ReferenceEpoch', ip.Results.ReferenceEpoch);
                obj.Epochs(obj.idx2epoch(epochIDs(i))).addRegistration(reg);
            end
        end
    end
end
