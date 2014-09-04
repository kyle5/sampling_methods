#include "get_random_points_new_object_model.h"
#include "get_rp_helper_functions.h"

#include <stdlib.h>

using namespace std;
using namespace cv;

typedef vector< vector< double > > v_o_d;
typedef vector< cv::Point2f > v_p2f;
typedef cv::Mat mat;
typedef std::pair< v_p2f, vector < int > > one_type;
typedef std::pair< v_o_d, v_o_d > two_type;		

void SamplingObjectModel::generate_random_new(vector<Point_2_new> &points, unsigned npoints, MTRand &rng)
{
		points.reserve(npoints);
		for (unsigned i = 0; i < npoints; ++i) {
		    Point_2_new p(rng.randExc(), rng.randExc());
		    points.push_back(p);
		}
}

void SamplingObjectModel::generate_darts_new(vector<Point_2_new> &points, unsigned npoints, MTRand &rng)
{
		const double rnorm  = 0.725;
		const double mdnorm = sqrt(SQRT3 * 0.5 * npoints);
		const double md     = rnorm / mdnorm;
		const double sqr_md = md * md;
		
		points.reserve(npoints);
		while (points.size() < npoints) {
		    while (true) {
		        Point_2_new cand(rng.randExc(), rng.randExc());
		        bool hit = true;
		        for (unsigned i = 0; i < points.size(); ++i) {
		            if (sqr_dist_unit_torus(cand, points[i]) < sqr_md) {
		                hit = false;
		                break;
		            }
		        }
		        if (hit) {
		            points.push_back(cand);
		            break;
		        }
		    }
		}
}

void SamplingObjectModel::update_statistics_new(const DT_new &dt, unsigned it, double &global_md, double &avg_md, bool output ) {
		dt.get_statistics(global_md, avg_md);
		
		const double mdnorm = sqrt(SQRT3 * 0.5 * dt.number_of_vertices());
		global_md *= mdnorm;
		avg_md    *= mdnorm;
		
		if (output)
		    std::cout << std::fixed << std::setprecision(6) << std::setw(5)
		    << it << " " << global_md << " " << avg_md << "\n";
}

void SamplingObjectModel::usage_new() {
		std::cout << "usage: fpo [options] [#points] [seed]\n\n"
		    "Options\n"
		    "  --help            show this message\n"
		    "  --max-iter n      maximum number of iterations (10000*)\n"
		    "  --max-mindist n   maximum mindist (0.925*)\n"
		    "  --strategy x      set optimization strategy (local,global*,hybrid)\n"
		    "  --silent          only print summary at the end\n";
}

