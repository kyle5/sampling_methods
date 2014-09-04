function plotComputerError( all_computer_mean_errors_four_d, cur_dataset_id, type_of_error_to_show_comp, parameters )
  plot_unscaled = 0;
  percentages_to_check= parameters.percentages_to_check;
  str_orchard_area_sampled = parameters.names_of_orchard_areas{parameters.area_in_orchard_for_error_calculation};

  all_computer_mean_errors = all_computer_mean_errors_four_d(:,:,:,parameters.area_in_orchard_for_error_calculation);
  string_of_loop_iterations = num2str(parameters.loop_iterations);

  cur_computer_mean_errors = all_computer_mean_errors(:, :, type_of_error_to_show_comp);
  if parameters.hand_counts_are_dependent_variable == 1
    unscaled_computer_mean_errors = cur_computer_mean_errors(:, 1);
  else
    unscaled_computer_mean_errors = cur_computer_mean_errors(1, :);
  end
  
  if type_of_error_to_show_comp <= parameters.num_sampling_strategies
    string_type_of_count = 'Continuous Blocks';
  else
    string_type_of_count = 'Discontinuous Blocks';
  end

  x_axis_increments = size(all_computer_mean_errors, 2);
  total_percentages = numel(percentages_to_check);

  all_sections = linspace(1, 100, x_axis_increments);

  if strcmp(cur_dataset_id, 'Red Thinned')
    apple_str = 'Red Delicious Apples';
  else
    apple_str = 'Green Apples';
  end
  title_str = { apple_str };
  %title_str = { apple_str; 'Error of Estimated Apples Counted by the Algorithm' };
  h = figure('Name', 'Algorithm Error', 'position', [100, 100, 600, 500]);
  
  hold all;
  
  if plot_unscaled == 1
    unscaled_percentage_error_computer_count = unscaled_computer_mean_errors * 100;
    plot(all_sections, unscaled_percentage_error_computer_count, 'LineWidth', 3);
  end
  
% Kyle: TODO: Change the indexing of the variables for either hand or
% algorithm counts
  if parameters.hand_counts_are_dependent_variable == 1
    total_variable_section_length = size(cur_computer_mean_errors, 2);
  else
    total_variable_section_length = size(cur_computer_mean_errors, 1);
  end
  
  for i = 1:total_variable_section_length
    if (parameters.hand_counts_are_dependent_variable == 1)
      cur_mean_error_computer_count = cur_computer_mean_errors(:, i);
    else
      cur_mean_error_computer_count = cur_computer_mean_errors(i, :);
    end
    cur_percentage_mean_error_computer_count = cur_mean_error_computer_count * 100;
    plot( all_sections, cur_percentage_mean_error_computer_count, 'LineWidth', 3 );
  end

  title_font_size = 16;    
  axis_font_size = 18;

  if parameters.hand_counts_are_dependent_variable == 1
    xlabel('Percent of Orchard Hand Sampled', 'fontsize',axis_font_size,'fontweight','bold');
  else
    xlabel('Percent of Orchard Imaged', 'fontsize',axis_font_size,'fontweight','bold');
  end
  ylabel('Error (Percent)', 'fontsize',axis_font_size,'fontweight','bold');
  title(title_str, 'fontsize', title_font_size, 'fontweight', 'bold');

  if plot_unscaled == 1
    cur_string = 'Error of Estimated Apples Counted by the Algorithm before Calibration';
    cell_array_titles{1, 1} = cur_string;
    offset = 1;
  else
    offset = 0;
  end
  legend_positions = total_variable_section_length + offset;
  cell_array_titles = cell( 1, legend_positions);

  all_num_trees = [10, 20, 45];
  for i = 1:(legend_positions - offset)
    cur_percentage = percentages_to_check(1, i);
    trees_per_section = 3;
    %cur_string = [num2str(floor(cur_percentage/100*total_sections)*trees_per_section) ' Trees Hand Counted'];
    if parameters.hand_counts_are_dependent_variable == 1
      cur_string = [num2str(all_num_trees(i)) ' Trees Counted by the Algorithm'];
    else
      cur_string = [num2str(all_num_trees(i)) ' Trees Hand Counted'];
    end
    cell_array_titles{1, offset + i} = cur_string;
  end

  legend( cell_array_titles, 'FontSize', 16, 'FontWeight', 'bold' );

  idx_over_ten_percent = find(all_sections > 5);
  first_idx_over_ten = idx_over_ten_percent(1);

  if parameters.hand_counts_are_dependent_variable == 1
    plottingErrorValuesToAnalyze = [cur_mean_error_computer_count(first_idx_over_ten:end, :) * 100];
  else
    plottingErrorValuesToAnalyze = [cur_mean_error_computer_count(:, first_idx_over_ten:end) * 100];
  end
  if plot_unscaled == 1
    plottingErrorValuesToAnalyze  = [unscaled_percentage_error_computer_count(:, first_idx_over_ten:end); plottingErrorValuesToAnalyze ];
  end
  
  max_y = getMaxYForPlotting(plottingErrorValuesToAnalyze, 10);
  min_y = getMinYForPlotting(plottingErrorValuesToAnalyze, 0);
  axis( [0 100 0 50 ] );
  %max_y
  hold off;
  
  graph_directory_name = 'Computer Errors  : One Error Type';
  appleType_orchardArea_countType_graphType_dir = makeDirectory({'PNGs'; cur_dataset_id;...
      str_orchard_area_sampled; string_type_of_count; graph_directory_name; 'NotLineFitted'});

  filename = [appleType_orchardArea_countType_graphType_dir, '/computer_error_', string_of_loop_iterations, '_loop_iterations'];
  print(h, '-dpng', filename);
end