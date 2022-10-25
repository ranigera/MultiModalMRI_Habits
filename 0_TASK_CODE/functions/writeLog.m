function writeLog(txt)
timeStampPosition = 45; %time will be written from this point
time = [datestr(now,'dd-mm-yy ') datestr(now,'HH') ':' datestr(now,'MM') ':' datestr(now,'SS')];
fid = fopen('temporalFiles/log.txt','a'); % write a temporal file with the winning in case the experimenter needs it.
fprintf(fid, [txt repmat(' ', 1,timeStampPosition-length(txt)) '[' time ']\n']);
fclose(fid);
end

