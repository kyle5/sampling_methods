#include "get_random_points.h"
#include "get_rp_helper_functions.h"

#include <opencv2/highgui/highgui.hpp>

//temp
#include <iostream>
#include <iostream>
#include <utility>
#include <stdexcept>
#include <cstdio>

using namespace std;
using namespace cv;

void generate_random(vector<Point_2> &points, unsigned npoints, MTRand &rng)
{
    points.reserve(npoints);
    for (unsigned i = 0; i < npoints; ++i) {
        Point_2 p(rng.randExc(), rng.randExc());
        points.push_back(p);
    }
}

void generate_darts(vector<Point_2> &points, unsigned npoints, MTRand &rng)
{
    const double rnorm  = 0.725;
    const double mdnorm = sqrt(SQRT3 * 0.5 * npoints);
    const double md     = rnorm / mdnorm;
    const double sqr_md = md * md;
    
    points.reserve(npoints);
    while (points.size() < npoints) {
        while (true) {
            Point_2 cand(rng.randExc(), rng.randExc());
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

void update_statistics(const DT &dt, unsigned it, double &global_md, double &avg_md, bool output ) {
    dt.get_statistics(global_md, avg_md);
    const double mdnorm = sqrt(SQRT3 * 0.5 * dt.number_of_vertices());
    global_md *= mdnorm;
    avg_md    *= mdnorm;
    
    //if (output)
        //std::cout << std::fixed << std::setprecision(6) << std::setw(5)
        //<< it << " " << global_md << " " << avg_md << "\n";
}

static void sighandler(int sig)
{
    std::cout << "Aborting...\n";
    interruptFlag = true;
}

void usage() 
{
    std::cout << "usage: fpo [options] [#points] [seed]\n\n"
        "Options\n"
        "  --help            show this message\n"
        "  --max-iter n      maximum number of iterations (10000*)\n"
        "  --max-mindist n   maximum mindist (0.925*)\n"
        "  --strategy x      set optimization strategy (local,global*,hybrid)\n"
        "  --silent          only print summary at the end\n";
}

//get_random_points(unsigned int, double, Strategy, bool, unsigned int, unsigned long)

vector<cv::Point2f> get_random_points( unsigned max_iter, double max_md, Strategy strategy, bool silent, unsigned npoints, unsigned long seed, Mat valid_counts ) {
	int print_statements = 0;
  MTRand rng(seed);
  double global_md = 0;
  double avg_md    = 0;
  double old_avg   = avg_md;
  if ( print_statements == 1 ) cerr << "aaa";
	bool only_use_valid = true;
	
	// temp: write out image cooresponding to
	Mat valid_counts_CV_8U;
	valid_counts.convertTo( valid_counts_CV_8U, CV_8U );
	
  // Initial points
  vector<Point_2> points;
  generate_random(points, npoints, rng);
  if ( print_statements == 1 ) cerr << "aab";

  // Set up initial triangulation
  DT dt(points, true);
  if ( print_statements == 1 ) cerr << "aac";

  signal(SIGINT, sighandler);
  update_statistics(dt, 0, global_md, avg_md, !silent);
  if ( print_statements == 1 ) cerr << "aad";

  unsigned it = 0;
  vector<VH> neighbors;
  neighbors.reserve(10);
  if ( print_statements == 1 ) cerr << "aae";
  
  // Set up vertex processing order
  // We choose a random order to ensure there is no correlation between the
  // original order of the point set and farthest-point optimization
  unsigned order[npoints];
  for (unsigned i = 0; i < npoints; ++i) order[i] = i;
  shuffle(order, npoints, rng);
  if ( print_statements == 1 ) cerr << "aaf";
  
  clock_t t0 = clock();
  while (!interruptFlag)
  {
    // Main loop that moves each point to the farthest point, i.e. the
    // center of the largest circumcircle of a triangle in the DT
    for (unsigned i = 0; i < npoints; ++i)
    {
			try
			{
				vector<Point2f> cur_vertices = dt.return_vertices_points();
				for( int j = 0; j < (int) cur_vertices.size(); j++ ) {
					double x = (double) cur_vertices[j].x;
					double y = (double) cur_vertices[j].y;
					if ( x < 0 || x > 1 || y < 0 || y > 1 ) {
						throw std::runtime_error( "Vertex indices are out of range!" );
					}
				}

        // Pick removal candidate
        unsigned r = order[i];
        Point_2 cand = dt.get_vertex(r)->point();
				Point2f cur_pt_Point2f( (double) cand.x(), (double) cand.y() );
				vector< Point2f > all_pts;
				all_pts.push_back( cur_pt_Point2f );
				vector<int> all_vertex_point_indices = get_point_indices_new( valid_counts, all_pts );
        int index_cur_pt = all_vertex_point_indices[0];
				double cur_pt_is_valid_double = valid_counts.at<double>( index_cur_pt%valid_counts.rows, index_cur_pt/valid_counts.rows );
        int cur_pt_is_valid = (int) round(cur_pt_is_valid_double);
			  if ( print_statements == 1 ) cerr << "aag" << endl;
				
        neighbors.clear();                 // Candidate's neighborhood
        dt.incident_vertices(r, neighbors);
			  if ( print_statements == 1 ) cerr << "aah" << endl;
        
        double cand_md = DBL_MAX;          // Candidate's local mindist
        for (unsigned j = 0; j < neighbors.size(); ++j) {
          cand_md = std::min(cand_md, 
                   CGAL::squared_distance(cand, neighbors[j]->point()));
					Point_2 cur_pt = neighbors[j]->point();
					if ( print_statements == 1 ) fprintf( stderr, "cur_pt: x: %.2f: y: %.2f\n", (double) cur_pt.x(), (double) cur_pt.y() );
        }
        
        Circle_2 c(cand, cand_md);         // Empty circle about candidate
			  if ( print_statements == 1 ) cerr << "aai" << endl;
				// Remove candidate
			  if ( print_statements == 1 ) fprintf( stderr, "r: %d\n", (int) r );
        dt.clear_vertex( r );
			  if ( print_statements == 1 ) fprintf( stderr, "aaj\n" );

        // Search for largest circumcircle in triangulation
        FH face;
        Circle_2 l = Circle_2(Point_2(0, 0), 0);
			  if ( print_statements == 1 ) fprintf( stderr, "aaja\n" );
        switch (strategy) {
          case GLOBAL:
					  if ( only_use_valid ) {
						  if ( print_statements == 1 ) fprintf( stderr, "in main code block\n" );
							vector< FH > sorted_circumcircle_faces = dt.get_sorted_largest_circumcircle_faces();
						  if ( print_statements == 1 ) cerr << "aak" << endl;
							vector< Circle_2 > sorted_circumcircles_Circle_2 = get_circumcircles_from_faces( sorted_circumcircle_faces );
						  if ( print_statements == 1 ) cerr << "aal" << endl;
							vector< Point2f > sorted_circumcircles_point2f = get_circle_coordinates_setup_for_original_DT_temp( sorted_circumcircles_Circle_2 );
						  if ( print_statements == 1 ) cerr << "aaam" << endl;
							vector<int> sorted_circumcircles_indices = get_point_indices_new( valid_counts, sorted_circumcircles_point2f );
						  if ( print_statements == 1 ) cerr << "aaan" << endl;
							int found_replacement = 0;
							if ( print_statements == 1 ) fprintf(stderr, "bool found_replacement = 0;\n" );
							if ( print_statements == 1 ) fprintf(stderr, "sorted_circumcircles_indices.size(): %d\n", (int) sorted_circumcircles_indices.size() );
							for ( int j = 0; j < (int) sorted_circumcircles_indices.size(); j++ ) {
								if ( print_statements == 1 ) fprintf(stderr, "In loop A\n" );
								int cur_possible_index = sorted_circumcircles_indices[j];
								double cur_is_valid = valid_counts.at<double>( cur_possible_index%valid_counts.rows, cur_possible_index/valid_counts.rows );
								double cur_is_valid_rounded = round(cur_is_valid);
								if ( cur_is_valid_rounded == 1.0 ) {
									dt.copy_face_at_index( j, face, sorted_circumcircle_faces[j]->info().circle.center() );
									l = sorted_circumcircles_Circle_2[j];
									// check the actual point here
									Point_2 pt_temp = l.center();
									Point2f pt_temp_Point2f( (double) pt_temp.x(), (double) pt_temp.y() );
									vector< Point2f > all_pts_temp;
									all_pts_temp.push_back( pt_temp_Point2f );
									vector<int> indices_temp = get_point_indices_new( valid_counts, all_pts_temp);
									int ind_temp = indices_temp[0];
									double pt_to_show = valid_counts.at<double>( ind_temp%valid_counts.rows, ind_temp/valid_counts.rows );
									if ( print_statements == 1 ) fprintf( stderr, "pt_to_show validity: %.2f\n", pt_to_show );
									found_replacement = 1;
									break;
								}
							}
						  if ( print_statements == 1 ) cerr << "aao" << endl;
							if ( print_statements == 1 ) fprintf( stderr, "found_replacement: %d\n", (int) found_replacement );
							if ( found_replacement == 0 ) {
								throw std::runtime_error( "NO VALID CIRCUMCIRCLES!!!" );
								// go through all possible points to find the furthest distance
								l = dt.global_largest_circumcircle(face);
							} else if ( found_replacement == 1 ) {
								
							}
						} else {
							throw std::runtime_error( "NO VALID CIRCUMCIRCLES!!!" );
							l = dt.global_largest_circumcircle(face);
						}
        }
        // Set center of largest circumcircle as new vertex
        if ( cur_pt_is_valid != 1 || l.squared_radius() > c.squared_radius() ) {
          Point_2 l_center = wrap_unit_torus(l.center());
					Point2f cur_pt_Point2f_temp_1( (double) l_center.x(), (double) l_center.y() );
					vector< Point2f > all_pts_temp_1;
					all_pts_temp_1.push_back( cur_pt_Point2f_temp_1 );
					vector<int> all_vertex_point_indices_temp_1 = get_point_indices_new( valid_counts, all_pts_temp_1 );
					int index_cur_pt_temp_1 = all_vertex_point_indices_temp_1[0];
					double cur_pt_is_valid_double_temp_1 = valid_counts.at<double>( index_cur_pt_temp_1 % valid_counts.rows, index_cur_pt_temp_1 / valid_counts.rows );
					if ( round(cur_pt_is_valid_double_temp_1) != 1.0 ) throw std::runtime_error( "Invalid pts being set right NOW - ps!" );
          dt.set_vertex(r, l_center, face);
        } else {
					Point_2 l_center = wrap_unit_torus(c.center());
          dt.set_vertex(r, l_center, face);
				}
				Point_2 cand_temp = dt.get_vertex(r)->point();
				Point2f cur_pt_Point2f_temp( (double) cand_temp.x(), (double) cand_temp.y() );
				vector< Point2f > all_pts_temp;
				all_pts_temp.push_back( cur_pt_Point2f_temp );
				vector<int> all_vertex_point_indices_temp = get_point_indices_new( valid_counts, all_pts_temp );
				int index_cur_pt_temp = all_vertex_point_indices_temp[0];
				double cur_pt_is_valid_double_temp = valid_counts.at<double>( index_cur_pt_temp % valid_counts.rows, index_cur_pt_temp / valid_counts.rows );
				if ( round(cur_pt_is_valid_double_temp) != 1.0 ) throw std::runtime_error( "Invalid pts being set - ps!" );
			} catch (int e) {
				std::cerr << "An exception occurred. Exception Nr. " << e << '\n';
			}
    }
    ++it;
    update_statistics(dt, it, global_md, avg_md, !silent);
    
    if (it >= max_iter || global_md >= max_md)
      break;
    if (avg_md - old_avg == 0.01) break;
    old_avg = avg_md;
  }
  clock_t t1 = clock();
	
  if (!silent) {
		double dtime = (double)(t1 - t0) / CLOCKS_PER_SEC;
		printf("optimization took %.3fs and %d iterations (%.1fms/iter)\n", dtime, it, dtime * 1000.0 / it);
  } else
      update_statistics(dt, it, global_md, avg_md, false);
  
	vector<cv::Point2f> all_points = dt.return_vertices_points();
	
  return all_points;
}
