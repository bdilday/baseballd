
module player;

import std.stdio;
import events;

class Player {
    string id;
    string name;
}

class Batter: Player {
    immutable double[] hit_probs;
}

class Pitcher: Player {
    immutable double[] hit_probs;
}

