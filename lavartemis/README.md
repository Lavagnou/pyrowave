# PyroWave for LavArtemis / LavApollo

This branch (`lavartemis`) is the single PyroWave source shared by the three
LavArtemis-family projects. Each one pins it as a git submodule **at the same
commit**:

| Consumer | Submodule path | Build glue |
|---|---|---|
| LavApollo (host, Windows, MinGW) | `third-party/pyrowave` | `lavartemis/CMakeLists.txt` → `pyrowave::capi` |
| LavArtemis-Qt (desktop client, MSVC / GCC) | `pyrowave/pyrowave` | `lavartemis/pyrowave.pri` |
| LavArtemis Android (arm64-v8a only) | `app/src/main/jni/pyrowave` | `lavartemis/Android.mk` → `pyrowave` |

## Why one source

The PyroWave bitstream has **no version field**. A host and a client built
from different PyroWave commits can disagree on the wire format and decode
garbage without anything noticing. The host advertises the commit in its RTSP
DESCRIBE (`x-ss-pyrowave.bitstream`) and the client only warns on a mismatch;
the real guarantee is that all three consumers pin this branch at the same
commit. Bump them together.

## What is here on top of upstream

Upstream: [Themaister/pyrowave](https://github.com/Themaister/pyrowave) v1
(`502a3b5`, bitstream frozen 2026-10-03, API/ABI 1.0.0).

1. **Two codec fixes** (one commit each), both carried by Vibepollo and found
   by Punktfunk:
   - the encoder payload buffer is sized for 4:4:4 (busy 4:4:4 content
     overran it on the GPU);
   - `push_packet` rejects a block shorter than its header (otherwise a
     duplicate `block_index` with `payload_words == 0` spins the decoder
     forever on network input).
2. **Granite, vendored and pruned** (`Granite/`, normally fetched by
   `checkout_granite.sh` and gitignored). Granite `fb178c80`, volk `47cddf7e`,
   Vulkan-Headers `6802bb47` — the revisions upstream's `checkout_granite.sh`
   pins at `502a3b5`. Only what the C API compiles against is kept.
3. **Build glue** in this directory.

The SPIR-V is precompiled in `shaders/slangmosh*.hpp`, so no shader compiler
is needed to build.

## Wire compatibility with 186f0393

Vibepollo and Nonary's moonlight-qt pin `186f0393` (2026-09-23, before the
freeze). Between that commit and v1, the codec core changed only by:

- `PWV1Header`, a global header for `.wave` files and containers — never sent
  over the network;
- an optional `RangeScale` specialization constant (default 1.0, i.e. no-op)
  for 10-bit LSB CPU buffers;
- an out-of-bounds read fix in the rate-control analysis shader.

Block headers, sequence headers, packetization and quantization are
identical, so v1 streams decode on 186f0393 builds and vice versa. Clients
should treat both IDs as compatible.

## Updating

1. Merge the new upstream tag into this branch.
2. If `checkout_granite.sh` pins a new Granite, re-copy the pruned subset
   (the directory list is in the Granite vendoring commit message).
3. Build upstream's standalone config (`cmake -S . -B build -G Ninja`, target
   `pyrowave-c-test`) and run it on a real GPU.
4. Refresh the source lists in `pyrowave.pri` and `Android.mk` from
   `ninja -t commands pyrowave-shared`.
5. Check `bitstream/bitstream.md` and the diff of `pyrowave_decoder.cpp`,
   `pyrowave_encoder.cpp` and `shaders/` for wire changes. If the wire format
   changed, the host's advertised bitstream ID and the clients' compatibility
   list must change with it.
6. Bump the submodule in LavApollo, LavArtemis (Android) and LavArtemis-Qt
   in the same release.
