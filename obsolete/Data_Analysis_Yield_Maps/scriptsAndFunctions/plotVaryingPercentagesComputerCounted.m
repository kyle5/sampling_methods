function plotVaryingPercentagesComputerCounted( original_size_of_image, cur_type_of_apple, hand_kriging_z_values, computer_kriging_z_values, percentages, scale_color_bar_per_tree, scaling_factor_image, scaling_factor_counts_percent )

    title_font_size = 18;
    axis_font_size = 16;

    rows_cur_map = original_size_of_image(:, 1);
    columns_cur_map = original_size_of_image(:, 2);

    flag_plot_varying_percentages_in_one_graph = 0;
    num_percentages = numel(percentages);
    [ normalized_scaled_indicies_x, normalized_scaled_indicies_y ] = getScaledAndNormalizedIndices( columns_cur_map, rows_cur_map, scaling_factor_image );
    
    str_scaling_factor_num_sections = num2str(scaling_factor_counts_percent);
    if scaling_factor_counts_percent == 0
        scaling_factor_string = '';
    else
        scaling_factor_string = ['Scaling Factor Computed with ', str_scaling_factor_num_sections, ' of Percent of Total Sections'];
    end
    
    hold all;
    if flag_plot_varying_percentages_in_one_graph == 1
        title_one = ['Yield Map - Varying Levels of Computer Counts - ', cur_type_of_apple];
        h_1 = figure('Name', title_one, 'Position', [100, 100, 1000, 1200]);
        subplot(2, 2, 1);
        z_hand_100_percent = hand_kriging_z_values{1};
        z_hand_100_percent_per_tree = z_hand_100_percent/3;
        imagesc( normalized_scaled_indicies_x, normalized_scaled_indicies_y, z_hand_100_percent_per_tree );
        title_one = { [ cur_type_of_apple ], [ 'Yield Map - Counted by Hand' ] };
        title( title_one, 'fontsize', title_font_size, 'fontweight', 'bold');
    else
        h_2 = figure('Name', 'Computer Count');
        z_comp_100_percent = computer_kriging_z_values{1};
        z_comp_100_percent_per_tree = z_comp_100_percent/3;
        imagesc( normalized_scaled_indicies_x, normalized_scaled_indicies_y, z_comp_100_percent_per_tree );
        title_one = { [ cur_type_of_apple ], [ 'Sections Counted by the Algorithm : 100%' ] };
        title( title_one, 'fontsize', title_font_size, 'fontweight', 'bold');
    end

    % Show the hand counts in the first subplot
    t1 = colorbar('YTick', 1:scale_color_bar_per_tree);
    set( get( t1,'ylabel' ), 'String', 'Apples Counted Per Tree' );
    caxis( [ 0 scale_color_bar_per_tree ] );
    ylabel('Section', 'fontsize', axis_font_size, 'fontweight', 'normal');
    xlabel('Row', 'fontsize', axis_font_size, 'fontweight', 'normal');
    set(gca,'YTick', 1:rows_cur_map);
    set(gca,'XTick', 1:columns_cur_map);

    if flag_plot_varying_percentages_in_one_graph ~= 1
        cur_percentage = percentages(1);
        string_of_percentage = num2str(cur_percentage);
        filename = ['PNGs/', cur_type_of_apple, '/computer_counted_', string_of_percentage, '_percent_sampled'];
        print(h_2, '-dpng', filename);
    end
        
    % For each computer count percentage setup a subplot to show the computer counts
    % over that percentage
    for j = 2:num_percentages
        cur_percentage = percentages(j);
        string_of_percentage = num2str(cur_percentage);

        if flag_plot_varying_percentages_in_one_graph == 1
            subplot(2, 2, j);
        else
            h_2 = figure('Name', 'Computer Count');
        end

        % Apple counts per section
        z_comp_cur_percent = computer_kriging_z_values{j};

        % Convert from per section terms to per tree terms
        z_comp_cur_percent_per_tree = z_comp_cur_percent/3;
        imagesc( normalized_scaled_indicies_x, normalized_scaled_indicies_y, z_comp_cur_percent_per_tree );

        t2 = colorbar('YTick', 1:scale_color_bar_per_tree);
        set(get(t2,'ylabel'),'String', 'Apples Counted Per Tree');

        caxis([0 scale_color_bar_per_tree]);
        title_one = { [cur_type_of_apple], ['Sections Counted by the Algorithm : ', string_of_percentage, '%']};
        title(title_one, 'fontsize', title_font_size, 'fontweight', 'bold');
        ylabel('Section', 'fontsize', axis_font_size, 'fontweight', 'normal');
        xlabel('Row', 'fontsize', axis_font_size, 'fontweight', 'normal');
        set(gca, 'YTick', 1:rows_cur_map);
        set(gca, 'XTick', 1:columns_cur_map);
        
        if flag_plot_varying_percentages_in_one_graph ~= 1
            filename = ['PNGs/', cur_type_of_apple, '/computer_counted_', string_of_percentage, '_percent_sampled'];
            print(h_2, '-dpng', filename);
        end
    end
    if flag_plot_varying_percentages_in_one_graph == 1
        filename = ['PNGs/', cur_type_of_apple, '/computer_counted_every_percentage_in_one_figure'];
        print(h_1, '-dpng', filename);
    end
    hold off;

end