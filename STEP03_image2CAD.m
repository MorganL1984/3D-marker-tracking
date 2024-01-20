% rotation and translation from PIV world coord to CAD coord
clear; close all; clc;

% PIV coord recon
casename = 'pitching_wing_5hz';
load(['marker_data/',casename,'_marker_coord.mat'],'recon');
imN = 100;

% CAD coord
load('aerofoil_data/NACA0021_W.mat');
markerN = size(W0,2);

W = W0-repmat(W0(:,1),[1,markerN]);     % set the first point as origin (temporarilly)

% matrix initialise
% Euler angles 
eul_PIV2CAD = zeros(imN,3);
eul_PIV2CAD_deg = zeros(imN,3);
% reconstructed marker location
W_recon_rot = zeros(3,markerN);
W_recon = zeros(3,markerN);

for im = 1:imN

    % Singular value decomposition of Wahba's problem
    % https://en.wikipedia.org/wiki/Wahba%27s_problem
    B = zeros(3);
    for i = 1:markerN
        B = B+W(:,i)*squeeze(recon(i,:,im)-recon(1,:,im)); % set the first point as origin (temporarilly)
    end
    B = B/markerN;
    
    [U,S,V] = svd(B);
    M = diag([1,1,det(U)*det(V)]);
    
    R_PIV2CAD = U*M*V';

    % marker PIV frame rotated to CAD frame
    for i = 1:markerN
        W_recon_rot(:,i) = R_PIV2CAD*squeeze(recon(i,:,im))';
    end
    
    % calculate the translation vector averaged over all markers
    t = mean(W0(:,:)-W_recon_rot(:,:),2);
    
    for i = 1:markerN
        W_recon(:,i) = R_PIV2CAD*squeeze(recon(i,:,im))'+t;
    end
    
    if im == 1
        % plot results for the first frame
        figure;
        % CAD coord
        plot3(W0(1,:),W0(2,:),W0(3,:),'x'); hold on;
        % CAD recon
        plot3(W_recon(1,:),W_recon(2,:),W_recon(3,:),'o');
        legend('ground truth','reconstruct'); 
        daspect([1 1 1]);
        xlabel('x [mm]'); ylabel('y [mm]'); zlabel('z [mm]');
    end
    
    eul_PIV2CAD(im,:) = rotm2eul(R_PIV2CAD);
    eul_PIV2CAD_deg(im,:) = rad2deg(eul_PIV2CAD(im,:));
end

% plot pitch angle of the wing
figure;
plot(eul_PIV2CAD_deg(:,2),'.-'); xlabel('Num. image'); ylabel('\alpha [deg]')