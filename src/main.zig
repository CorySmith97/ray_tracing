const std = @import("std");
const time = std.time;
const CUtil = @import("color.zig");
const Color = CUtil.Color;
const assert = std.debug.assert;
const Ray = @import("ray.zig").Ray;
const Vec = @import("vec.zig");
const Vec3 = Vec.Vec3;
const Hittable = @import("hittable.zig");
const Sphere = Hittable.Sphere;
const World = Hittable.HitList;
const Util = @import("util.zig");
const Interval = @import("interval.zig");
const Camera = @import("camera.zig");
const Matieral = @import("material.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    const matieral_ground = Matieral{ .type = .lambertian, .color = Color.new(0.8, 0.8, 0.0), .fuzz = 0.5 };
    const matieral_center = Matieral{ .type = .lambertian, .color = Color.new(0.1, 0.2, 0.5), .fuzz = 0.0 };
    const matieral_left = Matieral{ .type = .metal, .color = Color.new(0.8, 0.8, 0.8), .fuzz = 0.3 };
    const matieral_right = Matieral{ .type = .metal, .color = Color.new(0.8, 0.6, 0.2), .fuzz = 1.0 };

    // World
    var world: World = World{
        .sphere_list = std.ArrayList(Sphere).init(allocator),
    };
    defer world.deinit();

    try world.sphere_list.append(Sphere.new(0.5, 0, 0, -1.2, matieral_center));
    try world.sphere_list.append(Sphere.new(0.5, 1, 0, -1, matieral_right));
    try world.sphere_list.append(Sphere.new(0.5, -1.0, 0, -1, matieral_left));
    try world.sphere_list.append(Sphere.new(100, 0, -100.5, -1, matieral_ground));

    var cam: Camera = undefined;
    cam.init();
    try cam.render(&world);
}
