function plotOneHundredPercentComputerAndHandCountsSideBySide( original_size_of_image, cur_type_of_apple, hand_kriging_z_values, computer_kriging_z_values, scale_color_bar_per_tree, scaling_factor_image )

    title_font_size = 18;
    axis_font_size = 16;

    rows_cur_map = original_size_of_image(1, 1);
    columns_cur_map = original_size_of_image(1, 2);
    
    [ normalized_scaled_indicies_x, normalized_scaled_indicies_y ] = getScaledAndNormalizedIndices(columns_cur_map, rows_cur_map, scaling_factor_image );
    
    z_comp_100_percent = computer_kriging_z_values{1};
    z_hand_100_percent = hand_kriging_z_values{1};

    z_comp_100_percent_per_tree = z_comp_100_percent/3;
    z_hand_100_percent_per_tree = z_hand_100_percent/3;

    title_one = ['Yield Map ', cur_type_of_apple];
    h_1 = figure('Name', title_one, 'Position', [100, 100, 1300, 600]);

    % Show the hand counts
    subplot( 1, 2, 1 );
    imagesc( normalized_scaled_indicies_x, normalized_scaled_indicies_y, z_hand_100_percent_per_tree );
    t1 = colorbar('YTick', 1:scale_color_bar_per_tree);
    set(get(t1,'ylabel'),'String', 'Apples Counted Per Tree');
    caxis([0 scale_color_bar_per_tree]);
    title('Sections Counted by Hand : 100%', 'fontsize', title_font_size, 'fontweight', 'bold');
    ylabel('Section', 'fontsize', axis_font_size, 'fontweight', 'normal');
    xlabel('Row', 'fontsize', axis_font_size, 'fontweight', 'normal');
    set(gca,'YTick', 1:rows_cur_map);
    set(gca,'XTick', 1:columns_cur_map);

    subplot(1, 2, 2);
    imagesc(normalized_scaled_indicies_x, normalized_scaled_indicies_y, z_comp_100_percent_per_tree);
    t2 = colorbar('YTick', 1:scale_color_bar_per_tree);
    set(get(t2,'ylabel'),'String', 'Apples Counted Per Tree');
    caxis([0 scale_color_bar_per_tree]);
    title_two = ['Sections Counted by the Algorithm : 100%'];
    title( title_two, 'fontsize', title_font_size, 'fontweight', 'bold' );
    ylabel('Section', 'fontsize', axis_font_size, 'fontweight', 'normal');
    xlabel('Row', 'fontsize', axis_font_size, 'fontweight', 'normal');

    set(gca,'YTick', 1:rows_cur_map);
    set(gca,'XTick', 1:columns_cur_map);
    directory = makeDirectory({'PNGs/', cur_type_of_apple});
    filename = [directory, '/comparison_100_percent_hand_and_computer_counted'];
    print(h_1, '-dpng', filename);
end