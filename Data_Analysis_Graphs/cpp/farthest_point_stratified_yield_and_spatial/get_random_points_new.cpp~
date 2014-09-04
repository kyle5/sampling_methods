#include "get_random_points_new.h"
#include "get_rp_helper_functions.h"

#include <stdlib.h>

//temp

using namespace std;
using namespace cv;

typedef vector< vector< double > > v_o_d;
typedef vector< cv::Point2f > v_p2f;
typedef cv::Mat mat;
typedef std::pair< v_p2f, vector < int > > one_type;
typedef std::pair< v_o_d, v_o_d > two_type;

void generate_random_new(vector<Point_2_new> &points, unsigned npoints, MTRand &rng)
{
    points.reserve(npoints);
    for (unsigned i = 0; i < npoints; ++i) {
        Point_2_new p(rng.randExc(), rng.randExc());
        points.push_back(p);
    }
}

void generate_darts_new(vector<Point_2_new> &points, unsigned npoints, MTRand &rng)
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

void update_statistics_new(const DT_new &dt, unsigned it, double &global_md, double &avg_md, bool output ) {
    dt.get_statistics(global_md, avg_md);
    
    const double mdnorm = sqrt(SQRT3 * 0.5 * dt.number_of_vertices());
    global_md *= mdnorm;
    avg_md    *= mdnorm;
    
    if (output)
        std::cout << std::fixed << std::setprecision(6) << std::setw(5)
        << it << " " << global_md << " " << avg_md << "\n";
}


void usage_new() {
    std::cout << "usage: fpo [options] [#points] [seed]\n\n"
        "Options\n"
        "  --help            show this message\n"
        "  --max-iter n      maximum number of iterations (10000*)\n"
        "  --max-mindist n   maximum mindist (0.925*)\n"
        "  --strategy x      set optimization strategy (local,global*,hybrid)\n"
        "  --silent          only print summary at the end\n";
}

