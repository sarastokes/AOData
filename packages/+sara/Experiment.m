classdef Experiment < aod.core.Experiment
% EXPERIMENT
%
% Description:
%   Experiment subclass tailored to Primate 1P system experiments
%
% Methods:
%   getFileHeader(obj)
%   loadSiftTransforms(obj, fName)
%   clearSiftTransforms(obj)
% -------------------------------------------------------------------------
    
    properties (Hidden, Transient, Access = protected)
        cachedVideo
    end

    methods
        function obj = Experiment(name, homeDirectory, expDate, varargin)
            obj = obj@aod.core.Experiment(name, homeDirectory, expDate, varargin{:});
        end

        function value = getFileHeader(obj)
            % GETFILEHEADER
            %
            % Description:
            %   All files within our experiments begin with ID_yyyyMMdd
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
            fPath = fullfile(obj.homeDirectory, 'Analysis');
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

        function clearSiftTransforms(obj)
            % CLEARRIGIDTRANSFORMS
            %
            % Syntax:
            %   clearRigidTransforms(obj)
            % -------------------------------------------------------------
            for i = 1:numel(obj.Epochs)
                obj.Epochs(i).clearRigidTransform();
            end
        end

        function addSimilarityTransforms(obj, regDate, fileName)
            % ADDSIMILARITYTRANSFORMS
            %
            % Syntax:
            %   addSimilarityTransforms(obj, regDate, fileName)
            %
            % See also:
            %   sara.readers.SimilarityTransformReader
            %   sara.registrations.SimilarityRegistration
            % -------------------------------------------------------------
            TR = sara.readers.SimilarityTransformReader(fileName);
            for i = 1:numel(TR.epochIDs)
                reg = sara.registrations.SimilarityRegistration(...
                    regDate, TR.transforms(i), TR.references(i), TR.qualities(i));
                reg.setFile('Registration', TR.fullFile);
                obj.Epochs(obj.id2index(TR.epochIDs(i))).add(reg);
            end
        end

        function addSiftTransforms(obj, tforms, epochIDs, regDate, varargin)
            % ADDSIFTTRANSFORMS
            %
            % Syntax:
            %   addSiftTransforms(obj, tforms, epochIDs, varargin)
            % -------------------------------------------------------------
            ip = aod.util.InputParser();
            addParameter(ip, 'WhichTforms', 1:numel(epochIDs), @isnumeric);
            parse(ip, varargin{:});

            whichTforms = ip.Results.WhichTforms;

            if ischar(tforms)
                if ~isfile(tforms)
                    tforms = fullfile(obj.getAnalysisFolder(), tforms);
                end
                TR = sara.readers.RigidTransformReader(tforms);
                tforms = TR.readFile();
                if ~isempty(whichTforms)
                    tforms = tforms(:, :, whichTforms);
                end
                assert(size(tforms,3) == numel(epochIDs), ...
                    'Epoch IDs does not match number of transforms');
            end

            for i = 1:numel(epochIDs)
                reg = sara.registrations.SiftRegistration(...
                    regDate, squeeze(tforms(:,:,i)), varargin{:});
                obj.Epochs(obj.id2index(epochIDs(i))).add(reg);
            end
        end
    end

    methods 
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
