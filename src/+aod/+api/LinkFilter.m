classdef LinkFilter < aod.api.FilterQuery
% Filter entities by softlink
%
% Description:
%   Filter entities based on the presence of a specific link
%
% Parent:
%   aod.api.FilterQuery
%
% Constructor:
%   obj = aod.api.LinkFilter(parent, name)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Name
    end

    properties (SetAccess = private)
        allLinkNames
        allLinkParents
    end

    methods 
        function obj = LinkFilter(parent, name)
            obj@aod.api.FilterQuery(parent);

            obj.Name = name;
            obj.collectLinks();
        end
    end

    % Instantiation of abstract methods from FilterQuery
    methods
        function out = apply(obj)
            % Update local match indices to match those in Query Manager
            obj.localIdx = obj.Parent.filterIdx;

            for i = 1:numel(obj.Parent.allGroupNames)
                if ~obj.localIdx(i)
                    continue
                end

                groupIdx = find(obj.allLinkParents == obj.Parent.allGroupNames(i));

                if ~isempty(groupIdx)
                    linkIdx = nnz(endsWith(obj.allLinkNames(groupIdx), obj.Name,...
                        "IgnoreCase", true));
                    if linkIdx ~= 0
                        obj.localIdx(i) = true;
                    else
                        obj.localIdx(i) = false;
                    end
                else
                    obj.localIdx(i) = false;
                end
            end
            out = obj.localIdx;
        end
    end

    methods (Access = private)
        function collectLinks(obj)
            % Get a list of all soft links in the HDF5 file
            %
            % Syntax:
            %   collectAllLinks(obj)
            % -------------------------------------------------------------
            obj.allLinkNames = string.empty();
            for i = 1:numel(obj.Parent.hdfName)
                obj.allLinkNames = cat(1, obj.allLinkNames,...
                    h5tools.collectSoftlinks(obj.Parent.hdfName(i)));
            end
            obj.getLinkParentPaths();
        end

        function getLinkParentPaths(obj)
            % Get the parent paths for all links in HDF5 file
            %
            % Syntax:
            %   collectAllLinks(obj)
            % -------------------------------------------------------------
            obj.allLinkParents = string.empty();
            for i = 1:numel(obj.allLinkNames)
                obj.allLinkParents = cat(1, obj.allLinkParents,... 
                    string(h5tools.util.getPathParent(obj.allLinkNames(i))));
            end
        end
    end
end 