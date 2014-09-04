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

#include "DT_new.h"
#include "util_new.h"

int FaceInfo_new::maxid = 0;

int print_statements_2 = 0;

DT_new::DT_new(const vector<Point_2_new> &points, bool clip_heuristic) {
    // Clipping heuristic that excludes replications that probably do not
    // influence the boundary
    if (clip_heuristic) {
        const double e = 4.0 / sqrt(points.size());
        clip[0] = Point_2_new(-e, -e);
        clip[1] = Point_2_new(1.0 + e, 1.0 + e);
    } else {
        clip[0] = Point_2_new(-1, -1);
        clip[1] = Point_2_new(2, 2);
    }
    
    // Prepare storage
    sites.resize(points.size());

    // Add each point as a vertex to the triangulation
    for (unsigned i = 0; i < points.size(); ++i)
        set_vertex(i, points[i], FH_new(), true);
    
    // Initialize the sorting tree
    CDT_new::Face_iterator fc;
    for (fc = dt.faces_begin(); fc != dt.faces_end(); ++fc)
        update_face(fc);
}

DT_new::~DT_new()
{
    
}

Circle_2_new DT_new::global_largest_circumcircle(FH_new &face) const {
    face = sorted_faces.begin()->face;
    return face->info().circle;
}

vector<Circle_2_new> DT_new::global_sorted_circumcircles() const {
	vector<Circle_2_new> ret;
  for ( std::set< Node_new >::iterator it = sorted_faces.begin(); it != sorted_faces.end(); ++it ) {
    FH_new cur_face = it->face;
		Circle_2_new cur_circle = cur_face->info().circle;
		Point_2_new cur_center = cur_circle.center();
		Circle_2_new copy_circle( Point_2_new( cur_center.x(), cur_center.y() ), cur_circle.squared_radius() );
		ret.push_back( copy_circle );
	}
	return ret;
}

Circle_2_new DT_new::global_largest_circumcircle_bruteforce(FH_new &face) const {
    Circle_2_new largest(Point_2_new(0, 0), 0);
    CDT_new::Face_iterator fi;
    for (fi = dt.faces_begin(); fi != dt.faces_end(); ++fi) {
        if (dt.is_infinite(fi)) continue;
        if (!fi->info().main_face) continue;
        
        Circle_2_new c = fi->info().circle;
        if (c.squared_radius() > largest.squared_radius()) {
            largest = c;
            face = fi;
        }
    }
    return largest;
}

Circle_2_new DT_new::local_largest_circumcircle(const vector<VH_new> &neighbors, FH_new &face) const
{
    Circle_2_new largest(Point_2_new(0, 0), 0);
    for (unsigned i = 0; i < neighbors.size(); ++i) {
        CDT_new::Face_circulator fc = dt.incident_faces(neighbors[i]), done(fc);
        if (fc == 0) continue;
        
        do {
            if (dt.is_infinite(fc)) continue;
            
            Circle_2_new c = fc->info().circle;
            if (c.squared_radius() > largest.squared_radius()) {
                largest = c;
                face = fc;
            }
        } while (++fc != done);
    }
    return largest;
}

void DT_new::set_vertex(unsigned i, const Point_2_new &point, const FH_new &face,
                    bool setup)
{
    Site_new site;
    
    // Insert original vertex
    VH_new v = setup ? dt.insert(point) : insert_vertex(point, face);
    site.vertex = v;
    
    // Insert replications
    for (int u = -1; u <= 1; ++u) {
        for (int v = -1; v <= 1; ++v) {
            if (u != 0 || v != 0) {
                Point_2_new p(point.x() + u, point.y() + v);
                if (is_in_rect(p, clip[0], clip[1])) {
                    // Locate face where replicate would be inserted
                    CDT_new::Locate_type lt;
                    int li;
                    FH_new loc = dt.locate(p, lt, li);
                    // Skip replicate if it would duplicate an existing vertex
                    if (lt == CDT_new::VERTEX) continue;
                    // Insert replicate
                    VH_new r = setup ? dt.insert(p, lt, loc, li)
                                 : insert_vertex(p, FH_new());
                    site.replications[site.nreplications] = r;
                    site.nreplications++;
                }
            }
        }
    }
    
    sites[i] = site;
}

