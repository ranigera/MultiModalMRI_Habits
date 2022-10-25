function [instrDisp,text, position] = initInstructions(var)

% format text for intructions

% scale textsize to window
textref = 40;
windowref_y = 1560; % we want some thing that correpond to a size of 30 on a screen with a y of 1560
instrDisp.scaledSize = round((textref * var.rect(4)) / windowref_y);


% read general messages from instructions txt files (to simplify
% translation in another language);
%--- Rani (added the 'str2num')
text.repeatorcontinue = str2num(fileread('instructions/repeatContinue.txt'));
text.basicScreen      = str2num(fileread('instructions/basicScreen.txt'));
text.yellowBoxes      = str2num(fileread('instructions/yellowBoxes.txt'));
text.aFractal         = str2num(fileread('instructions/aFractal.txt'));
text.buttonWorks      = str2num(fileread('instructions/buttonWorks.txt'));
text.eachBox          = str2num(fileread('instructions/eachBox.txt'));
text.letsPractice     = str2num(fileread('instructions/letsPractice.txt'));
text.pleasePress      = str2num(fileread('instructions/pleasePress.txt'));
text.duringRespond    = str2num(fileread('instructions/duringRespond.txt'));
text.circleAppear     = str2num(fileread('instructions/circleAppear.txt'));
text.wrongPress       = str2num(fileread('instructions/wrongPress.txt'));
text.sometimesReward  = str2num(fileread('instructions/sometimesReward.txt'));
text.pictureMeans     = str2num(fileread('instructions/pictureMeans.txt'));
text.duringRest       = str2num(fileread('instructions/duringRest.txt'));
text.relax            = str2num(fileread('instructions/relax.txt'));
text.multipleFractal  = str2num(fileread('instructions/multipleFractals.txt'));
text.Fractalmeans     = str2num(fileread('instructions/fractalMeans.txt'));
text.payAttention     = str2num(fileread('instructions/payAttention.txt'));
text.restRespondTest  = str2num(fileread('instructions/restRespondTest.txt'));

% define dimensions of images used for illustrations
instrDisp.CUEbaseRect     = [0 0 var.CUEdim var.CUEdim];% Make a base Rect
instrDisp.FRACTALbaseRect = [0 0 var.FRACTALdim var.FRACTALdim];
instrDisp.CUEpointerRect  = [0 0 var.CUEdim*8 var.CUEdim + 40];
instrDisp.REWARDbaseRect  = [0 0 var.REWARDdim var.REWARDdim];
instrDisp.ACTIONbaseRect  = [0 0 var.ACTIONdim var.ACTIONdim];
instrDisp.triangle        = round((100 * var.rect(4)) / windowref_y);

% define position used for illustration
numSqaures = length(var.squareXpos);
allRectsV = nan(4, 4);% Make our rectangle coordinates
for i = 1:numSqaures
    position.allRectsV(:, i) = CenterRectOnPointd(instrDisp.CUEbaseRect, var.squareXpos(i), var.yUpper);
end

instrDisp.gridThick = 15;

position.Fractal    = CenterRectOnPointd(instrDisp.FRACTALbaseRect,var.xCenter, var.yCenter);
position.CUEpointer = CenterRectOnPointd(instrDisp.CUEpointerRect, var.xCenter, var.yUpper);
position.Reward     = CenterRectOnPointd(instrDisp.REWARDbaseRect, var.xCenter, var.yLower);
position.Action     = CenterRectOnPointd(instrDisp.ACTIONbaseRect, var.xCenter, var.yLower);

% define the fractal that will be used for the illustration
instrDisp.fractal   = var.rest_fractal_demo;

% previous and next keys
instrDisp.instKeyNext = KbName('LeftArrow') ;
instrDisp.instKeyPrev = KbName('RightArrow') ;
instrDisp.instKeyDone = KbName ('Return');