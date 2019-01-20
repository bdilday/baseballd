
import std.stdio;

import echo;
import player;
import events;
import std.algorithm.iteration : sum;
void main()
{

	auto probs = get_probs();
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
