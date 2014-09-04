function [ scaling_factor_hand_to_computer_count ] = computeScalingFactorFromHandToComputerCounts( hand_image_used, pc_image_used )
     % This program finds the scaling factor, which represents the ratio in counts
        % that are expected between hand counting and computer counting

     total_sections = numel( hand_image_used );
     [ rows_cur_map, columns_cur_map ] = size(hand_image_used);

     scaling_factor_percentages = [100, 50, 25, 10, 5, 2, 1];
     % Currently set to use 10 percent of the apple counts to compute the
     % scaling factor
     cur_scaling_factor_percentage = scaling_factor_percentages(1, 4);
     number_of_sections_to_count_cur_scaling_factor = floor(total_sections * cur_scaling_factor_percentage / 100);
     rand_sections_scaling = randperm(total_sections);
     
     rand_sections_to_count_scaling = rand_sections_scaling( 1:number_of_sections_to_count_cur_scaling_factor );
     
     hand_count_scaling_factor = 0;
     computer_count_scaling_factor = 0;
     for j = 1:rows_cur_map
        for k = 1:columns_cur_map
            current_place = ( j - 1 ) * ( columns_cur_map ) + k;
            
            current_hand_count = hand_image_used(j, k);
            current_computer_count = pc_image_used(j, k);
            
            if ismember(current_place, rand_sections_to_count_scaling)
                hand_count_scaling_factor = hand_count_scaling_factor + current_hand_count;
                computer_count_scaling_factor = computer_count_scaling_factor + current_computer_count;        
            end
        end
     end
     
     if hand_count_scaling_factor == 0
          scaling_factor_hand_to_computer_count = 1;
     else
          scaling_factor_hand_to_computer_count = computer_count_scaling_factor / hand_count_scaling_factor;
     end
end