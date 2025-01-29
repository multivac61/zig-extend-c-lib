const std = @import("std");
const testing = std.testing;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

export fn sub(a: i32, b: i32) i32 {
    return a - b;
}

test "basic add functionality" {
    try testing.expectEqual(10, add(3, 7));
}

test "basic sub functionality" {
    try testing.expectEqual(-4, sub(3, 7));
}
