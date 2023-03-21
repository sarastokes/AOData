classdef UIView < handle
% View using uifigure
%
% Description:
%   A copy of appbox.View that uses uifigure instead of figure
%
% Constructor:
%   obj = aod.app.UIView()
%
% See also:
%   appbox.View

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    events
        KeyPress
        Close
    end

    properties (SetAccess = private)
        isClosed
    end

    properties (Access = protected)
        figureHandle
        folderChooser
    end

    methods (Abstract)
        createUi(obj);
    end

    methods

        function obj = UIView(varargin)

            ip = inputParser();
            addParameter(ip, 'FolderChooser', aod.app.util.DefaultFolderChooser);
            parse(ip, varargin{:});
            obj.folderChooser = ip.Results.FolderChooser;

            warning('off', 'MATLAB:ui:javacomponent:FunctionToBeRemoved');
            obj.figureHandle = uifigure(...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'ToolBar', 'none',...
                'Visible', 'off', ...
                'Interruptible', 'off',...
                'WindowKeyPressFcn', @(h,d)notify(obj, 'KeyPress', appbox.EventData(d)),...
                'CloseRequestFcn', @(h,d)notify(obj, 'Close'));
                %'DockControls', 'off',...

            font = javax.swing.UIManager.getDefaults().getFont('Panel.font');
            for c = {'Uicontrol', 'Uitable', 'Uipanel', 'Uibuttongroup', 'Axes'}
                c = c{1}; %#ok<FXSET>
                set(obj.figureHandle, ['Default' c 'FontName'], char(font.getName()));
                set(obj.figureHandle, ['Default' c 'FontSize'], font.getSize());
                set(obj.figureHandle, ['Default' c 'FontUnits'], 'pixels');
            end

            try
                obj.createUi();
            catch x
                delete(obj.figureHandle);
                rethrow(x);
            end
        end

        function delete(obj)
            if ~obj.isClosed
                obj.close();
            end
        end

        function show(obj)
            figure(obj.figureHandle);
        end

        function hide(obj)
            set(obj.figureHandle, 'Visible', 'off');
            obj.resume();
        end

        function close(obj)
            delete(obj.figureHandle);
        end

        function tf = get.isClosed(obj)
            tf = ~isvalid(obj.figureHandle);
        end

        function wait(obj)
            uiwait(obj.figureHandle);
        end

        function resume(obj)
            uiresume(obj.figureHandle);
        end

        function update(obj) %#ok<MANU>
            drawnow();
        end

        function showError(obj, msg)
            obj.showMessage(msg, 'Error');
        end

        function [btn, tf] = showMessage(obj, text, title, varargin) %#ok<INUSL>
            if nargin < 3
                title = '';
            end
            presenter = appbox.MessagePresenter(text, title, varargin{:});
            presenter.goWaitStop();
            results = presenter.result;
            if ~isempty(results)
                btn = results{1};
                tf = results{2};
            else
                btn = [];
                tf = [];
            end
        end

        function p = showBusy(obj, title) %#ok<INUSL>
            p = appbox.BusyPresenter(title);
            p.go();
        end

        function showWeb(obj, url, varargin) %#ok<INUSL>
            web(url, varargin{:});
        end

        function p = showGetDirectory(obj, varargin)
            % Show uigetdir through helper class made for testing
            p = obj.folderChooser.chooseFolder(varargin{:});
        end

        function p = showGetFile(obj, title, filter, defaultName) %#ok<INUSL>
            if nargin < 3
                filter = '*';
            end
            if nargin < 4
                defaultName = '';
            end
            [filename, pathname] = uigetfile(filter, title, defaultName);
            if filename == 0
                p = [];
                return;
            end
            p = fullfile(pathname, filename);
        end

        function p = showPutFile(obj, title, filter, defaultName) %#ok<INUSL>
            if nargin < 3
                filter = '*';
            end
            if nargin < 4
                defaultName = '';
            end
            [filename, pathname] = uiputfile(filter, title, defaultName);
            if filename == 0
                p = [];
                return;
            end
            p = fullfile(pathname, filename);
        end
    end
end