void DT_new::clear_vertex(unsigned i)
{
  // Remove replications
	if(print_statements_2 == 1) fprintf(stderr, "Before remove replications call...\n");
  for (unsigned r = 0; r < sites[i].nreplications; ++r) {
 		remove_vertex(sites[i].replications[r]);
	}
  sites[i].nreplications = 0;
  
  // Remove original vertex
	if(print_statements_2 == 1)  fprintf(stderr, "Before remove vertex call...\n");
  remove_vertex( sites[i].vertex );
	if(print_statements_2 == 1)  fprintf(stderr, "After remove vertex call...\n");
  sites[i] = Site_new();
}

void DT_new::incident_vertices(unsigned i, vector<VH_new> &handles) const
{
    CDT_new::Vertex_circulator vc = dt.incident_vertices(sites[i].vertex), done(vc);
    do {
        handles.push_back(vc);
    } while (++vc != done);
}

void DT_new::get_statistics(double &global_md, double &avg_md) const
{
    global_md  = DBL_MAX;
    double sum = 0.0;
    
    // Determines local mindist for each site and updates global and sum of
    // mindists accordingly
    for (unsigned i = 0; i < sites.size(); ++i) {
        double local_md = DBL_MAX;
        CDT_new::Vertex_circulator vc = dt.incident_vertices(sites[i].vertex),
                                    done(vc);
        if (vc != 0) {
            do {
                double d = CGAL::squared_distance(sites[i].vertex->point(),
                                                  vc->point());
                local_md = std::min(local_md, d);
            } while (++vc != done);
        }
        global_md = std::min(local_md, global_md);
        sum += sqrt(local_md);
    }
    
    global_md = sqrt(global_md);
    avg_md    = sum / sites.size();
}

void DT_new::save_triangulation_eps(const char *fname, bool debug) const
{
    std::ofstream os;
    os.open(fname, std::ofstream::out | std::ofstream::trunc);
    
    double scale = 512.0;
    double radius = 3.0 / scale;
    Point_2_new BB[2];
    if (debug) {
        BB[0] = Point_2_new( -scale,  -scale);
        BB[1] = Point_2_new(2*scale, 2*scale);
    } else {
        BB[0] = Point_2_new(0, 0);
        BB[1] = Point_2_new(scale, scale);
    }
    
    os << "%!PS-Adobe-3.1 EPSF-3.0\n";
    os << "%%HiResBoundingBox: " << BB[0] << " " << BB[1] << "\n";
    os << "%%BoundingBox: " << BB[0] << " " << BB[1] << "\n";
    os << "%%CropBox: " << BB[0] << " " << BB[1] << "\n";
    os << "/radius { " << radius << " } def\n";
    os << "/p { radius 0 360 arc closepath fill stroke } def\n";
    
    os << "gsave " << scale << " " << scale << " scale\n";
    os << (1.0 / scale) << " setlinewidth\n";
    
    // Faces
    os << "0.75 0.75 0.75 setrgbcolor\n";
    CDT_new::Face_iterator fi;
    for (fi = dt.faces_begin(); fi != dt.faces_end(); ++fi) {
        if (!fi->info().main_face) continue;
        
        Point_2_new p0 = fi->vertex(0)->point(),
                p1 = fi->vertex(1)->point(),
                p2 = fi->vertex(2)->point();
        os << p0 << " moveto "
           << p1 << " lineto " << p2 << " lineto closepath "
           << (debug ? "fill" : "stroke") << "\n";
    }
    
    // Edges
    os << "0.25 0.25 0.25 setrgbcolor\n";
    CDT_new::Edge_iterator ei;
    for (ei = dt.edges_begin(); ei != dt.edges_end(); ++ei) {
        const FH_new fh = ei->first;
        const int i = ei->second;
        Point_2_new p0 = fh->vertex(CDT_new::cw(i))->point(),
                p1 = fh->vertex(CDT_new::ccw(i))->point();
        os << p0 << " moveto " << p1 << " lineto stroke\n";
    }
    
    // Vertices
    os << "0 0 0 setrgbcolor\n";
    for (unsigned i = 0; i < sites.size(); ++i)
        os << sites[i].vertex->point() << " p\n";
    
    os << "grestore\n";

    // Bounding Box
    if (debug) {
        os << "0 0 0 setrgbcolor\n";
        os << "1.0 setlinewidth\n";
        os << "0 0 moveto 0 " << scale << " rlineto " << scale
           << " 0 rlineto 0 " << -scale << " rlineto closepath stroke\n";
    }
    
    os.close();
}

