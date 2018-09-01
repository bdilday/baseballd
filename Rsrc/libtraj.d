
extern(C) {

import std.stdio;
import std.range;
import std.math;
import std.getopt;
import std.format;
import std.conv : to;

immutable double pi = 3.141592653590;


double ball_range(double launch_speed, double launch_angle, double launch_phi, double dt, TrajectoryParameters pars, int N) {
  auto trajectory = trajectory1(launch_speed, launch_angle, launch_phi, dt, pars, N);
  Vec3 v1, v2;
  double t1, t2, y1, y2, dxdt, dydt, dzdt, delt, newy, newx;
  t1 = trajectory.t[$-2];
  t2 = trajectory.t[$-1];
  v1 = trajectory.position[$-2];
  v2 = trajectory.position[$-1];
  dxdt = (v2.x - v1.x)/(t2-t1);
  dydt = (v2.y - v1.y)/(t2-t1);
  dzdt = (v2.z - v1.z)/(t2-t1);
  delt = -v1.z/dzdt;
  newx = v1.x + delt * dxdt;
  newy = v1.y + delt * dydt;
  return sqrt(newx * newx + newy * newy);
}

TrajectoryResult tmp(string[] args) {

  double launch_angle = 20;
  double launch_speed = 90;
  double launch_phi = 0.0;
  double dt = 0.0001;
  int N = 1000000;

  TrajectoryParameters pars;
  pars.launch_angle = launch_angle;
  pars.launch_speed = launch_speed;
  compute_pars(pars);

  auto trajectory = trajectory1(launch_speed, launch_angle, launch_phi, dt, pars, N);

  writeln(trajectory.print);
  return trajectory;
}

@property char[] help_message() {
  char[] s;
  s ~= "\nThe function takes 2 command line parameters \n";
  s ~= "launch velocity magnitude in miles per hour \n";
  s ~= "launch angle in degrees \n\n";
  s ~= "example: traj --la 27 --lv 101\n";
  s ~= "optional arguments are --N (the maximum number of runge-kutta steps\n and --dt (the time step))\n";
  s ~= "This computes the trajectory until the z-coordinate passes 0, and prints to stdout the time, position, and velocity\n\n";
  return s;
}

struct Vec3 {
  double x, y, z;

  double length() {
    return sqrt(x*x + y*y + z*z);
  }

  Vec3 times(double v) {
    return Vec3(x * v, y * v, z * v);
  }
}

struct TrajectoryResult {
  double[] t;
  Vec3[] position;
  Vec3[] velocity;
  Vec3[] acceleration_drag;
  Vec3[] acceleration_magnus;

  string print() {
    char[] c;
    c ~= "time,x,y,z,vx,vy,vz\n";
    for(int i=0; i < t.length; ++i) {
        c ~= format("%.6f,", t[i]);
        c ~= format("%.6f,%.6f,%.6f,", position[i].x, position[i].y, position[i].z);
        c ~= format("%.6f,%.6f,%.6f", velocity[i].x, velocity[i].y, velocity[i].z);
        c ~= " \n";
      }
    return to!string(c);
  }

};


struct TrajectoryParameters {
  immutable double g_gravity = 32.174;
  immutable double mass = 5.125; // oz;
  immutable double circumference = 9.125; // in
  immutable double beta = 1.217e-4; // 1 / meter
  double cd0 = 0.3008;
  double cdspin = 0.0292;
  double cl0 = 0.583;
  double cl1 = 2.333;
  double cl2 = 1.120;
  double tau = 10000; // seconds

   // conversions;
   double mph_to_fts = 1.467;
   double ft_to_m = 0.3048037;
   double lbft3_to_kgm3 = 16.01848;
   double kgm3_to_lbft3 = 0.06242789;

   // environmental parameters
   double vwind = 0; // mph
   double phiwind = 0; //deg
   double hwind = 0; //ft
   double relative_humidity = 50;
   double pressure_in_hg = 29.92;
   double temperature_f = 70; //F
   double elevation_ft= 15; //feet;

   // batted ball parameters
   double x0 = 0; // ft
   double y0 = 2.0; // ft
   double z0 = 3.0; // ft
   double spin = 2675; // revs per second
   double spin_phi = -18.5; // degrees
   double drag_strength = 1; // 1 = full; 0 to disable
   double magnus_strength = 1;
   double tmp = 1;

   double elevation_m;
   double temperature_c;
   double pressure_mm_hg;
   double RH;
   double SVP;
   double rho;

   double c0;
   double sidespin;
   double backspin;
   double omega;
   double romega;

   double launch_angle;
   double launch_speed;
};

void compute_pars(ref TrajectoryParameters pars) {
  pars.elevation_m = pars.elevation_ft * pars.ft_to_m;
  pars.temperature_c = (pars.temperature_f - 32) * 5 / 9;
pars.pressure_mm_hg = pars.pressure_in_hg * 1000/39.37;
pars.RH = pars.relative_humidity;
pars.SVP = 4.5841 * exp((18.687-pars.temperature_c/234.5)*pars.temperature_c/(257.14+pars.temperature_c));

pars.rho = 1.2929 * (273/(pars.temperature_c+273) *
                       (pars.pressure_mm_hg*exp(-pars.beta * pars.elevation_m) - 0.3783*pars.RH*pars.SVP * 0.01) / 760);


pars.c0 = 0.07182 * pars.rho * pars.kgm3_to_lbft3 * (5.125/pars.mass) * (pars.circumference/9.125)^^2;

pars.sidespin = pars.spin * sin(pars.spin_phi * pi/180);
pars.backspin = pars.spin * cos(pars.spin_phi * pi/180);
pars.omega = pars.spin * pi / 30;
pars.romega = pars.circumference * pars.omega / (24 * pi);

}



// a basic 4th-ordert runge kutta
double rk4 (double delegate(double, double) f, double xn, double tn, double h) {
  auto k1 = h*f(tn,xn);
  auto k2 = h*f(tn + h/2, xn + k1/2);
  auto k3 = h*f(tn + h/2, xn + k2/2);
  auto k4 = h*f(tn + h, xn + k3);

  auto xn_1 = xn + k1/6 + k2/3 + k3/3 + k4/6;
  return xn_1;
}


double s_fun(double t, double vw, TrajectoryParameters pars) {
  return (pars.romega / vw) * exp(-t *vw /(pars.tau*146.7));
}

double cl_fun(double t, double vw, TrajectoryParameters pars) {
  auto s = s_fun(t, vw, pars);
  return pars.cl2*s/(pars.cl0+pars.cl1*s);
}

double cd_fun(double t, double vw, TrajectoryParameters pars) {
  return pars.cd0 +
  pars.cdspin * (pars.spin * 1e-3)*exp(-t * vw/(pars.tau*146.7));
}


TrajectoryResult trajectory1(double v_initial, double launch_angle,
  double launch_phi, double dt, TrajectoryParameters pars, int N = 1000000, int stop_dim=3) {

    TrajectoryResult ta;

  pars.launch_angle = launch_angle;

  compute_pars(pars);

  double t0 = 0.0;

  double phi = launch_phi;
  double theta = pars.launch_angle;

  double phi_rad = launch_phi * pi / 180;
  double theta_rad = pars.launch_angle  * pi / 180;

  Vec3 xc = Vec3(pars.x0, pars.y0, pars.z0);

  Vec3 vc = Vec3(cos(theta_rad) * sin(phi_rad),
   cos(theta_rad) * cos(phi_rad),
   sin(theta_rad)
   );

  vc = vc.times(v_initial * pars.mph_to_fts);

  Vec3[] xa, va;

  int i = 0;


  while(xc.z > 0 && i < N) {

    i++;

    auto tc = t0 + i*dt;
    ta.t ~= tc;

    double v = vc.length;

    auto wb = pars.backspin;
    auto ws = pars.sidespin;
    auto wx = (wb * cos(phi_rad) - ws * sin(theta_rad) * sin(phi_rad)) * pi / 30;
    auto wy = (-wb * sin(phi_rad) - ws * sin(theta_rad) * cos(phi_rad)) * pi / 30;
    auto wz = (ws * cos(theta_rad)) * pi / 30;

    auto cd = cd_fun(tc, v, pars);
    auto cl = cl_fun(tc, v, pars);
    auto s = s_fun(tc, v, pars);

    auto magnus_const = pars.c0 * cl/pars.omega * v;
    magnus_const *= pars.magnus_strength;

    auto drag_const = pars.c0 * cd * v;
    drag_const *= pars.drag_strength;

    auto fx = delegate(double t, double x) {
      return -drag_const * vc.x + magnus_const * (wy * vc.z - wz * vc.y);
    };

    auto fy = delegate(double t, double x) {
      return -drag_const * vc.y + magnus_const * (-wx * vc.z + wz * vc.x);
    };

    auto fz = delegate(double t, double x) {
      return -drag_const * vc.z + magnus_const * (wx * vc.y - wy * vc.x) - pars.g_gravity;
    };

    auto gx = delegate(double a, double b) {return vc.x;};
    auto gy = delegate(double a, double b) {return vc.y;};
    auto gz = delegate(double a, double b) {return vc.z;};

    vc.x = rk4(fx, vc.x, tc, dt);
    vc.y = rk4(fy, vc.y, tc, dt);
    vc.z = rk4(fz, vc.z, tc, dt);

    xc.x = rk4(gx, xc.x, tc, dt);
    xc.y = rk4(gy, xc.y, tc, dt);
    xc.z = rk4(gz, xc.z, tc, dt);

    ta.position ~= xc;
    ta.velocity ~= vc;
    ta.acceleration_drag ~= vc.times(-drag_const);
    ta.acceleration_magnus ~= Vec3(0, 0, 0);
  }

return ta;
}

}