void SamplingObjectModel::get_random_points_new( unsigned max_iter, double max_md, Strategy_new strategy, bool silent, unsigned npoints, unsigned long seed_variable, Mat algorithm_counts, double weight_spatial, Mat valid_counts ) {
	
	int disconsider_edge_points = 0;
	int edge_buffer = 1;
	
	final_points.clear();
	indices_at_each_iteration_in_spatial_space.clear();
	spatial_probability_in_spatial_space.clear();
	stratified_probability_in_spatial_space.clear();
	combined_stratified_and_spatial_probability_in_spatial_space.clear();
	distribution_indices_in_spatial_space.clear();
	stratified_indices_organized_by_spatial_indices.clear();
	spatial_distance_in_spatial_space.clear();
	stratified_distance_in_spatial_space.clear();
	all_set_error_values.clear();
	all_spatial_metric_scores.clear();
	all_stratified_metric_scores.clear();

	double weight_stratified = 1.0 - weight_spatial;
	
	srand (time(NULL));
	
	MTRand rng(seed_variable);
	double global_md = 0;
	double avg_md    = 0;
	double old_avg   = avg_md;
	
	// Initial points
	vector<Point_2_new> points;
	generate_random_new(points, npoints, rng);
	
	// Set up initial triangulation
	DT_new dt(points, true);

	update_statistics_new(dt, 0, global_md, avg_md, !silent);
	
	unsigned it = 0;
	vector<VH_new> neighbors;
	neighbors.reserve(10);
	
	vector<int> all_stratified_indices = get_all_stratified_indices( valid_counts, algorithm_counts );
	int total_possible_points = (int) ( sum( valid_counts )[0] );

	bool total_breakout = false;
	unsigned order[npoints];
	for (unsigned i = 0; i < npoints; ++i) order[i] = i;
	shuffle(order, npoints, rng);

	bool interruptFlag_new = false;
	while (!interruptFlag_new) {
		for (unsigned i = 0; i < npoints; ++i) {
		  unsigned r = order[i];
		  Point_2_new cand = dt.get_vertex(r)->point();
			
			Point2f cur_pt_Point2f( (double) cand.x(), (double) cand.y() );
			vector< Point2f > temp_vector_Point2f;
			temp_vector_Point2f.push_back(cur_pt_Point2f);
			vector<int> all_vertex_point_indices = get_point_indices_new( valid_counts, temp_vector_Point2f );
			
		  neighbors.clear();                 // Candidate's neighborhood
		  dt.incident_vertices(r, neighbors);
		  double cand_md = DBL_MAX;          // Candidate's local mindist
		  for (unsigned ii = 0; ii < neighbors.size(); ++ii) {
		    cand_md = std::min(cand_md, CGAL::squared_distance(cand, neighbors[ii]->point()));
		  }
		  Circle_2_new c(cand, cand_md);         // Empty circle about candidate
		  // Remove candidate
		  dt.clear_vertex( r );
		  // Search for largest circumcircle in triangulation
		  FH_new face;
		  // Get the entire list of circles
			// Largest circumference is at the back
			vector< Circle_2_new > list_of_circles = dt.global_sorted_circumcircles();
			circumference_check( list_of_circles );
			vector< Circle_2_new > list_of_circles_altered = list_of_circles;
			vector<Point2f> all_other_vertex_coordinates = get_point_coordinates_new( npoints, order, dt, r );
			vector< Point2f > index_point_centers = get_all_index_point_centers( algorithm_counts );
			vector< double > closest_distances = get_closest_distances( index_point_centers, all_other_vertex_coordinates );
			for ( int ii = 0; ii < (int) index_point_centers.size(); ii++ ) {
				Circle_2_new new_circle( Point_2_new( index_point_centers[ii].x, index_point_centers[ii].y ), closest_distances[ii] );
				list_of_circles_altered.push_back( new_circle );
			}
			Circle_2_new original_circle(cand, cand_md);
			list_of_circles_altered.push_back( original_circle );
			int original_idx_before_sorting = (int) list_of_circles_altered.size()-1; // Do not remove this line!! It is needed to find the original point index
			vector < pair < Circle_2_new, int > > sorted_list_of_circles_altered = sort_and_return_indices_specified_function( list_of_circles_altered, &circle_2_new_comparison_function );
			int original_index_after_sorting = -1;
			for(int ii = 0; ii < sorted_list_of_circles_altered.size(); ii++) {
				if ( sorted_list_of_circles_altered[ii].second == original_idx_before_sorting ) {
					original_index_after_sorting = ii;
					break;
				}
			}
			if ( original_index_after_sorting == -1 ) throw std::runtime_error( "original_index_after_sorting == -1" );
			vector< Point2f > circumcircle_center_coordinates = get_circle_coordinates_new( list_of_circles_altered );
			vector< double > spatial_distribution = create_spatial_distribution_new( list_of_circles_altered );
			vector<int> point_indices = get_point_indices_new( algorithm_counts, all_other_vertex_coordinates );
			vector<int> cur_stratified_indices = get_stratified_point_indices_in_possible_space( point_indices, all_stratified_indices );
			vector<bool> stratified_point_indices_b = get_stratified_occupied_locations_new( cur_stratified_indices, total_possible_points );
			vector< int > circumcircle_point_indices = get_point_indices_new( algorithm_counts, circumcircle_center_coordinates );
			// get the distance for all of the circumcircle points possible
			// Kyle: TODO: now compute the distance over stratified_point_indices_in_possible_space
			vector<int> cur_stratified_circumcircle_point_indices = get_stratified_point_indices_in_possible_space( circumcircle_point_indices, all_stratified_indices );
			vector<double> circumcircle_average_distances = get_average_distance_for_possible_points_new( stratified_point_indices_b, cur_stratified_circumcircle_point_indices );
			// create the distribution cooresponding to the stratified counts
			vector<double> stratified_distribution = create_stratified_distribution_new( (int) circumcircle_point_indices.size() );
			vector<double> stratified_distribution_organized_by_spatial_indices = vector<double>((int) stratified_distribution.size(), 0);

			// sort the stratified distances:
			// This is in the reverse order of what it should be!
			vector < pair < double, int > > sorted_stratified_distances_copy;
			vector < pair < double, int > > sorted_stratified_distances = sort_and_return_indices( circumcircle_average_distances );
			sorted_stratified_distances = sorted_stratified_distances_copy;
			// The first point index in the sorted_stratified_distances is the point with the highest distribution:
			// second is the second highest, etc...
			// Make its index have the greatest probability
			for( int jj = 0; jj < (int) sorted_stratified_distances.size(); jj++ ) {
				int corresponding_spatial_index = sorted_stratified_distances[jj].second;
				stratified_distribution_organized_by_spatial_indices[ corresponding_spatial_index ] = stratified_distribution[jj];
			}
			
			// Check that both distributions are normalized
			double total_spatial_distribution_check = 0, total_stratified_distribution_check = 0;
			for( int jj = 0; jj < (int) spatial_distribution.size(); jj++ ) total_spatial_distribution_check += spatial_distribution[jj];
			for( int jj = 0; jj < (int) stratified_distribution_organized_by_spatial_indices.size(); jj++ ) total_stratified_distribution_check += stratified_distribution_organized_by_spatial_indices[jj];
			if ( abs(total_spatial_distribution_check-1) > 0.01 ) {
				fprintf(stderr, "%.2f\n", total_spatial_distribution_check);
				throw std::runtime_error( "sum( spatial_distribution(:) ) != 1" );
			}
			if ( abs(total_stratified_distribution_check-1) > 0.01 ) {
				fprintf(stderr, "%.2f\n", total_stratified_distribution_check);
				throw std::runtime_error( "sum( stratified_distribution(:) ) != 1" );
			}
			if ( (int) spatial_distribution.size() != (int) stratified_distribution.size() ) {
				fprintf( stderr, "spatial_distribution.size(): %d\nstratified_distribution.size(): %d\n", (int) spatial_distribution.size(), (int) stratified_distribution.size() );
				throw std::runtime_error( "(int) spatial_distribution.size() != (int) stratified_distribution.size()");
			}
			vector< int > valid_circumcircle_point_indices;
			vector<double> combined_distribution = vector<double>( (int) stratified_distribution.size(), 0 );
			double total_combined = 0;
			for ( int jj = 0; jj < (int) spatial_distribution.size(); jj++ ) {
				double cur_combined = 0;
				if ( valid_circumcircle_point_indices[jj] == 1 ) {
					cur_combined = weight_stratified * stratified_distribution_organized_by_spatial_indices[jj] + weight_spatial * spatial_distribution[jj];
				}
				combined_distribution[jj] = cur_combined;
				total_combined += cur_combined;
			}
			if (total_combined < 0.01) {
				combined_distribution[0] = 1;
				total_combined = 1;
			}
			for ( int jj = 0; jj < (int) combined_distribution.size(); jj++ ) {
				combined_distribution[jj] = combined_distribution[jj] / total_combined;
			}
			if ( disconsider_edge_points == 1 ) {
				for ( int ii = 0; ii < (int) combined_distribution.size(); ii++ ) {
					int cur_index = circumcircle_point_indices[ii];
					int cur_row_index = cur_index % algorithm_counts.rows;
					int cur_column_index = cur_index / algorithm_counts.rows;
					if ( cur_row_index < edge_buffer || cur_row_index >= (algorithm_counts.rows-edge_buffer) || cur_column_index < edge_buffer || cur_column_index >= (algorithm_counts.cols-edge_buffer) ) {
						combined_distribution[ii] = 0;
					}
				}
			}
			// Change the combined distribution to:
			// 	only consider the highest indices of the combined distribution
			int number_of_indices_to_consider = 3;
			vector< double > combined_distribution_copy = combined_distribution;
			vector< pair < double, int> > sorted_combined_distribution = sort_and_return_indices( combined_distribution_copy );
			int indices_to_eliminate = (int) sorted_combined_distribution.size() - number_of_indices_to_consider;
			//double combined_distribution_sum_before = sum_distribution( combined_distribution );
			for( int ii = 0; ii < indices_to_eliminate; ii++ ) {
				combined_distribution[ sorted_combined_distribution[ii].second ] = 0;
			}
			combined_distribution = normalize_distribution( combined_distribution );
			verify_distribution_sum( combined_distribution );
			int distribution_idx = -1;
			double cur_random = ((double) rand() / (RAND_MAX));
			double cur_start = 0, cur_end = 0;
			double total_combined_dist = 0;
			for ( int jj = 0; jj < (int) combined_distribution.size(); jj++ ) {
				cur_end += combined_distribution[jj];
				if ( cur_start < cur_random && cur_random < cur_end ) {
					distribution_idx = jj;
				}
				cur_start = cur_end;
				total_combined_dist += combined_distribution[jj];
			}
			if ( abs(total_combined_dist - 1 ) > 0.01 ) {
				fprintf( stderr, "%.2f\n", total_combined_dist );
				throw std::runtime_error( "The combined distribution does not equal 1!");
			}
			if ( combined_distribution[distribution_idx] < combined_distribution[original_index_after_sorting] ) {
				distribution_idx = original_index_after_sorting;
			}
			vector<int> indices_each_iteration_cur_vector;
			// Update the indices that have been chosen for the current iteration
			if ( distribution_idx > ((int) list_of_circles_altered.size() - 1) ) {
				fprintf( stderr, "distribution_idx: %d\nlist_of_circles_altered.size-1: %d\n", distribution_idx, (int) list_of_circles_altered.size()-1 );
				throw std::runtime_error("The distribution idx is greater than the distribution array length?!");
			}
			// check that distribution_idx is within list_of_circles, otherwise reuse the previous point that was taken out of the graph
			Circle_2_new best_circle = list_of_circles_altered[ distribution_idx ];
			// check that the new indices probability is absolutely higher than the old indices probability
			Point_2_new l_center = wrap_unit_torus(best_circle.center());
			if (l_center.x() < 0 || l_center.x() > 1 || l_center.y() < 0 || l_center.y() > 1 ) {
				throw std::runtime_error("The best center is out of range?!");
			}
			dt.set_vertex(r, l_center, face);
			// spatial distance organized according to spatial distribution points
			vector< double > distances_in_spatial_space;
			
			vector <Point2f> vector_removed_and_added_pt_temp;
			Point2f point2f_removed( cand.x(), cand.y() );
			Point2f point2f_added( l_center.x(), l_center.y() );
			vector< int > vector_removed_and_added_pt_indices = get_point_indices_new( algorithm_counts, vector_removed_and_added_pt_temp );
			vector<int> final_point_indices = point_indices;
		}
		++it;
		update_statistics_new(dt, it, global_md, avg_md, !silent);

		if ( total_breakout ) break;
		if (it >= max_iter || global_md >= max_md) break;
		if (avg_md - old_avg == 0.01) break;
		old_avg = avg_md;
	}

	// need to setup final_points to be of type one_type
	final_points = dt.return_vertices_points();
	vector<int> all_point_indices; for (int i = 0; i < algorithm_counts.rows*algorithm_counts.cols; i++ ) { all_point_indices.push_back( i ); }
}

