function plotHandCountErrorGraph( all_hand_count_errors_four_d, type_of_apple, parameters )
    
    loop_iterations = parameters.loop_iterations;
    area_in_orchard_for_error_calculation = parameters.area_in_orchard_for_error_calculation;
    names_of_orchard_areas = parameters.names_of_orchard_areas;
    
    str_orchard_area_sampled = names_of_orchard_areas{area_in_orchard_for_error_calculation};
    string_of_loop_iterations = num2str(loop_iterations);
    
    all_hand_count_errors = all_hand_count_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    
    total_sections = numel(all_hand_count_errors);
    all_sections = linspace(1, 100, total_sections);
    
    title_font_size = 16;    
    axis_font_size = 16;
    
    percentage_mean_error_hand_count = all_hand_count_errors * 100;
    
    figure_title = [type_of_apple, ' : Hand Count Error'];
    h = figure('Name', figure_title, 'position', [100, 100, 600, 500]);
    
    hold all;
    
    plot(all_sections, percentage_mean_error_hand_count);
    xlabel('Total Sections Counted by Hand (Percent)', 'fontsize',axis_font_size,'fontweight','normal');
    ylabel('Error (Percent)', 'fontsize',axis_font_size,'fontweight','normal');
    
    inner_title_one = {[ type_of_apple, ' - Hand Count Error'], str_orchard_area_sampled };
    title(inner_title_one, 'fontsize', title_font_size, 'fontweight', 'bold');
    
    legend_positions = 1;
    cell_array_titles = cell( 1, legend_positions );
    
    cur_string = 'Hand Count Error';
    cell_array_titles{1, 1} = cur_string;

    legend( cell_array_titles );
    
    idx_over_ten_percent = find(all_sections > 5);
    first_idx_over_ten = idx_over_ten_percent(1);
    max_y = getMaxYForPlotting(percentage_mean_error_hand_count(first_idx_over_ten:end), 10);
    axis( [0 100 0 max_y ] );
    
    hold off;
    
    string_type_of_count = 'Discontinuous Blocks';
    
    graph_directory_name = 'Hand Count Errors : Graph Form';
    full_dir_path = makeDirectory({'PNGs', type_of_apple, str_orchard_area_sampled,...
        string_type_of_count, graph_directory_name, 'NotLineFitted'});
    
    filename = [full_dir_path, '/hand_counts_graph_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
end