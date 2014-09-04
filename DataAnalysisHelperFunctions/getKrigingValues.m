function [ kriging_z_values ] = getKrigingValues( image_used, rand_sections_to_count, X, Y, scaling_factor_image )
    
    regular_image_size_y = mod( rand_sections_to_count - 1, size(image_used, 1) ) + 1;
    regular_image_size_x = floor( ( rand_sections_to_count - 1) / size(image_used, 1) ) + 1;
    input_z  = image_used( rand_sections_to_count );
    [ input_x, input_y ] = expandCoordinateValues( regular_image_size_x, regular_image_size_y, scaling_factor_image );
    
    maxdist = floor( size(X, 2)/3 );
    nrbins = 20;
    
    variogram_output = variogram([ input_x input_y ], ...
    input_z,'plotit',false, 'maxdist', maxdist, 'nrbins', nrbins);
    
    [ ~, ~, ~, vstruct ] = variogramfit( variogram_output.distance,variogram_output.val,[],[],[],'model','exponential', 'plotit', false );
    [ kriging_z_values, Z_error ] = kriging( vstruct, input_x, input_y, input_z, X, Y );
end