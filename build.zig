const std = @import("std");

const ZigRos = @import("zigros").ZigRos;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const linkage = b.option(
        std.builtin.LinkMode,
        "linkage",
        "Specify static or dynamic linkage",
    ) orelse .static;

    const zigros = ZigRos.init(b.dependency("zigros", .{
        .target = target,
        .optimize = optimize,
        .linkage = linkage,
        .@"system-python" = false,
    })) orelse return; // return early if lazy deps are needed

    //////////////////////////////////////////////////////////////////////////////////////
    // Custom ROS Interfaces
    //////////////////////////////////////////////////////////////////////////////////////
    const msg_compile_args = .{ .target = target, .optimize = optimize, .linkage = linkage };

    // zigros_example_interface
    var example_msgs = zigros.createInterface(b, "zigros_example_interface", msg_compile_args);
    const example_msgs_msgs = iterateMessages(b, "zigros_example_interface") catch unreachable;
    example_msgs.addInterfaces(b.path("zigros_example_interface"), example_msgs_msgs);

    // the example message uses the standard header message, so we must add builtin_interfaces
    // as a dependency
    example_msgs.addDependency("builtin_interfaces", zigros.ros_libraries.builtin_interfaces);
    example_msgs.addDependency("service_msgs", zigros.ros_libraries.service_msgs);

    if (linkage == .dynamic) {
        example_msgs.installArtifacts();
    }

    // std_msgs
    var std_msgs = zigros.createInterface(b, "std_msgs", msg_compile_args);
    const std_msgs_msgs = iterateMessages(b, "std_msgs") catch unreachable;
    std_msgs.addInterfaces(b.path("std_msgs"), std_msgs_msgs);
    std_msgs.addDependency("builtin_interfaces", zigros.ros_libraries.builtin_interfaces);
    if (linkage == .dynamic) {
        std_msgs.installArtifacts();
    }

    // geometry_msgs
    var geometry_msgs = zigros.createInterface(b, "geometry_msgs", msg_compile_args);
    const geometry_msgs_msgs = iterateMessages(b, "geometry_msgs") catch unreachable;
    geometry_msgs.addInterfaces(b.path("geometry_msgs"), geometry_msgs_msgs);
    geometry_msgs.addDependency("builtin_interfaces", zigros.ros_libraries.builtin_interfaces);
    geometry_msgs.addDependency("std_msgs", std_msgs.artifacts);
    if (linkage == .dynamic) {
        geometry_msgs.installArtifacts();
    }

    //////////////////////////////////////////////////////////////////////////////////////
    // Custom ROS Nodes
    //////////////////////////////////////////////////////////////////////////////////////
    var pub_sub_node = b.addExecutable(.{
        .name = "zig-node",
        .target = target,
        .optimize = optimize,
        .strip = if (optimize == .Debug) false else true,
    });

    pub_sub_node.want_lto = true;

    //  The core ZigROS libraries will also set these flags if ReleaseSmall is used.
    if (optimize == .ReleaseSmall) {
        pub_sub_node.link_function_sections = true;
        pub_sub_node.link_data_sections = true;
        pub_sub_node.link_gc_sections = true;
    }

    pub_sub_node.linkLibCpp();
    zigros.linkRclcpp(&pub_sub_node.root_module);
    zigros.linkRmwCycloneDds(&pub_sub_node.root_module);
    zigros.linkLoggerSpd(&pub_sub_node.root_module);

    pub_sub_node.addIncludePath(b.path("include"));
    pub_sub_node.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{
            "main.cpp",
            "consumer.cpp",
            "producer.cpp",
            "service.cpp",
        },
        .flags = &.{
            "--std=c++17",
            "-Wno-deprecated-declarations",
        },
    });

    example_msgs.artifacts.linkCpp(&pub_sub_node.root_module);
    std_msgs.artifacts.linkCpp(&pub_sub_node.root_module);
    geometry_msgs.artifacts.linkCpp(&pub_sub_node.root_module);

    b.installArtifact(pub_sub_node);

    var talker_node = b.addExecutable(.{
        .name = "talker",
        .target = target,
        .optimize = optimize,
        .strip = if (optimize == .Debug) false else true,
    });

    talker_node.want_lto = true;

    //  The core ZigROS libraries will also set these flags if ReleaseSmall is used.
    if (optimize == .ReleaseSmall) {
        talker_node.link_function_sections = true;
        talker_node.link_data_sections = true;
        talker_node.link_gc_sections = true;
    }

    talker_node.linkLibCpp();
    zigros.linkRclcpp(&talker_node.root_module);
    zigros.linkRmwCycloneDds(&talker_node.root_module);
    zigros.linkLoggerSpd(&talker_node.root_module);

    talker_node.addIncludePath(b.path("include"));
    talker_node.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{
            "talker_node.cpp",
            "producer.cpp",
        },
        .flags = &.{
            "--std=c++17",
            "-Wno-deprecated-declarations",
        },
    });

    example_msgs.artifacts.linkCpp(&talker_node.root_module);
    std_msgs.artifacts.linkCpp(&talker_node.root_module);
    geometry_msgs.artifacts.linkCpp(&talker_node.root_module);

    b.installArtifact(talker_node);

    var listener_node = b.addExecutable(.{
        .name = "listener",
        .target = target,
        .optimize = optimize,
        .strip = if (optimize == .Debug) false else true,
    });

    listener_node.want_lto = true;

    //  The core ZigROS libraries will also set these flags if ReleaseSmall is used.
    if (optimize == .ReleaseSmall) {
        listener_node.link_function_sections = true;
        listener_node.link_data_sections = true;
        listener_node.link_gc_sections = true;
    }

    listener_node.linkLibCpp();
    zigros.linkRclcpp(&listener_node.root_module);
    zigros.linkRmwCycloneDds(&listener_node.root_module);
    zigros.linkLoggerSpd(&listener_node.root_module);

    listener_node.addIncludePath(b.path("include"));
    listener_node.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{
            "listener_node.cpp",
            "consumer.cpp",
        },
        .flags = &.{
            "--std=c++17",
            "-Wno-deprecated-declarations",
        },
    });

    example_msgs.artifacts.linkCpp(&listener_node.root_module);
    std_msgs.artifacts.linkCpp(&listener_node.root_module);
    geometry_msgs.artifacts.linkCpp(&listener_node.root_module);

    b.installArtifact(listener_node);
}

fn iterateMessages(b: *std.Build, path: []const u8) ![]const []const u8 {
    var msgs = std.ArrayList([]const u8).init(b.allocator);

    var msg_dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer msg_dir.close();

    var msg_dir_iter = msg_dir.iterate();
    while (try msg_dir_iter.next()) |msg_subdir| {
        if (msg_subdir.kind == .directory) {
            var dir = try msg_dir.openDir(msg_subdir.name, .{ .iterate = true });
            defer dir.close();

            var iter = dir.iterate();
            while (try iter.next()) |entry| {
                if (entry.kind == .file) {
                    const extension = std.fs.path.extension(entry.name);
                    const is_msg = std.mem.eql(u8, ".msg", extension);
                    const is_srv = std.mem.eql(u8, ".srv", extension);
                    const is_action = std.mem.eql(u8, ".action", extension);
                    if (is_msg or is_srv or is_action) {
                        // Have to duplicate the filename b/c the iterator owns it
                        try msgs.append(try std.fmt.allocPrint(b.allocator, "{s}/{s}", .{ msg_subdir.name, entry.name }));
                    }
                }
            }
        }
    }

    return try msgs.toOwnedSlice();
}
