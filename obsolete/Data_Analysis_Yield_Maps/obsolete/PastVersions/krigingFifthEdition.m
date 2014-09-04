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

     % Got to get a scaling factor that I can use here
     total_sections = rows_cur_map * columns_cur_map;
     
     % Got to get an amount of sections to count
     newx_hand = ones(total_sections, 1);
     newy_hand = ones(total_sections, 1);
     newz_hand = ones(total_sections, 1);

     max_hand_count = 0;
     max_computer_count = 0;
     
     for j = 1:rows_cur_map
            for k = 1:columns_cur_map
                current_place = ( j - 1 ) * ( columns_cur_map ) + k;
                current_hand_count = hand_image_used(j, k);

                newx_hand(current_place, 1) = j * scaling_input_to_output;
                newy_hand(current_place, 1) = k * scaling_input_to_output;
                newz_hand(current_place, 1) = current_hand_count;

                if current_hand_count > max_hand_count
                    max_hand_count = current_hand_count;
                end
            end
     end
     
     maxdist = scaling_factor_image * rows_cur_map;
     nrbins = rows_cur_map;
     
     % Do kriging for all of the hand values
     v_hand = variogram([ newx_hand newy_hand ], newz_hand, 'plotit', false, 'maxdist', maxdist, 'nrbins', nrbins);
     [dum,dum,dum,vstruct_hand] = variogramfit(v_hand.distance,v_hand.val,[],[],[],'model','exponential', 'plotit', false);
     [Z_hand_values_returned_kriging, Z_error_hand] = kriging(vstruct_hand, newx_hand, newy_hand, newz_hand, X, Y);

     newx_all_computer_counts = cell(1, 3);
     newy_all_computer_counts = cell(1, 3);
     newz_all_computer_counts = cell(1, 3);

     max_computer_counts = [];
     
     percentages = [100];
     num_percentages = size(percentages, 2);

     for p = 1:num_percentages
         cur_percentage = percentages(:,p);
         number_of_sections_to_count_cur_percentage = floor(total_sections * cur_percentage / 100);
         
         rand_sections = randperm(total_sections);
         rand_sections_to_count = rand_sections( 1:number_of_sections_to_count_cur_percentage );
         
         newx_computer = ones(number_of_sections_to_count_cur_percentage, 1);
         newy_computer = ones(number_of_sections_to_count_cur_percentage, 1);
         newz_computer = ones(number_of_sections_to_count_cur_percentage, 1);
         
         hand_count_scaling_factor = 0;
         computer_count_scaling_factor = 0;
         cur_max_computer_count = 0;
         cur_comp_count = 0;
         
         % Get values in expanded image
         for j = 1:rows_cur_map
            for k = 1:columns_cur_map
                if ismember(current_place, rand_sections_to_count)
                    
                    cur_comp_count = cur_comp_count + 1;
                    
                    current_hand_count = hand_image_used(j, k);
                    current_computer_count = pc_image_used(j, k);

                    hand_count_scaling_factor = hand_count_scaling_factor + current_hand_count;
                    computer_count_scaling_factor = computer_count_scaling_factor + current_computer_count;

                    newx_computer(cur_comp_count, 1) = j * scaling_input_to_output;
                    newy_computer(cur_comp_count, 1) = k * scaling_input_to_output;
                    newz_computer(cur_comp_count, 1) = current_computer_count;
                    
                    if current_computer_count > cur_max_computer_count
                        cur_max_computer_count = current_computer_count;
                    end
                end
            end
         end
         cur_map_should_be_scaled = scale_map(1, i);
         if cur_map_should_be_scaled == 1
             scaling_factor_hand_to_computer_count = computer_count_scaling_factor / hand_count_scaling_factor;
             
             newz_computer = newz_computer/scaling_factor_hand_to_computer_count;
         end
         max_computer_counts = [max_computer_counts, cur_max_computer_count];
         newx_all_computer_counts{1, p} = newx_computer;
         newy_all_computer_counts{1, p} = newy_computer;
         newz_all_computer_counts{1, p} = newz_computer;
     end

     computer_kriging_z_values = [];
     computer_kriging_error_values = [];
     
     for j = 1:num_percentages
         curx_computer = newx_all_computer_counts{:,j};
         cury_computer = newy_all_computer_counts{:,j};
         curz_computer = newz_all_computer_counts{:,j};

         v_computer = variogram([ curx_computer cury_computer ], ...
             curz_computer,'plotit',false, 'maxdist', maxdist, 'nrbins', nrbins);
         [dum,dum,dum,vstruct_computer] = variogramfit(v_computer.distance,v_computer.val,[],[],[],'model','exponential', 'plotit', false);
         [Z_computer_value_returned_kriging, Z_error_computer] = kriging(vstruct_computer, curx_computer, cury_computer, curz_computer, X, Y);
         fprintf('The size of the array is : %d by %d \n', size(Z_computer_value_returned_kriging,1), size(Z_computer_value_returned_kriging,2));
         computer_kriging_z_values(:,:,j) = Z_computer_value_returned_kriging;
     end
     
     
     z_comp_100_percent = computer_kriging_z_values(:,:,1);
     z_comp_error_percent = Z_error_computer(:,:,1);
     
     
     normalized_scaled_indicies_x = scaled_x_indicies / scaling_factor_image;
     normalized_scaled_indicies_y = scaled_y_indicies / scaling_factor_image;
     
     %Get the data in per tree terms instead of per section terms
     Zhat_computer = z_comp_100_percent/3;
     Zhat_hand = Z_hand_values_returned_kriging/3;
     
     first_max_count = max_computer_counts(:, 1);
     max_computer_count = floor(first_max_count/3);
     max_hand_count = floor(max_hand_count/3);
     
     scale_color_bar = max(max_computer_count, max_hand_count) * 1.2;
     
     cur_type_of_apple = apple_types{i, :};
     title_one = ['Productivity Map ', cur_type_of_apple];
     figure('Name', title_one, 'Position', [400, 400, 1200, 500]);
     
     subplot(3, 2, [1 2]);
     % Show the hand counts
     imagesc(normalized_scaled_indicies_x, normalized_scaled_indicies_y, Zhat_hand);
     t2 = colorbar('YTick', 1:scale_color_bar);
     set(get(t2,'ylabel'),'String', 'Apples Counted Per Tree');
     caxis([0 scale_color_bar]);

     title('Yield Map - Ground Truth', 'fontsize', 12, 'fontweight', 'bold');
     ylabel('Sections', 'fontsize', 12, 'fontweight', 'normal');
     xlabel('Rows', 'fontsize', 12, 'fontweight', 'normal');
     set(gca,'YTick', 1:columns_cur_map);
     set(gca,'XTick', 1:rows_cur_map);

     
     total_graph_places = num_percentages + 2;
     
     for j = 3:total_graph_places
         % Show each of the computer counts
         subplot(3, 2, j)
         
     imagesc(normalized_scaled_indicies_x, normalized_scaled_indicies_y, Zhat_computer);
     t1 = colorbar('YTick', 1:scale_color_bar);
     set(get(t1,'ylabel'),'String', 'Apples Counted Per Tree');
     
     caxis([0 scale_color_bar]);
     title('Yield Map - Computer Count', 'fontsize', 12, 'fontweight', 'bold');
     ylabel('Sections', 'fontsize', 12, 'fontweight', 'normal');
     xlabel('Rows', 'fontsize', 12, 'fontweight', 'normal');
     set(gca,'YTick', 1:columns_cur_map);
     set(gca,'XTick', 1:rows_cur_map);
     
         
     end
 end