vector<Point2f> DT_new::return_vertices_points() const {
	vector<Point2f> all_points;
	for (unsigned i = 0; i < sites.size(); ++i) {
		Point_2_new cur_pt = sites[i].vertex->point();
		Point2f copied_pt( cur_pt.x(), cur_pt.y() );
		all_points.push_back( copied_pt );
	}
	return all_points;
}

void DT_new::save_vertices_eps(const char *fname) const
{
    std::ofstream os;
    os.open(fname, std::ofstream::out | std::ofstream::trunc);
    
    double radius = 2.0;
    double scale  = 512.0;
    const Point_2_new BB[2] = {
        Point_2_new(-radius, -radius), Point_2_new(scale + radius, scale + radius)
    };
    radius /= scale;
    
    os << "%!PS-Adobe-3.1 EPSF-3.0\n";
    os << "%%HiResBoundingBox: " << BB[0] << " " << BB[1] << "\n";
    os << "%%BoundingBox: " << BB[0] << " " << BB[1] << "\n";
    os << "%%CropBox: " << BB[0] << " " << BB[1] << "\n";
    os << "/radius { " << radius << " } def\n";
    os << "/p { radius 0 360 arc closepath fill stroke } def\n";
    os << "gsave " << scale << " " << scale << " scale\n";
    
    os << "0 0 0 setrgbcolor\n";
    for (unsigned i = 0; i < sites.size(); ++i)
        os << sites[i].vertex->point() << " p\n";

    os << "grestore\n";
    os.close();
}

void DT_new::save_vertices_rps(const char *fname) const
{
    FILE *fp;
    if (!(fp = fopen(fname, "wb"))) {
        fprintf(stderr, "Cannot write point set to %s!\n", fname);
        return;
    }
    
    int npoints = sites.size();
    float *points = new float[npoints * 2];
    for (unsigned i = 0; i < sites.size(); ++i) {
        points[2*i  ] = sites[i].vertex->point().x();
        points[2*i+1] = sites[i].vertex->point().y();
    }
    
    if (!fwrite(points, sizeof(float), npoints * 2, fp)) {
        fclose(fp);
        fprintf(stderr, "Cannot write point set to %s!\n", fname);
        return;
    }
    
    delete []points;
    fclose(fp);
}

VH_new DT_new::insert_vertex(const Point_2_new &p, const FH_new &face)
{
    VH_new v;
    
    if (dt.number_of_vertices() > 2) {
        // Determine faces that will be affected by the insert operation
        conflict_faces.clear();
        conflict_edges.clear();
        dt.get_conflicts_and_boundary(p, std::back_inserter(conflict_faces), 
                                      std::back_inserter(conflict_edges),
                                      face);
        
        // Invalidate these faces
        vector<FH_new>::iterator it;
        for (it = conflict_faces.begin(); it != conflict_faces.end(); ++it)
            invalidate_face(*it);
        
        // Insert point as new vertex using the information we already have
        v = dt.star_hole(p, conflict_edges.begin(), conflict_edges.end(),
                         conflict_faces.begin(), conflict_faces.end());
    } else {
        v = dt.insert(p, face);
    }
    
    // Update FaceInfo_new of all adjacent faces
    CDT_new::Face_circulator f = dt.incident_faces(v), fend = f;
    if (f != 0) {
        do {
            update_face(f);
        } while (++f != fend);
    }
    
    return v;
}