double spatial_metric( vector< int > final_point_indices, Mat algorithm_counts ) {
	vector< double > all_closest_distances;
	double total_distances_temp = 0, cur_closest_distance = 0;
	// get the points 
	for ( int i = 0; i < (int) final_point_indices.size(); i++ ) {
		cur_closest_distance = algorithm_counts.rows+algorithm_counts.cols;
		for ( int j = 0; j < (int) final_point_indices.size(); j++ ) {
			if ( i == j ) continue;
			int index_one = final_point_indices[i];
			int index_two = final_point_indices[j];
			// get x and y of the point
			double cur_dist = distance_between_indices( algorithm_counts, index_one, index_two );
			if ( cur_dist < cur_closest_distance  ) cur_closest_distance = cur_dist;
		}
		all_closest_distances.push_back( cur_closest_distance );
		total_distances_temp += cur_closest_distance;
	}
	// average the closest distance measurements to get the score
	return total_distances_temp / (double) final_point_indices.size();
}

double distance_between_indices( const Mat algorithm_counts, int index_one, int index_two ) {
	int x_one = index_one / algorithm_counts.rows;
	int y_one = index_one % algorithm_counts.rows;
	int x_two = index_two / algorithm_counts.rows;
	int y_two = index_two % algorithm_counts.rows;
	double delta_x = (double) x_two - x_one;
	double delta_y = (double) y_two - y_one;
	return sqrt( pow( delta_x, 2 ) + pow( delta_y, 2 ) );
}

