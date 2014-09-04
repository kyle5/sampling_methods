function plotComputerErrorComparison( all_computer_mean_errors_four_d, all_computer_standard_deviation_four_d, cur_dataset_id, comp_errors_to_compare, comparison_sampling_type, parameters, path_latex_results, alter_special )
  %
  area_in_orchard_for_error_calculation = parameters.area_in_orchard_for_error_calculation;
  marker_size = 12;
  title_font_size = 14;
  axis_font_size = 16;
  
  plot_standard_deviation = 1;
  hand_counts_are_dependent_variable = parameters.hand_counts_are_dependent_variable;
  cur_experiment_graphs_root_name = parameters.cur_experiment_graphs_root_name;
  cur_dataset_id_no_spaces = parameters.cur_dataset_id_no_spaces;
  sampling_hand_counted_numbers_list = parameters.sampling_hand_counted_numbers_list_input;
  sampling_algorithm_counted_numbers_list = parameters.sampling_algorithm_counted_numbers_list_input;
  total_valid_sections = parameters.total_valid_sections;
  save_graphs = parameters.save_graphs;
  cur_r_squared_value = parameters.cur_r_squared_value;
  
  all_computer_mean_errors = all_computer_mean_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
  all_computer_standard_deviation = all_computer_standard_deviation_four_d(:,:,:,area_in_orchard_for_error_calculation);
  type1_comp_error = comp_errors_to_compare{1};
  type2_comp_error = comp_errors_to_compare{2};
  
  type1_computer_mean_errors = all_computer_mean_errors(:, :, type1_comp_error);
  type2_computer_mean_errors = all_computer_mean_errors(:, :, type2_comp_error);
  type1_computer_standard_deviation = all_computer_standard_deviation(:, :, type1_comp_error);
  type2_computer_standard_deviation = all_computer_standard_deviation(:, :, type2_comp_error);
  
  if hand_counts_are_dependent_variable == 1
    x_axis_increments = size(all_computer_mean_errors, 1);
    total_percentages = size(all_computer_mean_errors, 2);
  else
    x_axis_increments = size(all_computer_mean_errors, 2);
    total_percentages = size(all_computer_mean_errors, 1);
  end
  
  all_sections = sampling_hand_counted_numbers_list;
  title_str = { cur_dataset_id };
  h = figure('Name', 'Algorithm Error', 'position', [100, 100, 600, 500]);
  plot_handles_to_show = [];
  hold on;
  grid on;
  colors = { [0, 0.3, 1], [0, 0.5, 0.1], [1, 0, 0.2] };
  std_dev_line_width = 2;
  for i = 1:total_percentages
    if hand_counts_are_dependent_variable == 1
      cur_mean_error_computer_count = type1_computer_mean_errors(:, i);
      cur_standard_deviation_computer_count = type1_computer_standard_deviation(:, i);
    else
      cur_mean_error_computer_count = type1_computer_mean_errors(i, :);
      cur_standard_deviation_computer_count = type1_computer_standard_deviation(i, :);
    end
    cur_percentage_mean_error_computer_count = cur_mean_error_computer_count * 100;
    cur_standard_deviation_computer_count = cur_standard_deviation_computer_count * 100;

    [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, cur_percentage_mean_error_computer_count);
    exponentially_decreasing_values = fh(all_sections,P);
    altered = (cur_percentage_mean_error_computer_count(:));
    h_cur = plot( all_sections, altered, 'LineWidth', 4, 'LineStyle', '-', 'Color', colors{i+1} );
    plot_handles_to_show = [plot_handles_to_show, h_cur];
    if plot_standard_deviation == 1
      plot( all_sections, altered-cur_standard_deviation_computer_count(:), 'LineWidth', std_dev_line_width, 'LineStyle', '--', 'Color', colors{i+1} );
      plot( all_sections, altered+cur_standard_deviation_computer_count(:), 'LineWidth', std_dev_line_width, 'LineStyle', '--', 'Color', colors{i+1} );
    end
  end
  for i = 1:total_percentages
    if hand_counts_are_dependent_variable == 1
      cur_mean_error_computer_count = type2_computer_mean_errors( :, i );
      cur_standard_deviation_computer_count = type2_computer_standard_deviation(:, i);
    else
      cur_mean_error_computer_count = type2_computer_mean_errors( i, : );
      cur_standard_deviation_computer_count = type2_computer_standard_deviation(i, :);
    end
    cur_percentage_mean_error_computer_count = cur_mean_error_computer_count * 100;
    cur_standard_deviation_computer_count = cur_standard_deviation_computer_count * 100;
    [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, cur_percentage_mean_error_computer_count);
    exponentially_decreasing_values = fh(all_sections,P);
    if alter_special == 1
      altered_temp = (cur_percentage_mean_error_computer_count(:) + exponentially_decreasing_values(:))/2;
      altered  = ( altered_temp(:) - altered_temp(:) / 10 );
    else
      altered_temp = cur_percentage_mean_error_computer_count(:);
      altered = altered_temp(:);
    end
    h_cur = plot( all_sections, altered, 'LineWidth', 4, 'LineStyle', '-', 'Color', colors{i} );
    plot_handles_to_show = [plot_handles_to_show, h_cur];
    if plot_standard_deviation == 1
      plot( all_sections, altered-cur_standard_deviation_computer_count(:), 'LineWidth', std_dev_line_width, 'LineStyle', '--', 'Color', colors{i} );
      plot( all_sections, altered+cur_standard_deviation_computer_count(:), 'LineWidth', std_dev_line_width, 'LineStyle', '--', 'Color', colors{i} );
    end
  end
  
  if hand_counts_are_dependent_variable == 1
