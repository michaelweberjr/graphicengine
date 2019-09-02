import std.stdio;
import derelict.sdl2.sdl;
import std.conv;
import std.math;
import std.stdio;

import window;
import scene;
import shape;
import color;
import vector;
import light;


int main(string[] args)
{
    // Load the SDL shared library. We need to use an older version because my linux
    // distro isn't running the latest version supported by Derelict
    DerelictSDL2.load(SharedLibVersion(2, 0, 2));
    if(SDL_Init(SDL_INIT_VIDEO) != 0)
        throw new Error("SDL Initilization failed: " ~ to!string(SDL_GetError()));

    // Create a new windw
    Window window = new Window(1080, 1080);
    // Create a new scene with a size of unity
    Scene scene = new Scene(1, 1, 1);
    // Add scene objects
    scene.addShape(new Sphere(Vector(0, -1, 3), 1, Color.Red, 0.2, 500));
    scene.addShape(new Sphere(Vector(2, 0, 4), 1, Color.Blue, 0.3, 500));
    scene.addShape(new Sphere(Vector(-2, 0, 4), 1, Color.Green, 0.4, 10));
    scene.addShape(new Sphere(Vector(0, -5001, 0), 5000, Color(1, 1, 0), 0.5, 1000));
    // Add scene lights
    scene.addLight(Light(Light.Type.Ambient, 0.2));
    scene.addLight(Light(Light.Type.Point, 0.6, Vector(2, 1, 0)));
    scene.addLight(Light(Light.Type.Directional, 0.2, Vector(1, 4, 4)));

    // SDL event to get events
    SDL_Event e;
    SDL_SetRelativeMouseMode(SDL_TRUE);
    bool quit = false;
    while(!quit)
    {
        Vector move = Vector(0, 0, 0);
        auto rotator_default = Vector.rotationGenerator(0.0, 0.0);
        auto rotator = rotator_default;
        // short delay to allow events to queue
        SDL_Delay(1);
        // check all events and quit the program when SDL_QUIT is recieved
        while(SDL_PollEvent(&e))
        {
            if(e.type == SDL_QUIT) quit = true;
            switch(e.type)
            {
                case SDL_KEYDOWN:
                    if(e.key.keysym.sym == SDLK_w) move.z = 1;
                    if(e.key.keysym.sym == SDLK_s) move.z = -1;
                    if(e.key.keysym.sym == SDLK_a) move.x = -1;
                    if(e.key.keysym.sym == SDLK_d) move.x = 1;
                    if(e.key.keysym.sym == SDLK_ESCAPE) quit = true;
                    break;
                case SDL_KEYUP:
                    if(e.key.keysym.sym == SDLK_w) move.z = 0.0;
                    if(e.key.keysym.sym == SDLK_s) move.z = -0.0;
                    if(e.key.keysym.sym == SDLK_a) move.x = -0.0;
                    if(e.key.keysym.sym == SDLK_d) move.x = 0.0;
                    break;
                /*case SDL_MOUSEBUTTONDOWN:
                    //if(e.button.button == SDL_BUTTON_LEFT) click = true;
                    click = true;
                    break;
                case SDL_MOUSEBUTTONUP:
                    //if(e.button.button == SDL_BUTTON_LEFT)
                    click = false;
                    break;*/
                case SDL_MOUSEMOTION:
                    rotator = Vector.rotationGenerator(cast(real)(-e.motion.xrel)/window.width, cast(real)(-e.motion.yrel)/window.height);
                    break;
                default:
                    // any event that we do not handle is simply ignored
                    break;
            }

        }

        // update the camera based on the input
        scene.updateCamera(move, rotator);
        // draw the scene to the window buffer
        scene.draw(window);
        // draw the window buffer the actual window
        window.draw();

        // reset the rotation
        window.resetMousePos();
    }

    // shutdown sdl on program exit
    scope(exit) SDL_Quit();
    return 0;
}

