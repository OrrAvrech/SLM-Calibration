%% Init file
% parent directory contains the entire code and measurements.
% code and measurement directories may be separate, but both folders
% should be in the parent directory.

parent_dir = (fullfile('..', '..'));
p = genpath(parent_dir);
addpath(p);