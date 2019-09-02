import derelict.sdl2.sdl;
import std.stdio;
import std.conv;

import color;

// Simple Window class that provides the drawing and wrapper
// over the SDL structures
class Window
{
    private SDL_Window * win;                   // Pointer to the SDL_Window
    private SDL_Surface * screenSurface;        // Pointer to the SDL_Surface that SDL draws to
    private Canvas[2] windowBuffer;             // Canvas that code in this program draws, setup for double buffering but not completely implemented
    private int drawCanvas = 0;                 // The current canvas to draw to for double buffering
    uint width;                                 // Width of the window
    uint height;                                // Height of the window
    static Color background = Color.Black;      // Default color to draw to a canvas

    this(uint width, uint height)
    {
        this.width = width;
        this.height = height;
        win = SDL_CreateWindow("Graphics Tutorials", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_SHOWN);
        if(win is null)
        {
            SDL_DestroyWindow(win);
            SDL_Quit();
            throw new Error("SDL Window creation failed: " ~ SDL_GetError().to!string());
        }
        screenSurface = SDL_GetWindowSurface(win);
        windowBuffer[0] = new Canvas(width, height);
        windowBuffer[1] = new Canvas(width, height);
    }

    ~this()
    {
        SDL_DestroyWindow(win);
    }

    void draw()
    {
        SDL_FillRect(screenSurface, null, SDL_MapRGBA(screenSurface.format, (background.r*255).to!ubyte(), (background.g*255).to!ubyte(), (background.b*255).to!ubyte(), (background.a*255).to!ubyte()));
        SDL_BlitSurface(windowBuffer[drawCanvas].getSurface(), null, screenSurface, null);
        SDL_FillRect(windowBuffer[drawCanvas].getSurface(), null, SDL_MapRGBA(screenSurface.format, (background.r*255).to!ubyte(), (background.g*255).to!ubyte(), (background.b*255).to!ubyte(), (background.a*255).to!ubyte()));
        drawCanvas = drawCanvas == 0 ? 1 : 0;

        SDL_UpdateWindowSurface(win);
    }

    Canvas getCanvas()
    {
        return windowBuffer[drawCanvas];
    }

    void resetMousePos()
    {
        SDL_WarpMouseInWindow(win,width/2,height/2);
    }
}

class Canvas
{
    private int width;
    private int height;
    private SDL_Surface * canvas;

    this(int new_width, int new_height)
    {
        width = new_width;
        height = new_height;
        canvas = SDL_CreateRGBSurface(0, width, height, 32, 0, 0, 0, 0);
        if(canvas is null)
            throw new Error("SDL Canvas creation failed: " ~ SDL_GetError().to!string());
    }

    private SDL_Surface * getSurface()
    {
        return canvas;
    }

    int getWidth()
    {
        return width;
    }

    int getHeight()
    {
        return height;
    }

    void putPixel(int x, int y, Color color)
    {
        //convert to uppler left corner coordinates
        SDL_Rect rect;
        rect.x = width/2 + x;
        rect.y = height/2 - y;
        rect.w = 1;
        rect.h = 1;
        SDL_FillRect(canvas, &rect, SDL_MapRGBA(canvas.format, (color.r*255).to!ubyte(), (color.g*255).to!ubyte(), (color.b*255).to!ubyte(), (color.a*255).to!ubyte()));
    }

    void putPixelRaw(int x, int y, Color color)
    {
        //convert to uppler left corner coordinates
        SDL_Rect rect;
        rect.x = x;
        rect.y = y;
        rect.w = 1;
        rect.h = 1;
        SDL_FillRect(canvas, &rect, SDL_MapRGBA(canvas.format, (color.r*255).to!ubyte(), (color.g*255).to!ubyte(), (color.b*255).to!ubyte(), (color.a*255).to!ubyte()));
     }
}
