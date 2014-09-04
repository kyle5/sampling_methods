function [ output_args ] = plotOneMap( cur_type_of_apple, max_count,...
    z_values, rows_cur_map, columns_cur_map, scaling_factor_image, Title, ColorBarTitle, filename )
     
     title_font_size = 18;
     axis_font_size = 16;
     
     % Multiply by the scaling factor and add an extra row and column
     % This way none of the points are on the edge of the image
     rows_cur_map_scaled = (rows_cur_map + 1) * scaling_factor_image;
     columns_cur_map_scaled = (columns_cur_map + 1) * scaling_factor_image;
     
     scaled_x_indicies = 1:(rows_cur_map_scaled);
     scaled_y_indicies = 1:(columns_cur_map_scaled);
     
     normalized_scaled_indicies_x = scaled_x_indicies / scaling_factor_image;
     normalized_scaled_indicies_y = scaled_y_indicies / scaling_factor_image;

     trees_per_a_section = 6;
     
     % This sets up the max range of the color map.
     scale_color_bar = max_count * 1.1;
     
     % This shows only the complete hand and computer counts side by side
        % More concise presentation and better looking, but less information 
     
    title_one = ['Yield Map ', cur_type_of_apple];
    h_1 = figure('Name', title_one, 'Position', [100, 100, 1300, 600]);

    % Show the hand counts

    imagesc( normalized_scaled_indicies_x, normalized_scaled_indicies_y, z_values );
    
    t1 = colorbar('YTick', 1:scale_color_bar);
    set(get(t1,'ylabel'),'String', ColorBarTitle );
    caxis([0 scale_color_bar]);
    
    title( Title, 'fontsize', title_font_size, 'fontweight', 'bold');
    ylabel('Section', 'fontsize', axis_font_size, 'fontweight', 'normal');
    xlabel('Row', 'fontsize', axis_font_size, 'fontweight', 'normal');
    set(gca,'YTick', 1:columns_cur_map);
    set(gca,'XTick', 1:rows_cur_map);
    
    
    
    print(h_1, '-dpng', filename);
    
end