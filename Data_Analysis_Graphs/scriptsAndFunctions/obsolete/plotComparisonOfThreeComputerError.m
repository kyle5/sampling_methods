function plotComparisonOfThreeComputerError( all_computer_mean_errors_four_d, type_of_apple, percentages_to_check, Show_Continuous_Blocks_Data, percentage_to_use )

    global loop_iterations;
    global area_in_orchard_for_error_calculation;
    
    all_computer_mean_errors = all_computer_mean_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    
    cur_percentage = percentages_to_check(percentage_to_use);
    all_computer_mean_errors_percentage = all_computer_mean_errors * 100;
    
    if Show_Continuous_Blocks_Data == 1
        offset_type_of_error_comp = 0;
        offset_type_of_error_hand = 0;
        string_type_of_count = 'Continuous Blocks';
    else
        offset_type_of_error_comp = 3;
        offset_type_of_error_hand = 2;
        string_type_of_count = 'Discontinuous Blocks';
    end
    
    computer_mean_errors_extrapolation = all_computer_mean_errors_percentage(percentage_to_use, :, offset_type_of_error_comp + 2);
    computer_mean_errors_kriging = all_computer_mean_errors_percentage(percentage_to_use, :, offset_type_of_error_comp + 3);
    computer_mean_errors_kriging_sf = all_computer_mean_errors_percentage(percentage_to_use, :, offset_type_of_error_comp + 1);

    string_of_loop_iterations = num2str(loop_iterations);
    
    total_sections = size(all_computer_mean_errors, 2);
    
    all_sections = linspace(1, 100, total_sections);
    
    figure_title = [type_of_apple, ' : Computer Count Error'];
    h = figure('Name', figure_title, 'position', [100, 100, 600, 500]);
    
    hold all;

    
    [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, computer_mean_errors_extrapolation);
    plot(all_sections, fh(all_sections,P))

    [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, computer_mean_errors_kriging);
    plot(all_sections, fh(all_sections,P))

    [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, computer_mean_errors_kriging_sf);
    plot(all_sections, fh(all_sections,P))
     
    
    title_font_size = 16;    
    axis_font_size = 16;
    
    xlabel('Percentage of Total Sections Computer Counted', 'fontsize',axis_font_size,'fontweight','normal');
    ylabel('Error (Percent)', 'fontsize',axis_font_size,'fontweight','normal');
    inner_title = [type_of_apple, ' : Computer Count Error from ', string_type_of_count];
    title(inner_title, 'fontsize', title_font_size, 'fontweight', 'bold');
    
    legend_positions = 3;
    cell_array_titles = cell( 1, legend_positions );
    
    cur_string_extrapolation = ['Extrapolation of Computer Counts : ' num2str(cur_percentage) '% of Sections Hand Counted'];
    cur_string_kriging = ['Kriging of Computer Counts : ' num2str(cur_percentage) '% of Sections Hand Counted'];
    cur_string_kriging_sf = ['Kriging of Computer Counts and SF Map : ' num2str(cur_percentage) '% of Sections Hand Counted'];
    
    
    cell_array_titles{1, 1} = cur_string_extrapolation;
    cell_array_titles{1, 2} = cur_string_kriging;
    cell_array_titles{1, 3} = cur_string_kriging_sf;
    
    legend( cell_array_titles );
    
    axis( [0 50 0 15] );
    hold off;
    
    
    appleType_dir = ['PNGs/', type_of_apple ];
    mkdir( appleType_dir );
    appleType_countType_dir = [appleType_dir, '/', string_type_of_count];
    mkdir( appleType_countType_dir );
    graph_directory_name = 'Comparison Three Computer Error Types';
    
    
    appleType_countType_graphType_dir = [appleType_countType_dir, '/', graph_directory_name, '/LineFitted'];
    mkdir(appleType_countType_graphType_dir);
    filename = [appleType_countType_graphType_dir, '/three_computer_errors_curve_fitting_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);

    cla(h);
    hold all;
    plot(all_sections, computer_mean_errors_extrapolation)
    plot(all_sections, computer_mean_errors_kriging)
    plot(all_sections, computer_mean_errors_kriging_sf)
    
    legend( cell_array_titles );
    
    
    appleType_countType_graphType_dir = [appleType_countType_dir, '/', graph_directory_name, '/NotLineFitted'];
    mkdir(appleType_countType_graphType_dir);
    filename = [appleType_countType_graphType_dir, '/three_computer_errors_no_curve_fitting_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
    
end