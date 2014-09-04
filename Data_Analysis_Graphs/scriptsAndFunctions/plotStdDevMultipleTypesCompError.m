function plotStdDevMultipleTypesCompError( std_dev_computer_errors_four_d, type_of_apple, percentages_to_check, Show_Continuous_Blocks_Data, percentage_to_use )


    % Get the correct directory structure
    % Use makeDirectory()
    
    global loop_iterations;
    global area_in_orchard_for_error_calculation;
    
    global names_of_orchard_areas;
    
    str_orchard_area_sampled = names_of_orchard_areas(area_in_orchard_for_error_calculation);
    
    std_dev_computer_errors = std_dev_computer_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    
    total_sections = size(all_comp_std_dev_errors, 2);
    
    if Show_Continuous_Blocks_Data == 1
        offset_type_of_error_comp = 0;
        string_type_of_count = 'Continuous Blocks';
    else
        offset_type_of_error_comp = 4;
        string_type_of_count = 'Discontinuous Blocks';
    end
    
    cur_comp_count_error_std_dev_de = std_dev_computer_errors(percentage_to_use, :, offset_type_of_error_comp + 4 );
    cur_comp_count_error_std_dev_kriging = std_dev_computer_errors(percentage_to_use, :, offset_type_of_error_comp + 1 );
    cur_percentage = percentages_to_check(percentage_to_use);
    
    string_of_loop_iterations = num2str( loop_iterations );
    
    all_sections = linspace(1, 100, total_sections);

    title_one = [ type_of_apple, ' : ', 'Comparison of Computer Count Error Standard Deviation : Sections in ', string_type_of_count];
    
    h = figure('Name', title_one, 'position', [100, 100, 600, 500]);
    
    hold all;

    cur_percentage_comp_count_error_std_dev_de = cur_comp_count_error_std_dev_de * 100;
    cur_percentage_comp_count_error_std_dev_kriging = cur_comp_count_error_std_dev_kriging * 100;
    

    plot( all_sections, cur_percentage_comp_count_error_std_dev_de );
    plot( all_sections, cur_percentage_comp_count_error_std_dev_kriging );

    title_font_size = 18;
    axis_font_size = 16;
    
    xlabel('Total Sections Computer Counted (Percent)', 'fontsize',axis_font_size,'fontweight','normal');
    ylabel('Standard Deviation of Percentage Error', 'fontsize',axis_font_size,'fontweight','normal');
    
    title(title_one, 'fontsize', title_font_size, 'fontweight', 'bold');
   
    legend_positions = 2;
    cell_array_titles = cell( 1, legend_positions );
    
    cur_string_extrapolation = ['Standared Deviation of Error : Extrapolation of Computer Counts : ' num2str(cur_percentage) '% of Sections Hand Counted'];
    cur_string_kriging = ['Standared Deviation of Error : Kriging of Computer Counts and Scaling Factors : ' num2str(cur_percentage) '% of Sections Hand Counted'];

    cell_array_titles{1, 1} = cur_string_extrapolation;
    cell_array_titles{1, 2} = cur_string_kriging;
    
    legend( cell_array_titles );
    
    max_y = getMaxYForPlotting( [cur_percentage_comp_count_error_std_dev_de(:); cur_percentage_comp_count_error_std_dev_kriging(:) ], 10);
    axis( [0 50 0 max_y] );
    hold off;
    
    graph_directory_name = 'Std Deviation Computer: Multiple Error Types';
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
        str_orchard_area_sampled; string_type_of_count; graph_directory_name; 'NotLineFitted'});
    
    filename = [ appleType_orchardArea_countType_graphType_dir,  '/comp_count_std_dev_of_error_comparison_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
    
    clf();
    
    hold on;
    [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, cur_comp_count_error_plot_std_dev_de);
    plot(all_sections, fh(all_sections,P));
        
    [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, cur_comp_count_error_plot_std_dev_kriging);
    plot(all_sections, fh(all_sections,P));
    
        
    legend( cell_array_titles );
    axis( [0 50 0 max_y] );
    hold off;
    
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
        str_orchard_area_sampled; string_type_of_count; graph_directory_name; 'LineFitted'});
    
    filename = [ appleType_orchardArea_countType_graphType_dir,  '/comp_count_std_dev_of_error_comparison_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
end