classdef FilterBox < aod.app.EventHandler 

    methods
        function obj = FilterBox(parent, publisher)
            obj = obj@aod.app.EventHandler(parent, publisher);
        end

        function handleRequest(obj, ~, evt)
            switch evt.EventType
                case "ChangeFilterType"
                    obj.Parent.update(evt);
                    %if isempty(evt.Data.FilterType)
                    %    value = [];
                    %else
                    %    value = aod.api.FilterTypes.init(evt.Data.FilterType);
                    %end
                    %obj.Parent.inputBox.changeFilterType(value);
                case "AddSubfilter"
                    obj.Parent.addNewSubfilter();
                case "RemoveSubfilter"
                case "ChangedFilterInput"
                    obj.Parent.update(evt);    
            end

            obj.passRequest(evt);
        end
    end
end 