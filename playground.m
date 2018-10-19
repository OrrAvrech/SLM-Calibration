%% PLAYGROUND
% Sharing contrib code

Init;

%% Checkerboard Detection
ch_0 = checkerboard_custom(32, 512, 512, 255);
[imagePoints, boardSize] = detectCheckerboardPoints(ch_0);
imshow(ch_0, []);
hold on
plot(imagePoints(:,1),imagePoints(:,2), 'ro');

%% Fit Aff>> playground
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, create an affine transform and a transformed (moving) image.
% Then, use corner detection to recover the transform from the
% extracted corner points of the fixed and moving images.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Affine Transformation - Translation, Scale, Rotation
TS = [1 0 0; 0 0.5 0; 0 0 1];
theta = 30; % degrees
R  = [cosd(theta) sind(theta) 0; -sind(theta) cosd(theta) 0; 0 0 1];
tform  = affine2d(TS * R);
timage = imwarp(ch_0, tform);
figure;
imshowpair(ch_0,timage);
figure;
imshow(timage, []);
% Detect Corners -- Transformed Image
[pts_t, bs_t] = detectCheckerboardPoints(timage);
hold on
plot(pts_t(:,1), pts_t(:,2), 'ro');
hold off
% Fit Geometric Transform
tform_fit = fitgeotrans(pts_t,imagePoints,'affine');
image_recon = imwarp(timage, tform_fit, 'OutputView', imref2d(size(ch_0)));
% Reconstructed Image
figure;
imshowpair(ch_0,image_recon,'montage');

%% Diff Image Corner Detection
captured = avi2gray('check_10_0.avi');
avg_captured = mean(captured, 3);
diff = avg_captured - captured(:,:,1);
[pts_diff, ~] = detectCheckerboardPoints(diff);
imshow(diff, []);
hold on
plot(pts_diff(:,1),pts_diff(:,2), 'ro');
hold off

%% 3 Boundary Corner Pts Fit
inputPts  = [150 1540; 150 400; 900 400];
movingPts = [1241 54; 54 71; 64 985]; 
tform_boundaries = fitgeotrans(movingPts, inputPts, 'affine');
% Interactive Crop
diffPatch = imcrop(diff);
diffPatch_recon = imwarp(diffPatch, tform_boundaries);
imshowpair(diffPatch, diffPatch_recon, 'montage');


%% Calibration Flow - Alpha Version (high level flow structure definition)

% *manual corner extraction for affine transform detection*
ref_pts_post = load(); % or manually 
ref_pts_pre = load(); % or manually
% load measurements
measured_vid = load(); % checkerboard
measured_neg_vid = load(); % checkerboard
measured_combined = measured_vid + measured_neg_vid;

% get transformation
tform = fitgeotrans(ref_pts_post, ref_pts_pre, 'affine');
    
% 1st option 
    % translate x,y to x_meas, y_meas and continue analysis on
    % measured vid
x_meas, y_meas = translate_coor(x, y, tform); % TODO: translate_coor

% choose x,y to get LUT
function [ LUT ] = get_LUT1(x_meas, y_meas, tform, measured_combined)
    % sum of vid + neg_vid should give all pixels in one vid
    %recon_vid = imwarp(measured_combined, tform);
    pixel_vid = measured_combined(x_meas,y_meas,:);
    first_cycle = get_first_cycle(pixel_vid); % get the first min to max time interval
    LUT = cycle2LUT(first_cycle); % interpolation
end

% 2nd option
    % translate measured_vid to recon_vid, and continue analysis 
    % with original x,y 
    recon_vid = imwarp(measured_combined, inv_tform); % TODO: check if inverse
    
function [ LUT ] = get_LUT2(x, y, recon_vid)
    pixel_vid = recon_vid(x,y,:);
    first_cycle = get_first_cycle(pixel_vid); % get the first min to max time interval
    LUT = cycle2LUT(first_cycle); % interpolation
end