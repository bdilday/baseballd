import std.stdio;
import std.format;
import std.algorithm : map;
import traj;

import ggplotd.colour : colourGradient;

import ggplotd.aes : aes;
import ggplotd.axes : xaxisLabel, yaxisLabel;
import ggplotd.ggplotd : GGPlotD, putIn;
import ggplotd.geom : geomPoint;
import ggplotd.colourspace : XYZ;
    import ggplotd.geom : geomHist2D;
    import ggplotd.legend : continuousLegend;
 import std.range : repeat, iota, chain, zip;

void main()
{

  double launch_angle = 20;
  double launch_speed = 90;
  double launch_phi = 0.0;
  double dt = 0.0001;
  int N = 1000000;

  TrajectoryParameters pars;
  pars.launch_angle = launch_angle;
  pars.launch_speed = launch_speed;
  compute_pars(pars);

  double[] x, y, c;
	for (double la=-30; la < 80; la += 10) {
		for (double lv=1; lv < 100; lv += 20) {
    		  auto b = ball_range(lv, la, launch_phi, dt, pars, N);
writeln(format("%.6f %.6f %.6f \n", la, lv, b));
x ~= la;
y ~= lv;
c ~= b;
		}
	}

plot_h2d(x, y, c);
}


struct ballr {
double x;
double y;
double c;
}

void plot_h2d(double []x, double[] y, double[] c) {


auto p = zip(x, y, c);
writeln(p);

/*
auto gg = p.map!( t => t[0] * t[0]);
writeln(gg);
*/

auto gg = p.map!((t) => aes!("x","y","colour")(t[0], t[1], t[2]))
                .geomHist2D.putIn(GGPlotD());

    // Use a different colour scheme
    gg.put( colourGradient!XYZ( "white-cornflowerBlue-crimson" ) );

    gg.put(continuousLegend);

    gg.save( "hist2D.png" );
}