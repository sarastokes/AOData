classdef FilterBoxHandler < aod.app.EventHandler 

    methods
        function obj = FilterBoxHandler(parent, publisher)
            obj = obj@aod.app.EventHandler(parent, publisher);
        end

        function handleRequest(obj, ~, evt)
            switch evt.EventType
                case "ChangeFilterType"
                    if isempty(evt.Data.FilterType)
                        value = [];
                    else
                        value = aod.api.FilterTypes.init(evt.Data.FilterType);
                    end
                    obj.Parent.inputBox.changeFilterType(value);
                case "AddSubfilter"
                    obj.Parent.addNewSubfilter();
                case "RemoveSubfilter"
                    
            end

            obj.passRequest(evt);
        end
    end
end 