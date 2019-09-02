import std.math;
import std.conv;

// simple structure for representing colors
// My original implementation used ubytes for the channells
// but this version follows the openGL format of using
// floating point data types for color channels.
struct Color
{
    real r;         // Red channel
    real g;         // Green channel
    real b;         // Blue channel
    real a = 1.0;   // Alpha channel, defaults to 1.0 for most applications and can be excluded

    // Some color presets
    enum Color Black = Color(0,0,0);
    enum White = Color(1.0, 1.0, 1.0);
    enum Color Red = Color(1.0, 0, 0);
    enum Color Green = Color(0, 1.0, 0);
    enum Color Blue = Color(0, 0, 1.0);

    // Define Color manipulated by a constant
    Color opBinary(string op)(float scalar)
        if(op == "*" || op == "/" || op == "+" || op == "-")
    {
        mixin("return Color(this.r "~op~" scalar, this.g "~op~" scalar, this.b "~op~" scalar, this.a);");
    }

    Color opBinaryRight(string op)(float scalar)
        if(op == "*" || op == "/" || op == "+" || op == "-")
    {
        return this.opBinary!(op)(scalar);
    }

    // Allow adding and subtracting Colors from each other
    Color opBinary(string op)(Color lhs)
        if(op == "+" || op == "-")
    {
        mixin("return Color(this.r "~op~" lhs.r, this.g "~op~" lhs.g, this.b "~op~" lhs.g, this.a "~op~" lhs.a);");
    }

    // Sets all of the color channels to between 0.0 and 1.0
    Color clamp()
    {
        r = r < 0.0 ? 0.0 : (r > 1.0 ? 1.0 : r);
        g = g < 0.0 ? 0.0 : (g > 1.0 ? 1.0 : g);
        b = b < 0.0 ? 0.0 : (b > 1.0 ? 1.0 : b);
        a = a < 0.0 ? 0.0 : (a > 1.0 ? 1.0 : a);

        return this;
    }

    string toString()
    {
        return "Color(r=" ~ r.to!string ~", g=" ~ g.to!string ~ ", b=" ~ b.to!string ~ ", a= " ~ a.to!string ~ ")";
    }
}

unittest
{
    import std.conv;
    assert(Color.White == (Color.Red + Color.Green + Color.Blue).clamp());
    assert(Color(0.2, 0.2, 0.2) * 2 == Color(0.4, 0.4, 0.4));
    assert(Color(-0.1, -0.5, -0.6).clamp() == Color.Black);
    assert(Color(1.2, 1.5, 40, 3).clamp() == Color.White);
    auto test = Color(0.5, 0.3, 0.2, 0.1);
    assert(test.clamp() == test);
}
