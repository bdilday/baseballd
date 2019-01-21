module events;

import mir.random.engine;
import mir.random;
import mir.random.variable;

enum HitEvent
{
    x1b,
    x2b,
    x3b,
    x4b,
    xbb,
    xout
};

enum RunEvent
{
    take_third,
    take_home
};

struct RunEventTransition
{
    bool take_home;
    bool take_third;

    this(bool take_third, bool take_home)
    {
        this.take_home = take_home;
        this.take_third = take_third;
    }

}

struct HitRunEvent
{
    HitEvent hit_event;
    RunEventTransition run_event_transition;

}

struct EventSimulator
{

    Random* gen;

    this(ulong seed)
    {
        this.gen = threadLocalPtr!Random;
    }

    HitRunEvent hit_run_event(
        double[HitEvent] hit_probs, 
        double[RunEvent] run_probs)
    {
        return HitRunEvent(
            this.hit_event(hit_probs), 
            this.run_event(run_probs)
            );
    }

    HitEvent hit_event(double[HitEvent] hit_probs)
    {
        HitEvent[] all_keys = hit_probs.keys();
        double[] weights;

        foreach (k; all_keys)
        {
            weights ~= [hit_probs[k]];
        }

        auto ds = discreteVar(weights);
        return all_keys[ds(this.gen)];
        
    }

    RunEventTransition run_event(double[RunEvent] run_probs)
    {
        auto rv_third = bernoulliVar(run_probs[RunEvent.take_third]);
        auto rv_home = bernoulliVar(run_probs[RunEvent.take_home]);
        bool take_third = rv_third(this.gen);
        bool take_home = rv_home(this.gen);

        return RunEventTransition(take_third, take_home);
    }
}
