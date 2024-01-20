% extract marker locations
clear; close all; clc;

casename = 'pitching_wing_5hz';
filepath = [casename,'/'];

thr = 1.4;                      % threshold for marker intensity on image intensity stretched to range 0.5% to 99.5%
thr_area_min = 3;               % smallest detected marker area [pixels]
thr_area_max = 30;              % largest detected marker area [pixels]
thr_aspect_ratio = 2;           % largest aspect ratio of marker (1 means perfectly circular)
thr_wing = 0.6;                 % threshold for wing intensity on image intensity stretched to range 0.5% to 99.5%

imN = 100;                      % total number of images
markerN = 16;                   % number of markers
camN = 3;                       % number of cameras

im_height = 1024;
im_width = 1024;

% define a mask (remove regions marked by NaN)
mask = NaN(im_height,im_width,camN);
mask(:,100:400,1) = 1;
mask(:,600:900,2) = 1;
mask(:,250:550,3) = 1;
%% detect marker positions
pos0 = zeros(markerN,2,camN);
pos_all = zeros(markerN,2,camN,imN);
for im = 1:imN
    disp(im);
    imgIn = imread([filepath,'B',num2str(im,'%04d'),'.tif']);

    img = zeros(im_height,im_width,camN);
    for cam = 1:camN
        img(:,:,cam) = imgIn((cam-1)*im_height+1:cam*im_height,:);
    end

    % invert intensity
    img = 2^12-img;

    % mask image
    img_masked = img.*mask;

    % rescale the masked image to 0.5% and 99.5% of the intensity range
    img_norm = img_masked;
    for cam = 1:camN
        img_norm(:,:,cam) = ((img_masked(:,:,cam)-prctile(img_masked(:,:,cam),0.5,'all')))/...
            (prctile(img_masked(:,:,cam),99.5,'all')-prctile(img_masked(:,:,cam),0.5,'all'));
        
        stats = regionprops(img_norm(:,:,cam)<thr_wing,'area','pixelidxlist');
        Area = [stats.Area];
        [~,ind] = sort(Area,'descend');
        wing_mask_temp = zeros(1,numel(img_norm(:,:,cam)));
        wing_mask_temp(stats(ind(1)).PixelIdxList) = 1;
        wing_mask_temp = reshape(wing_mask_temp,size(img_norm(:,:,cam)));
        
        wing_mask(:,:,cam) = imfill(wing_mask_temp,'holes');
    end
    
    % normalise the intensity again after applying wing mask
    img_wing_masked = img_norm.*wing_mask;
    for cam = 1:camN
        img_wing_norm(:,:,cam) = ((img_wing_masked(:,:,cam)-prctile(img_wing_masked(:,:,cam),0.5,'all')))/...
            (prctile(img_wing_masked(:,:,cam),99.5,'all')-prctile(img_wing_masked(:,:,cam),0.5,'all'));
    end
    img_bw = img_wing_norm>thr;
    
    pos = zeros(size(pos0));
    for cam = 1:camN
        stats = regionprops(img_bw(:,:,cam),'area','centroid','MajorAxisLength','MinorAxisLength');
        Area = [stats.Area];
        MajorAxis = [stats.MajorAxisLength];
        MinorAxis = [stats.MinorAxisLength];

        if im == 1
            % need to find all markers in the first image
            ind = (Area>thr_area_min)&(Area<thr_area_max)&(MajorAxis./MinorAxis<thr_aspect_ratio);
            stats = stats(ind);
            ind = [];
            c = [stats.Centroid];
            c = reshape(c,2,[])';
            % sort rows with a different weight; tweak the coefficient if
            % needed
            [~,sort_id] = sort(100*c(:,1)+c(:,2));
            temp = c(sort_id,:);
            pos(:,:,cam) = temp;
            figure;
            imagesc(img_masked(:,:,cam)); hold on;
            plot(temp(:,1),temp(:,2),'-mo')
        else
            % use more relaxed thresholds 
            % use the previous marker location as a reference
            c = [stats.Centroid];
            c = reshape(c,2,[])';

            for k = 1:size(pos0,1)
                res = sum((c-pos0(k,:,cam)).^2,2);
                [err,ind] = min(res);
                pos(k,:,cam) = c(ind,:);
            end
        end
    end

    pos_all(:,:,:,im) = pos;
    pos0 = pos;
    
    save(['marker_data/',casename,'_marker_pos.mat'],'pos_all')
end