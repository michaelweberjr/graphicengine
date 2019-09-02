import std.math;

import vector;
import color;

abstract class Shape
{
    Color color;
    real reflective;
    real specular;  // A value of -1 detnotes a non-specular Shape

    this(Color color, real reflective = 1.0, real specular = -1.0)
    {
        this.color = color;
        this.reflective = reflective;
        this.specular = specular;
    }

    // finds the object closest to the origin point
    static Intersect closestIntersection(Vector origin, Vector D, real t_min, real t_max, Shape[] shapes)
    {
        real closest_t = 1000.0;
         foreach(shape; shapes)
        {
            auto t = shape.intersectRay(origin, D, closest_t);
            if(t >= t_min && t <= t_max)
                return Intersect(shape, t);
        }
        return Intersect(null, closest_t);
    }

    real intersectRay(Vector cameraPos, Vector D, real t_max);
    Vector computeNormal(Vector P);
}

struct Intersect
{
    Shape shape;
    real dist;
}

class Sphere : Shape
{
    Vector center;
    real radius;

    this(Vector center, real radius, Color color, real reflective = 0.0, real specular = -1.0)
    {
        this.center = center;
        this.radius = radius;
        super(color, reflective, specular);
    }

    override real intersectRay(Vector cameraPos, Vector D, real t_max)
    {
        auto OC = cameraPos - center;
        auto k1 = D.dot(D);
        auto k2 = 2 * OC.dot(D);
        auto k3 = OC.dot(OC) - radius^^2;

        auto discriminant = k2*k2 - 4*k1*k3;
        if(discriminant < 0) return 2*t_max;
        auto t1 = (-k2 + sqrt(discriminant)) / (2*k1);
        auto t2 = (-k2 - sqrt(discriminant)) / (2*k1);
        return t1 < t2 ? t1 : t2;
    }

    override Vector computeNormal(Vector P)
    {
        return P - center;
    }

    static const Sphere empty = new Sphere(Vector(0,0,0), 0, Color.White);
}
