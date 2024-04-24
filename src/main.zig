const std = @import("std");
const c = @cImport(@cInclude("SDL2/SDL.h"));

const HEIGHT: u16 = 300;
const WIDTH: u16 = 400;

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        std.debug.print("ERROR", .{});
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("Test", 200, 100, WIDTH, HEIGHT, 0);
    defer c.SDL_DestroyWindow(window);

    const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED);
    defer c.SDL_DestroyRenderer(renderer);

    _ = c.SDL_RenderClear(renderer);
    var x: i32 = 0;
    var timer = try std.time.Timer.start();
    while (x < WIDTH) : (x += 1) {
        var y: i32 = 0;
        while (y < HEIGHT) : (y += 1) {
            const r: f32 = @as(f32, @floatFromInt(x)) / WIDTH;
            const g: f32 = @as(f32, @floatFromInt(y)) / HEIGHT;
            const b: f32 = 0;

            const ir: u8 = @as(u8, @intFromFloat(r * 255.999));
            const ig: u8 = @as(u8, @intFromFloat(g * 255.999));
            const ib: u8 = @as(u8, @intFromFloat(b * 255.999));
            _ = c.SDL_SetRenderDrawColor(renderer, ir, ig, ib, 255);
            _ = c.SDL_RenderDrawPoint(renderer, x, y);
        }
    }
    const time = timer.read();
    std.debug.print("Render Time: {}ms\n", .{time / std.time.ns_per_ms});
    _ = c.SDL_RenderPresent(renderer);
    var quit = false;
    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }
    }
}
