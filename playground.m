%% PLAYGROUND
% Sharing contrib code

Init;

%% Checkerboard Detection
ch_0 = checkerboard_custom(32, 512, 512, 255);
[imagePoints, boardSize] = detectCheckerboardPoints(ch_0);
imshow(ch_0, []);
hold on
plot(imagePoints(:,1),imagePoints(:,2), 'ro');

%% Fit Affine Transformation
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
