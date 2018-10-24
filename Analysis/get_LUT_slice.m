function [ LUT_slice ] = get_LUT_slice(pixel_vid)
    % smooth preprocess
    param = 20;
    vid_smooth = smooth(pixel_vid, param);   %TODO: need to do test and choose best smooth 
    % choose widest interval between adjacent extermums 
    [xmax,imax,xmin,imin] = extrema(vid_smooth); % find extermas
    maximal_range = max(xmax)-min(xmin); % smallest measurement to maximal measurement
    if imax<imin  % choose first step for pair checking
       ind_max_step = 1;
       ind_min_step = 0;
    else
       ind_max_step = 0;
       ind_min_step = 1;
    end
    ind_max = 1;
    ind_min = 1;
    max_interval = 0;
    best_max_ind = 1;
    best_min_ind = 1;
    len_max = len(imax);
    len_min = len(imin);
    iter_help = max([len_min, len_max]);
    iter_num = iter_help*2-1;
    for ii=1:iter_num
        curr_interval = abs(imax(ind_max)-imin(ind_min));
        if max_interval<curr_interval
           max_interval = curr_interval;
           best_max_ind = ind_max;
           best_min_ind = ind_min;
        end
        ind_max = ind_max + ind_max_step;
        ind_min = ind_min + ind_min_step;
        ind_max_step = 0^ind_max_step; % alternately make step each time with different ind
        ind_min_step = 0^ind_min_step;
    end
    if best_max_ind>best_min_ind
        first_chosen_ind = best_min_ind;
        second_chosen_ind = best_min_ind;
    else
        first_chosen_ind = best_min_ind;
        second_chosen_ind = best_min_ind;
    end
    
    % Validate y range  - make sure y range is atleast 50% of full range
    chosen_range = vid_smooth(best_max_ind) - vid_smooth(best_min_ind);
    if maximal_range*0.5>chosen_range
        print('the chosen interval for LUT covers small range')
    end
    LUT_slice = vid_smooth(first_chosen_ind:second_chosen_ind);
end