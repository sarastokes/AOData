classdef FilterBox < aod.app.EventHandler 

    methods
        function obj = FilterBox(parent)
            obj = obj@aod.app.EventHandler(parent);
        end

        function handleRequest(obj, ~, evt)
            assignin('base', 'evt', evt);
            switch evt.EventType 
                case "ChangeFilterType"
                    obj.Parent.update(evt);
                case "AddSubfilter"
                    obj.Parent.addNewSubfilter();
                case "RemoveSubfilter"
                case "ChangedFilterInput"
                    obj.Parent.update(evt);    
                case "PushFilter"
                    obj.Parent.Root.QueryManager.addFilter(...
                        obj.Parent.getFilter());
                    obj.Parent.Root.update(evt);
                case "PullFilter"
                case "CheckFilter"
            end

            obj.passRequest(evt);
        end
    end
end 