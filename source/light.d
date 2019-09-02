import std.math;

import vector;

struct Light
{
    enum Type
    {
        Ambient,
        Directional,
        Point
    }

    Type type;
    real intensity;
    union
    {
        Vector position;
        Vector direction;
    }
}
