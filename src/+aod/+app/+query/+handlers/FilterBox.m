classdef FilterBox < aod.app.EventHandler 

    methods
        function obj = FilterBox(parent)
            obj = obj@aod.app.EventHandler(parent);
        end

        function handleRequest(obj, ~, evt)
            assignin('base', 'FilterBoxRequest', evt);
            switch evt.EventType 
                case "ChangeFilterType"
                    obj.Parent.update(evt);
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