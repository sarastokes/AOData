classdef SubjectFactory < aod.util.Factory
% SUBJECTFACTORY
%
% Description:
%   Creates the standardized Subject hierarchies with consistent UUIDs 
%
% Parent:
%   aod.util.Factory
%
% Constructor:
%   obj = SubjectFactory()
%
% Methods:
%   subject = get(obj, ID, whichEye)
%   subject = create(ID, whichEye, location)
%
% Quick initialization:
%   subject = SubjectFactory(ID, whichEye, location, parent)
%
% Notes:
%   - Standardized UUIDs are provided for each animal, eye and, for 
%     eyes used for physiology, the standard imaging locations (this might 
%     be over-engineering)
% -------------------------------------------------------------------------

    properties (Hidden, Constant)
        DEFAULT_PUPIL_SIZE = 6.7;       % mm
        PHYSIOLOGY_LOCATIONS = ["Right", "Bottom", "Left", "Top"];
    end

    methods
        function obj = SubjectFactory()
            % Do nothing
        end

        function subject = get(obj, ID, whichEye, location)
            % GET
            %
            % Inputs:
            %   ID                  Subject ID
            %   whichEye            'OD' or 'OS'
            % Optional inputs:
            %   parent              aod.core.Entity subclass
            % -------------------------------------------------------------

            if nargin < 4 || isempty(location)
                location = "Unknown";
            else
                location = appbox.capitalize(location);
                if ischar(location)
                    location = string(location);
                end
            end

            whichEye = upper(whichEye);
            assert(ischar(whichEye) & ismember(whichEye, {'OD', 'OS'}),...
                'whichEye must be either OD or OS!');
            
            nhpProps = {'PupilSize', obj.DEFAULT_PUPIL_SIZE};

            subjectLoc = [];
                    
            switch ID
                case 838
                    animal = aod.builtin.sources.primate.Primate(...
                        'MC00838',...
                        'Species', "macaca fascicularis",...
                        'Sex', "female",...
                        'DateOfBirth', datetime('20130622', 'Format', 'yyyyMMdd'),...
                        'Demographics', "GCaMP6s");
                    animal.assignUUID("8a496cec-5034-4021-98da-22936bc164cb");

                    % Add the eye
                    if strcmp(whichEye, 'OD')
                        subjectEye = aod.builtin.sources.primate.Eye('OD',...
                            'AxialLength', 16.56, nhpProps{:});
                        subjectEye.assignUUID("bc7aea0b-ada1-42c1-8f45-695dfb664861");
                        animal.add(subjectEye);
                        
                        % Add location, if standardized
                        ID = find(obj.PHYSIOLOGY_LOCATIONS == location);
                        if ~isempty(ID)
                            locationUUIDs = [...                       
                                "d9f44105-0b58-4226-8332-9d750d27533e"
                                "46f21172-a773-469a-b866-9a3cd10ca7bd"
                                "fcd32ad9-f53b-4879-8686-d8514230dde5"
                                "e534bdca-fa2b-46ae-a099-4f28efbfd253"];
                            subjectLoc = sara.sources.PhysiologyLocation(location);
                            subjectLoc.assignUUID(locationUUIDs(ID));
                            subjectEye.add(subjectLoc);
                        end
                    end
                case 848
                    animal = aod.builtin.sources.primate.Primate('MC00848',...
                        'Species', "macaca fascicularis",...
                        'Sex', 'male',...
                        'Demographics', "rhodamine");
                    animal.assignUUID("749633e9-4dec-4a1b-833a-dbb9cfb66096");

                    % Add the eye
                    if strcmp(whichEye, 'OD')
                        subjectEye = aod.builtin.sources.primate.Eye('OD',...
                            'AxialLength', 18.47, nhpProps{:});
                        subjectEye.assignUUID("a0a28abd-c677-44d5-ab21-0a82452ab4e3");
                    else
                        subjectEye = aod.builtin.sources.primate.Eye('OS',...
                            'AxialLength', 18.59, nhpProps{:});
                        subjectEye.assignUUID("d305a3ba-4bb0-479a-9538-be2c18b65a2a");
                    end
                    animal.add(subjectEye);
                case 851
                    animal = aod.builtin.sources.primate.Primate('MC00851',...
                        'Species', "macaca fascicularis",...
                        'Sex', "male",...
                        'Demographics', "GCaMP6s, rhodamine");
                    animal.assignUUID("d89b9d19-10fd-4eff-bbfa-6d76a5864f0b");

                    % Add the eye
                    if strcmp(whichEye, 'OD')
                        subjectEye = aod.builtin.sources.primate.Eye('OD',...
                            'AxialLength', 16.88, nhpProps{:});
                        subjectEye.assignUUID("5c6327dd-52b5-4832-88f4-a3e3977258e9")
                        animal.add(subjectEye);

                        % Add location, if standardized
                        ID = find(obj.PHYSIOLOGY_LOCATIONS == location);
                        if ~isempty(ID)
                            locationUUIDs = [...                       
                                "795f1873-c222-4174-805c-6026c5301ba0"
                                "5b6c09f3-e221-49e9-8d10-67825c5e5318"
                                "21e804eb-d0b8-43e0-96ef-98718c84028d"
                                "b2208ed0-7abd-4bda-834e-75b0f1133359"];
                            subjectLoc = sara.sources.PhysiologyLocation(location);
                            subjectLoc.assignUUID(locationUUIDs(ID));
                            subjectEye.add(subjectLoc);
                        end
                    else
                        subjectEye = aod.builtin.sources.primate.Eye('OS',...
                            'AxialLength', 16.97, nhpProps{:});
                        subjectEye.setParam('ContactLens', "12.2mm/5.8mm/plano");
                        subjectEye.assignUUID("5e8118e0-a165-4c4f-a261-47fb31e9059c");
                        animal.add(subjectEye);
                        
                        % Add location, if standardized
                        ID = find(obj.PHYSIOLOGY_LOCATIONS == location);
                        if ~isempty(ID)
                            locationUUIDs = [...                       
                                "7baeb2bf-3a9b-40e8-ac44-8c5bbec500b9"
                                "8e76e7de-694e-48bb-91b3-b5333938071b"
                                "1ca0286f-1816-4093-9224-c0cad59491c2"
                                "fc161ba0-25aa-4a3b-b2fc-8d9b42c1e685"];
                            subjectLoc = sara.sources.PhysiologyLocation(location);
                            subjectLoc.assignUUID(locationUUIDs(ID));
                            subjectEye.add(subjectLoc);
                        end
                    end
                otherwise
                    error('Unrecognized ID %u', ID);
            end
            
            % Return the most specific source 
            if isempty(subjectLoc)
                subject = subjectEye;
            else
                subject = subjectLoc;
            end
        end
    end

    methods (Static)
        function subject = create(varargin)
            obj = sara.factories.SubjectFactory();
            subject = obj.get(varargin{:});
        end
    end
end