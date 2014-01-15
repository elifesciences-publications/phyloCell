%set the colors of the displayed channels
%input: the matrix data each chanel has a row in this matrix(RGBLoHiAl)
%       input images (not normalized)
%output: the values for each channel (RGBLoHiAl) in a form of matrix
function varargout = phy_setColorsGui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @phy_setColorsGui_OpeningFcn, ...
                   'gui_OutputFcn',  @phy_setColorsGui_OutputFcn, ...
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


% --- Executes just before phy_setColorsGui is made visible.
function phy_setColorsGui_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for phy_setColorsGui
handles.output = hObject;
%for debug only
% global segmentation;
% dispimg=segmentation.displayImage;
% handles.data=segmentation.colorData;
%----

handles.data=varargin{1};%first argument: colors and thresh hold
dispimg=varargin{2};% second argument: the images displayed.
handles.img=dispimg;
load phy_colormap; %the color map of the colorbar
handles.myColormaps=mycmap;

handles.chanels(1)=1;%first channel to display is channel 1

handles.pow=4; %power at wich the value of the slider will be rised(middle value = 0.5^4=0.0625)

%build the colorbar to chose the colors
cb=zeros(1,64,3);
cb(:,:,1)=mycmap(:,1);
cb(:,:,2)=mycmap(:,2);
cb(:,:,3)=mycmap(:,3);
imshow(cb,'parent',handles.axes2,'InitialMagnification','fit');
handles.hline=line([1 1],[0 3],'parent',handles.axes2,'color','w','linewidth',3); %make a line to show the exact color

handles.himg=ones(1,size(dispimg,3));%handles to dispaly images

handles.himg=imshow(dispimg(:,:,1),'parent',handles.axes1,'InitialMagnification','fit');%first image to display is image 1
%handles.hfluo=[];

%initialize the listbox
set(handles.listbox_Channels,'value',1);%select first value
str={};
for i=1:size(dispimg,3)
    str=[str;['channel',num2str(i)]];
end

set(handles.listbox_Channels,'string',str);%write the channels(1 2 3...)

%set the textx of displayed channels tu first channel
set(handles.text_Channels,'string',str(1));

%initialize the sliders
data=handles.data(1,:);
set(handles.slider_thresh_low,'Value',data(4)^(1/handles.pow));
set(handles.slider_thresh_high,'Value',data(5)^(1/handles.pow));
set(handles.slider_transparance,'Value',min(data(6),1));
if data(6)==2
    set(handles.checkbox_variable_transparence,'value',1);
else
    set(handles.checkbox_variable_transparence,'value',0);
end

%initialize slider collor
rgb=zeros(1,1,3);
rgb(:)=data([1 2 3]);
sval=rgb2ind(rgb,handles.myColormaps)+1;
set(handles.slider_color,'Value',sval);

handles=changeDisp(handles,'refresh');

guidata(hObject, handles);% Update handles structure


