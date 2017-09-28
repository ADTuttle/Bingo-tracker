% Setup a bingo game.
% Creates drawpile and continuously draws until you stop.

draw_pile=randperm(75);

Letter=['B','I','N','G','O'];
for i=1:75
    
    disp([Letter(ceil(draw_pile(i)/15)),num2str(draw_pile(i))])
    w= waitforbuttonpress;
end