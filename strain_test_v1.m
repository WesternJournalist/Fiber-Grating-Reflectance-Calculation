function varargout = strain_test_v1(varargin)
% STRAIN_TEST IS A DEMOSTRATION OF FBG REFLECTION CALCULATE UI
% USING cal_spec_new_v4.m DO CALCULATION BY TMM(TRANSFER MATRIX METHOD)
% V1.1 BY JIN XIN 
% Update: Optimize drawing
% STRAIN_TEST MATLAB code for strain_test.fig
%      STRAIN_TEST, by itself, creates a new STRAIN_TEST or raises the existing
%      singleton*.
%
%      H = STRAIN_TEST returns the handle to a new STRAIN_TEST or the handle to
%      the existing singleton*.
%
%      STRAIN_TEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STRAIN_TEST.M with the given input arguments.
%
%      STRAIN_TEST('Property','Value',...) creates a new STRAIN_TEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before strain_test_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to strain_test_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help strain_test

% Last Modified by GUIDE v2.5 29-Nov-2017 17:29:12

% Begin initialization code - DO NOT EDIT


gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @strain_test_OpeningFcn, ...
                   'gui_OutputFcn',  @strain_test_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before strain_test is made visible.
function strain_test_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to strain_test (see VARARGIN)

% Choose default command line output for strain_test
handles.output = hObject;
s=struct('center',      1550, ...
        'strains',      0, ...
        'apo',          0,...
        'ag',           0,...
        'a_dneff',      0.0001,...
        'hold_flag',    0, ...
        'curve_num',    0, ...
        'c',            matlab.graphics.chart.primitive.Line(),...
        'v',            1, ...
        'pe',           0.22, ...
        'refspec',      0, ...
        'refstrain',    [], ...
        'refstrainflag',0, ...
        'refspecflag',  0, ...
        'refsplot',     0, ...
        'lambdab',      1550, ...
        'l',            0.015, ...
        'N',            21, ...
        'neff',         1.45, ...
        'pts',          [], ...
        'strainplot',   0, ...
        'hplot',        0, ...
        'hweight',      0, ...
        'calspcplot',   0, ...
        'refspcplot',   0, ...
        'fastprev',     0, ...
        'testflag',     0, ...
        'apofun',       '', ...
        'strainmin',    -1000, ...
        'strainmax',    1000, ...
        'temppt',       [], ...
        'temppts',      [], ...
        'axes1btd',     0, ...
        'points',       [] ...
        );
handles.mydata=s;
% Update handles structure
axes(handles.axes1);
set(handles.axes1,'YLim',[handles.mydata.strainmin handles.mydata.strainmax]);
set(handles.axes1,'XLim',[0 handles.mydata.l]);
% axis ([0 handles.mydata.l handles.mydata.strainmin handles.mydata.strainmax ]);%strain axes limit
set(handles.axes1,'NextPlot','Add');
refsplot = plot(0,0);%ref strain
hplot = plot(0,0);% mouse tap input strain line
hweight = plot(0,0);% interpolation strain curve

axes(handles.axes2);
set(handles.axes2,'NextPlot','Add');
refspcplot = plot(0,0);%ref spectrum
calspcplot = plot(0,0);%calculation spectrum


% % set(hObject.hplot, 'xdata', [], 'ydata', []);
% % set(hObject.hweight, 'xdata', [], 'ydata', []);
handles.mydata.refspcplot = refspcplot;
handles.mydata.calspcplot = calspcplot;
handles.mydata.refsplot =  refsplot;
handles.mydata.hplot = hplot;
handles.mydata.hweight = hweight;
guidata(hObject, handles);

