classdef Subject < aod.core.Source 
% SUBJECT

    properties
        ID
        Eyes        % Keep?
    end
    
    methods 
        function obj = Subject(ID, parent, varargin)
            if nargin < 2
                parent = [];
            end

            obj@aod.core.Source(parent);
            if nargin > 0
                obj.ID = ID;
            end

            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'Species', [], @ischar);
            addParameter(ip, 'Sex', [], @ischar);
            addParameter(ip, 'Age', [], @isnumeric);
            addParameter(ip, 'Demographics', [], @ischar);
            parse(ip, varargin{:});

            obj.sourceParameters.addParser(ip);
        end

        function addEye(obj, Eye)
            assert(isa(Eye, 'aod.builtin.sources.Eye'),...
                'Must be class aod.builtin.sources.Eye');
            obj.Eyes = cat(1, obj.Eyes, Eye);
        end
    end
end