classdef Epoch < aod.core.Epoch
% EPOCH
%
% Protected methods:
%   imStack = applyTransform(obj, imStack)    
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        epochType       patterson.EpochTypes
    end

    properties (Dependent)
        transform
    end

    methods
        function obj = Epoch(ID, parent, epochType)
            obj@aod.core.Epoch(ID, parent);
            if nargin > 2
                obj.epochType = epochType;
            else
                obj.epochType = patterson.EpochTypes.Unknown;
            end
        end

        function value = get.transform(obj)
            value = [];
            if isempty(obj.Registration)
               return  
            end
            idx = find(isa(obj.Registration, 'aod.builtin.registrations.SiftRegistration'));
            if ~isempty(idx)
                value = obj.Registration(idx).Data;
            end
        end
    end

    methods 
        function clearTransform(obj)
            idx = cellfun(@(x) isa(x, 'aod.builtin.registrations.SiftRegistration'),... 
                obj.Registrations);
            obj.Registrations = obj.Registrations{~idx};
        end

        function makeStackSnapshots(obj, IDs, fPath)
            % MAKESTACKSNAPSHOTS
            %
            % Description:
            %   Mimics the Z-projections created by ImageJ and saves an
            %   AVG, MAX, SUM and STD projection to 'Analysis/Snapshots/'
            %
            % Syntax:
            %   obj.makeStackSnapshots(fPath);
            %
            % Optional Inputs:
            %   IDs         array
            %       Epoch IDs to create snapshots (default = obj.epochIDs)
            % -------------------------------------------------------------
            if nargin < 3
                fPath = [obj.homeDirectory, 'Analysis', filesep, 'Snapshots', filesep];
            end
            
            if nargin < 2 || isempty(obj.IDs)
                IDs = 1:numel(obj.Epochs);
            end

            baseName = ['_', obj.getShortName(), '.png'];
            imStack = obj.Epochs(IDs).getStack();
            
            % TODO: Omit dropped frames
            imSum = sum(im2double(imStack), 3);
            imwrite(uint8(255 * imSum/max(imSum(:))),...
                [fPath, 'SUM', baseName], 'png');
            imwrite(uint8(mean(imStack, 3)),...
                [fPath, 'AVG', baseName], 'png');
            imwrite(uint8(max(imStack, [], 3)),... 
                [fPath, 'MAX', baseName], 'png');
            imwrite(im2uint8(imadjust(std(im2double(imStack), [], 3))),... 
                [fPath, 'STD', baseName], 'png');
        end
    end

    methods (Access = protected)
        function videoName = getCoreVideoName(obj)
            videoName = obj.getFilePath('AnalysisVideo');
        end

        function imStack = applyTransform(obj, imStack)
            if isempty(obj.transform)
                return
            end

            disp('Applying transform...');
            try
                tform = affine2d_to_3d(obj.transform);
                viewObj = affineOutputView(size(imStack), tform,... 
                    'BoundsStyle','SameAsInput');
                imStack = imwarp(imStack, tform, 'OutputView', viewObj);
            catch
                [x, y, t] = size(imStack);
                refObj = imref2d([x y]);
                for i = 1:t
                    imStack(:,:,i) = imwarp(imStack(:,:,i), refObj,...
                        obj.transform, 'OutputView', refObj);
                end
            end
        end
    end


    % Overwritten methods
    methods 
        function imStack = getStack(obj)
            % GETSTACK
            if ~isempty(obj.cachedVideo)
                imStack = obj.cachedVideo;
                return;
            end

            videoName = obj.getCoreVideoName();
            imStack = obj.readStack(videoName);

            imStack(:,:,1) = [];

            obj.cachedVideo = imStack;
        end
    end

    methods (Access = protected)
        function value = getDisplayName(obj)
            value = [obj.Parent.displayName, '#', int2fixedwidthstr(obj.ID, 4)];
        end
    end
end

