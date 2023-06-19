classdef (Abstract) SpecificationManager < handle
% Organizes the dataset specifications for an AOData core class
%
% Constructor:
%   obj = aod.specification.DatasetManager(className)
%
% Static constructor to populate from metaclass information:
%   obj = aod.specification.DatasetManager.populate(className)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        className       (1,1)   string 
        Entries
    end

    properties (Hidden, SetAccess=private) 
        lastModified            datetime = datetime.empty()
        %version                 string  {mustBeScalarOrEmpty} = string.empty()
    end

    % properties (Access = private)
        % logger                  {mustBeScalarOrEmpty}
        % listeners               event.listener
    % end

    properties (Dependent)
        Count     (1,1)   double      {mustBeInteger}
    end

    properties (Abstract, Hidden, SetAccess = protected)
        % The specification type
        specType            string
    end

    methods 
        function obj = SpecificationManager(className)
            if nargin > 0 && ~aod.util.isempty(className)
                obj.className = convertCharsToStrings(className);
            end
            obj.lastModified = datetime('now');
        end
    end

    % Dependent methods
    methods
        function value = get.Count(obj)
            value = numel(obj.Entries);
        end
    end

    methods
        function set(obj, entryName, varargin)
            % Set aspects of an existing specification
            %
            % Syntax:
            %   set(obj, entryName, varargin)
            % -------------------------------------------------------------

            entry = obj.get(entryName);
            if isempty(entry)
                error('set:EntryNotFound',...
                    '%sManager for %s does not have dataset %s', ...
                    obj.specType, obj.className, entryName);
            end
            
            entry.assign(varargin{:});
        end

        function [tf, idx] = has(obj, entryName)
            % Determine whether Manager has a entry
            %
            % Syntax:
            %   [tf, idx] = has(obj, entryName)
            % -------------------------------------------------------------
            arguments
                obj
                entryName        string
            end

            if obj.Count == 0
                tf = false; idx = [];
                return
            end
            allNames = obj.list();
            idx = find(allNames == entryName);
            tf = ~isempty(idx);
        end

        function d = get(obj, entryName)
            % Get a dataset by name
            %
            % Syntax:
            %   d = get(obj, entryName)
            % -------------------------------------------------------------
            [tf, idx] = obj.has(entryName);

            if tf
                d = obj.Entries(idx);
            else
                d = [];
            end
        end

        function add(obj, entry)
            % Add a new dataset/attribute
            %
            % Syntax:
            %   add(obj, entry)
            %
            % Inputs:
            %   entry          aod.specification.Entry
            %
            % See also:
            %   aod.specification.Dataset
            % -------------------------------------------------------------
            arguments 
                obj
                entry         aod.specification.Entry 
            end

            if obj.Count > 0 && ismember(lower(entry.Name), lower(obj.list()))
                error('add:EntryExists',...
                    'A %s named %s is already present',... 
                    obj.specType, entry.Name);
            end
            obj.Entries = cat(1, obj.Entries, entry);
            % obj.listeners = cat(1, obj.listeners,...
            %     "LoggableEvent", @obj.onLoggableEvent);
        end

        function remove(obj, entryName)
            % Remove an entry
            %
            % Syntax:
            %   remove(obj, entryName)
            % -------------------------------------------------------------
            [tf, idx] = obj.has(entryName);
            if ~tf
                return
            end
            obj.Entries(idx) = [];
            % obj.listeners(idx) = [];
        end

        function names = list(obj)
            % List all dataset names
            %
            % Syntax:
            %   names = list(obj)
            % -------------------------------------------------------------
            if obj.Count == 0
                names = [];
                return 
            end
        
            names = arrayfun(@(x) x.Name, obj.Entries);
        end

        function out = text(obj)
            % Convert contents to text for display
            %
            % Syntax:
            %   out = text(obj)
            % -------------------------------------------------------------
            if isempty(obj)
                out = sprintf("Empty %sManager", obj.specType);
                return 
            end

            out = "";
            for i = 1:obj.Count 
                out = out + obj.Entries(i).text();
            end
        end
    end

    % methods (Access = private)
    %     function initializeLogger(obj)    
    %         obj.logger = aod.specification.logger.SpecificationLogger(...
    %             obj.className);
    %         obj.logger.clearLog();
    %     end

    %     function onLoggableEvent(obj, ~, evt)
    %         if isempty(obj.logger)
    %             return
    %         end
    %         obj.logger.write(evt.Name, evt.Type);
    %     end
    % end

    % MATLAB builtin methods
    methods
        function tf = isempty(obj)
            tf = (obj.Count == 0);
        end

        function tf = isequal(obj, other)
            if isa(other, class(obj))
                tf = false;
                return 
            end
            tf = strcmp(obj.text(), other.text());
        end

        function S = struct(obj)
            % Convert specified entries to a structure
            %
            % Syntax:
            %   S = struct(obj)
            % -------------------------------------------------------------
            S = struct();
            if isempty(obj)
                return
            end

            for i = 1:obj.Count
                iStruct = obj.Entries(i).struct();
                % Place into a struct named for the dataset
                S.(obj.Entries(i).Name) = iStruct;
            end
        end

        function T = table(obj)
            % Create a table from dataset specifications
            %
            % Syntax:
            %   T = table(obj)
            %
            % Output:
            %   T           table
            %       Table where each row is a dataset
            % -------------------------------------------------------------
            if isempty(obj)
                T = table.empty();
                return 
            end

            names = arrayfun(@(x) x.Name, obj.Entries);
            descriptions = arrayfun(@(x) x.Description.text(), obj.Entries);
            sizes = arrayfun(@(x) x.Size.text(), obj.Entries);
            classes = arrayfun(@(x) x.Class.text(), obj.Entries);
            defaults = arrayfun(@(x) x.Default.text(), obj.Entries);
            functions = arrayfun(@(x) x.Functions.text(), obj.Entries);

            T = table(names, descriptions, classes, sizes, functions, defaults,...
                'VariableNames', {'Name', 'Description', 'Class', 'Size', 'Functions', 'Default'});
        end
    end
end 