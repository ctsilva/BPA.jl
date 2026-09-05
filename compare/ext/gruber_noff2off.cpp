// NOFF -> OFF driver for bernhardmgruber/bpa, so that compare.jl can run it.
//   gruber_noff2off input.noff radius output.off
// Reads the NOFF (x y z nx ny nz per vertex) into bpa::Point (float), calls
// bpa::reconstruct, and maps the returned triangle positions back to input indices by
// their float bit patterns (the library copies positions verbatim). Prints
// "time: T s" with the reconstruction time only.
#include <bpa.h>

#include <chrono>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>

struct Key {
	std::uint32_t x, y, z;
	bool operator==(const Key& o) const { return x == o.x && y == o.y && z == o.z; }
};
struct KeyHash {
	std::size_t operator()(const Key& k) const {
		return (std::size_t(k.x) * 73856093u) ^ (std::size_t(k.y) * 19349663u) ^ (std::size_t(k.z) * 83492791u);
	}
};
static Key key(const glm::vec3& v) {
	Key k;
	std::memcpy(&k.x, &v.x, 4);
	std::memcpy(&k.y, &v.y, 4);
	std::memcpy(&k.z, &v.z, 4);
	return k;
}

int main(int argc, char** argv) {
	if (argc != 4) {
		std::cerr << "usage: gruber_noff2off input.noff radius output.off\n";
		return 1;
	}
	std::ifstream in(argv[1]);
	std::string magic;
	std::size_t nv, nf, ne;
	in >> magic >> nv >> nf >> ne;
	if (magic != "NOFF") {
		std::cerr << "expected a NOFF file\n";
		return 1;
	}
	std::vector<bpa::Point> pts(nv);
	for (auto& p : pts)
		in >> p.pos.x >> p.pos.y >> p.pos.z >> p.normal.x >> p.normal.y >> p.normal.z;
	const float radius = std::stof(argv[2]);

	std::unordered_map<Key, std::size_t, KeyHash> index;
	index.reserve(nv * 2);
	for (std::size_t i = 0; i < nv; i++)
		index.emplace(key(pts[i].pos), i);

	const auto t0 = std::chrono::steady_clock::now();
	const auto tris = bpa::reconstruct(pts, radius);
	const auto t1 = std::chrono::steady_clock::now();

	std::ofstream out(argv[3]);
	out << "OFF\n" << nv << ' ' << tris.size() << " 0\n";
	out.precision(17);
	for (const auto& p : pts)
		out << p.pos.x << ' ' << p.pos.y << ' ' << p.pos.z << '\n';
	for (const auto& t : tris)
		out << "3 " << index.at(key(t[0])) << ' ' << index.at(key(t[1])) << ' ' << index.at(key(t[2])) << '\n';
	std::cout << "gruber: " << tris.size() << " triangles, time: " << std::chrono::duration<double>(t1 - t0).count() << " s\n";
}
