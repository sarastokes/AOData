classdef SimilarityTransformReader < aod.util.FileReader 
% SIMILARITYTRANSFORMREADER
%
% Description:
%   Reads in a structure of similarity transforms (simtform2d)
%
% Parent:
%   aod.util.FileReader
%
% Constructor:
%   obj = SimilarityTransformReader(fileName)
%
% Properties
%   transforms      simtform2d
%   qualities       struct
%   references      imref2d
%   epochIDs        double
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        transforms          simtform2d
        qualities           struct 
        references          imref2d 
        epochIDs(1,:)       double
    end

    methods
        function obj = SimilarityTransformReader(fName)
            obj = obj@aod.util.FileReader(fName);

            obj.readFile()
        end
    end

    % Overloaded methods from aod.util.FileReader
    methods 
        function out = readFile(obj)
            % READ
            %
            % Syntax:
            %   out = read(obj)
            % -------------------------------------------------------------
            S = load(obj.fullFile);
            f = fieldnames(S);
            if numel(f) == 1
                S = S.(f{1});
            end
            
            for i = 1:numel(S.Registration)
                obj.transforms = cat(1, obj.transforms, S.Registration(i).Transformation);
                obj.references = cat(1, obj.references, S.Registration(i).SpatialRefObj);
                obj.qualities = cat(1, obj.qualities, S.Quality(i));
                obj.epochIDs = cat(2, obj.epochIDs, S.IDs(i));
            end
            out = S;
        end
    end

    methods (Static)
        function out = read(fName)
            obj = sara.readers.SimilarityTransformReader(fName);
            out = obj.Data;
        end
    end

end 