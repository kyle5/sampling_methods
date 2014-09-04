 close all
 clear all
 clc

 load redAppleVariables.mat
 load greenAppleVariables.mat

 global percentages;     
 percentages = [100, 50, 25, 10];
 
 % This determines how much the image increases in size for kriging
 % Note: A larger image is smoother after kriging
 global scaling_factor_image;
 scaling_factor_image = 10;
 
 % These flags determine the types of figures that are displayed
 % The first flag shows the complete hand counts along with varying
    % percentages of computer counts sampled
 % The second flag shows varying percentages of hand counts sampled
 % The third flag shows the complete computer counts along with
    % the complete hand counts
 global flag_varying_percentages_computer_count;
 global flag_varying_percentages_hand_count;
 global flag_plot_varying_percentages_in_one_graph;
 global flag_100_percent_computer_count_and_hand_count;
 
 flag_varying_percentages_computer_count = 1;
 flag_varying_percentages_hand_count = 1;
 flag_plot_varying_percentages_in_one_graph = 0;
 flag_100_percent_computer_count_and_hand_count = 1;
 
 % We did not use the red not thinned data, so just set red counts to redset(gca,'YTick', 1:columns_cur_map);
        %
 % thinned counts
 red_ground_counts = red_thinned_ground_counts;
 red_pc_counts = red_thinned_pc_counts;

 types_of_apples = 2;
 
 apple_types = {'Green'; 'Red Thinned'};
 scaled_types = [1, 0];
 
 % Cell arrays are setup to iterate through the types of apples
 apple_types_ground_counts = cell(1, types_of_apples);
 apple_types_ground_counts{1, 1} = green_ground_counts;
 apple_types_ground_counts{1, 2} = red_ground_counts;
 
 apple_types_pc_counts = cell(1, types_of_apples);
 apple_types_pc_counts{1, 1} = green_pc_counts;
 apple_types_pc_counts{1, 2} = red_pc_counts;
 
 % Loop through the types of apples, greens and then reds
 for i = 1:types_of_apples
     pc_image_used = apple_types_pc_counts{1, i};
     hand_image_used = apple_types_ground_counts{1, i};
     
     [pc_counted_rows, pc_counted_columns] = size(pc_image_used);
     [hand_counted_rows, hand_counted_columns] = size(hand_image_used);
     
     if pc_counted_rows == hand_counted_rows
        rows_cur_map = pc_counted_rows;
     else
        error('Number of rows in computer map not equal to number of rows in hand count map');
     end
     if pc_counted_columns == hand_counted_columns
        columns_cur_map = pc_counted_columns;
     else
        error('Number of columns in computer map not equal to number of rows in hand count map');
     end
     
     max_hand_count_vector = max(hand_image_used);
     max_hand_count = max(max_hand_count_vector);
     
     max_computer_count_vector = max(pc_image_used);
     max_computer_count = max(max_computer_count_vector);

     % This checks if the current variety of apple counts should be scaled
     % for appearance
     if scaled_types(1, i) == 1
         scaling_factor_hand_to_computer_count = computeScalingFactorFromHandToComputerCounts(hand_image_used, pc_image_used);
     else
         scaling_factor_hand_to_computer_count = 1;
     end
     [ computer_kriging_z_values, hand_kriging_z_values ] = getHandAndComputerKrigingValues(hand_image_used,...
         pc_image_used, scaling_factor_hand_to_computer_count);
     
     % Got to have a plot all different graphs part of the code in here
     cur_apple_type = apple_types{i, 1};
     plotAllGraphs(cur_apple_type, max_hand_count, max_computer_count, computer_kriging_z_values, hand_kriging_z_values, scaling_factor_hand_to_computer_count, hand_image_used);
 end