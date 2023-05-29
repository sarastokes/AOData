function obj = map2attributes(cMap)
% Create AOData's KeyValueMap from containers.Map
%
% Syntax:
%   obj = map2attributes(cMap)
%
% See also:
%   aod.common.KeyValueMap, containers.Map

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    assert(isa(cMap, 'containers.Map'),...
        'Input must be a containers.Map');
             
    obj = aod.common.KeyValueMap();
    if isempty(cMap)
        return 
    end
    
    k = cMap.keys;
    for i = 1:numel(k)
        obj(k{i}) = cMap(k{i});
    end