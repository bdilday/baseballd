
import std.stdio;

import std.algorithm;
import std.range;
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

	//auto gen = Random(unpredictableSeed);
	Random* gen = threadLocalPtr!Random;

	auto probs = get_probs();
	HitEvent[] all_keys = probs.keys();
	double[] weights;

	GameState game_state;
	
	foreach(k ; all_keys) {
		weights ~= [probs[k]];
	}

	auto ds = discreteVar(weights);
	ulong res;

	foreach (i; 0..1000) {
		res = ds(gen);
		writeln(all_keys[res]);
	}

	writeln(probs);
	writeln(typeid(gen));
	writeln(typeid(typeof(gen)));
	writeln(unpredictableSeed);

	auto sim = EventSimulator(189);

	auto score = iota(0, 100000).map!(_ => runs_from_state(game_state, sim)).mean;
//	writeln(score);
	writeln(score);
	writeln(score * 9);


}	

double[HitEvent] get_probs() {
	double[HitEvent] probs = [
		HitEvent.xbb: 0.08,
		HitEvent.x1b: 0.15,
		HitEvent.x2b: 0.05,
		HitEvent.x3b: 0.005,
		HitEvent.x4b: 0.035
	];

	double sum_probs = sum(probs.values);
	assert(sum_probs < 1.0);
	probs[HitEvent.xout] = 1.0 - sum_probs;
	return probs;

}

int runs_from_state(
	GameState game_state,
	EventSimulator sim) 
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

