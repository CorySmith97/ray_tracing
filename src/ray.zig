const Vec = @import("vec.zig");
const Vec3 = Vec.Vec3;

pub const Ray = struct {
    const Self = @This();
    origin: Vec3,
    direction: Vec3,

    pub fn at(self: *Self, t: f32) Vec3 {
        return Vec.add(
            self.origin,
            Vec.scale(self.direction, t),
        );
    }
};
