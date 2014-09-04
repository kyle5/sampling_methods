//

#include <map>
#include <vector>

vector < int > get_spread_out_locations( sections_map, cur_sections_algorithm_counted ) {
	vector < int > spread_out_locations;
	// do the spacing algorithm that I read about
	return spread_out_locations;
}

std::map< int, vector< vector<int> > > get_all_spatial_diverse_maps( vector< int > sections_algorithm_counted_vector, Mat sections_map ) {
	std::map spatially_diverse_maps< int, vector< vector<int> > >;
	
	for ( int i = 0; i < sections_algorithm_counted_vector.size(); i++ ) {
		int cur_sections_algorithm_counted = sections_algorithm_counted_vector[i];
		// setup the map using the iteration scheme described in the paper that I last read
		
		vector <int> spread_out_locations = get_spread_out_locations( sections_map, cur_sections_algorithm_counted );
		spatially_diverse_maps[cur_sections_algorithm_counted] = spread_out_locations;
	}
	
	return spatially_diverse_maps;
}
