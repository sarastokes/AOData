classdef Subject < aod.core.Source 

    properties
        ID
        Eyes
    end
    
    methods 
        function obj = Subject(ID, parent, varargin)
            obj@aod.core.Source(parent);
            obj.ID = ID;

            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'Species', [], @ischar);
            addParameter(ip, 'Sex', [], @ischar);
            addParameter(ip, 'Age', [], @isnumeric);
            addParameter(ip, 'Demographics', [], @ischar);
            parse(ip, varargin{:});

            obj.addParserToParams(ip.Results);
        end

        function addEye(obj, Eye)
            assert(isa(Eye, 'aod.builtin.sources.Eye'),...
                'Must be class aod.builtin.sources.Eye');
            obj.Eyes = cat(1, obj.Eyes, Eye);
        end
    end
end