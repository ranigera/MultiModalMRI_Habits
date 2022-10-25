function pressEnter()

ListenChar(2)
disp('press ENTER to continue to the next TASK phase')
while 1
    [down, ~, keycode] = KbCheck(-1);
    if down && keycode(40)
        break;
    end
end
ListenChar(0)

end