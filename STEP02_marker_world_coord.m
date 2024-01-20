% determine world coordinates of markers from images

clear; close all; clc;

% load camera calibration
load('cam_calib_data/cam_calib.mat');

for cam = 1:3
    F(cam) = FocalLength_(cam);                     % focal length [mm]
    p(cam) = 0.02;                                  % pixel size [mm]
    f(cam,:) = [F(cam)/p(cam),F(cam)/p(cam)];       % focal length [pixel]
    c(cam,:) = PrinciplePoint_(cam,:);              % principal point [pixel]
    ang(cam,:) = Rotation_(cam,:);                  % rotation ZYX [rad]
    t(cam,:) = Translation_(cam,:);                 % translation [mm]
end

for cam = 1:3
    K(:,:,cam) = [f(cam,1),0,c(cam,1);0,f(cam,2),c(cam,2);0,0,1];
    R(:,:,cam) = eul2rotm(ang(cam,:),'ZYX');
    P(:,:,cam) = K(:,:,cam)*[R(:,:,cam),t(cam,:)'];
end

%% 
imN = 100;                      % total number of images
markerN = 16;                   % number of markers
camN = 3;                       % number of cameras

%% load marker pixel positions 
casename = 'pitching_wing_5hz';
load(['marker_data/',casename,'_marker_pos.mat']);

%% marker on aerofoil
recon = zeros(markerN,camN,imN);
sol = [0;0;0];
for im = 1:imN
    pos = pos_all(:,:,:,im);
    for n = 1:size(pos,1)
        frame = 1;
        xy = 1;
        x = [pos(n,xy,1),pos(n,xy,2),pos(n,xy,3)];
        xy = 2;
        y = [pos(n,xy,1),pos(n,xy,2),pos(n,xy,3)];
    
        A = []; b = [];
        for cam = 1:camN
            A = [A;P(1,1,cam)-x(cam)*P(3,1,cam), P(1,2,cam)-x(cam)*P(3,2,cam), P(1,3,cam)-x(cam)*P(3,3,cam);
        P(2,1,cam)-y(cam)*P(3,1,cam), P(2,2,cam)-y(cam)*P(3,2,cam), P(2,3,cam)-y(cam)*P(3,3,cam)];
            b = [b;x(cam)*P(3,4,cam)-P(1,4,cam);y(cam)*P(3,4,cam)-P(2,4,cam)];
        end

        sol= lsqr(A,b,1e-12,100,[],[],sol);
    
        recon(n,:,im) = sol;
    end
end

figure;
colours = parula(imN);
for im = 1:imN
    plot3(recon(:,1,im),recon(:,2,im),recon(:,3,im),'o','color',colours(im,:)); hold on;
end
xlabel('x [mm]'); ylabel('y [mm]'); zlabel('z [mm]');
daspect([1 1 1])


save(['marker_data/',casename,'_marker_coord.mat'],'recon')