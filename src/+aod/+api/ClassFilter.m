classdef ClassFilter < aod.api.FilterQuery 
% CLASSFILTER
%
% Description:
%   Filter entities in an AOData HDF5 file based on MATLAB class name
%
% Parent:
%   aod.api.FilterQuery
%
% Constructor:
%   obj = ClassFilter(hdfName, className)
%
% Methods:
%   applyFilter(obj)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        className
    end
    
    properties (SetAccess = protected)
        allClassNames
    end

    methods
        function obj = ClassFilter(hdfName, className)
            obj = obj@aod.api.FilterQuery(hdfName);

            obj.collectClassNames();

            if nargin > 1 && ~isempty(className)
                obj.className = className;
                obj.applyFilter();
            end
        end

        function applyFilter(obj)
            % APPLYFILTER
            %
            % Description:
            %   Apply the filter to all HDF5 groups representing entities
            %
            % Syntax:
            %   applyFilter(obj)
            % -------------------------------------------------------------
            for i = 1:numel(obj.allClassNames)
                if obj.filterIdx(i)
                    obj.filterIdx(i) = strcmpi(obj.className, obj.allClassNames(i));
                end
            end
        end
    end

    methods (Access = private)
        function collectClassNames(obj)
            classNames = repmat("", [numel(obj.allGroupNames), 1]);
            for i = 1:numel(obj.allGroupNames)
                classNames(i) = h5readatt(obj.hdfName,...
                    obj.allGroupNames(i), 'Class');
            end
            obj.allClassNames = classNames;
        end
    end

    methods (Static)
        function names = summarize(hdfName)
            obj = aod.api.ClassFilter(hdfName);
            names = unique(obj.allClassNames);
        end
    end
end 