std::pair< one_type, two_type > get_random_points_new( unsigned max_iter, double max_md, Strategy_new strategy, bool silent, unsigned npoints, unsigned long seed, Mat algorithm_counts, double weight_spatial ) {
	double weight_stratified = 1.0 - weight_spatial;
	if ( interruptFlag_new ) cout << "Will this cause an error? In the header file: Yes" << endl;
	
	srand (time(NULL));
	
	vector< vector< int > > indices_each_iteration;
	vector< vector< double > > stratified_probabilities_each_iteration;
	vector< vector< double > > spatial_probabilities_each_iteration;
	
  MTRand rng(seed);
  double global_md = 0;
  double avg_md    = 0;
  double old_avg   = avg_md;
  
  // Initial points
  vector<Point_2_new> points;
  generate_random_new(points, npoints, rng);
  
  // Set up initial triangulation
  DT_new dt(points, true);
  
  signal(SIGINT, sighandler);
  update_statistics_new(dt, 0, global_md, avg_md, !silent);
  
  unsigned it = 0;
  vector<VH_new> neighbors;
  neighbors.reserve(10);

	int print_statements = 0;  

  // Set up vertex processing order
  // We choose a random order to ensure there is no correlation between the
  // original order of the point set and farthest-point optimization
  unsigned order[npoints];
  for (unsigned i = 0; i < npoints; ++i) order[i] = i;
  shuffle(order, npoints, rng);
	
  clock_t t0 = clock();
	int iteration_count = 0;
  while (!interruptFlag_new) {
		if (print_statements == 1) fprintf( stderr, "iteration_count: %d\n", iteration_count );
		iteration_count++;
    // Main loop that moves each point to the farthest point, i.e. the
    // center of the largest circumcircle of a triangle in the DT
    for (unsigned i = 0; i < npoints; ++i) {
			if (print_statements == 1) fprintf( stderr, "i: %d\n", i );
      // Pick removal candidate
      unsigned r = order[i];
			if (print_statements == 1) fprintf( stderr, "baab\n" );
      Point_2_new cand = dt.get_vertex(r)->point();
			if (print_statements == 1) fprintf( stderr, "baac\n" );
      neighbors.clear();                 // Candidate's neighborhood
      dt.incident_vertices(r, neighbors);
			if (print_statements == 1) fprintf( stderr, "baad\n" );
      double cand_md = DBL_MAX;          // Candidate's local mindist
      for (unsigned ii = 0; ii < neighbors.size(); ++ii) {
        cand_md = std::min(cand_md, CGAL::squared_distance(cand, neighbors[ii]->point()));
      }
			if (print_statements == 1) fprintf( stderr, "baae\n" );
      Circle_2_new c(cand, cand_md);         // Empty circle about candidate
			if (print_statements == 1) fprintf( stderr, "baaf\n" );
      // Remove candidate
      dt.clear_vertex( r );
			if (print_statements == 1) fprintf( stderr, "baag\n" );
      // Search for largest circumcircle in triangulation
      FH_new face;
      // Get the entire list of circles
			// Largest circumference is at the back
			if (print_statements == 1) fprintf( stderr, "aaaa\n" );
			vector< Circle_2_new > list_of_circles = dt.global_sorted_circumcircles();
			circumference_check( list_of_circles );
			
			// Print off the circle coordinates:
			
			if (print_statements == 1) fprintf( stderr, "aaab\n" );
			//	 - Create probability distribution
			// - Multiply spatial distribution by the normalized circle radius (squared, yes sure bias it more)
			if (print_statements == 1) fprintf( stderr, "list_of_circles.size : %d\n", (int) list_of_circles.size() );
			vector< double > spatial_distribution = create_spatial_distribution_new( list_of_circles );
			if (print_statements == 1) fprintf( stderr, "spatial_distribution.size : %d\n", (int) spatial_distribution.size() );
			
			/// Done with spatial setup ///
			if (print_statements == 1) fprintf( stderr, "aaac\n" );
			
			// get the other current points coordinates
			vector<Point2f> all_other_vertex_coordinates = get_point_coordinates_new( npoints, order, dt, r );
			if (print_statements == 1) fprintf( stderr, "aaad\n" );
			// get the other n-1 points indices 
			if (print_statements == 1) fprintf( stderr, "Before call of get_point_indices_new()\n" );
			if (print_statements == 1) fprintf( stderr, "algorithm_counts.rows: %d\tall_other_vertex_coordinates.size(): %d\n", (int) algorithm_counts.rows, (int) all_other_vertex_coordinates.size() );
			vector<int> point_indices = get_point_indices_new( algorithm_counts, all_other_vertex_coordinates );
			// get the points indices in the stratified space
			// 	returns:
			// 		Mat of the final stratified indices where the algorithm counts indices end up
			//			This variable should be the same size as the "algorithm_counts"
			if (print_statements == 1) fprintf( stderr, "aaae\n" );

			Mat stratified_point_indices_mat = get_stratified_point_indices_new( algorithm_counts, point_indices );

			if (print_statements == 1) fprintf( stderr, "aaaf\n" );
			// get the boolean array for the current stratified points space
			vector<bool> stratified_point_indices_b = get_stratified_occupied_locations_new( point_indices, stratified_point_indices_mat );
			if (print_statements == 1) fprintf( stderr, "aaag\n" );
			
			// get the points of all of the possible circles
			vector< Point2f > circumcircle_center_coordinates = get_circle_coordinates_new( list_of_circles );
			if (print_statements == 1) fprintf( stderr, "aaah\n" );
			// get the indices of all of the possible circles
			vector< int > circumcircle_point_indices = get_point_indices_new( algorithm_counts, circumcircle_center_coordinates );
			if (print_statements == 1) fprintf( stderr, "aaai\n" );
			// get the distance for all of the circumcircle points possible
			vector<double> circumcircle_average_distances = get_average_distance_for_possible_points_new( stratified_point_indices_b, circumcircle_point_indices, stratified_point_indices_mat );
			if (print_statements == 1) fprintf( stderr, "aaaj\n" );
			// create the distribution cooresponding to the stratified counts
			vector<double> stratified_distribution = create_stratified_distribution_new( list_of_circles );
			vector<double> stratified_distribution_organized_by_spatial_indices = vector<double>((int) stratified_distribution.size(), 0);
			
			// sort the stratified distances:
			// This is in the reverse order of what it should be!
			vector < pair < double, int > > sorted_stratified_distances_copy;
			vector < pair < double, int > > sorted_stratified_distances = sort_and_return_indices( circumcircle_average_distances );
			for( int ii = ( (int)sorted_stratified_distances.size() ) - 1; ii >= 0; ii-- ) {
				sorted_stratified_distances_copy.push_back( sorted_stratified_distances[ii] );
			}
			sorted_stratified_distances = sorted_stratified_distances_copy;
			// The first point index in the sorted_stratified_distances is the point with the highest distribution:
			// second is the second highest, etc...
			// Make its index have the greatest probability
			for( int jj = 0; jj < (int) sorted_stratified_distances.size(); jj++ ) {
				int corresponding_spatial_index = sorted_stratified_distances[jj].second;
				stratified_distribution_organized_by_spatial_indices[ corresponding_spatial_index ] = stratified_distribution[jj];
			}
			if (print_statements == 1) fprintf( stderr, "aaak\n" );
			// Check that both distributions are normalized
			double total_spatial_distribution_check = 0, total_stratified_distribution_check = 0;
			for( int jj = 0; jj < (int) spatial_distribution.size(); jj++ ) total_spatial_distribution_check += spatial_distribution[jj];
			for( int jj = 0; jj < (int) stratified_distribution_organized_by_spatial_indices.size(); jj++ ) total_stratified_distribution_check += stratified_distribution_organized_by_spatial_indices[jj];
			if ( abs(total_spatial_distribution_check-1) > 0.01 ) {
				fprintf(stderr, "%.2f\n", total_spatial_distribution_check);
				throw std::runtime_error( "sum( spatial_distribution(:) ) ~= 1" );
			}
			if ( abs(total_stratified_distribution_check-1) > 0.01 ) {
				fprintf(stderr, "%.2f\n", total_stratified_distribution_check);
				throw std::runtime_error( "sum( stratified_distribution(:) ) ~= 1" );
			}
			if ( (int) spatial_distribution.size() != (int) stratified_distribution.size() ) {
				fprintf( stderr, "spatial_distribution.size(): %d\nstratified_distribution.size(): %d\n", (int) spatial_distribution.size(), (int) stratified_distribution.size() );
				throw std::runtime_error( "(int) spatial_distribution.size() != (int) stratified_distribution.size()");
			}
			if (print_statements == 1) fprintf( stderr, "aaaka\n" );
			vector< bool > valid_circumcircle_point_indices;
			for( int jj = 0; jj < (int) circumcircle_point_indices.size(); jj++ ) {
				bool cur_index_is_valid = true;
				for( int kk = 0; kk < (int) point_indices.size(); kk++ ) {
					if ( circumcircle_point_indices[jj] == point_indices[kk] ) {
						// This index is invalid
						cur_index_is_valid = false;
					}
				}
				valid_circumcircle_point_indices.push_back( cur_index_is_valid );
			}
			if (print_statements == 1) fprintf( stderr, "aaakb\n" );
			vector<double> combined_distribution = vector<double>( (int) stratified_distribution.size(), 0 );
			double total_combined = 0;
			for ( int jj = 0; jj < (int) stratified_distribution.size(); jj++ ) {
				double cur_combined = 0;
				if ( valid_circumcircle_point_indices[jj] ) {
					cur_combined = weight_stratified * stratified_distribution_organized_by_spatial_indices[jj] + weight_spatial * spatial_distribution[jj];
				}
				combined_distribution[jj] = cur_combined;
				total_combined += cur_combined;
			}
			if (print_statements == 1) fprintf( stderr, "aaakc\n" );
			if (total_combined < 0.01) {
				combined_distribution[0] = 1;
				total_combined = 1;
			}
			if (print_statements == 1) fprintf( stderr, "aaakd\n" );
			for ( int jj = 0; jj < (int) combined_distribution.size(); jj++ ) {
				combined_distribution[jj] = combined_distribution[jj] / total_combined;
			}
			if (print_statements == 1) fprintf( stderr, "aaake\n" );
			int distribution_idx = -1;
			double cur_random = ((double) rand() / (RAND_MAX));
			// find the index of combined_distribution that has cur_random
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
			if (print_statements == 1) fprintf( stderr, "aaakf\n" );
			if ( abs(total_combined_dist - 1 ) > 0.01 ) {
				fprintf( stderr, "%.2f\n", total_combined_dist );
				throw std::runtime_error( "The combined distribution does not equal 1!");
			}
			// Return indices and probabilities //
			/* START 1 */				
			/* Setup the indices that have been in place for this iteration */
			if (print_statements == 1) fprintf( stderr, "aaal\n" );
			vector<int> indices_each_iteration_cur_vector;
			// Update the indices that have been chosen for the current iteration
			for ( int ii = 0; ii < (int) point_indices.size(); ii++ ) {
				indices_each_iteration_cur_vector.push_back( point_indices[ii] );
			}
			indices_each_iteration_cur_vector.push_back( circumcircle_point_indices[circumcircle_point_indices.size()-1] );
			indices_each_iteration.push_back( indices_each_iteration_cur_vector );
			/* END 1 */
			if (print_statements == 1) fprintf( stderr, "aaam\n" );
			/* START 2 */
			vector<double> stratified_probabilities_each_iteration_cur_vector;
			for( int ii = 0; ii < (int) stratified_distribution.size(); ii++ ) {
				stratified_probabilities_each_iteration_cur_vector.push_back( stratified_distribution[ii] );
			}
			stratified_probabilities_each_iteration.push_back( stratified_probabilities_each_iteration_cur_vector );
			if (print_statements == 1) fprintf( stderr, "aaan\n" );
			vector<double> spatial_probabilities_each_iteration_cur_vector;
			for( int ii = 0; ii < (int) spatial_distribution.size(); ii++ ) {
				spatial_probabilities_each_iteration_cur_vector.push_back( spatial_distribution[ii] );
			}
			spatial_probabilities_each_iteration.push_back( spatial_probabilities_each_iteration_cur_vector );
			/* START 2 */
			if (print_statements == 1) fprintf( stderr, "aaao\n" );
			if ( distribution_idx > ((int) list_of_circles.size() - 1) ) {
				fprintf( stderr, "distribution_idx: %d\nlist_of_circles.size-1: %d\n", distribution_idx, (int) list_of_circles.size()-1 );
				throw std::runtime_error("The distribution idx is greater than the distribution array length?!");
			}
			// if distribution_idx = -1
				// there are no valid indices
				// so use the best spatial index
			// 
			Circle_2_new best_circle = list_of_circles[distribution_idx];
			if (print_statements == 1) fprintf( stderr, "aaaoa\n" );
			Point_2_new l_center = wrap_unit_torus(best_circle.center());
			if (print_statements == 1) fprintf( stderr, "aaaob\n" );
			if (l_center.x() < 0 || l_center.x() > 1 || l_center.y() < 0 || l_center.y() > 1 ) {
				throw std::runtime_error("The best center is out of range?!");
			}
			if (print_statements == 1) fprintf( stderr, "aaaoc\n" );
	    dt.set_vertex( r, l_center, face );
			if (print_statements == 1) fprintf( stderr, "aaaod\n" );
    }
		if (print_statements == 1) fprintf( stderr, "aaaq\n" );
		
    ++it;
    update_statistics_new(dt, it, global_md, avg_md, !silent);
		if (print_statements == 1) fprintf( stderr, "aaar\n" );
    
    if (it >= max_iter || global_md >= max_md)
      break;
    if (avg_md - old_avg == 0.01) break;
    old_avg = avg_md;
  }
  clock_t t1 = clock();
  
	if (print_statements == 1) fprintf( stderr, "aaas\n" );

  if (!silent) {
		double dtime = (double)(t1 - t0) / CLOCKS_PER_SEC;
		printf("optimization took %.3fs and %d iterations (%.1fms/iter)\n", dtime, it, dtime * 1000.0 / it);
  } else
      update_statistics_new(dt, it, global_md, avg_md, false);
  
	// need to setup all_points to be of type one_type
	vector<cv::Point2f> all_points = dt.return_vertices_points();
	
	vector<int> all_point_indices; for (int i = 0; i < algorithm_counts.rows*algorithm_counts.cols; i++ ) { all_point_indices.push_back( i ); }
  Mat stratified_point_indices_mat_ret = get_stratified_point_indices_new( algorithm_counts, all_point_indices );
	vector<int> stratified_point_indices_mat_ret_vec; for (int i = 0; i < stratified_point_indices_mat_ret.rows*stratified_point_indices_mat_ret.cols; i++ ) {
		double value = stratified_point_indices_mat_ret.at<double>( i/stratified_point_indices_mat_ret.rows, i%stratified_point_indices_mat_ret.rows );
		stratified_point_indices_mat_ret_vec.push_back( value );
	}
	one_type all_points_and_stratified_indices = one_type( all_points, stratified_point_indices_mat_ret_vec );
	
	for ( int i = 0; i < (int) all_points.size(); i++ ) {
		Point2f cur_pt = all_points[i];
		if ( cur_pt.x < 0 || cur_pt.x > 1 || cur_pt.y < 0 || cur_pt.y > 1 ) {
			throw runtime_error( "Points are out of bounds: Return from C++ code" );
		}
	}
	
	two_type all_probabilities = two_type( spatial_probabilities_each_iteration,  stratified_probabilities_each_iteration );
	std::pair< one_type, two_type > all_ret_values = std::pair< one_type, two_type >( all_points_and_stratified_indices, all_probabilities );
	
	return all_ret_values;
}

vector < pair < double, int > > sort_and_return_indices( vector<double> input_vector ) {
	vector < pair < double, int > > input_vector_with_indices;
	for ( int i = 0; i < (int) input_vector.size(); i++ ) {
		pair< double, int > cur_pair = pair< double, int >( input_vector[i], i );
		input_vector_with_indices.push_back( cur_pair );
	}
	sort( input_vector_with_indices.begin(), input_vector_with_indices.end() );
	return input_vector_with_indices;
}

void circumference_check( vector< Circle_2_new > list_of_circles ) {
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
