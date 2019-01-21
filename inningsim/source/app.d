
import std.stdio;

import std.parallelism;
import std.concurrency;
import std.algorithm;
import std.range;
import std.conv;
import mir.random.engine;
import mir.random.engine.mersenne_twister : MersenneTwisterEngine;
import mir.random.variable;
import echo;
import player;
import events;
import game;
import std.algorithm.iteration : sum;

void main()
{


	immutable GameState game_state;
	
	auto sim = EventSimulator(unpredictableSeed);

	
	auto score = iota(0, 100000).map!(_ => runs_from_state(game_state, sim)).mean;
	//auto score = taskPool.map!runs_from_state(game_state, sim)(iota(0, 100000));
	//auto score = taskPool.map!runs_from_initial_state(iota(0, 100000)).mean;
	//auto score = iota(0, 100000).map!(i => fx(i)).mean;

	//auto score = taskPool.map!runs_from_initial_state(iota(0, 100000)).mean;
	writeln(score);
	writeln(score * 9);


}	


double[HitEvent] get_probs() {
	// double[HitEvent] probs = [
	// 	HitEvent.xbb: 0.08,
	// 	HitEvent.x1b: 0.15,
	// 	HitEvent.x2b: 0.05,
	// 	HitEvent.x3b: 0.005,
	// 	HitEvent.x4b: 0.035
	// ];

	double[HitEvent] probs = [
		HitEvent.xbb: 0.25,
		HitEvent.x1b: 0.0,
		HitEvent.x2b: 0.0,
		HitEvent.x3b: 0.25,
		HitEvent.x4b: 0.0
	];
	double sum_probs = sum(probs.values);
	assert(sum_probs < 1.0);
	probs[HitEvent.xout] = 1.0 - sum_probs;
	return probs;

}


int runs_from_initial_state(int i) {
	EventSimulator sim = EventSimulator(unpredictableSeed);
	static immutable GameState gs;
	return runs_from_state(gs, sim);
}

int runs_from_state(
	GameState game_state,
	ref EventSimulator sim) 
	{

		auto hit_probs = get_probs();
		//writeln(hit_probs);

		double[RunEvent] run_probs = [
			RunEvent.take_third: 0,
			RunEvent.take_home: 0];
//		writeln(run_probs);

		HitRunEvent ev = sim.hit_run_event(hit_probs, run_probs);
		//writeln(ev);

		GameState new_state = game_state.transition(ev);

		if (new_state.base_out_state.outs == 3) {
			return new_state.score;
		} else {
			return runs_from_state(new_state, sim);
		}
	}

