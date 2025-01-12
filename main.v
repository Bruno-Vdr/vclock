module main

import raylib
import math
import time

const screen_width = 512
const screen_height = 512
const r = 230.0
const brand = 'V\'s 60Hz clock'
const brand_height = 10

fn main() {
	raylib.set_config_flags(raylib.ConfigFlags.flag_msaa_4x_hint)
	raylib.init_window(screen_width, screen_height, 'V / raylib time example.')
	raylib.set_target_fps(60) // Set our game to run at 60 frames-per-second

	defer {
		// De-Initialization
		raylib.close_window() // Close window and OpenGL context
	}

	offset := raylib.Vector2{256, 256}
	target := raylib.Vector2{0, 0}
	camera := raylib.Camera2D{offset, target, 0.0, 1.0}

	brand_pos := -raylib.measure_text(brand, brand_height)/ 2

	for !raylib.window_should_close() { // Detect window close button or ESC key
		t := time.now()
	    s := '${t.hour:02}:${t.minute:02}:${t.second:02}'

		raylib.begin_drawing()
		raylib.clear_background(raylib.raywhite)
		raylib.begin_mode_2d(camera)
		raylib.draw_text(brand, brand_pos, 30, brand_height, raylib.lightgray)
		draw_dial()
		draw_hands(&t)
		raylib.draw_text(s, -250, -250, 20, raylib.lightgray)
		raylib.draw_circle(0, 0, 20.0, raylib.darkgray)
		raylib.end_mode_2d()
		raylib.end_drawing()
	}
}

// draw_dial renders the clock dial. Keep in mind that raylib Camera2D Y axis is reversed.
fn draw_dial() {
	mut angle := 0.0
	for i in 0 .. 60 {
		angle_rad := angle * math.pi / 180.0
		x := int(r * math.cos(angle_rad))
		y := int(r * math.sin(angle_rad))
		radius := if i % 5 == 0 { f32(10) } else { f32(3) }
		raylib.draw_circle(x, y, radius, raylib.black)
		angle += 360.0/60.0  // angular_step
	}
}

// Draw the 3 clock hands. Keep in mind that raylib Camera2D Y axis is reversed.
fn draw_hands(now &time.Time ) {
	angle_seconds := f64(180 + (360 / 60) * (now.second + f64(now.nanosecond) / 1_000_000_000.0))
	angle_minutes := f64(180 + (360 / 60) * (now.minute + (f64(now.second) / 60.0)))
	angle_hours := f64(180 + (360 / 12) * (now.hour + (f64(now.minute) / 60.0)))
	draw_hand(angle_hours, 15, 120, raylib.black)
	draw_hand(angle_minutes, 10, 225, raylib.black)
	draw_hand(angle_seconds, 7, 230, raylib.red)
}

// draw_hand draws a single clock hand. base_width is the base of the triangle
// while length is the distance from the clock center. Keep in mind that raylib Camera2D Y
// axis is reversed.
fn draw_hand(angle f64, base_width int, length int, col raylib.Color) {
	x0 := int(base_width * math.cos(angle * math.pi / 180.0))
	y0 := int(base_width * math.sin(angle * math.pi / 180.0))
	v0 := raylib.Vector2{x0, y0}
	v1 := raylib.Vector2{-x0, -y0}

	x2 := int(length * math.cos((angle + 90.0) * math.pi / 180.0))
	y2 := int(length * math.sin((angle + 90.0) * math.pi / 180.0))
	v2 := raylib.Vector2{x2, y2}
	raylib.draw_triangle(v0, v1, v2, col)
}
