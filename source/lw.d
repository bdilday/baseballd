module lw;

import std.stdio;
import std.algorithm.setops : cartesianProduct;
import std.algorithm : map;
import std.range : iota;
import std.conv : to;
import std.typecons : Tuple, tuple;
import std.format;
import std.functional : memoize;

alias Inning = int;
alias Outs = int;
alias StateVector = State[];
alias fastReachable = memoize!ReachableStates;

void main(string[] args){

    StateVector state_vec;
    real[BaseOutState] bo_vec;

    auto initial_state = BaseOutState();
    BaseOutState[] next_state;

    GameState gs = GameState(initial_state, 1, LineupSlot(Player(), 1), 0);

    BaseOutState[][BaseOutState] reachable;

    static BaseOutState[] all_bo = generate_all_bo_states(3);

    foreach (bo ; all_bo) {

    writeln("bo ", bo);
    bo_vec[bo] = 0.0;
     /*   writeln("bo ", bo);
        writeln("reachable *** ");
        writeln(ReachableStates(bo, events.BB));
        writeln(ReachableStates(bo, events.X1B));
     */

     foreach (e ; events) {
        reachable[bo] ~= ReachableStates(bo, e);
     }

    }

    foreach (k, v; reachable) {
        writeln(k, " ", v);
    }

    bo_vec[initial_state] = 1.0;
    state_vec ~= State(initial_state, 1.0);

    writeln(state_vec);
    Player generic_player = Player();

    foreach (s ; state_vec) {
        next_state = evolve_state(s, generic_player);
    }

}


BaseOutState[] evolve_state(State s, Player atbat) {

    BaseOutState[] X;

    foreach (i, e ; events) {
        auto p = atbat.event_probs[i];
        writeln(p);
    }
//    X = fastReachable(s, e);

    return X;
}


struct Event {
    string name;
    int num_advance;
    int num_outs;
}

immutable Event[] events = [
    Event("BB", 0, 0),
    Event("X1B", 1, 0),
    Event("X2B", 2, 0),
    Event("X3B", 3, 0),
    Event("X4B", 4, 0),
    Event("Out", 0, 1)];

void compute_transition_probs() {

}


BaseOutState[] ReachableStates(BaseOutState b, Event e) {
    BaseOutState[] X;
    Base[] update;

    if (b.end) {
     X ~= b;
     return X;
    }

    if (e.name == "Out") {
        X ~= BaseOutState(b.bases, b.outs + e.num_outs);
    } else if (e.name == "BB") {
        update = advance_bases(b.bases, e.num_advance, 0);
        X ~= BaseOutState(update, b.outs);
    } else {
       update = advance_bases(b.bases, e.num_advance, 0);
        X ~= BaseOutState(update, b.outs);
        update = advance_bases(b.bases, e.num_advance, 1);
        X ~= BaseOutState(update, b.outs);
    }


    return X;
}

Base[] advance_bases(Base[] bsX, int num_advance, bool extra_base) {

    auto bs = bsX.dup;

    if (num_advance == 0) { // cheap way of doing BB
        if (!bs[0].occupied) {
            bs[0] = Base(true);
        } else if (!bs[1].occupied) {
            bs[1] = Base(true);
            bs[0] = Base(true);
        } else if (!bs[2].occupied) {
            bs[2] = Base(true);
            bs[1] = Base(true);
            bs[0] = Base(true);
        } else {
            bs[2] = Base(true);
            bs[1] = Base(true);
            bs[0] = Base(true);
        }

    } else if (num_advance == 1) {
        bs[0] = Base(true);
        if (extra_base) {
            bs[1] = Base(false);
            bs[2] = bsX[0];
        } else {
            bs[1] = bsX[0];
            bs[2] = bsX[1];
        }
    } else if (num_advance == 2) {
        bs[0] = Base(false);
        bs[1] = Base(true);
        bs[2] = bsX[0];

        if (extra_base) {
            bs[2] = Base(false);
        }

    } else if (num_advance == 3) {
        bs[0] = Base(false);
        bs[1] = Base(false);
        bs[2] = Base(true);
    } else if (num_advance == 4) {
        bs[0] = Base(false);
        bs[1] = Base(false);
        bs[2] = Base(false);
    }

return bs;

}

struct State {
    BaseOutState bo;
    real prob;
}

struct TransitionProbs {
    BaseOutState state1;
    BaseOutState state2;
    real probability;
}


string[] outs_string = ["OO", "OX", "XX", "ZZ"];

struct BaseOutState {

    Base[3] bases;
    Outs outs;
    bool end = false;
    int max_outs = 3;

    void set_end () {
        end = true;
        bases[0] = Base(0);
        bases[1] = Base(0);
        bases[2] = Base(0);
    }

    this(Tuple!(int, int, int, int) x) {
        bases[0] = Base(x[0]);
        bases[1] = Base(x[1]);
        bases[2] = Base(x[2]);
        outs = x[3];
           if (outs == max_outs) {
                    set_end();
                }
    }

    this(Base[] b, int o) {
        bases = b[0..3];
        outs = o;
        if (outs == max_outs) {
            set_end();
        }
      }

    string toString() {
       char[] c;

       if (end) return "END|ZZ";
       foreach (i, b ; bases) {
          c ~= b.occupied ? to!string(i+1) : "_";
       }

       c ~= format("|%s", outs_string[outs]);
       return to!string(c);
    }

}

struct GameState {
    BaseOutState bo_state;
    Inning inning;
    LineupSlot slot;
    int score;
}

struct LineupSlot {
    Player player;
    int slot;
}
struct Base {
    bool occupied;
    Player player;

    this(int i) {
        occupied = to!bool(i);
    }
}

struct Player {
    char[] name = "default".dup;
    char[] plid = "none".dup;
    real[] event_probs = [0.08, 0.15, 0.05, 0.005, 0.025, 0.69];

}

BaseOutState[] generate_all_bo_states(int number_outs) {
    BaseOutState[] all_bo;
    BaseOutState bo;
    foreach (bo_data ; cartesianProduct([0, 1], [0, 1], [0, 1], iota(number_outs))) {
        bo = BaseOutState(bo_data);
        all_bo ~= bo;
    }

    bo = BaseOutState(tuple(0, 0, 0, number_outs));
    all_bo ~= bo;
    return all_bo;
}