double stratified_metric( vector< int > final_point_indices, Mat algorithm_counts, Mat ground_counts, vector<int> all_stratified_indices, int total_possible_points ) {
	vector<double> all_closest_distances;
	double total_closest_distances = 0;
	for ( int i = 0; i < (int) final_point_indices.size(); i++ ) {
		int cur_pt_idx = final_point_indices[i];
		vector<int> other_indices;
		for (int j = 0; j < (int) final_point_indices.size(); j++) {
			if ( i == j ) continue;
			other_indices.push_back(final_point_indices[j]);
		}
		vector<int> cur_stratified_indices = get_stratified_point_indices_in_possible_space( other_indices, all_stratified_indices );
		vector<bool> stratified_point_indices_b = get_stratified_occupied_locations_new( cur_stratified_indices, total_possible_points );
		vector< int > cur_point_index_vector;
		cur_point_index_vector.push_back(cur_pt_idx);
		vector<int> cur_pt_stratified_index_vector = get_stratified_point_indices_in_possible_space( cur_point_index_vector, all_stratified_indices );
		vector<double> cur_pt_stratified_average_distance = get_average_distance_for_possible_points_new( stratified_point_indices_b, cur_pt_stratified_index_vector );
		
		// compute the distance between other_indices and final_point_indices
		// get stratified locations
		total_closest_distances += cur_pt_stratified_average_distance[0];
	}
	return total_closest_distances/(double)final_point_indices.size();
}

