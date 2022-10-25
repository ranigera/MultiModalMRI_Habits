function [var] = uploadImages (var)

% last modifed on August 2017 by Eva
% last modifed on April 2019 by Rani

% SWEET OPTION
switch var.sweet
    
    case 1  % case participant likes M&Ms the most
        [var.sweetImage, ~, alpha] = imread('images/MM.png');
        var.sweetImage(:,:,4) = alpha;
        var.sweetLabel = 'M&Ms';
        var.sweetLabelHebrew = [77 38 77];
        % read bulk image:
        var.sweetImageBulk = imread('images/MM_bulk.jpg');
        
    case 2 % case participant likes malters the most
        [var.sweetImage, ~, alpha] = imread('images/Click.png');
        var.sweetImage(:,:,4) = alpha;
        var.sweetLabel = 'Click';
        var.sweetLabelHebrew = [1511 1500 1497 1511];
        % read bulk image:
        var.sweetImageBulk = imread('images/Click_bulk.jpg');
        
    case 3  % case participant likes skittles the most
        [var.sweetImage, ~, alpha] = imread('images/skittles.png');
        var.sweetImage(:,:,4) = alpha;
        var.sweetLabel = 'Skittles';
        var.sweetLabelHebrew = [1505 1511 1497 1496 1500 1505];
        % read bulk image:
        var.sweetImageBulk = imread('images/Skittles_bulk.jpg');
        
    case 4 % case participant likes  cashews the most
        [var.saltyImage, ~, alpha] = imread('images/cashew.png');
        var.saltyImage(:,:,4) = alpha;
        var.saltyLabel = 'Cashews';
        var.saltyLabelHebrew = [1511 1513 1497 1493];
        % read bulk image:
        var.saltyImageBulk = imread('images/Cashew_bulk.jpg');
   
    case 5 % case participant likes doritos the most
        [var.saltyImage, ~, alpha] = imread('images/doritos.png');
        var.saltyImage(:,:,4) = alpha;
        var.saltyLabel = 'Doritos';
        var.saltyLabelHebrew = [1491 1493 1512 1497 1496 1493 1505];
        % read bulk image:
        var.saltyImageBulk = imread('images/Doritos_bulk.jpg');
        
    case 6 % case participant likes chips it the most
        [var.saltyImage, ~, alpha] = imread('images/TapuChips.png');
        var.saltyImage(:,:,4) = alpha;
        var.saltyLabel = 'Tapuchips';
        var.saltyLabelHebrew = [1514 1508 1493 1510 39 1497 1508 1505];
        % read bulk image:
        var.saltyImageBulk = imread('images/Tapuchips_bulk.jpg');
        
end



% SALTY OPTION
switch var.salty
    
    case 1  % case participant likes M&Ms the most
        [var.sweetImage, ~, alpha] = imread('images/MM.png');
        var.sweetImage(:,:,4) = alpha; % set background of the png as transparent
        var.sweetLabel = 'M&Ms';
        var.sweetLabelHebrew = [77 38 77];
        % read bulk image:
        var.sweetImageBulk = imread('images/MM_bulk.jpg');
        
    case 2 % case participant likes malters the most
        [var.sweetImage, ~, alpha] = imread('images/Click.png');
        var.sweetImage(:,:,4) = alpha;
        var.sweetLabel = 'Click';
        var.sweetLabelHebrew = [1511 1500 1497 1511];
        % read bulk image:
        var.sweetImageBulk = imread('images/Click_bulk.jpg');
        
    case 3  % case participant likes skittles the most
        [var.sweetImage, ~, alpha] = imread('images/skittles.png');
        var.sweetImage(:,:,4) = alpha;
        var.sweetLabel = 'Skittles';
        var.sweetLabelHebrew = [1505 1511 1497 1496 1500 1505];
        % read bulk image:
        var.sweetImageBulk = imread('images/Skittles_bulk.jpg');
        
    case 4 % case participant likes  cashew the most
        [var.saltyImage, ~, alpha] = imread('images/cashew.png');
        var.saltyImage(:,:,4) = alpha;
        var.saltyLabel = 'Cashews';
        var.saltyLabelHebrew = [1511 1513 1497 1493];
        % read bulk image:
        var.saltyImageBulk = imread('images/Cashew_bulk.jpg');
        
    case 5 % case participant likes doritos the most
        [var.saltyImage, ~, alpha] = imread('images/doritos.png');
        var.saltyImage(:,:,4) = alpha;
        var.saltyLabel = 'Doritos';
        var.saltyLabelHebrew = [1491 1493 1512 1497 1496 1493 1505];
        % read bulk image:
        var.saltyImageBulk = imread('images/Doritos_bulk.jpg');
        
    case 6 % case participant likes  chipit the most
        [var.saltyImage, ~, alpha] = imread('images/TapuChips.png');
        var.saltyImage(:,:,4) = alpha;
        var.saltyLabel = 'Tapuchips';
        var.saltyLabelHebrew = [1514 1508 1493 1510 39 1497 1508 1505];
        % read bulk image:
        var.saltyImageBulk = imread('images/Tapuchips_bulk.jpg');
        
end