% UIWAIT makes strain_test wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = strain_test_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%%
function [xi,interps, points] = LinearInterpolation(points, handles)
l=handles.mydata.l;
N=handles.mydata.N;
if size(points,1)>1
    points = sortrows(points);
    x = points(:,1);
    y = points(:,2);
    xi = linspace(0,l,N);
  

    interps = interp1(x, y, xi', 'pchip');% 可以改变最后一个参量改变插值的方法
    points = [x, y];
end

%%
function pts = FindNearestPointAndRemove(pts, point)
if ~isempty(pts)
    points = pts;
    points(:,1) = points(:,1) - point(1);
    points(:,2) = points(:,2) - point(2);
    points = abs(points);
    
    [points, index] = sortrows(points, [1, 2]);
    pts(index(1),:) = [];
end

function plotrefstrain(hObject,handles)
    refstrain = handles.mydata.refstrain.*1e6;
    refstrainflag = handles.mydata.refstrainflag;
    l = handles.mydata.l;
    N = handles.mydata.N;
    refsplot = handles.mydata.refsplot;
    if refstrainflag
  
        x=1:length(refstrain);
        xi=linspace(1,length(refstrain),N);
        length_plot = linspace(0,l,N);
        strains_plot=interp1(x,refstrain,xi,'pchip');
        set(refsplot,'xdata',length_plot,'ydata',strains_plot, 'color', 'r', 'LineStyle', '--');
        set(handles.axes1,'YLim',[min(strains_plot)-100 max(strains_plot)+100]);
        handles.mydata.strainmin=min(strains_plot)-100;
        handles.mydata.strainmax=max(strains_plot)+100;
    else
        set(refsplot,'xdata',[],'ydata',[], 'color', 'r', 'LineStyle', '--');   
   end
guidata(hObject, handles);

function plotrefspec(hObject,handles)
refspecflag=handles.mydata.refspecflag;
refspec=handles.mydata.refspec;
refspcplot = handles.mydata.refspcplot;% handle of ref spectrum
if size(refspec,2)==2
    refspec=refspec';
end
if refspecflag
%     cla reset;
%     hold on;
%      c=plot(L.*1e9,R);
%      d=plot(refspec(:,1),refspec(:,2));
%      xlim([min(L.*1e9) max(L.*1e9)]);
%      hold off;

    set(refspcplot, 'XData', refspec(1,:), 'YData', refspec(2,:), 'color', 'r', 'LineStyle', '--')
    set(handles.axes2,'XLim',[min(refspec(1,:)) max(refspec(1,:))]);

else

    set(refspcplot, 'XData', [], 'YData', [], 'color', 'r', 'LineStyle', '--')
%     set(handles.axes2,'XLim',[min(refspec(1,:)) max(refspec(1,:))]);
end
    
function plots(hObject,handles)

strains=handles.mydata.strains.*1e-6;
center=handles.mydata.center.*1e-9;
apo_flag=handles.mydata.apo;
a_dneff=handles.mydata.a_dneff;
v=handles.mydata.v;
pe=handles.mydata.pe;
apofun=handles.mydata.apofun;
lambdab=handles.mydata.lambdab.*1e-9;
l=handles.mydata.l;
N=handles.mydata.N;
neff = handles.mydata.neff;
calspcplot = handles.mydata.calspcplot;% handle of cal spectrum 



if apo_flag
    ag=handles.mydata.ag;
else
    ag=0;
end
set(handles.edit_windowcenter,'String',num2str(center.*1e9));

% handles.mydata.strainplot=pt;
if handles.mydata.testflag==0
[R,L]=cal_spec_new_v4('strain',strains,'L',l,'v',v,'pe',pe,'N',N,'a_deltaN',a_dneff,...
    'Neff',neff,'range',[center-1e-9 center+1e-9],'ag',ag,'LambdaD',lambdab,'a_func',apofun);
elseif handles.mydata.testflag==1

  strain1 = [[-1.43814416416088e-05;8.67673607672153e-07;1.51762096287781e-05;...
      2.83211507722654e-05;4.06369377552399e-05;5.27353135041358e-05;...
      6.26710601788450e-05;6.88556320789756e-05;7.33884447296834e-05;...
      7.70265142222374e-05;8.00272881587121e-05;8.26717975191206e-05;...
      8.53529105134948e-05;8.77752020391738e-05;8.94733935621195e-05;...
      8.99691279448592e-05;8.84074130442406e-05;8.52983258500887e-05;...
      8.18102952422065e-05;7.63927132590784e-05;4.19333986639308e-05]];
        Period=lambdab/neff/2;
    Periodz=Period.*(1+(1-pe).*strain1);
    neff=neff.*(1-pe.*strain1);
[R,L]=cal_spec_new_v4('strain',strains,'L',l,'v',v,'pe',pe,'N',N,'a_deltaN',a_dneff,...
    'Neff',neff,'range',[center-1e-9 center+1e-9],'ag',ag,'LambdaD',lambdab,'period',Periodz,'a_func',apofun);
end
if handles.checkbox_smooth.Value
    set(calspcplot, 'XData', L'.*1e9, 'YData', smooth(R,str2num(handles.edit_smooth.String))', 'color', 'b', 'LineStyle', '-');
else
    set(calspcplot, 'XData', L'.*1e9, 'YData', R', 'color', 'b', 'LineStyle', '-');
end
        set(handles.axes2,'XLim',[min(L'.*1e9) max(L'.*1e9)]);
guidata(hObject, handles);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plots(hObject, handles);


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2
% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2

% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function pushbutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
strains=zeros(1,6);
set(hObject,'UserData',strains);



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
center=handles.mydata.center.*1e-9;
center=center-1e-10;
handles.mydata.center=center*1e9;
guidata(hObject, handles);
plots(hObject, handles);



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
center=handles.mydata.center.*1e-9;
center=center+1e-10;
handles.mydata.center=center*1e9;
guidata(hObject, handles);
plots(hObject, handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.mydata.pts=[];
hplot=handles.mydata.hplot;
hweight=handles.mydata.hweight;
refsplot=handles.mydata.refsplot;
strainmin=handles.mydata.strainmin;
strainmax=handles.mydata.strainmax;
handles.mydata.strains=0;
set(hplot,'xdata',[],'ydata',[]);
set(hweight,'xdata',[],'ydata',[]);
set(handles.axes1,'YLim',[strainmin strainmax]);
set(handles.axes1,'XLim',[0 handles.mydata.l]);

if ~isempty(handles.mydata.refstrain)
   plotrefstrain(hObject,handles);
else
    set(refsplot,'xdata',[],'ydata',[]);
end
guidata(hObject, handles);

function edit_cwl_Callback(hObject, eventdata, handles)
% hObject    handle to edit_cwl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_cwl as text
%        str2double(get(hObject,'String')) returns contents of edit_cwl as a double
cwl=str2double(get(hObject,'String'));
handles.mydata.lambdab=cwl;
guidata(hObject,handles);
plots(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_cwl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_cwl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
chk=get(hObject,'value');
handles.mydata.apo=chk;
guidata(hObject,handles);



function edit_dneff_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dneff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dneff as text
%        str2double(get(hObject,'String')) returns contents of edit_dneff as a double
a_dneff=str2double(get(hObject,'String'));
handles.mydata.a_dneff=a_dneff;
guidata(hObject,handles);
plots(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_dneff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dneff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ag_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ag as text
%        str2double(get(hObject,'String')) returns contents of edit_ag as a double
ag=str2double(get(hObject,'String'));
handles.mydata.ag=ag;
guidata(hObject,handles);
plots(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_ag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton_snap.
function pushbutton_snap_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_snap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

calspcplot = handles.mydata.calspcplot;% handle of cal spectrum 
refspcplot = handles.mydata.refspcplot;% handle of ref spectrum
    set(calspcplot, 'XData', [], 'YData', [], 'color', 'b', 'LineStyle', '-')
    set(refspcplot, 'XData', [], 'YData', [], 'color', 'r', 'LineStyle', '--')
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function pushbutton_snap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_snap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function edit_v_Callback(hObject, eventdata, handles)
% hObject    handle to edit_v (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_v as text
%        str2double(get(hObject,'String')) returns contents of edit_v as a double
v=str2double(get(hObject,'String'));
handles.mydata.v=v;
guidata(hObject,handles);
plots(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_v_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_v (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_pe_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pe as text
%        str2double(get(hObject,'String')) returns contents of edit_pe as a double
pe=str2double(get(hObject,'String'));
handles.mydata.pe=pe;
guidata(hObject,handles);
plots(hObject, handles);

function edit_N_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pe as text
%        str2double(get(hObject,'String')) returns contents of edit_pe as a double
N=str2double(get(hObject,'String'));
handles.mydata.N=N;
guidata(hObject,handles);
plots(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_pe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
flag=handles.mydata.refspecflag;
flag=~flag;
handles.mydata.refspecflag=flag;
popstr=get(handles.popupmenu1,'string');
value=get(handles.popupmenu1,'value');
refspec=evalin('base',popstr{value});
if size(refspec,2)==2
    refspec = refspec';
end
handles.mydata.refspec = refspec;
guidata(hObject,handles);
plotrefspec(hObject, handles);




% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
S=evalin('base','whos');
VarNames=char(S.name);
if isempty(VarNames)
    VarNames='No Variables...';
    popstr=VarNames;
else
    k=1;
    for ii=1:size(VarNames,1)
        if (S(ii).size(2)==2&&S(ii).size(1)>100)||(S(ii).size(1)==2&&S(ii).size(2)>100)
            popstr{k,:}=VarNames(ii,:);
            k=k+1;
        end
    end
    if k==1
    VarNames='Wrong Variables Format...';
    popstr=VarNames;
    end
end
set(hObject,'string',popstr);

popstr=get(hObject,'string');

value=get(hObject,'value');
spec=evalin('base',popstr{value});
if size(spec,2)==2
    spec = spec';
end
handles.mydata.refspec=spec;
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
S=evalin('base','whos');
VarNames=char(S.name);
if isempty(VarNames)
    VarNames='No Variables...';
    popstr=VarNames;
else
    k=1;
    for ii=1:size(VarNames,1)
        if (S(ii).size(2)==2&&S(ii).size(1)>100)||(S(ii).size(1)==2&&S(ii).size(2)>100)
            popstr{k,:}=VarNames(ii,:);
            k=k+1;
        end
    end
    if k==1
    VarNames='Wrong Variables Format...';
    popstr=VarNames;
    end
end
set(hObject,'string',popstr);
guidata(hObject,handles);



function edit_windowcenter_Callback(hObject, eventdata, handles)
% hObject    handle to edit_windowcenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_windowcenter as text
%        str2double(get(hObject,'String')) returns contents of edit_windowcenter as a double
windowcenter=str2double(get(hObject,'string'));
handles.mydata.center=windowcenter;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_windowcenter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_windowcenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_length_Callback(hObject, eventdata, handles)
% hObject    handle to edit_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_length as text
%        str2double(get(hObject,'String')) returns contents of edit_length as a double
L=str2double(get(hObject,'string'));
handles.mydata.l=L;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edit_N_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_N (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    
% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hplot=handles.mydata.hplot;
hweight=handles.mydata.hweight;
pts=handles.mydata.pts;
temppts=handles.mydata.temppts;
l=handles.mydata.l;
fastprev=handles.mydata.fastprev;
strainmin= handles.mydata.strainmin;
strainmax= handles.mydata.strainmax;
temppt = handles.axes1.CurrentPoint;

if temppt(1,1) >= l
    temppt(1,1) = l;
elseif temppt(1,1) <= 0
    temppt(1,1) = 0;
end
if temppt(1,2) >= strainmax
    temppt(1,2) = strainmax;
elseif temppt(1,2) <= strainmin
    temppt(1,2) = strainmin;
end
if ~isempty(pts)
    if(any(pts(:,1)==temppt(1,1)))%有重复的x坐标点
        pts = [pts(1:end-1,:);temppt(1,1:2)];
    else
        pts = [pts; temppt(1,1:2)];
    end
else
    pts = [pts; temppt(1,1:2)];
end

points = sortrows(pts);
set(hplot, 'xdata', points(:,1), 'ydata', points(:,2), 'color', 'b','Marker', '*', 'LineStyle', '-')
set(hweight,'xdata',[],'ydata',[])
set(handles.axes1,'YLim',[strainmin strainmax]);
set(hObject, 'WindowButtonMotionFcn','')
set(hObject, 'WindowButtonUpFcn','')
if size(pts,1)>1
    [x, weight, pts1] = LinearInterpolation(pts,handles);
    set(hweight,'xdata',x,'ydata',weight, 'color', 'magenta', 'Marker', '.', 'LineStyle', '-')
    set(hplot,'xdata',pts1(:,1),'ydata',pts1(:,2))
    handles.mydata.strains = weight;
end
handles.mydata.axes1btd = 0;
handles.mydata.pts = pts;
handles.mydata.temppts = temppts;
handles.mydata.points = points;
handles.mydata.temppt = temppt;
if fastprev
    plots(hObject,handles);
end

guidata(hObject,handles);



        




% --- Executes on mouse motion over figure - except title and menu.
% --- This fcn is used to smooth drag animation
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hplot=handles.mydata.hplot;
hweight=handles.mydata.hweight;
pts=handles.mydata.pts;
strainmin= handles.mydata.strainmin;
strainmax= handles.mydata.strainmax;

l=handles.mydata.l;

temppt = handles.axes1.CurrentPoint;
        if temppt(1,1) >= l
            temppt(1,1) = l;
        elseif temppt(1,1) <= 0
            temppt(1,1) = 0;
        end
        if temppt(1,2) >= strainmax
            temppt(1,2) = strainmax;
        elseif temppt(1,2) <= strainmin
            temppt(1,2) = strainmin;
        end
temppts = [pts; temppt(1,1:2)];
points = sortrows(temppts);
set(hplot, 'xdata', points(:,1), 'ydata', points(:,2), 'color', 'b','Marker', '*', 'LineStyle', '-')
set(hweight,'xdata',[],'ydata',[])
set(handles.axes1,'YLim',[strainmin strainmax]);

handles.mydata.pts = pts;
handles.mydata.temppts = temppts;
handles.mydata.points = points;
handles.mydata.temppt = temppt;
guidata(hObject,handles);

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hplot = handles.mydata.hplot;
hweight = handles.mydata.hweight;
pts = handles.mydata.pts;
temppts = handles.mydata.temppts;
points = handles.mydata.points;
temppt = handles.mydata.temppt;
axes1btd = handles.mydata.axes1btd;% mouse click in axes1 area
l = handles.mydata.l;
strainmin= handles.mydata.strainmin;
strainmax= handles.mydata.strainmax;
if strcmp(get(hObject, 'SelectionType'),'normal') % mouse left click
temppt = handles.axes1.CurrentPoint;
        if temppt(1,1) >= l
            temppt(1,1) = l;
        elseif temppt(1,1) <= 0
            temppt(1,1) = 0;
        end
        if temppt(1,2) >= strainmax
            temppt(1,2) = strainmax;
        elseif temppt(1,2) <= strainmin
            temppt(1,2) = strainmin;
        end
    temppts = [pts; temppt(1,1:2)];
    points = sortrows(temppts);    
    set(hplot, 'xdata', points(:,1), 'ydata', points(:,2), 'color', 'b','Marker', '*', 'LineStyle', '-');
    set(hweight,'xdata',[],'ydata',[]);
    set(handles.axes1,'YLim',[strainmin strainmax]);
    set(hObject, 'WindowButtonMotionFcn',@(hObject,eventdata)strain_test_v1('figure1_WindowButtonMotionFcn',hObject,eventdata,guidata(hObject)))
        set(hObject, 'WindowButtonUpFcn',@(hObject,eventdata)strain_test_v1('figure1_WindowButtonUpFcn',hObject,eventdata,guidata(hObject)))
elseif strcmp(get(hObject, 'SelectionType'),'alt') % mouse right click
    temppt = handles.axes1.CurrentPoint;
        if temppt(1,1) >= l
            temppt(1,1) = l;
        elseif temppt(1,1) <= 0
            temppt(1,1) = 0;
        end
    pts = FindNearestPointAndRemove(pts, temppt(1,1:2));            
    temppts = [pts; temppt(1,1:2)];
    points = sortrows(temppts);
    set(hplot, 'xdata', points(:,1), 'ydata', points(:,2), 'color', 'b','Marker', '*', 'LineStyle', '-')
    set(hweight,'xdata',[],'ydata',[])
    set(handles.axes1,'YLim',[strainmin strainmax]);
    set(hObject, 'WindowButtonMotionFcn',@(hObject,eventdata)strain_test_v1('figure1_WindowButtonMotionFcn',hObject,eventdata,guidata(hObject)))
        set(hObject, 'WindowButtonUpFcn',@(hObject,eventdata)strain_test_v1('figure1_WindowButtonUpFcn',hObject,eventdata,guidata(hObject)))      
end
handles.mydata.axes1btd = axes1btd;
handles.mydata.pts = pts;
handles.mydata.temppts = temppts;
handles.mydata.points = points;
handles.mydata.temppt = temppt;


guidata(hObject,handles);


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%   Key: name of the key that was pressed, in lower case
%   Character: character interpretation of the key(s) that was pressed
%   Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
hplot = handles.mydata.hplot;
hweight = handles.mydata.hweight;
pts = handles.mydata.pts;
temppts = handles.mydata.temppts;
points = handles.mydata.points;
temppt = handles.mydata.temppt;

if eventdata.Character == '`' % 删除前一点
    if isempty(pts)
        return
    end
    pts = pts(1:length(pts)-1,:);
    points = sortrows(pts);
    set(hplot,'xdata',points(:,1),'ydata',points(:,2))
    [x, weight, pts1] = LinearInterpolation(points,handles);
    set(hweight,'xdata',x,'ydata',weight, 'color', 'magenta', 'Marker', '.', 'LineStyle', '-')
 
    handles.mydata.strains = weight;
    
    
% elseif eventdata.Character == '2' % 删除所有点
%     pts = [];
%     set(hplot,'xdata',[],'ydata',[])
%     set(hweight,'xdata',[],'ydata',[])
%     
% elseif eventdata.Character == '3' % 删除拟合线
%     set(hweight,'xdata',[],'ydata',[])
    

% elseif eventdata.Character == 13 % 回车，线性插值数据
%     [x, weight, pts] = LinearInterpolation(pts,handles);
%     set(hweight,'xdata',x,'ydata',weight, 'color', 'r', 'Marker', '.', 'LineStyle', '-')
%     set(hplot,'xdata',pts(:,1),'ydata',pts(:,2))
end

handles.mydata.pts = pts;
handles.mydata.temppts = temppts;
handles.mydata.points = points;
handles.mydata.temppt = temppt;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject, 'WindowButtonMotionFcn','')
set(hObject, 'WindowButtonDownFcn',@(hObject,eventdata)strain_test_v1('figure1_WindowButtonDownFcn',hObject,eventdata,guidata(hObject)));
set(hObject, 'WindowButtonUpFcn','')
% set(hObject, 'WindowButtonUpFcn','');


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%   Key: name of the key that was pressed, in lower case
%   Character: character interpretation of the key(s) that was pressed
%   Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on selection change in popupmenu3.

function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3

S=evalin('base','whos');
VarNames=char(S.name);
if isempty(VarNames)
    VarNames='No Variables...';
    popstr=VarNames;
else
    k=1;
    for ii=1:size(VarNames,1)
        if (S(ii).size(2)==1&&S(ii).size(1)>1)||(S(ii).size(1)==1&&S(ii).size(2)>1)
            popstr{k,:}=VarNames(ii,:);
            k=k+1;
        end
    end
    if k==1
    VarNames='Wrong Variables Format...';
    popstr=VarNames;
    end
end
set(hObject,'string',popstr);
value=get(hObject,'value');
refstrain=evalin('base',popstr{value});
if size(refstrain,2)==1
    refstrain = refstrain';
end
handles.mydata.refstrain = refstrain;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
S=evalin('base','whos');
VarNames=char(S.name);
if isempty(VarNames)
    VarNames='No Variables...';
    popstr=VarNames;
else
    k=1;
    for ii=1:size(VarNames,1)
        if (S(ii).size(2)==1&&S(ii).size(1)>1)||(S(ii).size(1)==1&&S(ii).size(2)>1)
            popstr{k,:}=VarNames(ii,:);
            k=k+1;
        end
    end
    if k==1
    VarNames='Wrong Variables Format...';
    popstr=VarNames;
    end
end
set(hObject,'string',popstr);
guidata(hObject,handles);



function edit_strainmin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_strainmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_strainmin as text
%        str2double(get(hObject,'String')) returns contents of edit_strainmin as a double
handles.mydata.strainmin=str2double(get(hObject, 'String'));
set(handles.axes1,'YLim',[handles.mydata.strainmin handles.mydata.strainmax]);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_strainmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_strainmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_strainmax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_strainmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_strainmax as text
%        str2double(get(hObject,'String')) returns contents of edit_strainmax as a double
handles.mydata.strainmax=str2double(get(hObject, 'String'));
set(handles.axes1,'YLim',[handles.mydata.strainmin handles.mydata.strainmax]);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_strainmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_strainmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in checkbox_fastprev.
function checkbox_fastprev_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_fastprev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_fastprev

handles.mydata.fastprev=get(hObject,'Value');
if get(hObject,'Value')
    set(handles.edit_N,'Enable','off');
    set(handles.edit_N,'String',num2str(21));
    handles.mydata.N=21;
else
    set(handles.edit_N,'Enable','on');
end    
guidata(hObject,handles);


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
flag=handles.mydata.refstrainflag;
flag=~flag;
handles.mydata.refstrainflag=flag;

popstr=get(handles.popupmenu3,'string');
value=get(handles.popupmenu3,'value');
refstrain=evalin('base',popstr{value});
if size(refstrain,2)==1
    refstrain = refstrain';
end
handles.mydata.refstrain = refstrain;
guidata(hObject,handles);
plotrefstrain(hObject, handles);

    


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
strains=handles.mydata.strains.*1e-6;
assignin('base','STRAIN',strains);


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% strains=handles.mydata.strains.*1e-6;
% center=handles.mydata.center.*1e-9;
% ag=handles.mydata.ag;
% a_dneff=handles.mydata.a_dneff;
% v=handles.mydata.v;
% pe=handles.mydata.pe;
% lambdab=handles.mydata.lambdab.*1e-9;
% l=handles.mydata.l;
% N=handles.mydata.N;
% neff = handles.mydata.neff;

calspcplot = handles.mydata.calspcplot;% handle of cal spectrum 


% para = struct( ...
%     'center',center, ...
%     'ag',ag, ...
%     'a_dneff',a_dneff, ...
%     'v',v, ...
%     'pe',pe, ...
%     'lambdab',lambdab, ...
%     'l',l, ...
%     'N',N, ...
%     'neff',neff);
% [R,L]=cal_spec_new_v4('strain',strains,'L',l,'v',v,'pe',pe,'N',N,'a_deltaN',a_dneff,...
%     'Neff',neff,'range',[center-1e-9 center+1e-9],'ag',ag,'LambdaD',lambdab);
% assignin('base','PARAS',para);
assignin('base','SPEC',[calspcplot.XData',calspcplot.YData']);



function edit_neff_Callback(hObject, eventdata, handles)
% hObject    handle to edit_neff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_neff as text
%        str2double(get(hObject,'String')) returns contents of edit_neff as a double
neff=str2double(get(hObject,'String'));
handles.mydata.neff=neff;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_neff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_neff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
handles.mydata.testflag=get(hObject,'Value');
guidata(hObject,handles);


% --- Executes on button press in checkbox_smooth.
function checkbox_smooth_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_smooth
% calspcplot=handles.mydata.calspcplot;
% sfac=str2num(handles.edit_smooth.String);
% Ydata=calspcplot.YData;
% if get(hObject,'value')
%     set(calspcplot, 'YData',smooth(Ydata,sfac));
% else
%     plots(hObject, handles);
% end
%     
    


function edit_smooth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_smooth as text
%        str2double(get(hObject,'String')) returns contents of edit_smooth as a double


% --- Executes during object creation, after setting all properties.
function edit_smooth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
contents = cellstr(get(hObject,'String'));
handles.mydata.apofun= contents{get(hObject,'Value')};
plots(hObject,handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