template void verify_distribution_sum<double>( vector<double> vector_input );
template <class T > void verify_distribution_sum( vector<T> vector_input ) {
	T total_distribution = 0;
	for (int i = 0; i < (int)vector_input.size(); i++) {
		total_distribution = total_distribution + vector_input[i];
	}
	if ( abs(total_distribution-1 ) > 0.02 ) throw std::runtime_error("distribution does not sum to 1.");
}

template double sum_distribution( vector<double> vector_input );
template <class T> T sum_distribution( vector<T> vector_input ) {
	T total_distribution = 0;
	for (int i = 0; i < (int)vector_input.size(); i++) {
		total_distribution = total_distribution + vector_input[i];
	}
	return total_distribution;
}

template vector<double> normalize_distribution<double>( vector<double> vector_input );
template <class T > vector< T > normalize_distribution( vector<T> vector_input ) {
	T total_distribution = sum_distribution( vector_input );
	if ( total_distribution == 0) throw std::runtime_error("Cannot normalize a distribution that sums to 0.");
	vector<T> normalized_distribution = vector_input;
	for (int i = 0; i < (int) normalized_distribution.size(); i++) {
		normalized_distribution[i] = normalized_distribution[i] / total_distribution;
	}
	return normalized_distribution;
}

vector< double > get_closest_distances( vector<Point2f> index_point_centers, vector<Point2f> all_other_vertex_coordinates ) {
	vector< double > closest_distances;
	for( int i = 0; i < (int) index_point_centers.size(); i++ ) {
		Point2f cur_pt = index_point_centers[i];
		double cur_closest_distance = 100000;
		for( int j = 0; j < (int) all_other_vertex_coordinates.size(); j++ ) {
			double cur_distance = sqrt( pow( (all_other_vertex_coordinates[j].y - cur_pt.y), 2 ) + pow( (all_other_vertex_coordinates[j].x - cur_pt.x), 2 ) );
			if ( cur_distance < cur_closest_distance ) {
				cur_closest_distance = cur_distance;
			}
		}
		closest_distances.push_back( cur_closest_distance );
	}
	return closest_distances;
}