% UIWAIT makes phy_setColorsGui wait for user response (see UIRESUME)
uiwait(handles.figure1);
uiwait(handles.figure1);
%delete(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = phy_setColorsGui_OutputFcn(hObject, eventdata, handles) 

varargout{1}=handles.data;
 varargout{2}=handles.chanels;
 delete(handles.figure1);
 



% --- Executes on slider movement.
function slider_color_Callback(hObject, eventdata, handles)
handles=changeDisp(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function slider_color_CreateFcn(hObject, eventdata, handles)


% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_thresh_high_Callback(hObject, eventdata, handles)

handles=changeDisp(handles);


guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function slider_thresh_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_thresh_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_thresh_low_Callback(hObject, eventdata, handles)
handles=changeDisp(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function slider_thresh_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_thresh_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function slider_transparance_Callback(hObject, eventdata, handles)
handles=changeDisp(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function slider_transparance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_transparance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in listbox_Channels.
function listbox_Channels_Callback(hObject, eventdata, handles)

butonType=get(handles.figure1,'SelectionType');
chval = get(handles.listbox_Channels,'Value');
chanels=handles.chanels;
data=handles.data;
if strcmp(butonType,'open') %if double click
    if any(chanels==chval) % if already dispayed 
        chanels(chanels==chval)=[];
        %delete(handles.himg(chval)); %undispayed it
        
        if numel(chanels)==0
            if ishandle(handles.himg)
               delete(handles.himg); 
            end        
        else
        
        img=handles.img(:,:,chval);
        img=imadjust(img,data(chval,[4 5]),[]);
        atemp=[size(img) 3];
        imgRGBsum=uint16(zeros(atemp));
        data=handles.data;
        
        warning off all;
        for i=1:length(chanels)
            cha=chanels(i);
            
             imgtemp=handles.img(:,:,cha);
             imgtemp=imadjust(imgtemp,[data(cha,4) data(cha,5)],[]);

             RGBtemp=data(cha,[1 2 3]);
             rat=data(cha,6);
             imgRGBtemp=cat(3,imgtemp*RGBtemp(1)*rat,imgtemp*RGBtemp(2)*rat,imgtemp*RGBtemp(3)*rat);
             imgRGBsum=imgRGBsum+imgRGBtemp;
        end
        
        warning on all;
        %'ok1'
        %a=handles.hfluo
        %ishandle(a)
        if ishandle(handles.himg)
          %  'ok'
           set(handles.himg,'CDAta',imgRGBsum);
        else
         % 'ok'
        handles.himg=imshow(imgRGBsum,'Parent',handles.axes1,'InitialMagnification','fit'); %display it
        end
        
        
        hold(handles.axes1,'off');
        end
        
    else %if not displayed
        chanels=[chanels chval];
        hold(handles.axes1,'on');

        
        img=handles.img(:,:,chval);
        img=imadjust(img,data(chval,[4 5]),[]);
        atemp=[size(img) 3];
        imgRGBsum=uint16(zeros(atemp));
        data=handles.data;
        
        warning off all;
        for i=1:length(chanels)
            cha=chanels(i);
            
             imgtemp=handles.img(:,:,cha);
             imgtemp=imadjust(imgtemp,[data(cha,4) data(cha,5)],[]);

             RGBtemp=data(cha,[1 2 3]);
             rat=data(cha,6);
             imgRGBtemp=cat(3,imgtemp*RGBtemp(1)*rat,imgtemp*RGBtemp(2)*rat,imgtemp*RGBtemp(3)*rat);
             imgRGBsum=imgRGBsum+uint16(imgRGBtemp);
        end
        
        warning on all;
        %'ok1'
        %a=handles.hfluo
        %ishandle(a)
        if ishandle(handles.himg)
           % 'ok'
           set(handles.himg,'CDAta',imgRGBsum);
        else
         % 'ok'
        handles.himg=imshow(imgRGBsum,'Parent',handles.axes1,'InitialMagnification','fit'); %display it
        %fla=sum(imgRGBsum,3);
 %
        %fla=65535*sum(imgRGBsum,3);
        %fla=fla/max(max(fla));
        
        %[min(min(fla))/65535;max(max(fla))/65535]
        
        %fla=imadjust(fla,[max(0,min(min(fla))/65535);min(1,max(max(fla))/65535)],[0;1]);
        
       % min(min(img)),max(max(img))
        
        %set(handles.hfluo,'AlphaData',fla);
        end
        
        
        hold(handles.axes1,'off');
    end

end
%refresh text
str=get(handles.listbox_Channels,'String');
set(handles.text_Channels,'string',{str{chanels}});

%save new channels to memory
handles.chanels=chanels;
data=handles.data(chval,:);
%actualize the sliders


set(handles.slider_thresh_low,'Value',data(4)^(1/handles.pow));
set(handles.slider_thresh_high,'Value',data(5)^(1/handles.pow));
set(handles.slider_transparance,'Value',min(data(6),1));
%set the variable transparence
if data(6)==2
    set(handles.checkbox_variable_transparence,'value',1);
else
    set(handles.checkbox_variable_transparence,'value',0);
end

%actuallize the color bar
rgb=zeros(1,1,3);
rgb(:)=data([1 2 3]);
sval=rgb2ind(rgb,handles.myColormaps)+1;
set(handles.slider_color,'Value',sval);

handles=changeDisp(handles);

%update handles
guidata(handles.figure1, handles);


% --- Executes during object creation, after setting all properties.
function listbox_Channels_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
handles=changeDisp(handles);
guidata(hObject,handles);


function handles=changeDisp(handles,refresh)
%function called each time the mose moves

chanels=handles.chanels;

tresh_low=get(handles.slider_thresh_low,'Value');
tresh_high=get(handles.slider_thresh_high,'Value');

if tresh_low>tresh_high %check if the low value smaller than the high , else error in imadjust
    set(handles.slider_thresh_low,'Value',tresh_high-0.001);
    tresh_low=tresh_high-0.001;
end

tresh_low=tresh_low^(handles.pow);%rescale the sliders values
tresh_high=tresh_high^(handles.pow);
%get values from alpha and color slider 
alpha=get(handles.slider_transparance,'Value');
col=round(get(handles.slider_color,'Value'));
color=handles.myColormaps(col,:);
ch=get(handles.listbox_Channels,'Value');

if get(handles.checkbox_variable_transparence,'value');
    alpha=2;
end
datanew=[color,tresh_low,tresh_high,alpha];

%update the texts and the colors.
set(handles.edit_color,'string',num2str(color,'%0.1f '));
set(handles.edit_color,'backgroundcolor',color);
set(handles.hline,'Xdata',[col,col]);
set(handles.edit_transparance,'string',num2str(alpha));
set(handles.edit_thresh_high,'string',num2str(tresh_high));
set(handles.edit_thresh_low,'string',num2str(tresh_low));


data=handles.data;
%test new changes or 'refresh'


if any(data(ch,:)~=datanew)||(nargin==2)
    %if ishandle(handles.himg(ch))
 
        handles.data(ch,:)=datanew;
 
        img=handles.img(:,:,ch);
        img=imadjust(img,datanew([4 5]),[]);

        
        RGB=datanew([1 2 3]);
        imgRGB=cat(3,img*RGB(1),img*RGB(2),img*RGB(3));
        
        imgRGBsum=uint16(zeros(size(imgRGB)));
        chanels=handles.chanels;
        
        warning off all;
        for i=1:length(chanels)
            cha=chanels(i);
             
             imgtemp=uint16(handles.img(:,:,cha));
             imgtemp=imadjust(imgtemp,[data(cha,4) data(cha,5)],[]);
 
             RGBtemp=handles.data(cha,[1 2 3]);
             
             rat=handles.data(cha,6);
             imgRGBtemp=cat(3,imgtemp*RGBtemp(1)*rat,imgtemp*RGBtemp(2)*rat,imgtemp*RGBtemp(3)*rat);
             
             imgRGBsum=imgRGBsum+imgRGBtemp;
        end 
        
        warning on all;
        
        if ishandle(handles.himg)
        set(handles.himg,'CDAta',imgRGBsum);
        
       % fla=65535*sum(imgRGBsum,3);
       % fla=fla/max(max(fla));
        
        %[min(min(fla))/65535;max(max(fla))/65535]
        
        %fla=imadjust(fla,[max(0,min(min(fla))/65535);min(1,max(max(fla))/65535)],[0;1]);
        
       % min(min(img)),max(max(img))
        
       % set(handles.hfluo,'AlphaData',fla);
        
        end
        
%         if alpha~=2
%             set(handles.himg(ch),'AlphaData',datanew(6));
%         else
%             set(handles.himg(ch),'AlphaData',img);
%         end
    %end
end


%set the transparence to all displayed channels
% for i=chanels
%     
%     
%     %first channel has always transparence of 1
%     if i==chanels(1)
%         if ishandle(handles.himg(i))
%             set(handles.himg(i),'AlphaData',1);
%         end
%     else
%         if i~=ch %the others channels in the display window
%             if ishandle(handles.himg(i))
%                 if data(i,6)~=2
%                     set(handles.himg(i),'AlphaData',data(i,6));
%                 else %if variable transparence
%                     img=handles.img(:,:,i);
%                     img=imadjust(img,handles.data(i,[4 5]),[]); %calculate the image for each channel
%                     set(handles.himg(i),'AlphaData',img);
%                 end
%             end
%         end;
%     end
% end


guidata(handles.figure1, handles);




% --- Executes on button press in pushbutton_crop.
function pushbutton_crop_Callback(hObject, eventdata, handles)
%crop function to go faster 
%use imcrop
axes(handles.axes1);
pos=handles.chanels(1);

[I2,rect] =imcrop(handles.himg(pos));

handles.himg(pos)=imshow(I2,'Parent',handles.axes1,'InitialMagnification','fit');
hold(handles.axes1,'on')
for i=2:length(handles.chanels)
    pos=handles.chanels(i);
    handles.himg(pos)=imshow(I2,'Parent',handles.axes1,'InitialMagnification','fit');
end
hold(handles.axes1,'off');

for i=1:size(handles.img,3)
    I(:,:,i)=imcrop(handles.img(:,:,i),rect);
end

handles.img=I;%change all the input imaes

handles=changeDisp(handles,1);

guidata(hObject, handles);


% --- Executes on button press in pushbutton_Channel_OK.
function pushbutton_Channel_OK_Callback(hObject, eventdata, handles)
%read all the values end exit;
tresh_low=get(handles.slider_thresh_low,'Value');
tresh_low=tresh_low^(handles.pow);
tresh_high=get(handles.slider_thresh_high,'Value');
tresh_high=tresh_high^(handles.pow);
alpha=get(handles.slider_transparance,'Value');
col=round(get(handles.slider_color,'Value'));
color=handles.myColormaps(col,:);
ch=get(handles.listbox_Channels,'Value');
if get(handles.checkbox_variable_transparence,'value');
    alpha=2;
end

datanew=[color,tresh_low,tresh_high,alpha];
handles.data(ch,:)=datanew;
guidata(hObject, handles);

uiresume(handles.figure1);%to call the output funtion and exit
uiresume(handles.figure1);


% --- Executes on button press in checkbox_variable_transparence.
function checkbox_variable_transparence_Callback(hObject, eventdata, handles)

handles=changeDisp(handles);
guidata(hObject, handles);




function edit_color_Callback(hObject, eventdata, handles)
col=zeros(1,1,3);
col(:)=str2num(get(hObject,'String'));
colind=rgb2ind(col,handles.myColormaps)+1;
set(handles.slider_color,'value',colind);
handles=changeDisp(handles);
guidata(hObject, handles);


function edit_thresh_low_Callback(hObject, eventdata, handles)
val=str2double(get(hObject,'String'));
set(handles.slider_thresh_low,'value',val);
handles=changeDisp(handles);
guidata(hObject, handles);



function edit_thresh_high_Callback(hObject, eventdata, handles)
val=str2double(get(hObject,'String'));
set(handles.slider_thresh_high,'value',val);
handles=changeDisp(handles);
guidata(hObject, handles);  



function edit_transparance_Callback(hObject, eventdata, handles)
val=str2double(get(hObject,'String'));
set(handles.slider_transparance,'value',val);
handles=changeDisp(handles);
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(hObject,'waitstatus'),'waiting')
 uiresume(hObject);
else
    delete(hObject);
end