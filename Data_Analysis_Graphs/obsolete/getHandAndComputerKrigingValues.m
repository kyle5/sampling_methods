function [ computer_kriging_z_values, hand_kriging_z_values ] = ...
                        getHandAndComputerKrigingValues( hand_image_used, ...
                        pc_image_used, scaling_factor_hand_to_computer_count)
     
     global percentages;
     global scaling_factor_image;
     
     [ rows_cur_map, columns_cur_map ] = size(hand_image_used);
     total_sections = numel(hand_image_used);

     maxdist = scaling_factor_image * rows_cur_map;
     nrbins = rows_cur_map;
     
     % Multiply by the scaling factor and add an extra row and column
     % This way none of the points are on the edge of the image
     rows_cur_map_scaled = (rows_cur_map + 1) * scaling_factor_image;
     columns_cur_map_scaled = (columns_cur_map + 1) * scaling_factor_image;

     % X and Y will be used with every instance of the kriging() function
     [X,Y] = meshgrid(1:rows_cur_map_scaled, 1:columns_cur_map_scaled);
     
     % This function does kriging on images of hand and computer
     % counts to make the image appear smoother to the user
     num_percentages = size(percentages, 2);

     computer_kriging_z_values = cell(num_percentages);
     hand_kriging_z_values = cell(num_percentages);
     
     % Perhaps a compute percentages for computer counts and a compute
     % percentages for hand counts also
     
     for p = 1:num_percentages
         cur_percentage = percentages(1,p);
         number_of_sections_to_count_cur_percentage = floor(total_sections * cur_percentage / 100);
         
         rand_sections = randperm(total_sections);
         rand_sections_to_count = rand_sections( 1:number_of_sections_to_count_cur_percentage );
         
         newx = ones(number_of_sections_to_count_cur_percentage, 1);
         newy = ones(number_of_sections_to_count_cur_percentage, 1);
         newz_computer = ones(number_of_sections_to_count_cur_percentage, 1);
         newz_hand = ones(number_of_sections_to_count_cur_percentage, 1);
         
         % Easier to use index for indexing computer counts
         temp_i = 0;
         
         % Get values in expanded image
         for j = 1:rows_cur_map
            for k = 1:columns_cur_map
                current_place = ( j - 1 ) * ( columns_cur_map ) + k;
                if ismember(current_place, rand_sections_to_count)
                    temp_i = temp_i + 1;
                    current_computer_count_one_section = pc_image_used(j, k);
                    current_hand_count_one_section = hand_image_used(j, k);
                    
                    newx(temp_i, 1) = j * scaling_factor_image;
                    newy(temp_i, 1) = k * scaling_factor_image;
                    
                    newz_computer(temp_i, 1) = current_computer_count_one_section;
                    newz_hand(temp_i, 1) = current_hand_count_one_section;
                end
            end
         end
         
         % Scale the computer counts with the scaling factor
         newz_computer = newz_computer/scaling_factor_hand_to_computer_count;
         
         
         v_computer = variogram([ newx newy ], ...
             newz_computer,'plotit',false, 'maxdist', maxdist, 'nrbins', nrbins);
         [~,~,~,vstruct_computer] = variogramfit(v_computer.distance,v_computer.val,[],[],[],'model','exponential', 'plotit', false);
         [ Z_computer_value_returned_kriging, Z_error_computer ] = kriging(vstruct_computer, newx, newy, newz_computer, X, Y);
         
         computer_kriging_z_values{p} = Z_computer_value_returned_kriging;
         
         
         
         v_hand = variogram([ newx newy ], newz_hand, 'plotit', false, 'maxdist', maxdist, 'nrbins', nrbins);
         [~,~,~,vstruct_hand] = variogramfit(v_hand.distance,v_hand.val,[],[],[],'model','exponential', 'plotit', false);
         [Z_hand_value_returned_kriging, Z_error_hand] = kriging(vstruct_hand, newx, newy, newz_hand, X, Y);
         
         hand_kriging_z_values{p} = Z_hand_value_returned_kriging;
     
     end
end

