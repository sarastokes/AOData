classdef (ConstructOnLoad) DiscrepancyEvent < event.EventData
% Specification discrepancy event
%
% Superclasses:
%   event.EventData
%
% Constructor:
%   obj = aod.specification.events.DiscrepancyEvent(specType,... 
%       readerValue, writerValue) 

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties 
        PropName        (1,1)       string 
        SpecType        (1,1)       string 
        ReaderValue
        WriterValue
    end

    methods
        function obj = DiscrepancyEvent(propName, specType, readerValue, writerValue)
            
            arguments
                propName        (1,1)   string
                specType        (1,1)   string
                readerValue
                writerValue
            end

            obj.PropName = propName;
            obj.SpecType = specType;
            obj.ReaderValue = readerValue;
            obj.WriterValue = writerValue;
        end
    end
end 