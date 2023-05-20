function obj = map2attributes(cMap)
% Create from containers.Map
%
% Syntax:
%   obj = map2attributes(cMap)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    assert(isa(cMap, 'containers.Map'),...
        'Input must be a containers.Map');
             
    obj = aod.util.Attributes();
    if isempty(cMap)
        return 
    end
    
    k = cMap.keys;
    for i = 1:numel(k)
        obj(k{i}) = cMap(k{i});
    end