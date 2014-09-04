function plotOneMap( cur_type_of_apple, scale_color_bar_min, scale_color_bar_max,...
    z_values, rows_cur_map, columns_cur_map, plotting_indicies_x, plotting_indicies_y, Title, ColorBarTitle, filename )
     
     title_font_size = 18;
     axis_font_size = 16;
     
     % This shows only the complete hand and computer counts side by side
        % More concise presentation and better looking, but less information 
        
    title_one = ['Yield Map ', cur_type_of_apple];
    h_1 = figure('Name', title_one, 'Position', [100, 100, 1300, 600]);

    imagesc( plotting_indicies_x, plotting_indicies_y, z_values );
    
    t1 = colorbar('YTick', scale_color_bar_min:scale_color_bar_max);
    set(get(t1,'ylabel'),'String', ColorBarTitle );
    caxis([scale_color_bar_min scale_color_bar_max]);
    
    title( Title, 'fontsize', title_font_size, 'fontweight', 'bold');
    ylabel('Section', 'fontsize', axis_font_size, 'fontweight', 'normal');
    xlabel('Row', 'fontsize', axis_font_size, 'fontweight', 'normal');
    set(gca,'YTick', 1:rows_cur_map);
    set(gca,'XTick', 1:columns_cur_map);
    
    print(h_1, '-dpng', filename);
end