void SamplingObjectModel::circumference_check( vector< Circle_2_new > list_of_circles ) {
	double cur_sr, last_sr;
	last_sr = -1;
	for ( int i = 0; i < (int) list_of_circles.size(); i++ ) {
		cur_sr = list_of_circles[i].squared_radius();
		if ( cur_sr > last_sr ) {
			last_sr = cur_sr;
		}
	}
	for ( int i = 0; i < (int) list_of_circles.size(); i++ ) {
		cur_sr = list_of_circles[i].squared_radius();
		if (cur_sr > last_sr) {
			for ( int j = 0; j <= i; j++ ) {
				fprintf( stderr, "final circumference outputs: %d\t%.8f\n", i, list_of_circles[i].squared_radius() );
			}
			throw std::runtime_error("The squared radii are not ordered in the way that I had thought");
		} else last_sr = cur_sr;
	}
}

vector< Point2f > SamplingObjectModel::get_final_points(  ) {
	return final_points;
}

vector< Point2f > get_all_index_point_centers( Mat algorithm_counts ) {
	double width_each_cell = 1.0 / algorithm_counts.cols;
	double height_each_cell = 1.0 / algorithm_counts.rows;
	vector< Point2f > index_point_centers;
	for ( int i = 0; i < algorithm_counts.cols; i++ ) {
		for ( int j = 0; j < algorithm_counts.rows; j++ ) {
			double cur_x = width_each_cell*i + width_each_cell*0.5;
			double cur_y = height_each_cell*j + height_each_cell*0.5;
			Point2f cur_point2f( cur_x, cur_y );
			index_point_centers.push_back( cur_point2f );
		}
	}
	return index_point_centers;
}

vector<int> get_stratified_point_indices_in_possible_space( vector<int> point_indices, vector<int> all_stratified_indices ) {
	vector<int> cur_stratified_indices;
	for ( int i = 0; i < (int) point_indices.size(); i++ ) {
		int cur_farm_plot_idx = point_indices[i];
		int cur_stratified_index = all_stratified_indices[cur_farm_plot_idx];
		cur_stratified_indices.push_back( cur_stratified_index );
	}
	return cur_stratified_indices;
}

bool circle_2_new_comparison_function( pair< Circle_2_new, int> pair_1, pair< Circle_2_new, int > pair_2 ) {
	return pair_1.first.squared_radius() > pair_2.first.squared_radius();
}
