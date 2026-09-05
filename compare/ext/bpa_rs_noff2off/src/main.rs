//! NOFF -> OFF driver for martinfrances107/bpa_rs, so that compare.jl can run it.
//!   bpa_rs_noff2off input.noff radius output.off
//! bpa_rs returns triangles as positions (f32), not indices; they are mapped back to the
//! input indices by their bit patterns. Prints "time: T s" with the reconstruction time.
use std::collections::HashMap;
use std::io::{BufRead, BufWriter, Write};
use std::time::Instant;

use bpa_rs::{Point, reconstruct};
use glam::Vec3;

fn main() {
    let a: Vec<String> = std::env::args().collect();
    if a.len() != 4 {
        eprintln!("usage: bpa_rs_noff2off input.noff radius output.off");
        std::process::exit(1);
    }
    let (inp, rho, out) = (&a[1], a[2].parse::<f32>().unwrap(), &a[3]);
    let f = std::io::BufReader::new(std::fs::File::open(inp).unwrap());
    let mut lines = f.lines().map(|l| l.unwrap());
    assert!(lines.next().unwrap().trim().starts_with("NOFF"), "expected a NOFF file");
    let hdr = lines.next().unwrap();
    let nv: usize = hdr.split_whitespace().next().unwrap().parse().unwrap();
    let mut pts = Vec::with_capacity(nv);
    for _ in 0..nv {
        let l = lines.next().unwrap();
        let v: Vec<f32> = l.split_whitespace().map(|s| s.parse().unwrap()).collect();
        pts.push(Point { pos: Vec3::new(v[0], v[1], v[2]), normal: Vec3::new(v[3], v[4], v[5]) });
    }
    let key = |v: Vec3| [v.x.to_bits(), v.y.to_bits(), v.z.to_bits()];
    let mut idx: HashMap<[u32; 3], usize> = HashMap::with_capacity(nv);
    for (i, p) in pts.iter().enumerate() {
        idx.entry(key(p.pos)).or_insert(i);
    }
    let t0 = Instant::now();
    let tris = reconstruct(&pts, rho).unwrap_or_default();
    let dt = t0.elapsed().as_secs_f64();
    let mut w = BufWriter::new(std::fs::File::create(out).unwrap());
    writeln!(w, "OFF\n{} {} 0", nv, tris.len()).unwrap();
    for p in &pts {
        writeln!(w, "{} {} {}", p.pos.x, p.pos.y, p.pos.z).unwrap();
    }
    for t in &tris {
        writeln!(w, "3 {} {} {}", idx[&key(t.0[0])], idx[&key(t.0[1])], idx[&key(t.0[2])]).unwrap();
    }
    println!("bpa_rs: {} triangles, time: {dt:.6} s", tris.len());
}
