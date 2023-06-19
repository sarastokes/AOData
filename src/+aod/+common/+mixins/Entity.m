classdef Entity < handle
% Shared implementation between the core and persistent interface
%
% Description:
%   The core and persistent entities have several methods with identical
%   implementation. To reduce code duplication, they are provided as a
%   separate mixin class
%
% Superclasses:
%   handle
%
% Constructor:
%   N/A
%
% See also:
%   aod.core.Entity, aod.persistent.Entity

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods (Sealed)
        function out = getGroupName(obj)
            % Get the entity's HDF5 group name
            %
            % Description:
            %   Can be accessed through the groupName property; however, 
            %   this function supports groupName access for multiple 
            %   entities at once. 
            %
            % Syntax:
            %   out = getGroupName(obj)
            % -------------------------------------------------------------
            if ~isscalar(obj)
                out = arrayfun(@(x) string(x.groupName), obj);
                return
            end

            out = string(obj.groupName); %#ok<MCNPN>
        end

        function parent = getParent(entity, entityType)
            % Get the parent of an entity or ancestor of a specific type
            %
            % Description:
            %   Can be accessed through the Parent property, but this 
            %   method will concatenate parents if more than one entity 
            %   is provided
            %
            % Syntax:
            %   parent = getParent(obj, entityType)
            %
            % Examples:
            %   % Get the parent of an entity (equivalent to obj.Parent)
            %   parent = obj.getParent()
            %   % Get the parent experiment of a device
            %   parent = obj.getParent('Experiment');
            % -------------------------------------------------------------
            if nargin < 2
                entityType = [];
            elseif ~isempty(entityType)
                entityType = aod.common.EntityTypes.get(entityType);
            end

            if ~isscalar(entity)
                parent = aod.util.arrayfun(@(x) getParent(x, entityType), entity);
                return
            end

            % This will catch "Experiment" with no parent
            if entityType == entity.entityType %#ok<MCNPN>
                parent = entity;
                return
            end

            if isempty(entity.Parent) %#ok<MCNPN>
                parent = [];
                return
            end
            
            if isempty(entityType)
                parent = entity.Parent; %#ok<MCNPN>
                return 
            end

            out = entity;
            while out.entityType ~= entityType
                out = out.Parent;
                if isempty(out)
                    break
                end
            end
            if isequal(out, entity)
                error("getParent:NotFound",...
                    "A parent of type %s was not found", entityType);
            else
                parent = out;
            end
        end
    end

    methods (Sealed)
        function tf = hasProp(obj, propName)
            % Determine whether an entity has a specific property.
            %
            % Description:
            %   The advantage of having this as a method is that it
            %   supports both scalar and nonscalar arrays of objects
            %
            % Syntax:
            %   tf = hasProp(obj, propName)
            %
            % See also:
            %   findprop, aod.common.mixins.Entity.getProp
            % -------------------------------------------------------------
            arguments 
                obj 
                propName        char 
            end

            if ~isscalar(obj)
                tf = aod.util.arrayfun(@(x) hasProp(x, propName), obj);
                return 
            end

            p = findprop(obj, propName);
            tf = ~isempty(p);
        end
        
        function propValue = getProp(obj, propName, errorType)
            % Return an entity property (works with arrays of entities)
            %
            % Syntax:
            %   propValue = getProp(obj, propName)
            %   propValue = getProp(obj, propName, errorType)
            % -----------------------------------------------------------
            arguments 
                obj     
                propName        char 
                errorType               = aod.infra.ErrorTypes.NONE
            end

            import aod.infra.ErrorTypes
            errorType = ErrorTypes.init(errorType);

            if ~isscalar(obj)
                propValue = aod.util.arrayfun(...
                    @(x) x.getProp(propName, ErrorTypes.MISSING), obj);
                
                % Parse missing values
                isMissing = getMissing(propValue);
                if any(isMissing)
                    if errorType == ErrorTypes.ERROR 
                        error("getProp:PropertyNotFound",... 
                            "%u of %u entities did not have property ""%s""",... 
                            nnz(isMissing), numel(obj), propName);
                    elseif errorType == ErrorTypes.WARNING 
                        warning("getProp:PropertyNotFound",... 
                            "%u of %u entities did not have property ""%s""",... 
                            nnz(isMissing), numel(obj), propName);
                    end
                end
                
                % Attempt to return a matrix rather than a cell
                if iscell(propValue) && any(isMissing)
                    propValue = extractCellData(propValue);
                end
                return
            end

            if obj.hasProp(propName)
                propValue = obj.(propName);
            else
                switch errorType 
                    case ErrorTypes.ERROR 
                        error('getProp:PropertyNotFound',... 
                            'Entity did not have property named "%s"', propName);
                    case ErrorTypes.WARNING 
                        warning('getProp:PropertyNotFound',... 
                            'Entity did not have property named "%s"', propName);
                        propValue = [];
                    case ErrorTypes.MISSING
                        propValue = missing;
                    case ErrorTypes.NONE
                        propValue = [];
                end
            end
        end
    end

    methods (Sealed)
        function tf = hasAttr(obj, attrName)
            % Check whether entity has a attribute
            %
            % Description:
            %   Check whether entity attributes has a specific attribute
            %
            % Syntax:
            %   tf = hasAttr(obj, attrName)
            %
            % Examples:
            %   % See whether entity has attribute 'MyAttr'
            %   tf = obj.hasAttr('MyAttr')
            %
            % See also:
            %   isKey
            % -------------------------------------------------------------
            arguments
                obj
                attrName       char
            end

            if ~isscalar(obj)
                tf = arrayfun(@(x) x.hasAttr(attrName), obj);
                return
            end
            
            tf = obj.attributes.isKey(attrName); %#ok<MCNPN>
        end


        function attrValue = getAttr(obj, attrName, errorType)
            % Get the value of a attribute
            %
            % Description:
            %   Return the value of a specific attribute. 
            %
            % Syntax:
            %   attrValue = getAttr(obj, attrName, errorType)
            %
            % Inputs:
            %   attrName       char
            % Optional inputs:
            %   errorType       aod.infra.ErrorTypes (default = NONE) 
            %
            % Examples:
            %   % Get the value of 'MyAttr'
            %   attrValue = obj.getAttr('MyAttr')           
            % -------------------------------------------------------------

            arguments
                obj
                attrName           char 
                errorType           = aod.infra.ErrorTypes.NONE
            end
            
            import aod.infra.ErrorTypes
            errorType = ErrorTypes.init(errorType);
            
            if ~isscalar(obj)
                attrValue = aod.util.arrayfun(...
                    @(x) x.getAttr(attrName, ErrorTypes.MISSING), obj);

                % Parse missing values
                isMissing = getMissing(attrValue);
                if all(isMissing)
                    if ErrorTypes.ERROR
                        error('getAttr:NotFound',... 
                            'Did not find attribute %s', attrName);
                    elseif errorType == ErrorTypes.WARNING
                        warning('getAttr:NotFound',...
                            'Did not find attribute %s', attrName);
                    end
                end

                % Attempt to return a matrix rather than a cell
                if iscell(attrValue) && any(isMissing)
                    attrValue = extractCellData(attrValue);
                end
                return
            end

            if obj.hasAttr(attrName)
                attrValue = obj.attributes(attrName); %#ok<MCNPN>
            else
                switch errorType 
                    case ErrorTypes.ERROR 
                        error('getAttr:NotFound',... 
                            'Did not find %s in attributes', attrName);
                    case ErrorTypes.WARNING 
                        warning('getAttr:NotFound',... 
                            'Did not find %s in attributes', attrName);
                        attrValue = [];
                    case ErrorTypes.MISSING
                        attrValue = missing;
                    case ErrorTypes.NONE
                        attrValue = [];
                end
            end
        end
    end

    methods (Sealed)
        function tf = hasFile(obj, fileName)
            % Check whether entity has a file
            %
            % Description:
            %   Check whether entity files has a specific file name
            %
            % Syntax:
            %   tf = hasFile(obj, fileName)
            %
            % Examples:
            %   % Check for the file named 'MyFile'
            %   tf = obj.hasFile('MyFile')
            % -------------------------------------------------------------
            arguments
                obj 
                fileName                char
            end

            if ~isscalar(obj)
                tf = arrayfun(@(x) hasFile(x, fileName), obj);
                return
            end

            if isempty(obj.files) %#ok<MCNPN>
                tf = false;
            else
                tf = obj.files.isKey(fileName); %#ok<MCNPN>
            end
        end
    end

    methods (Sealed, Access = protected)
        function parseAttributes(obj, varargin)
            % Parses varargin input to constructor with expectedAttributes
            % 
            % Syntax:
            %   parseAttributes(obj, varargin)
            %
            % See also:
            %   aod.core.Entity.specifyAttributes,
            %   aod.util.AttributeManager
            % -------------------------------------------------------------
            ip = obj.expectedAttributes.parse(varargin{:}); %#ok<MCNPN>
            f = fieldnames(ip.Results);
            for i = 1:numel(f)
                if ~isempty(ip.Results.(f{i}))
                    obj.setAttr(f{i}, ip.Results.(f{i})); %#ok<MCNPN>
                end
            end
        end
    end

    % Overloaded MATLAB functions
    methods
        function tf = isequal(obj, other)
            % Test whether two entities have the same UUID. If 2nd input 
            % is not an entity, returns false
            %
            % Syntax:
            %   tf = isequal(obj, entity)
            % -------------------------------------------------------------
            arguments
                obj
                other
            end

            if aod.util.isEntitySubclass(other)
                if ~isequal(isprop(other, 'hdfName'), isprop(obj, 'hdfName'))
                    % Interfaces are different
                    tf = false;
                elseif isempty(other) && isempty(obj)
                    % Both are empty
                    tf = true;
                elseif isempty(other) ~= isempty(obj)
                    % One is empty and the other is not
                    tf = false;
                else
                    % UUIDs must be equal
                    tf = isequal(obj.UUID, other.UUID); %#ok<MCNPN>
                end
            else
                tf = false;
            end
        end
    end
end