function plotHandCountErrorBarGraphs( all_hand_count_errors_four_d, type_of_apple, percentages_to_check, type_of_error_to_show_hand )

% To do : Make this a bar graph
    % Put in makeDirectory() at the bottom of the program

    global loop_iterations;
    global area_in_orchard_for_error_calculation;
    global names_of_orchard_areas;
    
    str_orchard_area_sampled = names_of_orchard_areas{area_in_orchard_for_error_calculation};
    
    all_hand_count_errors = all_hand_count_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    
    one_type_hand_errors = all_hand_count_errors( :, :, type_of_error_to_show_hand);
    
    string_of_loop_iterations = num2str(loop_iterations);

    total_sections = 10;
    total_percentages = numel(percentages_to_check);
    
    all_sections = linspace(1, 100, total_sections);

    if type_of_error_to_show_hand <= 2
        string_type_of_count = 'Continuous Blocks';
    else
        string_type_of_count = 'Discontinuous Blocks';
    end
    
    % There has got to be a for loop here, for each level of hand counts
    % that are possible
    
    title_one = [ type_of_apple, ' : ', 'Error of Estimated Apples Counted by Hand'];
    h = figure('Name', title_one, 'position', [100, 100, 600, 500]);
    
    title_two = {title_one, ['Sections Sampled in ', string_type_of_count, ' : ', str_orchard_area_sampled]};
    hold all;
    
    bar( 1:numel(percentages_to_check), one_type_hand_errors*100, 'stacked');
    
    title_font_size = 18;
    axis_font_size = 16;
    
    xlabel('Percentage of Total Sections Counted by Hand', 'fontsize',axis_font_size,'fontweight','normal');
    ylabel('Error (Percent)', 'fontsize',axis_font_size,'fontweight','normal');
    
    max_y = getMaxYForPlotting( one_type_hand_errors(:)*100, 10);
    axis([0, numel(percentages_to_check)+1, 0, max_y]);
    
    set(gca,'XTick', 1:numel(percentages_to_check))
    set(gca,'XTickLabel', percentages_to_check )
    
    title(title_two, 'fontsize', title_font_size, 'fontweight', 'bold');
   
    cell_array_titles = cell(1, total_percentages);
    for i = 1:total_percentages
        cur_percentage = percentages_to_check(1, i);
        cur_string = ['Error of Estimated Apples Counted by Hand : ' num2str(cur_percentage) '% of Sections Hand Counted'];
        cell_array_titles{1, i} = cur_string;
    end
    
    %legend( cell_array_titles );
    
    hold off;
    
    graph_directory_name = 'Hand Count Errors : One Error Type';
    full_dir_path = makeDirectory({'PNGs', type_of_apple, str_orchard_area_sampled,...
        string_type_of_count, graph_directory_name, 'NotLineFitted'});
    
    filename = [full_dir_path, '/hand_count_error_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
end