void DT_new::remove_vertex(VH_new v)
{
	if(print_statements_2 == 1) fprintf(stderr, "Start of remove_vertex() ...\n");
  // Invalidate adjacent faces
  Point_2_new p = v->point();
	if(print_statements_2 == 1)  fprintf(stderr, "caaa ...\n");
  CDT_new::Face_circulator f = dt.incident_faces(v), fend = f;
	if(print_statements_2 == 1)  fprintf(stderr, "caab ...\n");
  if (f != 0) {
		if(print_statements_2 == 1) fprintf(stderr, "caac ...\n");
    do {
        invalidate_face(f);
    } while (++f != fend);
  }
  if(print_statements_2 == 1) fprintf(stderr, "caad ...\n");
  
  // Remember one neighbor for faster conflict check below
  VH_new neighbor = dt.incident_vertices(v);
	if(print_statements_2 == 1) fprintf(stderr, "caae ...\n");
    
  // Remove the vertex
  dt.remove(v);
  if(print_statements_2 == 1) fprintf(stderr, "caaf ...\n");
  
  // Determine faces that were created or affected by the remove operation
  conflict_faces.clear();
	if(print_statements_2 == 1) fprintf(stderr, "caag ...\n");
  conflict_edges.clear();
	if(print_statements_2 == 1) fprintf(stderr, "caah ...\n");
  FH_new face = dt.incident_faces(neighbor);
	if(print_statements_2 == 1) fprintf(stderr, "caai ...\n");
  dt.get_conflicts_and_boundary(p, std::back_inserter(conflict_faces), 
                                std::back_inserter(conflict_edges), face);
  if(print_statements_2 == 1) fprintf(stderr, "caaj ...\n");
  
  // Update these faces
  vector<FH_new>::iterator it;
  for (it = conflict_faces.begin(); it != conflict_faces.end(); ++it) {
    update_face(*it);
	}
	if(print_statements_2 == 1) fprintf(stderr, "end of remove vertex ...\n");
}

void DT_new::invalidate_face(const FH_new &face)
{
    // Clears FaceInfo_new and removes a main face from the sorting tree
    FaceInfo_new &info = face->info();
    if (info.node != FaceTree_new::iterator())
        sorted_faces.erase(info.node);
    info.circle = Circle_2_new(Point_2_new(0, 0), 0);
    info.node = FaceTree_new::iterator();
}

void DT_new::update_face(const FH_new &face)
{
	if(print_statements_2 == 1) fprintf(stderr, "daaa\n");
  if (dt.is_infinite(face)) return;
	if(print_statements_2 == 1) fprintf(stderr, "daab\n");
  // Update FaceInfo_new for the given face
	// Kyle: TODO: There is an error at the Point_2_new c = dt.circumcenter(face); command below. I need to figure out why.
  Point_2_new c = dt.circumcenter(face);
	if(print_statements_2 == 1) fprintf(stderr, "daac\n");
  double r = CGAL::squared_distance(c, face->vertex(0)->point());
	if(print_statements_2 == 1) fprintf(stderr, "daad\n");
  
  FaceInfo_new &info = face->info();
	if(print_statements_2 == 1) fprintf(stderr, "daae\n");
  info.circle = Circle_2_new(c, r);
	if(print_statements_2 == 1) fprintf(stderr, "daaf\n");
  info.main_face = is_in_unit_torus(c);
	if(print_statements_2 == 1) fprintf(stderr, "daaj\n");
  
  // Only main faces are linked to the sorting tree
  if (info.main_face) {
      Node_new n;
      n.face = face;
			if(print_statements_2 == 1) fprintf(stderr, "daak\n");
      std::pair<FaceTree_new::iterator,bool> x = sorted_faces.insert(n);
      if (x.second)
          info.node = x.first;
			if(print_statements_2 == 1) fprintf(stderr, "daal\n");
  }
	if(print_statements_2 == 1) fprintf(stderr, "daam\n");
}
