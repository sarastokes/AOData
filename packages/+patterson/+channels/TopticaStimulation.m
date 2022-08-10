classdef TopticaStimulation < aod.core.Channel

    properties (SetAccess = private)
        laserLine
        basePower
        digital                 % in digital mode or analog
    end

    methods 
        function obj = TopticaStimulation(parent, laserLine, varargin)
            obj = obj@aod.core.Channel(parent);
            obj.laserLine = laserLine;

            ip = inputParser();
            addParameter(ip, 'BasePower', [], @isnumeric);
            addParameter(ip, 'Digital', false, @isnumeric);
            addParameter(ip, 'NDF', [], @isnumeric);
            parse(ip, varargin{:});
            
            obj.digitalMode = ip.Results.Digital;
            obj.basePower = ip.Results.BasePower;

            obj.initialize(ip.Results.NDF);
        end
    end

    methods (Access = private)
        function initialize(obj, ndf)

            obj.addDevice(aod.builtin.devices.LightSource(obj, 561,...
                'Manufacturer', 'Toptica', 'Model', 'iChrome MLE'));
            if ~isempty(ndf)
                ndf = aod.builtin.NeutralDensityFilter(obj, ndf,...
                    'Model', sprintf('NE%sA-A', int2fixedwidthstr(ndf, 2)));
                [filePath, tf] = patterson.resources.getResource('NE%sA.txt',...
                    int2fixedwidthstr(ndf, 2));
                if tf
                    ndf.setTransmission(dlmread(filePath));
                end
                obj.addDevice(ndf);
            end
        end
    end
end 