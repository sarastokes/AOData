classdef RegionsOfInterest < aod.core.Annotation

    properties (SetAccess = protected)
        % The image used for annotation
        Image 
        % Size of the image used for annotation
        Size(1,2)       {mustBeInteger}         = [0, 0]
        % FileReader used to load data
        Reader 
    end

    properties (Dependent)
        Count (1,1)     {mustBeInteger}
        RoiIDs 
    end

    methods
        function obj = RegionsOfInterest(name, varargin)
            obj = obj@aod.core.Annotation(name, varargin{:});
        end
    end

end