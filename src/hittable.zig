const Ray = @import("ray.zig").Ray;
const Vec = @import("vec.zig");
const Vec3 = Vec.Vec3;
const std = @import("std");
const Interval = @import("interval.zig");
const Material = @import("material.zig");
const Color = @import("color.zig").Color;

pub const HitRecord = struct {
    point: Vec3 = .{},
    normal: Vec3 = .{},
    material: Material = .{
        .type = .default,
        .color = Color.new(0, 0, 0),
        .fuzz = 0.0,
    },
    t: f32 = 0,
    front_face: bool = false,

    pub fn setFaceNormal(self: *@This(), ray: *Ray, outward_normal: *Vec3) void {
        self.front_face = Vec.dot(ray.direction, outward_normal.*) < 0;
        self.normal = if (self.front_face) outward_normal.* else .{
            .x = outward_normal.x,
            .y = outward_normal.y,
            .z = outward_normal.z,
        };
    }
};

pub const Sphere = struct {
    const Self = @This();
    radius: f32,
    center: Vec3,
    mat: Material,

    pub fn new(radius: f32, x: f32, y: f32, z: f32, mat: Material) Self {
        return Self{
            .radius = radius,
            .center = .{
                .x = x,
                .y = y,
                .z = z,
            },
            .mat = mat,
        };
    }

    pub fn hit(self: *Self, ray: *Ray, interval: Interval, record: *HitRecord) bool {
        const oc = Vec.sub(self.center, ray.origin);
        const a = Vec.dot(ray.direction, ray.direction);
        const h = Vec.dot(ray.direction, oc);
        const c = Vec.lengthsq(oc) - (self.radius * self.radius);
        const discriminant = (h * h) - (a * c);
        if (discriminant < 0) {
            return false;
        }

        const sqrtd = @sqrt(discriminant);
        var root = (h - sqrtd) / a;
        if (!interval.surrounds(root)) {
            root = (h + sqrtd) / a;
            if (!interval.surrounds(root)) {
                return false;
            }
        }

        record.t = root;
        record.point = ray.at(root);
        var outward_norm = Vec.scale(Vec.sub(record.point, self.center), 1 / self.radius);
        record.setFaceNormal(ray, &outward_norm);
        record.material = self.mat;

        return true;
    }
};

pub const HitList = struct {
    sphere_list: std.ArrayList(Sphere),

    pub fn hit(
        self: *@This(),
        ray: *Ray,
        interval: Interval,
        record: *HitRecord,
    ) bool {
        var temp_record: HitRecord = .{};
        var hit_anything: bool = false;
        var closest: f32 = interval.max;

        for (self.sphere_list.items) |*sphere| {
            if (sphere.hit(ray, Interval.new(interval.min, closest), &temp_record)) {
                hit_anything = true;
                closest = record.t;
                record.* = temp_record;
            }
        }

        return hit_anything;
    }

    pub fn deinit(self: *@This()) void {
        self.sphere_list.deinit();
    }
};
