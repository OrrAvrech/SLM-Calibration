function [] = slideshow(frame_time, masks)
% Args: 
%   frame_time - dispaly each mask for frame_time duration  
%   masks      - a set of masks to display

for ii = 1 : size(masks, 3)
    im = masks(:, :, ii);
    fullscreen('cdata',im,'screennumber',1);
    pause (frame_time)
    drawnow
end

end

