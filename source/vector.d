import std.math;
import std.conv;

alias Vector3d Vector;

struct Vector3d
{
    real x, y, z = 0;
    enum Unit = Vector3d(1.0, 1.0, 1.0);

    real dot(Vector3d lhs)
    {
        return (this.x * lhs.x) + (this.y * lhs.y) + (this.z * lhs.z);
    }

    Vector3d cross(Vector3d lhs)
    {
        return Vector3d(this.y*lhs.z - this.z*lhs.y, this.z*lhs.x - this.x*lhs.z, this.x*lhs.y - this.y*lhs.x);
    }

    real length()
    {
        return sqrt(x^^2 + y^^2 + z^^2);
    }

    Vector3d opUnary(string op)()
        if(op == "-")
    {
        mixin("return Vector3d(-this.x, -this.y, -this.z);");
    }

    Vector3d opBinary(string op)(real scalar)
        if(op == "+" || op == "-" || op == "*" || op == "/")
    {
        mixin("return Vector3d(this.x "~op~"scalar, this.y "~op~"scalar, this.z "~op~"scalar);");
    }

    Vector3d opBinaryRight(string op)(real scalar)
        if(op == "+" || op == "-" || op == "*" || op == "/")
    {
        return this.opBinary!(op)(scalar);
    }

    Vector3d opBinary(string op)(Vector3d lhs)
        if(op == "+" || op == "-" || op == "*" || op == "/")
    {
        mixin("return Vector3d(this.x "~op~"lhs.x, this.y "~op~"lhs.y, this.z "~op~"lhs.z);");
    }

    string toString()
    {
        return "Vector("~x.to!string~", "~y.to!string~", "~z.to!string~")";
    }

    static auto rotationGenerator(real rot_x, real rot_y)
    {
        real const_x = sqrt(rot_x*rot_x+1);
        real const_y = sqrt(rot_y*rot_y+1);

        Vector rotateVector(Vector v)
        {
            Vector rot_v;
            rot_v.x = v.x/const_x - v.y*rot_x*rot_y/(const_x*const_y) + v.z*rot_x/(const_x*const_y);
            rot_v.y = v.y/const_y + v.z*rot_y/const_y;
            rot_v.z = v.z/(const_x*const_y) - v.x*rot_x/const_x - v.y*rot_y/(const_x*const_y);
            return rot_v;
        }
        return &rotateVector;
    }

    Vector round(real digit)
    {
        real scale = digit==0.1 ? (1.0/digit)/10 : 1.0/digit;
        return Vector(std.math.round(x*scale)/scale, std.math.round(y*scale)/scale, std.math.round(z*scale)/scale);
    }

}

unittest
{
    Vector v1 = Vector(1,3,-5);
    Vector v2 = Vector(4,-2,-1);
    assert(v1.dot(v2) == 3);
    assert(v2.dot(v1) == 3);
    assert(Vector(2,3,6).length() == 7);
    assert(Vector(2,3,6).length() == sqrt(Vector(2,3,6).dot(Vector(2,3,6))));
    assert(-v1 == Vector(-1,-3,5));
    v1.x = v1.x/2;
    assert(v1 == Vector(0.5,3,-5))

    import std.conv;
    auto v3 = Vector(-1.5, 2.8, 5.4);
    v3 = v3.round(0.1);
    assert(v3 == Vector(-2, 3, 5));
    auto generator = Vector.rotationGenerator(0.05, 1.0);
    // both sides need to be rounded in order deal with stupid small calculation errors
    assert(generator(v3).round(0.001) == Vector(-1.927, 5.657, 1.512).round(0.001), (generator(v3).round(0.001).z - Vector(-1.927, 5.657, 1.512).z).to!string);
}
