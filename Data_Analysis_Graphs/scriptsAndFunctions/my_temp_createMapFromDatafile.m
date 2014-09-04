function [lat_lon_grid, grid_measurements] = my_temp_createMapFromDatafile( local_parameters, data_file_csv, lat_lon_grid )
 
  if(~exist('local_parameters','var'))
     addpath('..');
     local_parameters = load_local_parameters();
     setupPaths(local_parameters);
  end
  
  if(~exist('data_file_csv','var'))
    dialog_title_1 = 'Select Data File (.csv)';
    [data_file_csv, pathname] = uigetfile('*.csv', dialog_title_1 )
    data_file_csv = fullfile(pathname, data_file_csv);
  end
  
  [path file ext] = fileparts(data_file_csv);
  
  kml_dir=[local_parameters.ROOT_SOURCE_DIR, '/matlab/src/mapping/map_kml'];
  
%   grid_step = 0.00004; % ! Hardcoded
  grid_step = 0.00005; % ! Hardcoded
%   measurement_smoothing_radius = 0.00008; % ! Hardcoded
  measurement_smoothing_radius = 0.00010; % ! Hardcoded
  threshold_too_few_measurements = 0.5; % ! Hardcoded
  
  colormaps = loadColorMaps();
  
  raw_data = dlmread(data_file_csv, ',',  1);
  
  all_lats = raw_data(:,4);
  all_lons = raw_data(:,3);
  data_values=raw_data(:,5);
  
  dataset_name='HarvestMonitorMap';
  map_name = 'Harvest Monitor';
  if (~exist('lat_lon_grid','var'))  
    lat_lon_grid=[];
  end
  [lat_lon_grid, grid_measurements] = smoothMeasurementsToGrid(all_lats, all_lons,map_name, data_values, grid_step, measurement_smoothing_radius, threshold_too_few_measurements, lat_lon_grid);
end