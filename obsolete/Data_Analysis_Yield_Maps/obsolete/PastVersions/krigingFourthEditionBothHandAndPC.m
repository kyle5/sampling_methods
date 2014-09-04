 close all
 clear all
 clc

 load redAppleVariables.mat
 load greenAppleVariables.mat

 red_ground_counts = red_thinned_ground_counts;
 red_pc_counts = red_thinned_pc_counts;

 types_of_transformations = cell( 2, 1 );
 types_of_transformations{1, 1} = 'original_image'; 
 types_of_transformations{2, 1} = 'resized_image_all_pixels';

 cur_type_of_image_transformation = types_of_transformations{1, :};

 types_of_apples = 2;
 
 apple_types = {'Green'; 'Red'};
 scale_map = [1, 0];

 apple_types_ground_counts = cell(1, types_of_apples);
 apple_types_ground_counts{1, 1} = green_ground_counts;
 apple_types_ground_counts{1, 2} = red_ground_counts;

 %apple_types_ground_counts{1, 3} = red_not_thinned_ground_counts;
 
 apple_types_pc_counts = cell(1, types_of_apples);
 apple_types_pc_counts{1, 1} = green_pc_counts;
 apple_types_pc_counts{1, 2} = red_pc_counts;

 %apple_types_pc_counts{1, 3} = red_not_thinned_pc_counts;
 
 
 scaling_factor_image = 10;

 percentages = [100, 50, 25, 10];
 num_percentages = size(percentages, 2);
 
 
 for i = 1:types_of_apples
     counted_map_pc = apple_types_pc_counts{1, i};
     counted_map_hand = apple_types_ground_counts{1, i};
     
     [pc_counted_rows, pc_counted_columns] = size(counted_map_pc);
     [hand_counted_rows, hand_counted_columns] = size(counted_map_hand);
     
     if pc_counted_rows == hand_counted_rows
        rows_cur_map = pc_counted_rows;
     else
        error('Number of rows in computer map not equal to number of rows in hand count map');
     end
     if pc_counted_columns == hand_counted_columns
        columns_cur_map = pc_counted_columns;
     else
        error('Number of rows in computer map not equal to number of rows in hand count map');
     end

     rows_cur_map_scaled = (rows_cur_map + 1) * scaling_factor_image;
     columns_cur_map_scaled = (columns_cur_map + 1) * scaling_factor_image;

     x_indicies = 1:rows_cur_map;
     y_indicies = 1:columns_cur_map;

     scaled_x_indicies = 1:(rows_cur_map_scaled);
     scaled_y_indicies = 1:(columns_cur_map_scaled);

     [X,Y] = meshgrid(1:rows_cur_map_scaled, 1:columns_cur_map_scaled);

     pc_image_used = counted_map_pc;
     hand_image_used = counted_map_hand;
     scaling_input_to_output = scaling_factor_image;
     middle = scaling_factor_image/2;

     total_sections = rows_cur_map * columns_cur_map;
     
     % This 
     newx_hand = ones(total_sections, 1);
     newy_hand = ones(total_sections, 1);
     newz_hand = ones(total_sections, 1);

     for j = 1:rows_cur_map
            for k = 1:columns_cur_map
                current_place = ( j - 1 ) * ( columns_cur_map ) + k;
                current_hand_count = hand_image_used(j, k);

                newx_hand(current_place, 1) = j * scaling_input_to_output;
                newy_hand(current_place, 1) = k * scaling_input_to_output;
                newz_hand(current_place, 1) = current_hand_count;
            end
     end

     maxdist = scaling_factor_image * rows_cur_map;
     nrbins = rows_cur_map;
     
     % Do kriging for all of the hand values
     v_hand = variogram([ newx_hand newy_hand ], newz_hand, 'plotit', false, 'maxdist', maxdist, 'nrbins', nrbins);
     [dum,dum,dum,vstruct_hand] = variogramfit(v_hand.distance,v_hand.val,[],[],[],'model','exponential', 'plotit', false);
     [Z_hand_values_returned_kriging, Z_error_hand] = kriging(vstruct_hand, newx_hand, newy_hand, newz_hand, X, Y);
     
     % This section does two things
     % First: It finds the scaling factor for hand counting to computer
     % counting
     % Second: It gets the max computer count and hand count over a
     % section
     scaling_factors = [100, 50, 25, 10, 5];
     cur_scaling_factor = scaling_factors(1, 3);
     number_of_sections_to_count_cur_scaling_factor = floor(total_sections * cur_scaling_factor / 100);
     rand_sections_scaling = randperm(total_sections);
     rand_sections_to_count_scaling = rand_sections_scaling( 1:number_of_sections_to_count_cur_scaling_factor );
     
     max_hand_count = 0;
     max_computer_count = 0;
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
            if current_computer_count > max_computer_count
                max_computer_count = current_computer_count;
            end
            if current_hand_count > max_hand_count
                max_hand_count = current_hand_count;
            end
        end
     end
     scaling_factor_hand_to_computer_count = computer_count_scaling_factor / hand_count_scaling_factor;

     
     
     % Next, we need to get the computer counts for the different
     % percentages of the orchard sampled
        % Percent of sections sampled by the computer varies from 10 - 100
        % percent of all sections
        
     newx_all_computer_counts = cell(1, 3);
     newy_all_computer_counts = cell(1, 3);
     newz_all_computer_counts = cell(1, 3);
     
     percentages = [100, 50, 25, 10];
     num_percentages = size(percentages, 2);

     computer_kriging_z_values = cell(num_percentages);
     
     for p = 1:num_percentages
         cur_percentage = percentages(1,p);
         number_of_sections_to_count_cur_percentage = floor(total_sections * cur_percentage / 100);
         
         rand_sections = randperm(total_sections);
         rand_sections_to_count = rand_sections( 1:number_of_sections_to_count_cur_percentage );
         
         newx_computer = ones(number_of_sections_to_count_cur_percentage, 1);
         newy_computer = ones(number_of_sections_to_count_cur_percentage, 1);
         newz_computer = ones(number_of_sections_to_count_cur_percentage, 1);

         % index for computer counts
         cur_comp_count = 0;

         % Get values in expanded image
         for j = 1:rows_cur_map
            for k = 1:columns_cur_map
                current_place = ( j - 1 ) * ( columns_cur_map ) + k;
                if ismember(current_place, rand_sections_to_count)
                    cur_comp_count = cur_comp_count + 1;
                    current_computer_count_one_section = pc_image_used(j, k);
                    
                    newx_computer(cur_comp_count, 1) = j * scaling_input_to_output;
                    newy_computer(cur_comp_count, 1) = k * scaling_input_to_output;
                    newz_computer(cur_comp_count, 1) = current_computer_count_one_section;
                end
            end
         end
         
         % Scale the yield map if the current type is green apples
         cur_map_should_be_scaled = scale_map(1, i);
         if cur_map_should_be_scaled == 1
             newz_computer = newz_computer/scaling_factor_hand_to_computer_count;
         end
         
         v_computer = variogram([ newx_computer newy_computer ], ...
             newz_computer,'plotit',false, 'maxdist', maxdist, 'nrbins', nrbins);
         [dum,dum,dum,vstruct_computer] = variogramfit(v_computer.distance,v_computer.val,[],[],[],'model','exponential', 'plotit', false);
         [ Z_computer_value_returned_kriging, Z_error_computer ] = kriging(vstruct_computer, newx_computer, newy_computer, newz_computer, X, Y);
         
         %fprintf('The size of the array is : %d by %d \n', size(Z_computer_value_returned_kriging,1), size(Z_computer_value_returned_kriging,2));
         
         computer_kriging_z_values{p} = Z_computer_value_returned_kriging;
     end
     
     normalized_scaled_indicies_x = scaled_x_indicies / scaling_factor_image;
     normalized_scaled_indicies_y = scaled_y_indicies / scaling_factor_image;

     
     %Get the data in per tree terms instead of per section terms
     Zhat_hand = Z_hand_values_returned_kriging/3;

     scale_color_bar_per_section = max(max_computer_count, max_hand_count) * 1.2;
     
     % set scale for trees
     scale_color_bar_per_tree = scale_color_bar_per_section / 3;
     
     cur_type_of_apple = apple_types{i, :};
     title_one = ['Productivity Map ', cur_type_of_apple];
     figure('Name', title_one, 'Position', [100, 100, 1000, 1200]);
     
     subplot(3, 2, 1);
     % Show the hand counts
     imagesc(normalized_scaled_indicies_x, normalized_scaled_indicies_y, Zhat_hand);
     t2 = colorbar('YTick', 1:scale_color_bar_per_tree);
     set(get(t2,'ylabel'),'String', 'Apples Counted Per Tree');
     caxis([0 scale_color_bar_per_tree]);

     title('Yield Map - Ground Truth', 'fontsize', 12, 'fontweight', 'bold');
     ylabel('Sections', 'fontsize', 12, 'fontweight', 'normal');
     xlabel('Rows', 'fontsize', 12, 'fontweight', 'normal');
     set(gca,'YTick', 1:columns_cur_map);
     set(gca,'XTick', 1:rows_cur_map);

     string_scaling_factor = num2str(cur_scaling_factor);
     %subplot(3, 2, 2)
     %text(string_scaling_factor);
     
     for j = 1:num_percentages
         cur_percentage = percentages(j);
         string_of_percentage = num2str(cur_percentage);
         
         subplot(3, 2, j+2)
         z_comp_cur_percent = computer_kriging_z_values{j};
         z_comp_cur_percent_per_tree = z_comp_cur_percent/3;
         imagesc(normalized_scaled_indicies_x, normalized_scaled_indicies_y, z_comp_cur_percent_per_tree);
         
         caxis([0 scale_color_bar_per_tree]);
         title_one = ['Computer Count - Sections Sampled by Computer : ', string_of_percentage];
         title(title_one, 'fontsize', 12, 'fontweight', 'bold');
         ylabel('Sections', 'fontsize', 12, 'fontweight', 'normal');
         xlabel('Rows', 'fontsize', 12, 'fontweight', 'normal');
         set(gca,'YTick', 1:columns_cur_map);
         set(gca,'XTick', 1:rows_cur_map);
     end
 end