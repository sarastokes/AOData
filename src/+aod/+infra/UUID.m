classdef UUID
% UUID
%
% Description:
%   Collection of methods for working with UUIDs in AOData
%
% Methods:
%   UUID = aod.infra.UUID.generate()
%   UUID = aod.infra.UUID.validate(uuid)
%   UUID = aod.infra.UUID.dehyphenate(uuid)
%   UUID = aod.infra.UUID.rehyphenate(uuid)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods (Static)
        function UUID = generate()
            % GENERATE
            %
            % Description:
            %   Returns a UUID string using Java's UUID function
            %
            % Syntax:
            %   UUID = aod.infra.UUID.generate()
            % --------------------------------------------------------------

            jUUID = java.util.UUID.randomUUID;
            jUUID = jUUID.toString;
            UUID = string(jUUID.toCharArray');
        end

        function UUID = validate(input)
            % Ensure UUID is valid
            %
            % Description:
            %   Validates the composition of a UUID
            %
            % Syntax:
            %   uuid = aod.infra.UUID.validate(uuid)
            % -------------------------------------------------------------
            arguments
                input        string
            end

            if strlength(input) ~= 36 || numel(strfind(input, '-')) ~= 4
                error('validate:InvalidUUID',...
                    'UUID is not properly formatted, use aod.infra.UUID.generate()');
            end
            UUID = input;
        end

        function UUID = dehyphenate(input)
            arguments
                input           string
            end

            if ~isscalar(input)
                UUID = arrayfun(@(x) aod.util.dehyphenateUID(x), input);
                return
            end

            if strlength(input) ~= 36
                error('dehyphenateUID:InvalidUUID',...
                    'UIDs with hyphens contain 36 characters, not %u', strlength(input));
            end
            UUID = erase(input, "-");
        end

        function UUID = rehyphenate(input)
            arguments
                input           string
            end

            if ~isscalar(input)
                UUID = arrayfun(@(x) aod.util.rehyphenateUID(x), input);
                return
            end

            input = convertStringsToChars(input);
            UUID = [input(1:8) '-' input(9:12) '-' input(13:16) '-' input(17:20) '-' input(21:32)];
            UUID = string(UUID);
        end
    end

    methods (Static)
        function UUID = getClassUUID(className) %#ok<STOUT>
            % Get the UUID from a class by name
            % -------------------------------------------------------------
            arguments
                className       string
            end

            if ~isSubclass(className, "aod.core.Entity")
                error('getClassUUID:InvalidClass',...
                    'Class %s is not a subclass of aod.core.Entity', className);
            end
            eval(sprintf("UUID = %s.specifyClassUUID();", className));
        end

        function validateClass(obj)
            % Validate class UUID to ensure it's unique
            % -------------------------------------------------------------
            value = obj.classUUID;

            superNames = string(superclasses(obj));
            if value == eval(sprintf("%s.specifyClassUUID()", superNames(1)))
                error('Entity:InvalidClassUUID',...
                    [sprintf('Class %s''s classUUID matches superclass. ', class(obj)),...
                    'Run aod.infra.UUID.generateCodeBlock(), then paste into class.']);
            end
        end

        function out = writeCodeBlock(methodsFlag)
            arguments
                methodsFlag     (1,1)   logical = true
            end

            if methodsFlag
                out = sprintf("\tmethods (Static)\n");
            else
                out = "";
            end
            out = out + sprintf("\t\tfunction UUID = specifyClassUUID()\n");
            out = out + sprintf("\t\t\t UUID = ""%s"";\n", aod.infra.UUID.generate());
            out = out + sprintf("\t\tend\n");
            if methodsFlag
                out = out + sprintf("\tend\n");
            end
        end
    end
end