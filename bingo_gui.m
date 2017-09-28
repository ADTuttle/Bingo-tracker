function varargout = bingo_gui(varargin)
% BINGO_GUI MATLAB code for bingo_gui.fig
%     Running this will open an interface that will play and tabulate bingo
%     games.
%     Play, plays games until either pause is pressed or the number of
%     boards is modified.
%     
%     The games are tallied continuously and currently don't reset
%     when the number of boards changes.
% 
%     Unless paused (or number of boards changed) the same 1000 boards
%     will be used continuously.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bingo_gui

% Last Modified by GUIDE v2.5 28-Sep-2017 10:27:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bingo_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @bingo_gui_OutputFcn, ...
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


% --- Executes just before bingo_gui is made visible.
function bingo_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bingo_gui (see VARARGIN)

% Choose default command line output for bingo_gui
handles.output = hObject;
    num_cards=1000;
    stats.rounds=zeros(75,1);
    stats.hor=0;
    stats.vert=0;
    stats.diag=0;
    stats.heatmap=zeros(5,5);
    stats.cards=num_cards;
    stats.games=0;
    handles.stats=stats;
    handles.num_cards=num_cards;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bingo_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bingo_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in play_button.
function play_button_Callback(hObject, eventdata, handles)
% hObject    handle to play_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        num_cards=handles.num_cards;
        if get(hObject,'userdata')>1
           num_cards=get(hObject,'userdata');
        end
        Cards=cell(num_cards,2);
        for i=1:num_cards
           Cards{i,1}=generate_card(); 
           Cards{i,2}=zeros(5,5);
        end
        set(handles.play_button,'userdata',0);
        while(true)
            if get(hObject,'userdata')>0
                break;
            end
            handles=update_gui(hObject,handles,Cards);
            drawnow
            guidata(hObject,handles)
%             pause(.01);
        end
        
        
function handles=update_gui(hObject,handles,Cards)
            stats=handles.stats;
            [~,card,rounds,type_win]=play_game(Cards);
        stats.rounds(rounds)=stats.rounds(rounds)+1;
%         disp(card)
%         disp(type_win)
        if strcmp(type_win,'h')
            stats.hor=stats.hor+1;
        end
        if strcmp(type_win,'v')
            stats.vert=stats.vert+1;
        end
        if strcmp(type_win,'d')
           stats.diag=stats.diag+1; 
        end
        stats.heatmap=stats.heatmap+card;
        stats.games=stats.games+1;
        
        set(handles.gamebox,'String',['Games: ',num2str(stats.games)]);
        
        ax1=handles.vert_plot;
        bar(ax1,[stats.hor,stats.vert,stats.diag]/stats.games)
        ylim(ax1,[0,1]);
        xticklabels(ax1,{'Horizontal','Vertical','Diagonal'})
        
        ax2=handles.round_hist;
        bar(ax2,stats.rounds(1:30)/stats.games)
        ylim(ax2,[0,1]);
        xlim(ax2,[0,30]);
        xlabel(ax2,'Number of Rounds');
        
        ax3=handles.heatmap;
        bar3(ax3,stats.heatmap/stats.games);
        title(ax3,'Winning Dist')
        
        
        handles.stats=stats;
            

function card=generate_card()
    card=zeros(5,5);
    for i=1:5
        card(:,i)=randperm(15,5)+(i-1)*15;
    end
    
function [winner,card,rounds,type_win]=play_game(Cards)
        [num_cards,~]=size(Cards);
        no_winner=true;
        draw_pile=randperm(75);
        round=1;
        while no_winner
            %Draw next lot
            pick=draw_pile(round);
            
            col=ceil(pick/15);
            %         Fill in the card
            for i=1:num_cards
                row=find(Cards{i,1}(:,col)==pick);
                if ~isempty(row)
                    Cards{i,2}(row,col)=1;
                end
            end
            %         Check for a winner
            for i=1:num_cards
                if ~isempty(find(sum(Cards{i,2},1)==5,1))
                    no_winner=false;
                    winner=i;
                    card=Cards{i,2};
                    rounds=round;
                    type_win='v';
                end
                if~isempty(find(sum(Cards{i,2},2)==5,1))
                    no_winner=false;
                    winner=i;
                    card=Cards{i,2};
                    rounds=round;
                    type_win='h';
                end
                %            Check diagonal
                if(sum(diag(Cards{i,2})==5))
                    no_winner=false;
                    winner=i;
                    card=Cards{i,2};
                    rounds=round;
                    type_win='d';
                end
                %            And anti-diagonal
                if(sum(Cards{i,2}(5 : 5-1 : end-1))==5)
                    no_winner=false;
                    winner=i;
                    card=Cards{i,2};
                    rounds=round;
                    type_win='d';
                end
            end
            round=round+1;
        end


% --- Executes during object creation, after setting all properties.
function vert_plot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vert_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate vert_plot


% --- Executes on button press in Pause.
function Pause_Callback(hObject, eventdata, handles)
% hObject    handle to Pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.play_button,'userdata',1);
guidata(hObject,handles);
drawnow();



function card_count_Callback(hObject, eventdata, handles)
% hObject    handle to card_count (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of card_count as text
%        str2double(get(hObject,'String')) returns contents of card_count as a double
num_cards=str2double(get(hObject,'String'));
set(handles.play_button,'userdata',num_cards);
guidata(handles.play_button,handles);
drawnow();


% --- Executes during object creation, after setting all properties.
function card_count_CreateFcn(hObject, eventdata, handles)
% hObject    handle to card_count (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
