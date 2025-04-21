const Ray = @import("ray.zig").Ray;
const Hit = @import("hittable.zig");
const Color = @import("color.zig").Color;
const Vec = @import("vec.zig");

const Materials = enum {
    default,
    lambertian,
    metal,
};

const Self = @This();
type: Materials,
color: Color,
fuzz: f32,

pub fn scatter(
    self: *Self,
    ray: *const Ray,
    rec: *Hit.HitRecord,
    attenuation: *Color,
    scattered: *Ray,
) bool {
    switch (self.type) {
        .lambertian => {
            var scattered_dir = Vec.add(rec.normal, Vec.randomUnitVector());
            if (Vec.nearZero(scattered_dir)) {
                scattered_dir = rec.normal;
            }
            scattered.* = Ray{ .origin = rec.point, .direction = scattered_dir };
            attenuation.* = self.color;
            return true;
        },
        .metal => {
            var scattered_dir = Vec.reflect(ray.direction, rec.normal);
            scattered_dir = Vec.add(Vec.unit(scattered_dir), Vec.scale(
                Vec.randomUnitVector(),
                self.fuzz,
            ));
            if (Vec.nearZero(scattered_dir)) {
                scattered_dir = rec.normal;
            }
            scattered.* = Ray{ .origin = rec.point, .direction = scattered_dir };
            attenuation.* = self.color;
            return true;
        },
        .default => {},
    }
    return false;
}
