function [ output_args ] = plotAllGraphs( cur_type_of_apple, max_hand_count, max_computer_count,...
    computer_kriging_z_values, hand_kriging_z_values, scaling_factor_hand_to_computer_count, hand_image_used)

     global flag_varying_percentages_hand_count;
     global flag_varying_percentages_computer_count;
     global flag_plot_varying_percentages_in_one_graph;
     global flag_100_percent_computer_count_and_hand_count;
     global scaling_factor_image;
     global percentages;
     
     title_font_size = 18;
     axis_font_size = 16;
     
     original_size_of_image;
     
     num_percentages = numel(percentages);
     
     [ rows_cur_map, columns_cur_map ] = size(hand_image_used);
     
     % Multiply by the scaling factor and add an extra row and column
     % This way none of the points are on the edge of the image
     rows_cur_map_scaled = (rows_cur_map + 1) * scaling_factor_image;
     columns_cur_map_scaled = (columns_cur_map + 1) * scaling_factor_image;
     
     scaled_x_indicies = 1:(rows_cur_map_scaled);
     scaled_y_indicies = 1:(columns_cur_map_scaled);
     
     normalized_scaled_indicies_x = scaled_x_indicies / scaling_factor_image;
     normalized_scaled_indicies_y = scaled_y_indicies / scaling_factor_image;

     z_comp_100_percent = computer_kriging_z_values{1};
     z_hand_100_percent = hand_kriging_z_values{1};
     
     z_comp_100_percent_per_tree = z_comp_100_percent/3;
     z_hand_100_percent_per_tree = z_hand_100_percent/3;
     
     % This sets up the max range of the color map.
     scale_color_bar_per_section = max(max_computer_count, max_hand_count)*1.1;
     disp(size(scale_color_bar_per_section));
     
     % Setup scalebar by tree instead of by section
     scale_color_bar_per_tree = scale_color_bar_per_section / 3;

     % This sets up the string of the scaling factor, which can be shown in
     % each of the graphs
     actual_scaling_factor_string = sprintf('%.3g', 1/scaling_factor_hand_to_computer_count);
     if scaling_factor_hand_to_computer_count ~= 1
        scaling_factor_final = [' Scaling Factor of ', actual_scaling_factor_string];
     else
        scaling_factor_final = 'No Scaling Factor Applied';
     end
     
     % This shows the yield maps of varying percentages of the computer counts, along with
     % the 100 percent hand counts for comparison
     if flag_varying_percentages_hand_count == 1
         
     end
     
     % This shows the yield maps of varying percentages of the computer counts, along with
     % the 100 percent hand counts for comparison
     if flag_varying_percentages_computer_count == 1
         
     end
     
     % This shows only the complete hand and computer counts side by side
        % More concise presentation and better looking, but less information 
     if flag_100_percent_computer_count_and_hand_count == 1
        title_one = ['Yield Map ', cur_type_of_apple];
        h_1 = figure('Name', title_one, 'Position', [100, 100, 1300, 600]);
        
        % Show the hand counts
        subplot(1, 2, 1);
        imagesc(normalized_scaled_indicies_x, normalized_scaled_indicies_y, z_hand_100_percent_per_tree);
        %t1 = colorbar('YTick', 1:scale_color_bar_per_tree);
        %set(get(t1,'ylabel'),'String', 'Apples Counted Per Tree');
        caxis([0 scale_color_bar_per_tree]);
        title('Ground Truth', 'fontsize', title_font_size, 'fontweight', 'bold');
        ylabel('Section', 'fontsize', axis_font_size, 'fontweight', 'normal');
        xlabel('Row', 'fontsize', axis_font_size, 'fontweight', 'normal');
        set(gca,'YTick', 1:columns_cur_map);
        set(gca,'XTick', 1:rows_cur_map);
        
        subplot(1, 2, 2);
        imagesc(normalized_scaled_indicies_x, normalized_scaled_indicies_y, z_comp_100_percent_per_tree);
        %t2 = colorbar('YTick', 1:scale_color_bar_per_tree);
        %set(get(t2,'ylabel'),'String', 'Apples Counted Per Tree');
        caxis([0 scale_color_bar_per_tree]);
        title_two = ['Computer Count'];
        title( title_two, 'fontsize', title_font_size, 'fontweight', 'bold' );
        ylabel('Section', 'fontsize', axis_font_size, 'fontweight', 'normal');
        xlabel('Row', 'fontsize', axis_font_size, 'fontweight', 'normal');
        
        set(gca,'YTick', 1:columns_cur_map);
        set(gca,'XTick', 1:rows_cur_map);
        
        filename = ['PNGs/', cur_type_of_apple, '/comparison_100_percent_hand_and_computer_counted'];
        print(h_1, '-dpng', filename);
     end
end