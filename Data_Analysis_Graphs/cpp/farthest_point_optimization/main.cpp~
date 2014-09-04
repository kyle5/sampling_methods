/**
 * This file is part of the optimization tool fpo which implements the
 * farthest point optimization method proposed in the paper
 *
 *   T. Schlömer, D. Heck, O. Deussen:
 *   Farthest-Point Optimized Point Sets with Maximized Minimum Distance
 *   HPG '11: High Performance Graphics Proceedings
 * 
 * fpo is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <algorithm>
#include <signal.h>
#include <sstream>
#include <time.h>
#include <unistd.h>

#include "DT.h"
#include "util.h"

enum Strategy {
    GLOBAL, LOCAL, HYBRID
};

static bool interruptFlag = false;


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

void update_statistics(const DT &dt, unsigned it, double &global_md,
                       double &avg_md, bool output = true)
{
    dt.get_statistics(global_md, avg_md);
    
    const double mdnorm = sqrt(SQRT3 * 0.5 * dt.number_of_vertices());
    global_md *= mdnorm;
    avg_md    *= mdnorm;
    
    if (output)
        std::cout << std::fixed << std::setprecision(6) << std::setw(5)
        << it << " " << global_md << " " << avg_md << "\n";
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

vector<cv::Point2f> called( unsigned max_iter = 20, double max_md = 0.925, Strategy strategy = GLOBAL, bool silent = false, unsigned npoints = 400, unsigned long seed = 0 ) {

    MTRand rng(seed);
    double global_md = 0;
    double avg_md    = 0;
    double old_avg   = avg_md;
    
    // Initial points
    vector<Point_2> points;
    generate_random(points, npoints, rng);
    
    // Set up initial triangulation
    DT dt(points, true);
    
    signal(SIGINT, sighandler);
    update_statistics(dt, 0, global_md, avg_md, !silent);
    
    unsigned it = 0;
    vector<VH> neighbors;
    neighbors.reserve(10);
    
    // Set up vertex processing order
    // We choose a random order to ensure there is no correlation between the
    // original order of the point set and farthest-point optimization
    unsigned order[npoints];
    for (unsigned i = 0; i < npoints; ++i) order[i] = i;
    shuffle(order, npoints, rng);
    
    clock_t t0 = clock();
    while (!interruptFlag)
    {
        // Main loop that moves each point to the farthest point, i.e. the
        // center of the largest circumcircle of a triangle in the DT
        for (unsigned i = 0; i < npoints; ++i)
        {
            // Pick removal candidate
            unsigned r = order[i];
            Point_2 cand = dt.get_vertex(r)->point();
            
            neighbors.clear();                 // Candidate's neighborhood
            dt.incident_vertices(r, neighbors);
            
            double cand_md = DBL_MAX;          // Candidate's local mindist
            for (unsigned i = 0; i < neighbors.size(); ++i) {
                cand_md = std::min(cand_md, 
                         CGAL::squared_distance(cand, neighbors[i]->point()));
            }
            
            Circle_2 c(cand, cand_md);         // Empty circle about candidate

            // Remove candidate
            dt.clear_vertex(r); 
            
            // Search for largest circumcircle in triangulation
            FH face;
            Circle_2 l = Circle_2(Point_2(0, 0), 0);
            switch (strategy) {
                case GLOBAL:
                    l = dt.global_largest_circumcircle(face);
                    break;
                case LOCAL:
                    l = dt.local_largest_circumcircle(neighbors, face);
                    break;
                case HYBRID:
                    if (old_avg < 0.930)
                        l = dt.global_largest_circumcircle(face);
                    else
                        l = dt.local_largest_circumcircle(neighbors, face);
                    break;
            }

            // Set center of largest circumcircle as new vertex
            if (l.squared_radius() > c.squared_radius()) {
                Point_2 l_center = wrap_unit_torus(l.center());
                dt.set_vertex(r, l_center, face);
            } else
                dt.set_vertex(r, c.center(), face);
        }
        ++it;
        update_statistics(dt, it, global_md, avg_md, !silent);
        
        if (it >= max_iter || global_md >= max_md)
            break;

        if (avg_md - old_avg == 0.03) break;
        old_avg = avg_md;
    }
    clock_t t1 = clock();
    
    if (!silent) {
        double dtime = (double)(t1 - t0) / CLOCKS_PER_SEC;
        printf("optimization took %.3fs and %d iterations (%.1fms/iter)\n", 
                dtime, it, dtime * 1000.0 / it);
    } else
        update_statistics(dt, it, global_md, avg_md, false);
    
    // Output resulting set of vertices as EPS file
    std::ostringstream eps;
    eps << "fpo_n" << npoints << ".eps";
    dt.save_vertices_eps(eps.str().c_str());

		vector<cv::Point2f> all_points = dt.return_vertices_points();
    return all_points;
}

int main(int argc, const char * argv[]) {
  unsigned max_iter  = 20;
  double max_md      = 0.925;
  Strategy strategy  = GLOBAL;
  bool silent        = false;
  unsigned npoints   = 400;
  unsigned long seed = 0;
  
  // Parse command line
  int pos_arguments = 0;
  bool show_usage = false;
  for (int i = 1; i < argc; ++i) {
      if (argv[i][0] == '-') {
          std::string arg = argv[i];
          if (arg == "--help") {
              show_usage = true;
          } else if (arg == "--max-iter" && i+1 < argc) {
              max_iter = atoi(argv[++i]);
          } else if (arg == "--max-mindist" && i+1 < argc) {
              max_md = atof(argv[++i]);
          } else if (arg == "--strategy" && i+1 < argc) {
              std::string param = argv[++i];
              if (param == "global") strategy = GLOBAL;
              else if (param == "local") strategy = LOCAL;
              else if (param == "hybrid") strategy = HYBRID;
              else {
                  fprintf(stderr, "Invalid strategy %s.\n", argv[i]);
                  show_usage = true;
              }
          } else if (arg == "--silent") {
              silent = true;
          } else {
              fprintf(stderr, "Unknown option %s.\n", argv[i]);
              show_usage = true;
          }
      } else {
          switch (pos_arguments) {
              case 0:  npoints = atoi(argv[i]); break;
              case 1:  seed = atol(argv[i]); break;
              default: fprintf(stderr, "Invalid positional argument.\n");
                       show_usage = true;
                       break;
          }
          ++pos_arguments;
      }
  }
  if (show_usage) {
      usage();
      exit(0);
  }

	called( max_iter, max_md, strategy, silent, npoints, seed );
	return 1;
}

