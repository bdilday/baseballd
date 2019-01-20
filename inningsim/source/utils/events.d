
module events;


enum HitEvent {x1b, x2b, x3b, x4b, xbb, xout};

enum RunEvent {take_third, take_home};


struct RunEventTransition {
    bool take_home;
    bool take_third;
    
    this(bool take_third, bool take_home) {
        this.take_home = take_home;
        this.take_third = take_third;
    }

}

struct HitRunEvent {
    HitEvent hit_event;
    RunEventTransition run_event_transition;
}

