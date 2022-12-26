classdef RigidTransformReader < aod.util.FileReader
% RIGIDTRANSFORMREADER
%
% Parent:
%   aod.util.FileReader
%
% Constructor:
%   obj = RigidTransformReader(fullFilePath)
%
% See also:
%   READRIGIDTRANSFORM, AO.CORE.FILEREADER
%
% History:
%   19May2022 - SSP
% -------------------------------------------------------------------------
    
    properties
        Count (1,1)     {mustBeInteger}     = 0
    end

    methods
        function obj = RigidTransformReader(varargin)
            obj@aod.util.FileReader(varargin{:});
        end
        
        function tform = getTransform(obj, ID)
            if isempty(obj.Data)
                error('Read file first!');
            end
            tform = affine2d(squeeze(obj.Data(:, :, ID)));
        end

        function out = readFile(obj)
            header = 'Transformation Matrix: AffineTransform[[';
        
            TT = [];
        
            fid = fopen(obj.fullFile, 'r');
            tline = fgetl(fid);
            while ischar(tline)
                if startsWith(tline, header)
                    str = tline(numel(header) + 1 : end);
                    str = erase(str, ']');
                    str = erase(str, '[');
                    str = erase(str, ',');
                    t = strsplit(str, ' ');
        
                    T = cellfun(@str2double, t);
                    T = reshape(T, [3 2]);
                    TT = cat(3, TT, [T, [0 0 1]']);
                end
                tline = fgetl(fid);
            end
            fclose(fid);
        
            % Account for serial transforms
            tforms = TT;
            tforms(1, 2, :) = cumsum(tforms(1, 2, :));
            tforms(2, 1, :) = cumsum(tforms(2, 1, :));
            tforms(3, 1, :) = cumsum(tforms(3, 1, :));
            tforms(3, 2, :) = cumsum(tforms(3, 2, :));

            obj.Data = tforms;
            obj.Count = size(tforms, 3);
            out = obj.Data;
        end
    end
    
end
