classdef SubjectFactory < aod.core.Factory
% SUBJECTFACTORY
%
% Description:
%   Creates the appropriate Protocol for a given filename
%
% Parent:
%   aod.core.Factory
%
% Syntax:
%   obj = SubjectFactory()
%
% Methods:
%   protocol = get(obj, ID, whichEye, parent)
%   protocol = create(ID, whichEye, parent)
% -------------------------------------------------------------------------

    properties (Hidden, Constant)
        DEFAULT_PUPIL_SIZE = 6.7;       % mm
    end

    methods
        function obj = SubjectFactory()
            % Do nothing
        end

        function subject = get(obj, ID, whichEye, parent)
            % GET
            %
            % Inputs:
            %   ID                  Subject ID
            %   whichEye            'OD' or 'OS'
            % Optional inputs:
            %   parent              aod.core.Entity subclass
            % -------------------------------------------------------------

            if nargin < 4 || isempty(parent)
                parent = aod.core.Empty();
            end

            whichEye = upper(whichEye);
            assert(ischar(whichEye) & ismember(whichEye, {'OD', 'OS'}),...
                'whichEye must be either OD or OS!');
            
            nhpProps = {'PupilSize', obj.DEFAULT_PUPIL_SIZE};
                    
            switch ID
                case 838
                    subject = aod.builtin.sources.primate.Primate(838, parent,...
                        'Species', 'macaca fascicularis',...
                        'Sex', 'F',...
                        'Demographics', 'GCaMP6s');
                    if strcmp(whichEye, 'OD')
                        obj = aod.builtin.sources.primate.Eye(subject, 'OD',...
                            'AxialLength', 16.56, nhpProps{:});
                    end
                case 848
                    subject = aod.builtin.sources.primate.Primate(848, parent,...
                        'Species', 'macaca fascicularis',...
                        'Sex', 'M',...
                        'Demographics', 'rhodamine');
                    if strcmp(whichEye, 'OD')
                        obj = aod.builtin.sources.primate.Eye(subject, 'OD',...
                            'AxialLength', 18.47, nhpProps{:});
                    else
                        obj = aod.builtin.sources.primate.Eye(subject, 'OS',...
                            'AxialLength', 18.59, nhpProps{:});
                    end
                case 851
                    subject = aod.builtin.sources.primate.Primate(851, parent,...
                        'Species', 'macaca fasciularis',...
                        'Sex', 'M',...
                        'Demographics', 'GCaMP6s, rhodamine');
                    if strcmp(whichEye, 'OD')
                        obj = aod.builtin.sources.primate.Eye(subject, 'OD',...
                            'AxialLength', 16.88, nhpProps{:});
                    else
                        obj = aod.builtin.sources.primate.Eye(subject, 'OS',...
                            'AxialLength', 16.97, nhpProps{:});
                    end
                otherwise
                    error('Unrecognized ID %u', ID);
            end
        end
    end

    methods (Static)
        function subject = create(varargin)
            obj = patterson.factories.SubjectFactory();
            subject = obj.get(varargin{:});
        end
    end
end