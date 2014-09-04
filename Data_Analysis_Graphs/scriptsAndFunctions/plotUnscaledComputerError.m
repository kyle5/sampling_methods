function plotUnscaledComputerError( all_computer_mean_errors_four_d, type_of_apple, parameters )
  % To do : Put in the makeDirectory() program
  % Use this form of adjusting the graphs to a max in the other programs
  loop_iterations = parameters.loop_iterations;
  area_in_orchard_for_error_calculation = parameters.area_in_orchard_for_error_calculation;
  names_of_orchard_areas = parameters.names_of_orchard_areas;
  percentages_to_check = parameters.percentages_to_check;
  
  str_orchard_area_sampled = names_of_orchard_areas{area_in_orchard_for_error_calculation};
  
  all_computer_mean_errors = all_computer_mean_errors_four_d(:,:,:,area_in_orchard_for_error_calculation);
  total_percentages = numel(percentages_to_check);
  
  offset_type_of_error_comp = parameters.num_sampling_strategies;
  string_type_of_count = 'Discontinuous Blocks';
  
  type_of_error_to_show_computer = offset_type_of_error_comp + 1;
  cur_computer_mean_errors = all_computer_mean_errors( :, :, type_of_error_to_show_computer );
  string_of_loop_iterations = num2str(loop_iterations);
  total_sections = size(all_computer_mean_errors, 2);
  all_sections = linspace(1, 100, total_sections);

  figure; hold all;
  cur_mean_error_computer_count = cur_computer_mean_errors(1, :);
  cur_percentage_mean_error_computer_count = cur_mean_error_computer_count * 100;
  plot(all_sections,cur_percentage_mean_error_computer_count);

  title_font_size = 16;    
  axis_font_size = 16;

  xlabel('Percentage of Total Sections Counted by the Algorithm', 'fontsize',axis_font_size,'fontweight','normal');
  ylabel('Error (Percent)', 'fontsize',axis_font_size,'fontweight','normal');

  inner_title = {[type_of_apple, ' : Error of Estimated Apples Counted by the Algorithm before Calibration'],['Sections Sampled in ', string_type_of_count, ' : ', str_orchard_area_sampled ]};
  title(inner_title, 'fontsize', title_font_size, 'fontweight', 'bold');

  legend_positions = 1;
  cell_array_titles = cell( 1, legend_positions );

  cur_string = ['Error of Estimated Apples Counted by the Algorithm before Calibration'];
  cell_array_titles{1, 1} = cur_string;

  legend( cell_array_titles );

  idx_over_ten_percent = find(all_sections > 5);
  first_idx_over_ten = idx_over_ten_percent(1);
  max_y = getMaxYForPlotting(cur_percentage_mean_error_computer_count(first_idx_over_ten:end), 10);
  min_y = getMinYForPlotting(cur_percentage_mean_error_computer_count(first_idx_over_ten:end), 0);
  axis( [0 100 min_y max_y ] );

  hold off;
end