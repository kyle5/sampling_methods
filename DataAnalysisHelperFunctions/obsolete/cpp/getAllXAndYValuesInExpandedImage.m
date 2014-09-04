//function [ X, Y ] = getAllXAndYValuesInExpandedImage( rows_cur_map, columns_cur_map, scaling_factor_image )

std::pair< vector<int>, vector<int> > getAllXAndYValuesInExpandedImage( int rows_cur_map, int columns_cur_map, int scaling_factor_image ) {
	int rows_cur_map_scaled = (rows_cur_map + 1) * scaling_factor_image;
	int columns_cur_map_scaled = (columns_cur_map + 1) * scaling_factor_image;
	
	vector<int> X = ;
	vector<int> Y = ;
	int count = 0;
	for(int i = 0; i < rows_cur_map_scaled; i++) {
		for(int j = 0; j < columns_cur_map_scaled; j++) {
			
		}
	}
	[X,Y] = meshgrid(1:rows_cur_map_scaled, 1:columns_cur_map_scaled);
}
