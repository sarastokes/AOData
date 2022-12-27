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
%   obj = aod.api.LinkFilter(hdfName, linkName)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        linkName
    end

    properties (SetAccess = protected)
        allLinkNames
        allLinkParents
    end

    methods 
        function obj = LinkFilter(hdfName, linkName)
            obj = obj@aod.api.FilterQuery(hdfName);

            obj.linkName = linkName;
            obj.collectLinks();
            obj.apply();
        end
    end

    % Instantiation of abstract methods from FilterQuery
    methods
        function apply(obj)
            % APPLY
            %
            % Description:
            %   Apply the filter
            % -------------------------------------------------------------
            obj.resetFilterIdx();

            for i = 1:numel(obj.allGroupNames)
                if ~obj.filterIdx(i)
                    continue
                end
                groupIdx = find(obj.allLinkParents == obj.allGroupNames(i));
                if ~isempty(groupIdx)
                    linkIdx = nnz(endsWith(obj.allLinkNames(groupIdx), obj.linkName,...
                        "IgnoreCase", true));
                    if linkIdx ~= 0
                        obj.filterIdx(i) = true;
                    else
                        obj.filterIdx(i) = false;
                    end
                else
                    obj.filterIdx(i) = false;
                end
            end
        end
    end

    methods (Access = private)
        function collectLinks(obj)
            % COLLECTALLLINKS
            %
            % Description:
            %   Get a list of all soft links in the HDF5 file
            %
            % Syntax:
            %   collectAllLinks(obj)
            % -------------------------------------------------------------
            obj.allLinkNames = h5tools.collectSoftlinks(obj.hdfName);
            obj.getLinkParentPaths();
        end

        function getLinkParentPaths(obj)
            % GETLINKPARENTPATHS
            %
            % Description:
            %   Get the parent paths for all links in HDF5 file
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