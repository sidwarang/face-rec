function statusbarHandles = statusbar(varargin)

    % Check for available Java/AWT (not sure if Swing is really needed so let's just check AWT)
    if ~usejava('awt')
        error('YMA:statusbar:noJava','statusbar only works on Matlab envs that run on java');
    end

    % Args check
    if nargin < 1 | ischar(varargin{1})  %#ok for Matlab 6 compatibility
        handles = gcf;  % note: this skips over figures with 'HandleVisibility'='off'
    else
        handles = varargin{1};
        varargin(1) = [];
    end

    % Ensure that all supplied handles are valid HG GUI handles (Note: 0 is a valid HG handle)
    if isempty(handles) | ~all(ishandle(handles))  %#ok for Matlab 6 compatibility
        error('YMA:statusbar:invalidHandle','invalid GUI handle passed to statusbar');
    end

    % Retrieve the requested text string (only process once, for all handles)
    if isempty(varargin)
        deleteFlag = (nargout==0);
        updateFlag = 0;
        statusText = '';
    else
        deleteFlag = 0;
        updateFlag = 1;
        statusText = sprintf(varargin{:});
    end

    % Loop over all unique root handles (figures/desktop) of the supplied handles
    rootHandles = [];
    if any(handles)  % non-0, i.e. non-desktop
        try
            rootHandles = ancestor(handles,'figure');
            if iscell(rootHandles),  rootHandles = cell2mat(rootHandles);  end
        catch
            errMsg = 'Matlab version is too old to support figure statusbars';
            % Note: old Matlab version didn't have the ID optional arg in warning/error, so I can't use it here
            if any(handles==0)
                warning([errMsg, '. Updating the desktop statusbar only.']);  %#ok for Matlab 6 compatibility
            else
                error(errMsg);
            end
        end
    end
    rootHandles = unique(rootHandles);
    if any(handles==0), rootHandles(end+1)=0; end
    statusbarObjs = handle([]);
    for rootIdx = 1 : length(rootHandles)
        if rootHandles(rootIdx) == 0
            setDesktopStatus(statusText);
        else
            thisStatusbarObj = setFigureStatus(rootHandles(rootIdx), deleteFlag, updateFlag, statusText);
            if ~isempty(thisStatusbarObj)
                statusbarObjs(end+1) = thisStatusbarObj;
            end
        end
    end

    % If statusbarHandles requested
    if nargout
        % Return the list of all valid (non-empty) statusbarHandles
        statusbarHandles = statusbarObjs;
    end

%end  % statusbar  %#ok for Matlab 6 compatibility

%% Set the status bar text of the Matlab desktop
function setDesktopStatus(statusText)
    try
        % First, get the desktop reference
        try
            desktop = com.mathworks.mde.desk.MLDesktop.getInstance;      % Matlab 7+
        catch
            desktop = com.mathworks.ide.desktop.MLDesktop.getMLDesktop;  % Matlab 6
        end

        % Schedule a timer to update the status text
        % Note: can't update immediately, since it will be overridden by Matlab's 'busy' message...
        try
            t = timer('Name','statusbarTimer', 'TimerFcn',{@setText,desktop,statusText}, 'StartDelay',0.05, 'ExecutionMode','singleShot');
            start(t);
        catch
            % Probably an old Matlab version that still doesn't have timer
            desktop.setStatusText(statusText);
        end
    catch
        %if any(ishandle(hFig)),  delete(hFig);  end
        error('YMA:statusbar:desktopError',['error updating desktop status text: ' lasterr]);
    end
%end  %#ok for Matlab 6 compatibility

%% Utility function used as setDesktopStatus's internal timer's callback
function setText(varargin)
    if nargin == 4  % just in case...
        targetObj  = varargin{3};
        statusText = varargin{4};
        targetObj.setStatusText(statusText);
    else
        % should never happen...
    end
%end  %#ok for Matlab 6 compatibility

%% Set the status bar text for a figure
function statusbarObj = setFigureStatus(hFig, deleteFlag, updateFlag, statusText)
    try
        jFrame = get(handle(hFig),'JavaFrame');
        jFigPanel = get(jFrame,'FigurePanelContainer');
        jRootPane = jFigPanel.getComponent(0).getRootPane;

        % If invalid RootPane, retry up to N times
        tries = 10;
        while isempty(jRootPane) & tries>0  %#ok for Matlab 6 compatibility - might happen if figure is still undergoing rendering...
            drawnow; pause(0.001);
            tries = tries - 1;
            jRootPane = jFigPanel.getComponent(0).getRootPane;
        end
        jRootPane = jRootPane.getTopLevelAncestor;

        % Get the existing statusbarObj
        statusbarObj = jRootPane.getStatusBar;

        % If status-bar deletion was requested
        if deleteFlag
            % Non-empty statusbarObj - delete it
            if ~isempty(statusbarObj)
                jRootPane.setStatusBarVisible(0);
            end
        elseif updateFlag  % status-bar update was requested
            % If no statusbarObj yet, create it
            if isempty(statusbarObj)
               statusbarObj = com.mathworks.mwswing.MJStatusBar;
               jProgressBar = javax.swing.JProgressBar;
               jProgressBar.setVisible(false);
               statusbarObj.add(jProgressBar,'West');  % Beware: East also works but doesn't resize automatically
               jRootPane.setStatusBar(statusbarObj);
            end
            statusbarObj.setText(statusText);
            jRootPane.setStatusBarVisible(1);
        end
        statusbarObj = handle(statusbarObj);

        % Add quick references to the corner grip and status-bar panel area
        if ~isempty(statusbarObj)
            addOrUpdateProp(statusbarObj,'CornerGrip',  statusbarObj.getParent.getComponent(0));
            addOrUpdateProp(statusbarObj,'TextPanel',   statusbarObj.getComponent(0));
            addOrUpdateProp(statusbarObj,'ProgressBar', statusbarObj.getComponent(1).getComponent(0));
        end
    catch
        try
            try
                title = jFrame.fFigureClient.getWindow.getTitle;
            catch
                title = jFrame.fHG1Client.getWindow.getTitle;
            end
        catch
            title = get(hFig,'Name');
        end
        error('YMA:statusbar:figureError',['error updating status text for figure ' title ': ' lasterr]);
    end
%end  

%% Utility function: add a new property to a handle and update its value
function addOrUpdateProp(handle,propName,propValue)
    try
        if ~isprop(handle,propName)
            schema.prop(handle,propName,'mxArray');
        end
        set(handle,propName,propValue);
    catch
        % never mind... - maybe propName is already in use
        %lasterr
    end
%end