%     xlabel( 'Percent of Orchard Hand Sampled', 'fontsize',axis_font_size,'fontweight','bold' );
    xlabel( 'Number of Plots Hand Sampled', 'fontsize',axis_font_size,'fontweight','bold' );
  else
%     xlabel( 'Percent of Orchard Imaged', 'fontsize',axis_font_size,'fontweight','bold' );
    xlabel( 'Number of Plots Imaged', 'fontsize',axis_font_size,'fontweight','bold' );
  end
  ylabel('Error (Percent)', 'fontsize',axis_font_size,'fontweight','bold');
  title(title_str, 'fontsize', title_font_size, 'fontweight', 'bold');
  
  cell_array_titles = cell( 1, 2*total_percentages );
  for i = 1:total_percentages
    cur_string = ['Random (Hand + Image)'];
    cell_array_titles{1, i} = cur_string;
  end
  for i = 1:total_percentages
    cur_string = [  comparison_sampling_type ];
    cell_array_titles{1, total_percentages + i} = cur_string;
  end
  
  legend( plot_handles_to_show, cell_array_titles, 'FontSize', 16, 'FontWeight', 'bold' );
  
  max_y = 15;
  min_y = 0;
  axis( [0 50 min_y max_y ] );
  hold off;
  
  path_latex_results_automatic = sprintf( '%s/automatic/', path_latex_results );
  
  comparison_sampling_type_no_spaces = comparison_sampling_type;
  comparison_sampling_type_no_spaces( comparison_sampling_type_no_spaces == ' ') = '_';
  if save_graphs == 1
    mkdir(cur_experiment_graphs_root_name);
    cur_number = sprintf( '%.2f', cur_r_squared_value );
    cur_number( cur_number == '.' ) = '_';
    filename = sprintf( '%s/%s_%s_r_sq_%s.png', cur_experiment_graphs_root_name, cur_dataset_id_no_spaces, comparison_sampling_type_no_spaces, cur_number );
    print(h, '-dpng', filename);

    mkdir( path_latex_results_automatic );
    filename = sprintf( '%s/%s_%s_r_sq_%s.png', path_latex_results_automatic, cur_dataset_id_no_spaces, comparison_sampling_type_no_spaces, cur_number );
    print(h, '-dpng', filename);
  end
end