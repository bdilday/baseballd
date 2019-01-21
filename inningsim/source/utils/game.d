
module game;

import events;
import states;

struct GameState {
    BaseOutState base_out_state;
    int score;

    GameState transition(HitRunEvent hit_run_event) {
        BaseOutState new_state = this.base_out_state.transition(hit_run_event);
        int runs_scored = BaseOutState.runs_scored(
            this.base_out_state, 
            new_state);
        return GameState(new_state, this.score + runs_scored);
    }

}

unittest {
    GameState gs;
    assert(gs.base_out_state.outs == 0);
}
