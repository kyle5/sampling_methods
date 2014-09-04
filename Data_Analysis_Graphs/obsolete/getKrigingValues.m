function [ kriging_z_values ] = getKrigingValues( expanded_map_values, X, Y )
     % I've also got to have an option so the user can select either row or
     % random sampling of tree locations
     [ rows_expanded_map, columns_expanded_map ] = size( X );
     
     maxdist = rows_expanded_map;
     nrbins = 10;
     
     % This is where I can put the two forms of getting random sections:
     % Either by row or by random selection
     
     input_x = expanded_map_values(:, 1);
     input_y = expanded_map_values(:, 2);
     input_z = expanded_map_values(:, 3);
     
     % Perhaps a compute percentages for computer counts and a compute
     % percentages for hand counts also
     variogram_output = variogram([ input_x input_y ], ...
         input_z,'plotit',false, 'maxdist', maxdist, 'nrbins', nrbins);
     [ ~, ~, ~, vstruct ] = variogramfit( variogram_output.distance,variogram_output.val,[],[],[],'model','exponential', 'plotit', false );
     [ kriging_z_values, Z_error ] = kriging( vstruct, input_x, input_y, input_z, X, Y );
end