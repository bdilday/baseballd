module states;

import events;
import std.algorithm.iteration : sum;

class BaseOccupiedException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

struct BaseState
{
    immutable int[3] bases;

    BaseState _base_transition(HitEvent hit_event) {
        int b1, b2, b3;

        if (hit_event == HitEvent.xout)
        {
            b1 = this.bases[0];
            b2 = this.bases[1];
            b3 = this.bases[2];
        }
        else if (hit_event ==  HitEvent.xbb)
        {
            b1 = 1;
            b2 = this.bases[0] == 1 ? 1 : 0;
            b3 = this.bases[0] == 1 && this.bases[1] == 1 ? 1 : 0;
        }
        else if (hit_event ==  HitEvent.x1b)
        {
            b1 = 1;
            b2 = this.bases[0] == 1 ? 1 : 0;
            b3 = this.bases[0] == 1 && this.bases[1] == 1 ? 1 : 0;
        }
        else if (hit_event ==  HitEvent.x2b)
        {
            b1 = 0;
            b2 = 1;
            b3 = this.bases[0] == 1 ? 1 : 0;
        }
        else if (hit_event ==  HitEvent.x3b)
        {
            b1 = b2 = 0;
            b3 = 1;
        }
        else if (hit_event ==  HitEvent.x4b)
        {
            b1 = b2 = b3 = 0;
        }

        return BaseState([b1, b2, b3]);
    }

    BaseState _run_transition(RunEventTransition run_event_transition) {

        int b1, b2, b3;
        b1 = this.bases[0];
        b2 = this.bases[1];
        b3 = this.bases[2];

        if (b1 && b2 && 
            run_event_transition.take_third && 
            !run_event_transition.take_home) {
                throw new BaseOccupiedException("Attempt to take third when not open");
            }

        // take home?
        b3 = run_event_transition.take_home ? 0 : b3;

        // take third?
        if (run_event_transition.take_third && b3) {
            throw new BaseOccupiedException("Attempt to take third when not open");
        }
        b3 = run_event_transition.take_third ? b2 : b3;
        
        return BaseState([b1, b2, b3]);
    }

    BaseState transition(HitRunEvent hit_run_event)
    {
        BaseState bs = this._base_transition(hit_run_event.hit_event)._run_transition(hit_run_event.run_event_transition);
        return bs;
    }

}

struct BaseOutState
{
    BaseState base_state;
    int outs;

    BaseOutState transition(HitRunEvent ev)
    {
        return BaseOutState(
            this.base_state.transition(ev),
            this.outs + (ev.hit_event == HitEvent.xout ? 1 : 0)
            );
    }

    static int runs_scored(
        BaseOutState initial_state, 
        BaseOutState end_state) {
        // before = after
        // runners + 1 = runners + runs scored + outs made
        // runs scored = -d(runners) - d(outs) + 1 
        int runners_end = sum(end_state.base_state.bases[]);
        int runners_start = sum(initial_state.base_state.bases[]);
        int douts = end_state.outs - initial_state.outs;
        return 1 - douts - (runners_end - runners_start);
    }
}


