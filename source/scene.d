import std.math;

import vector;
import window;
import color;
import shape;
import light;

// The Scene class holds all of the objects in the scene
// as well as the position of the camera and performs a
// ray-tracing originating from the camera
class Scene
{
    Vector camera = Vector(0, 0, 0);    // Location of the camera
    //Vector cameraRotation = Vector(1, 1, 1);    // Rotation vector for the camera
    double width, height, depth;        // The size of the scene, it's more of it's relative size compared to the actual window size
    Shape[] objects;                    // List of objects in the scene
    Light[] lights;                     // List of lights
    Vector delegate(Vector) rotator;

    enum Mode
    {
        RayTrace,
        Raster
    }

    Mode mode;

    this(double width, double height, double depth)
    {
        this.width = width;
        this.height = height;
        this.depth = depth;
    }

    void setMode(Mode mode)
    {
        this.mode = mode;
    }

    // Draws the scene to the window buffer by sending rays out from the camera to
    // the scene using the canvas as a window
    void draw(Window win)
    {
        Canvas canvas = win.getCanvas();
        auto cw = canvas.getWidth();
        auto ch = canvas.getHeight();

        foreach(x; -cw/2..cw/2)
            foreach(y; -ch/2..ch/2)
            {
                auto D = canvasToViewport(Vector(x, y), cw, ch);
                //D = rotator(D);
                auto color = traceRay(camera, D, 1.0, 1000.0, 0);
                canvas.putPixel(x, y, color);
            }
    }

    void updateCamera(Vector move, Vector delegate(Vector) rotator)
    {
        camera = rotator(camera + move);
        //this.rotator = rotator;
    }

    void addShape(Shape object)
    {
        objects ~= object;
    }

    void addLight(Light light)
    {
        lights ~= light;
    }

    Color traceRay(Vector origin, Vector D, real t_min, real t_max, int recursion_depth = 3)
    {
        auto intersect = Shape.closestIntersection(origin, D, t_min, t_max, objects);
        auto closest_object = intersect.shape;
        auto closest_t = intersect.dist;

        if(closest_object is null) return Window.background;
        else
        {
            auto P = origin + (D * closest_t);
            auto N = closest_object.computeNormal(P);
            N = N / N.length();
            auto color = (closest_object.color * computeLighting(P, N, -D, closest_object.specular)).clamp();

            auto r = closest_object.reflective;
            if(recursion_depth <= 0 || r <= 0.0) return color;

            auto R = reflectRay(-D, N);
            auto reflected_color = traceRay(P, R, 0.001, t_max, recursion_depth-1);

            return (color*(1.0 - r) + reflected_color*r).clamp();
        }
    }

     // computes the reflected ray, R, off the normal vector
    Vector reflectRay(Vector R, Vector N)
    {
        return ((2*N)*(N.dot(R))) - R;
    }

    real computeLighting(Vector P, Vector N, Vector V, real s)
    {
        real i = 0.0;
        real t_max;
        Vector L;
        foreach(Light light; lights)
        {
            if(light.type == Light.Type.Ambient) i += light.intensity;
            else
            {
                if(light.type == Light.Type.Point)
                {
                    L = light.position - P;
                    t_max = 1.0;
                }
                else
                {
                    L = light.direction;
                    t_max = 1000.0;
                }

                // check for shadows
                auto intersection = Shape.closestIntersection(P, L, 0.001, t_max, objects);
                if(intersection.shape !is null) continue;

                // calculate diffuse light
                auto n_dot_l = N.dot(L);
                if(n_dot_l > 0)
                    i += light.intensity * n_dot_l / (N.length() *L.length());

                // calculate specular light
                if(s != -1)
                {
                    auto R = N * N.dot(L) * 2 - L;
                    auto r_dot_v = R.dot(V);
                    if(r_dot_v > 0) i += light.intensity * (r_dot_v / (R.length() * V.length()))^^s;
                }
            }
        }

        return i;
    }

    private Vector canvasToViewport(Vector coor, int cw, int ch)
    {
        return Vector(coor.x*width/cw, coor.y*height/ch, depth);
    }
}
