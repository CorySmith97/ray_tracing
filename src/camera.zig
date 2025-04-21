const std = @import("std");
const time = std.time;
const Vec = @import("vec.zig");
const Vec3 = Vec.Vec3;
const Hit = @import("hittable.zig");
const HitList = Hit.HitList;
const Ray = @import("ray.zig").Ray;
const assert = std.debug.assert;
const Interval = @import("interval.zig");
const Util = @import("util.zig");
const CUtil = @import("color.zig");
const Color = CUtil.Color;
const prng = std.Random.DefaultPrng;
const Material = @import("material.zig");
const builtin = @import("builtin");

const Self = @This();
aspect_ratio: f32 = 1.0,
image_width: f32 = 100,
image_height: f32 = 100,
samples_per_pixel: f32 = 100.0,
pixel_sample_scale: f32 = 10,
center: Vec3 = .{},
pixel00_loc: Vec3 = .{},
pixel_delta_u: Vec3 = .{},
pixel_delta_v: Vec3 = .{},
max_depth: i32 = 10,

pub fn init(self: *Self) void {
    self.aspect_ratio = 16.0 / 9.0;
    self.image_width = 400.0;
    self.image_height = self.image_width / self.aspect_ratio;
    self.samples_per_pixel = 100.0;
    self.pixel_sample_scale = 1.0 / self.samples_per_pixel;
    self.max_depth = 10;
    if (builtin.mode == .ReleaseSafe or builtin.mode == .Debug) {
        assert(self.image_height > 0);
    }

    // Camera
    const focal_length: f32 = 1.0;
    const viewport_height: f32 = 2.0;
    const viewport_width: f32 = viewport_height * self.image_width / self.image_height;
    self.center = .{};

    const viewport_u = Vec3.new(viewport_width, 0, 0);
    const viewport_v = Vec3.new(0, -viewport_height, 0);

    self.pixel_delta_u = Vec.scale(viewport_u, 1 / self.image_width);
    self.pixel_delta_v = Vec.scale(viewport_v, 1 / self.image_height);
    const viewport_upper_left = Vec.sub(
        Vec.sub(
            Vec.sub(self.center, Vec3.new(0, 0, focal_length)),
            Vec.scale(viewport_v, 0.5),
        ),
        Vec.scale(viewport_u, 0.5),
    );

    self.pixel00_loc = Vec.add(
        viewport_upper_left,
        Vec.scale(Vec.add(self.pixel_delta_u, self.pixel_delta_v), 0.5),
    );
}
pub fn render(self: *Self, world: *HitList) !void {
    if (builtin.mode == .ReleaseSafe or builtin.mode == .Debug) {
        assert(self != undefined);
    }
    var file = try std.fs.cwd().createFile("render.ppm", .{});
    defer file.close();

    var writer = file.writer();

    try writer.print("P6\n{d:.0} {d:.0}\n255\n", .{ self.image_width, self.image_height });

    var timer = try time.Timer.start();
    var count: i32 = 0;
    for (0..@intFromFloat(self.image_height)) |h| {
        const fh: f32 = @floatFromInt(h);
        for (0..@intFromFloat(self.image_width)) |w| {
            const fw: f32 = @floatFromInt(w);
            var pixel_color = Color.new(0, 0, 0);
            for (0..@intFromFloat(self.samples_per_pixel)) |_| {
                var r = try self.getRay(fw, fh);
                pixel_color.add(try self.rayColor(&r, self.max_depth, world));
            }
            self.max_depth = 10;
            pixel_color.scale(self.pixel_sample_scale);
            try pixel_color.writeColor(&file);

            count += 1;
        }
    }

    std.log.info("Render Time: {}ms", .{timer.read() / time.ns_per_ms});
}

pub fn getRay(self: *Self, w: f32, h: f32) !Ray {
    const offset = try self.sampleSquare();
    //std.log.info("{any}", .{offset});
    const pixel_sample = Vec.add(
        Vec.add(
            self.pixel00_loc,
            Vec.scale(self.pixel_delta_u, w + offset.x),
        ),
        Vec.scale(self.pixel_delta_v, h + offset.y),
    );

    const ray_origin = self.center;
    const ray_dir = Vec.sub(pixel_sample, ray_origin);

    return Ray{ .origin = ray_origin, .direction = ray_dir };
}

pub fn sampleSquare(self: *Self) !Vec3 {
    _ = self;
    // @performance dont init this in the sample
    return Vec3.new(Vec.rand(-0.5, 0.5), Vec.rand(-0.5, 0.5), 0);
}

pub fn rayColor(self: *Self, ray: *Ray, depth: i32, world: *HitList) !Color {
    if (builtin.mode == .ReleaseSafe or builtin.mode == .Debug) {
        assert(self != undefined);
    }
    if (depth <= 0) {
        return Color.new(0, 0, 0);
    }
    if (builtin.mode == .ReleaseSafe or builtin.mode == .Debug) {
        assert(depth >= 0);
    }
    var rec: Hit.HitRecord = undefined;
    if (world.hit(ray, Interval.new(0.001, Util.inf_f32), &rec)) {
        var scattered: Ray = undefined;
        var attenuation: Color = undefined;
        if (rec.material.scatter(ray, &rec, &attenuation, &scattered)) {
            attenuation.mul(try self.rayColor(&scattered, depth - 1, world));
            return attenuation;
        }
        return Color.new(0, 0, 0);
        //const direction = Vec.randomOnHemisphere(&rec.normal);
        //var color = try self.rayColor(@constCast(&Ray{ .origin = rec.point, .direction = direction }), depth - 1, world);
        //color.scale(0.3);
        //return color;
    }
    const unit_direction = Vec.unit(ray.direction);
    const a = 0.5 * (unit_direction.y + 1);
    var base_color = Color.new(1, 1, 1);
    base_color.scale(1 - a);
    var color2 = Color.new(0.5, 0.7, 1.0);
    color2.scale(a);
    base_color.add(color2);
    return base_color;
}
