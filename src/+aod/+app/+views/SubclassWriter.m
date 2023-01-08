classdef SubclassWriter < handle
% Write an AOData subclass
%
% Constructor:
%   obj = aod.app.views.SubclassWriter(model, isDemo)
%
% See also:
%    SubclassGenerator, SubclassGeneratorController

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

%#ok<*AGROW> 
%#ok<*MANU> 

    properties
        Model
        isDemo          logical = false
        output
        fileID
        fileMode        logical = false;
    end

    methods
        function obj = SubclassWriter(model, isDemo)
            obj.Model = model;
            if nargin > 1
                obj.isDemo = isDemo;
            end
            if ~obj.Model.isViewable
                warning("SubclassWritier:NotViewable",...
                    "Model needs name and SuperClass to be writeable");
            end
        end

        function set.fileMode(obj, flag)
            arguments
                obj 
                flag        logical
            end

            obj.fileMode = flag;
        end
    end

    methods
        function write(obj)

            if exist(obj.Model.classFileName, 'file')
                delete(obj.Model.classFileName);
            end 
            out = obj.getFull();
            out = strsplit(out, '\n');
            for i = 1:numel(out)
                writelines(out{i}, obj.Model.classFileName,...
                    "WriteMode", "append");
            end
            % Open in the editor
            edit(obj.Model.classFileName);
        end

        function out = getFull(obj)
            % Classdef
            out = obj.getHeader() + newline;
            % Comments
            out = out + obj.getCommentBlock();
            % Properties
            out = out + obj.getPropertyBlock();
            % Constructor block
            out = out + obj.getConstructorBlock();
            % Set methods
            out = out + obj.getSetMethods();
            % Dependent property methods
            out = out + obj.getDependentSetMethods();
            % Close classdef
            out = out + "end" + newline;
        end

        function out = getPropertyBlock(obj)
            out = "";
            if isempty(obj.Model.Properties)
                return
            end
            out = obj.indent(1) + "properties (SetAccess = protected)" + newline;
            for i = 1:numel(obj.Model.Properties)
                iProp = obj.Model.Properties(i);
                % Description comment
                if ~isempty(iProp.Description)
                    out = out + obj.indent(2) + "% " + iProp.Description + newline;
                end
                % Name
                out = out + obj.indent(2) + iProp.Name;

                % EntityType-based validation for Links
                if isa(iProp, 'aod.util.templates.LinkSpecification')
                    out = out + obj.indent(2) + string(sprintf('{mustBeEntityType(%s, "%s")}',...
                        iProp.Name,...
                        char(iProp.EntityType)));
                    out = out + sprintf(" = %s.empty()", ...
                        iProp.EntityType.getCoreClassName());
                    out = out + newline;
                    continue
                end

                % Dataset-based processing for Datasets
                if isprop(iProp, 'Validation') && ~isempty(iProp.Validation)
                    out = out + obj.indent(2) + obj.getValidation(iProp.Validation);
                end
                % Default value
                if isprop(iProp, 'Default') && ~isempty(iProp.Default)
                    defaultValue = iProp.Default;
                    out = out + " = ";
                    val = obj.getDefaultValue(defaultValue);
                    out = out + val + newline;
                else
                    out = out + newline;
                end
            end
            out = out + obj.indent(1) + "end" + newline;
            out = out + obj.addLineBreak();
        end

        function out = getConstructorBlock(obj)
            out = obj.indent(1) + "methods" + newline;
            out = out + obj.indent(2) + "function ";
            out = out + obj.getConstructor() + newline;
            if obj.Model.groupNameMode == "UserDefinedWithDefault"
                out = out + obj.indent(3) + "if nargin == 0 || isempty(name)" + newline;
                out = out + obj.indent(4) + "name = " + string(sprintf('"%s";', obj.Model.defaultName)) + newline;
                out = out + obj.indent(3) + "end" + newline;
                out = out + obj.addLineBreak();
            end 
            out = out + obj.indent(3) + obj.getSupercall() + newline;

            % Direct assignment for required properties
            propAssign = obj.getPropAssignments();
            if ~isempty(propAssign)
                out = out +  obj.addLineBreak();
                out = out + obj.indent(3) + "% Required input assignment" + newline;
                for i = 1:numel(propAssign)
                    out = out + obj.indent(3) + propAssign(i) + newline;
                end
            end

            % Input parser for optional inputs
            optionalText = obj.getParser();
            if optionalText ~= ""
                out = out + obj.addLineBreak();
                out = out + optionalText;
            end

            % Close out
            out = out + obj.indent(2) + "end" + newline; % function
            out = out + obj.indent(1) + "end" + newline;
            out = out + obj.addLineBreak();
        end

        function out = getHeader(obj)
            out = sprintf("classdef %s < %s", ...
                obj.Model.ClassName, obj.Model.SuperClass);
        end

        function out = getCommentBlock(obj)
            out = sprintf("%% Short description of %s\n", obj.Model.ClassName);
            out = out + "%" + newline;
            out = out + sprintf("%% Description:\n");
            out = out + sprintf("%%\tDetailed description of %s\n%%\n", ...
                obj.Model.ClassName);
            out = out + sprintf("%% Parent:\n%%\t%s\n%%\n", ...
                obj.Model.SuperClass);
            out = out + "% Constructor:" + newline;
            out = out + "%" + sprintf('\t%s\n', obj.getConstructor);
            out = out + "%" + newline;
            out = out + "% " + string(repmat('-', [1 74]));
            out = out + newline + newline;
        end

        function out = getPropAssignments(obj)
            % Direct property assignment in constructor
            out = string.empty();
            for i = 1:numel(obj.Model.Properties)
                iProp = obj.Model.Properties(i);
                if iProp.isRequired
                    if iProp.makeSetFcn
                        setLine = sprintf("obj.set%s(%s);",... 
                            capFirstChar(iProp.Name),... 
                            camelCase(iProp.Name));
                    else
                        setLine = sprintf("obj.%s = %s;",... 
                            iProp.Name, camelCase(iProp.Name));
                    end
                    out = cat(1, out, setLine);
                end
            end
        end

        function out = getParser(obj)
            % Optional property assignment in constructor
            setters = "";
            for i = 1:numel(obj.Model.Properties)
                if obj.Model.Properties(i).isOptional
                    setFcn = sprintf("addParameter(ip, '%s', ",...
                        capFirstChar(obj.Model.Properties(i).Name));
                    if isempty(obj.Model.Properties(i).Default)
                        setFcn = setFcn + "[]);";
                    else
                        setFcn = setFcn + sprintf('%s);',... 
                            value2string(obj.Model.Properties(i).Default));
                    end
                    setters = setters + obj.indent(3) + setFcn + newline;
                end
            end
            if setters == ""
                out = "";
                return
            end
            out = " " + newline + " " + newline;
            out = obj.indent(3) + "% Optional input parsing" + newline;
            out = out + obj.indent(3) + "ip = aod.util.InputParser();" + newline + setters;
            out = out + obj.indent(3) + "parse(ip, varargin{:});" + newline;

            out = out + obj.addLineBreak();
            for i = 1:numel(obj.Model.Properties)
                if obj.Model.Properties(i).isOptional
                    if obj.Model.Properties(i).makeSetFcn
                        out = out + obj.indent(3) + sprintf("obj.set%s(ip.Results.%s);",...
                            capFirstChar(obj.Model.Properties(i).Name),...
                            capFirstChar(obj.Model.Properties(i).Name));
                    else
                        out = out + obj.indent(3) + sprintf("obj.%s = ip.Results.%s;",...
                            obj.Model.Properties(i).Name,...
                            capFirstChar(obj.Model.Properties(i).Name));
                    end
                    out = out + newline;
                end
            end
        end

        function out = getConstructor(obj)
            out = sprintf("obj = %s(", obj.Model.ClassName);
            if obj.Model.groupNameMode == "UserDefined"
                out = out + "name, ";
            end
            % TODO: Inherited constructor
            for i = 1:numel(obj.Model.Properties)
                if obj.Model.Properties(i).isRequired
                    out = out + camelCase(obj.Model.Properties(i).Name) + ", "; 
                end
            end
            out = out + "varargin)";
        end

        function out = getSupercall(obj)
            mc = meta.class.fromName(obj.Model.SuperClass);
            out = sprintf('obj@%s(', obj.Model.SuperClass);
            for i = 1:numel(mc.MethodList(1).InputNames)
                if i > 1
                    out = [out, ', '];
                end
                out = [out, sprintf('%s', mc.MethodList(1).InputNames{i})];
            end
            out = string(out);
            if contains(out, 'name, ')
                if obj.Model.groupNameMode == "HardCoded"
                    out = strrep(out, "name, ", string(sprintf('"%s", ', obj.Model.defaultName)));
                elseif ismember(obj.Model.groupNameMode, ["DefinedInternally", "ClassName"])
                    out = strrep(out, "name, ", "[], ");
                end
            end
            if endsWith(out, "varargin")
                out = out + "{:}";
            end
            out = out + ");";
        end

        function out = getSetMethods(obj)
            tf1 = arrayfun(@(x) x.makeSetFcn, obj.Model.Properties);
            tf2 = arrayfun(@(x) x.makeSetFcn, obj.Model.Attributes);
            if any(tf1) || any(tf2)
                out = obj.indent(1) + "methods" + newline;
            else
                out = "";
                return
            end
            idx1 = find(tf1);
            for i = 1:numel(idx1)
                if i > 1
                    out = out + " " + newline;
                end
                %if tf1(i)
                out = out + obj.getSetMethod(obj.Model.Properties(idx1(i)));
                %end
            end

            idx2 = find(tf2);
            for i = 1:numel(idx2)
                if ~isempty(idx1) || i > 1
                    out = out + " " + newline;
                end
                out = out + obj.getSetMethod(obj.Model.Attributes(idx2(i)));
            end
            out = out + obj.indent(1) + "end" + newline + " " + newline;

        end

        function out = getDependentSetMethods(obj)
            out = "";
            if obj.Model.groupNameMode == "DefinedInternally"
                out = out + obj.indent(2) + "function value = getLabel(obj)" + newline;
                out = out + obj.indent(3) + sprintf("value = getLabel@%s(obj);", obj.Model.SuperClass) + newline + newline;
                out = out + obj.indent(3) + "% Define any additional processing needed to set label value" + newline;
                out = out + obj.indent(2) + "end" + newline;
                out = out + " " + newline;
            end

            if ~isempty(obj.Model.Attributes)
                out = out + obj.indent(2) + "function value = getExpectedParameters(obj)" + newline;
                out = out + obj.indent(3) + sprintf(...
                    "value = getExpectedParameters@%s(obj);",...
                    obj.Model.SuperClass);
                out = out + newline + " " + newline;
                out = out + obj.indent(3) + "% Add new parameters" + newline;
                for i = 1:numel(obj.Model.Attributes)
                    iAttr = obj.Model.Attributes(i);
                    out = out + obj.indent(3)  + sprintf("value.add('%s'", iAttr.Name);
                    if isempty(iAttr.Default)
                        out = out + ", []";
                    else
                        out = out + ", " + obj.getDefaultValue(iAttr.Default);
                    end

                    if ~isempty(iAttr.Validation)
                        val = obj.getValidation(iAttr.Validation);
                        val = getCharIdx(val, 2:strlength(val)-1);
                        val = "@" + val;
                        out = out + ", " + val;
                    end
                    out = out + ");" + newline;
                end
                out = out + obj.indent(2) + "end" + newline +  " " + newline;
            end

            if out == ""
                return
            end
            out = obj.indent(1) + "methods (Access = protected)" + newline + out;
            out = out + obj.indent(1) + "end" + newline;
            out = out + " " + newline;
        end
    end

    methods %(Access = private)
        function writeLine(obj, txt)
            arguments
                obj
                txt         string
            end

            if obj.fileMode
                fprintf(obj.fileID, txt);
            else
                obj.output = sprintf('%s%s', obj.output, txt);
            end
        end

        function out = getSetMethod(obj, prop)
            out = obj.indent(2) + "function ";
            out = out + sprintf("set%s(obj, value)", capFirstChar(prop.Name));
            out = out + newline;
            if isa(prop, 'aod.util.templates.LinkSpecification')
                out = out + obj.indent(3) + "if isempty(value)" + newline;
                out = out + obj.indent(4) + sprintf("value = %s", prop.EntityType.getCoreClassName());
                out = out + ".empty();" + newline;
                out = out + obj.indent(3) + "end" + newline;
            end
            
            out = out + obj.indent(3);
            if isa(prop, 'aod.util.templates.AttributeSpecification')
                out = out + sprintf("obj.setParam(%s, value);", prop.Name);
            else
                out = out + sprintf("obj.%s = value;", prop.Name);
            end
            out = out + newline;

            out = out + obj.indent(2) + "end" + newline; 
        end

        function out = getValidation(~, fcn)
            if isempty(fcn)
                out = "";
                return
            end

            out = "{";
            for i = 1:numel(fcn)
                if i > 1
                    out = out + ", ";
                end
                value = strtrim(formattedDisplayText(fcn{i}));
                out = out + erase(value, "@");
            end

            out = out + "}";
        end

        function val = getDefaultValue(obj, defaultValue) 
            val = strtrim(formattedDisplayText(defaultValue));
            if ischar(defaultValue)
                val = "'" + val + "'";
            elseif isstring(defaultValue)
                val = string(sprintf('"%s"', val));
            elseif isnumeric(defaultValue) && numel(defaultValue) > 1
                val = "[" + val + "]";
            end
        end
    end

    methods (Static)
        function out = indent(nTabs)
            if nargin < 1
                nTabs = 1;
            end
            out = repmat('    ', [1, nTabs]);
            out = string(sprintf(out));
        end

        function out = addLineBreak()
            out = " " + newline;
        end
    end
end