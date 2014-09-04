function plotVaryingPercentagesHandCounted( original_size_of_image, cur_type_of_apple, hand_kriging_z_values, percentages, scale_color_bar_per_tree, scaling_factor_image )

     title_font_size = 18;
     axis_font_size = 16;

     rows_cur_map = original_size_of_image(:, 1);
     columns_cur_map = original_size_of_image(:, 2);
     
     flag_plot_varying_percentages_in_one_graph = 0;
     num_percentages = numel(percentages);
     [ normalized_scaled_indicies_x, normalized_scaled_indicies_y ] = getScaledAndNormalizedIndices(columns_cur_map, rows_cur_map, scaling_factor_image );
     
     title_one = ['Yield Map - Varying Levels of Hand Counts - ', cur_type_of_apple];

     if flag_plot_varying_percentages_in_one_graph == 1
        h_1 = figure('Name', title_one, 'Position', [100, 100, 1000, 1200]);
     end

     % For each percentage setup a subplot to show the computer counts
     % over that percentage
     for j = 1:num_percentages
         cur_percentage = percentages(j);
         string_of_percentage = num2str(cur_percentage);
         if flag_plot_varying_percentages_in_one_graph == 1
            subplot(2, 2, j)
         else
            h_2 = figure('Name', 'Hand Count');
         end
         z_hand_cur_percent = hand_kriging_z_values{j};

         % Convert from per section terms to per tree terms
         z_hand_cur_percent_per_tree = z_hand_cur_percent/3;
         imagesc(normalized_scaled_indicies_x, normalized_scaled_indicies_y, z_hand_cur_percent_per_tree);

         t1 = colorbar('YTick', 1:scale_color_bar_per_tree);
         set(get(t1,'ylabel'),'String', 'Apples Counted Per Tree');
         caxis([0 scale_color_bar_per_tree]);

         title_one = { [cur_type_of_apple], ['Sections Counted by Hand : ', string_of_percentage, '%' ] };
         title(title_one, 'fontsize', title_font_size, 'fontweight', 'bold');
         ylabel('Section', 'fontsize', axis_font_size, 'fontweight', 'normal');
         xlabel('Row', 'fontsize', axis_font_size, 'fontweight', 'normal');
         set(gca,'YTick', 1:rows_cur_map);
         set(gca,'XTick', 1:columns_cur_map);

         caxis([0 scale_color_bar_per_tree]);

         if flag_plot_varying_percentages_in_one_graph ~= 1
            filename = ['PNGs/', cur_type_of_apple, '/hand_counted_', '', string_of_percentage, '_percent_sampled'];
            print(h_2, '-dpng', filename);
         end
     end
     
     if flag_plot_varying_percentages_in_one_graph == 1
        filename = ['PNGs/', cur_type_of_apple, '/hand_counted_every_percentage_in_one_figure'];
        print(h_1, '-dpng', filename);
     end
end

