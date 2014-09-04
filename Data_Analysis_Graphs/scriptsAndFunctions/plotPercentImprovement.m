function plotPercentImprovement( all_hand_mean_errors_four_d, all_computer_mean_errors_four_d, percentages, type_of_apple, type_of_error_to_show_computer, type_of_error_to_show_hand, total_sections )    

    % perhaps use the flexible max_y program

    global loop_iterations;
    global area_in_orchard_for_error_calculation;
    global names_of_orchard_areas;
    
    str_orchard_area_sampled = names_of_orchard_areas{area_in_orchard_for_error_calculation};
    
    all_hand_mean_errors = all_hand_mean_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    all_computer_mean_errors = all_computer_mean_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
    
    string_of_loop_iterations = num2str(loop_iterations);
    x_axis_increments = size( all_computer_mean_errors, 2 );
    all_sections = linspace(1,100, x_axis_increments);
    
    number_of_percentages = size(percentages, 2);
    
    continuous_hand_counts = type_of_error_to_show_hand <= 2;
    continuous_comp_counts = type_of_error_to_show_computer <= 3;
    if continuous_comp_counts ~= continuous_hand_counts
        error('The type of computer and hand counts need to be the same');
    elseif continuous_hand_counts == 1 && continuous_comp_counts == 1 
        string_type_of_count = 'Continuous Blocks';
    else
        string_type_of_count = 'Discontinuous Blocks';
    end
    
    all_percent_improvement = [];
    for j = 1:number_of_percentages
        percent_improvement = [];
        
        computer_mean_errors_one_percentage = all_computer_mean_errors(j, :, type_of_error_to_show_computer );
        cur_hand_error = all_hand_mean_errors(j, 1, type_of_error_to_show_hand);
        
        for num_sections = 1:x_axis_increments
            cur_computer_error = computer_mean_errors_one_percentage(num_sections);
            cur_percent_improvement = 100 * ( cur_hand_error - cur_computer_error ) / cur_hand_error;
            percent_improvement = [percent_improvement, cur_percent_improvement];
        end    
        all_percent_improvement = [all_percent_improvement; percent_improvement];
    end
    
    if strcmp( type_of_apple, 'Green' )
      apple_spec = 'Granny Smith Apples';
    else
      apple_spec = 'Red Delicious Apples';
    end
    title_one = [apple_spec];
    h = figure( 'Name', title_one, 'Position', [100, 100, 600, 500] );
    
    %title_two = { title_one; 'Percentage Improvement : Algorithm over Hand Counting' };
    title_two = { title_one };
    hold all;
    
    for i = 1:number_of_percentages
        plot( all_sections, all_percent_improvement(i,:), 'LineWidth', 3 );
    end
    
    title( title_two, 'fontsize', 16,'fontweight','bold' );
    xlabel( 'Percent of Orchard Imaged', 'fontsize',18,'fontweight','bold' );
    ylabel( 'Percent Improvement','fontsize',18,'fontweight','bold' );
    
    cell_array_titles = cell(1, number_of_percentages);
    
  all_num_trees = [10, 20, 45];
    for i = 1:number_of_percentages
        cur_percentage = percentages(i);
        trees_per_section = 3;
        cur_string = [num2str(all_num_trees(i)) ' Trees Hand Counted'];
        %cur_string = [num2str(floor(cur_percentage/100*total_sections)*trees_per_section) ' Trees Hand Counted'];
        cell_array_titles{1, i} = cur_string;
    end
    
    hleg = legend( cell_array_titles, 'fontsize', 16, 'fontweight', 'bold' );
    set( hleg, 'String', cell_array_titles );
    
    axis([0 100 0 75]);
    hold off;
    
    graph_directory_name = 'Percent Improvement';
    appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; type_of_apple;...
        str_orchard_area_sampled; string_type_of_count; graph_directory_name; 'NotLineFitted'});
    
    filename = [appleType_orchardArea_countType_graphType_dir, '/percent_improvement_one_error_type_', string_of_loop_iterations, '_loop_iterations'];
    print(h, '-dpng', filename);
end