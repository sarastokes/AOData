classdef SpecificationWriter < handle 

    methods (Static)
        function makePackageSpecification(pkgName)
            
            [classes, pkgs] = aod.specification.util.collectAllPackageClasses(pkgName);

            pkgLevel = 1 + arrayfun(@(x) numel(find(char(x) == '.')), pkgs);
            classLevel = arrayfun(@(x) numel(find(char(x) == '.')), classes);

            pkgs = pkgs(sort(pkgLevel));
            pkgLevel = sort(pkgLevel);

            S = struct();
            for i = 1:numel(pkgs)
                pkgClasses = classList(classLevel == pkgLevel(i) & startsWith(pkgs(i)));
                if ~isempty(pkgClasses)
                    iS = createNamespace(S, pkgs(i), pkgClasses);
                end
            end
        end
    end

    methods (Static)
        function getNameSpace(S, pkgName)
            pkgs = strsplit(pkgName, '.');
            for i = 1:numel(pkgs)
            end
        end

        function S = createNamespace(S, pkgName, classList)
            S.Namespace = pkgName;
            txt = strsplit(pkgName, '.');
            S.Name = txt{end};
            S.Classes = struct();
            S.Namespaces = struct();
            
            for i = 1:numel(classList)
                S.Classes.(classList(i)) = struct();
            end
        end

        function S = createSubStructs(S, pkgList)
            for i = 1:numel(pkgList)
                names = strsplit(pkgList(i), '.');
                iS = S;
                for j = 1:numel(names)
                    if ~isfield(iS.Packages.(names))
                        iS.Packages.(names) = struct();
                    end
                    iS = iS.Packages.(names);
                end
            end
        end
    end
end