const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimizer = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "hello",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimizer,
    });

    exe.linkSystemLibrary("sdl2");
    //exe.addLibraryPath(.{ .cwd_relative = "include/lib/libSDL2.a" });
    //exe.addIncludePath(.{ .path = "include/SDL2" });
    exe.linkLibC();
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);
}
