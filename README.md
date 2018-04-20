# baseballd

A collection of routines to analyze baseball data using `D`. 

## trajectories

The code `traj.d` computes the trajectory of a batted ball using a 4th-order runge-kutta routine.

example use:

compile with dmd
```
cd D/
dmd traj.d

```

compile with lldc

```
cd D/
ldc2 traj.d
```

run the compiled exe

```
./traj --help

The function takes 2 command line parameters 
launch velocity magnitude in miles per hour 
launch angle in degrees 

example: traj --la 27 --lv 101
optional arguments are --N (the maximum number of runge-kutta steps
 and --dt (the time step))This computes the trajectory until the z-coordinate passes 0, and prints to stdout the time, position, and velocity
```

example 

```
./traj --la 20 --lv 90 --dt 0.01

time,x,y,z,vx,vy,vz
0.010,0.001,3.237,3.449,0.072,123.662,44.916 
0.020,0.002,4.469,3.896,0.143,123.259,44.675 
0.030,0.004,5.698,4.340,0.214,122.858,44.434 
0.040,0.007,6.922,4.782,0.285,122.460,44.193 
.
.
.
3.940,26.095,327.504,1.277,9.320,62.099,-42.357 
3.950,26.188,328.124,0.852,9.323,62.051,-42.541 
3.960,26.282,328.744,0.425,9.326,62.002,-42.725 
3.970,26.375,329.364,-0.005,9.329,61.954,-42.909 
```