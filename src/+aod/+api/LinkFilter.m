classdef LinkFilter < aod.api.StackedFilterQuery
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
        % Softlinks in the file (excluding "Parent")
        allLinkNames                string
        % Entity paths containing the softlinks
        allLinkParents              string
        % The file names for each link
        linkFileNames               string
    end

    methods 
        function obj = LinkFilter(parent, name, varargin)
            obj@aod.api.StackedFilterQuery(parent, varargin{:});

            name = convertCharsToStrings(name);
            if name == "Parent"
                error('LinkFilter:ParentInvalid',...
                    'Use aod.api.ParentFilter for "Parent" links');
            end

            obj.Name = name;
            obj.collectLinks();
        end
    end

    % Instantiation of abstract methods from FilterQuery
    methods
        function tag = describe(obj)
            childTags = describe@aod.api.StackedFilterQuery(obj);
            tag = sprintf("LinkFilter: Name=%s", value2string(obj.Name));
            tag = tag + newline + childTags;
        end

        function out = apply(obj)
            % Update local match indices to match those in Query Manager
            obj.localIdx = obj.getQueryIdx();
            obj.filterIdx = false(size(obj.localIdx));
            entities = obj.getEntityTable();

            if ~isempty(obj.Filters)
                for i = 1:numel(obj.Filters)
                    out = obj.Filters(i).apply();
                    obj.filterIdx = out;
                end
            end

            for i = 1:height(entities)
                if ~obj.localIdx(i)
                    continue
                end

                % Get all the links within the group
                groupIdx = find(obj.linkFileNames == entities.File(i) & ...
                    obj.allLinkParents == entities.Path(i));

                if ~isempty(groupIdx)
                    % See whether one has the correct name
                    linkIdx = nnz(endsWith(obj.allLinkNames(groupIdx), obj.Name,...
                        "IgnoreCase", true));
                    obj.localIdx(i) = linkIdx > 0;
                else
                    obj.localIdx(i) = false;
                end
            end

            out = obj.localIdx;

            if nnz(obj.localIdx) == 0
                warning('apply:NoMatches',...
                    'No links found with name %s', obj.Name);
                return
            end
            
            if isempty(obj.Filters)
                return
            end

            for i = 1:numel(obj.localIdx)
                if ~obj.localIdx
                    continue
                end

                % Get the linked path
                linkedPath = h5tools.readlink(entities.File(i),...
                    entities.Path(i), obj.Name);
                % Find the linked entity within the same file
                idx = find(entities.File == entities.File(i) & ...
                    entities.Path(i) == linkedPath); 
                obj.localIdx(i) = obj.filterIdx(idx);
            end
        end
    end

    methods (Access = private)
        function collectLinks(obj)
            % Get a list of all soft links in the HDF5 file
            %
            % Syntax:
            %   collectAllLinks(obj)
            % -------------------------------------------------------------
            fileNames = obj.getFileNames();
            obj.allLinkNames = string.empty();
            obj.linkFileNames = string.empty();
            for i = 1:numel(fileNames)
                % Collect all links in file except the "Parent" links
                linkNames = h5tools.collectSoftlinks(fileNames(i));
                linkNames(endsWith(linkNames, "Parent")) = [];
                obj.allLinkNames = cat(1, obj.allLinkNames, linkNames);
                % Track the files links come from
                obj.linkFileNames = cat(1, obj.linkFileNames,...
                    repmat(fileNames(i), [numel(linkNames), 1]));
            end
            % Remove "Parent" links
            obj.allLinkNames(endsWith(obj.allLinkNames, "Parent")) = [];
            obj.getLinkParentPaths();
        end

        function getLinkParentPaths(obj)
            % Get the parent paths for all softlinks in HDF5 file
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