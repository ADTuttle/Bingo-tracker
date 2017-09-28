function stats=play_bingo(num_cards,num_games)
% Inputs: num_cards is the number of cards that are played.
%         num_games is the number of games
% Output: stats contains.
%         rounds: number of wins on that round
%         hor: number of horizontal wins
%         vert: number of vertical wins.
%         diag: number of diagonal wins
%         heatmap: The number of times any number was chosen on the winning
%         board. (for num_games=1 this is the checked off winning board)
    stats.rounds=zeros(75,1);
    stats.hor=0;
    stats.vert=0;
    stats.diag=0;
    stats.heatmap=zeros(5,5);
    stats.cards=num_cards;
    stats.games=num_games;
    for i=1:num_games
        disp(['Game num:',num2str(i)])
        Cards=cell(num_cards,2);
        for i=1:num_cards
           Cards{i,1}=generate_card(); 
           Cards{i,2}=zeros(5,5);
        end
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
        
    end

end


function card=generate_card()
    card=zeros(5,5);
    
    for i=1:5
       card(:,i)=randperm(15,5)+(i-1)*15;
    end
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

end
