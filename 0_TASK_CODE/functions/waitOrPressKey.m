function waitOrPressKey(minWait, maxWait)

startTime = GetSecs;
WaitSecs(minWait);
while GetSecs - startTime < maxWait
    down = KbCheck(-3,2);
    if down
        break
    end
end

end