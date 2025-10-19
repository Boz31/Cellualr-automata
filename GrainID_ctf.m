% % =========================
% % Step 0: Setup MTEX
% % =========================
clc; clear; close all;
% startup_mtex;   % if needed
% 
% =========================
% Step 1: Import CTF
% =========================
fname = 'example.ctf';
cs = crystalSymmetry('m-3m', [2.866 2.866 2.866], 'mineral', 'Fe-bcc');
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');

ebsd = loadEBSD(fname, cs, 'interface', 'ctf', 'convertEuler2SpatialReferenceFrame');

% Optional: remove bad points if any (MAD>1.5°)
% ebsd = ebsd(ebsd.mad < 1.5*degree);

% =========================
% Step 2: Grain Reconstruction
% =========================
% Misorientation threshold for defining grain boundaries
% typical: 5–10° for Fe-bcc
threshold = 5*degree;

[grains, ebsd.grainId] = calcGrains(ebsd('indexed'), 'angle', threshold);

% Smooth grain boundaries if desired
grains = smooth(grains, 3);

% =========================
% Step 3: Visual check
% =========================
plot(grains, grains.meanOrientation);
hold on;
plot(ebsd(grains.boundary),'FaceColor','none','LineWidth',0.5);
hold off;
title('Grain structure with mean orientations');

% =========================
% Step 4: Add grainId into ebsd table
% =========================
T = table(...
    ebsd.x/1, ...   % convert to microns if stored in meters
    ebsd.y/1, ...
    ebsd.orientations.phi1/degree, ...
    ebsd.orientations.Phi/degree, ...
    ebsd.orientations.phi2/degree, ...
    ebsd.grainId, ...
    'VariableNames', {'X','Y','Euler1','Euler2','Euler3','GrainID'});

% =========================
% Step 5: Export to text file
% =========================
writetable(T, 'ebsd_with_grainid.txt', 'Delimiter', '\t');
disp('✅ EBSD file with GrainID exported.');
