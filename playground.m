%% PLAYGROUND
% Sharing contrib code

Init;

%% Checkerboard Detection
ch_0 = checkerboard_custom(32, 512, 512, 255);
[imagePoints, boardSize] = detectCheckerboardPoints(ch_0);
imshow(ch_0, []);
hold on
plot(imagePoints(:,1),imagePoints(:,2), 'ro');

%% Diff Image Corner Detection
captured = avi2gray('check_10_0.avi');
avg_captured = mean(captured, 3);
diff = avg_captured - captured(:,:,1);
[pts_diff, ~] = detectCheckerboardPoints(diff);
imshow(diff, []);
hold on
plot(pts_diff(:,1),pts_diff(:,2), 'ro');

%% Fit Affine Transformation
