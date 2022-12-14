function [modType, modName] = parseModulation(baseValue, modValue)
% PARSEMODULATION
%
% Description:
%   Determine whether modulation is an increment or decrement in intensity 
%   or contrast
%
% Syntax:
%   [modType, modName] = sara.util.parseModulation(baseValue, modValue)
%
% History:
%   14Jul2022 - SSP
% -------------------------------------------------------------------------
    
    % No modulation, base and mod values are equal
    if modValue == baseValue
        modType = 'background';
        modName = '';
        return
    end

    % Intensity modulation (0 base value)
    if baseValue == 0
        modType = 'intensity';
        if modValue < 0
            error('parseModulation: Negative modulations from 0 background are invalid');
        end
        modName = 'increment';
        return;
    end

    % Contrast modulation (relative to base value)
    modType = 'contrast';
    if modValue > baseValue
        modName = 'increment';
    elseif modValue < baseValue
        modName = 'decrement';
    end


    