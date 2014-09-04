function [ grid_measurements_groundtruth, grid_measurements_image_results ] = load_map_data( local_parameters, data_file_csv_groundtruth, all_res_dirs, all_dataset_names )
  lat_lon_grid = [];
  [ lat_lon_grid_groundtruth, grid_measurements_groundtruth ] = my_temp_createMapFromDatafile( local_parameters, data_file_csv_groundtruth, lat_lon_grid );
  
  [all_results] = readImageEstimates(all_res_dirs, all_dataset_names);
  
  if numel(all_results) == 0
    disp('Every dataset was sampled sparsely, so no mapping will occur');
    return;
  end
  
  disp('finished reading estimates');
  %%%%%% extract measurements
  visible_fruit_per_m = all_results(:,5);
  valid=(visible_fruit_per_m>0);
  visible_fruit_per_m=visible_fruit_per_m(valid);
  all_lats = all_results(valid, 6);
  all_longs = all_results(valid, 7);
  harvestable_fruit_ratio = all_results(valid,8);
  
%   grid_step = 0.00001; % ! Hardcoded
  grid_step = 0.00005; % ! Hardcoded
%   measurement_smoothing_radius = 0.00008; % ! Hardcoded
  measurement_smoothing_radius = 0.00010; % ! Hardcoded
  threshold_too_few_measurements = 0.5; % ! Hardcoded
  
  colormaps = loadColorMaps();
  data_values = visible_fruit_per_m; % Keep this so that image results only come from the valid locations.   
  
  dataset_name='HarvestMonitorMap';
  map_name = 'Harvest Monitor';
  if (~exist('lat_lon_grid','var'))  
    lat_lon_grid=[];
  end
  [lat_lon_grid, grid_measurements_image_results] = smoothMeasurementsToGrid( all_lats, all_longs,map_name, data_values, grid_step, measurement_smoothing_radius, threshold_too_few_measurements, lat_lon_grid_groundtruth );
  figure, imagesc( grid_measurements_groundtruth );
  figure, imagesc( grid_measurements_image_results );
end