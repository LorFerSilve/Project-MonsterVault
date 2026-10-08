"""Original procedural MonsterVault sounds; no sampled third-party material."""
from pathlib import Path
import array
import json
import math
import random
import wave

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets/exported/audio"
RATE = 24000


def tone(t, hz, length):
    if not 0 <= t < length:
        return 0
    envelope = min(1, t / .012) * (1 - t / length) ** 1.8
    return envelope * (math.sin(math.tau * hz * t) + .18 * math.sin(math.tau * hz * 2 * t))


def write(name, seconds, notes=(), ambience=False, machinery=False):
    rng = random.Random(701 + sum(name.encode()))
    values, air = [], 0
    for i in range(int(seconds * RATE)):
        t = i / RATE
        value = sum(tone(t - start, hz, duration) * gain for start, hz, duration, gain in notes)
        if ambience:
            air = air * .98 + rng.uniform(-1, 1) * .02
            # Periodic, quiet wind bed; designed for low playback gain.
            value += air * .5 + .016 * math.sin(math.tau * 60 * t)
        if machinery:
            value += .06 * math.sin(math.tau * 60 * t) + .022 * math.sin(math.tau * 240 * t)
        # Clean edges, including ambience loops; no clicks at restart.
        value *= min(1, t / .04, (seconds - t) / .04)
        values.append(value)
    peak = max(abs(v) for v in values) or 1
    samples = array.array('h', (int(v / max(1, peak / .65) * 32767) for v in values))
    path = OUT / f"MV_GS_{name}.wav"
    with wave.open(str(path), 'wb') as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        wav.writeframes(samples.tobytes())
    return {"key": name, "file": path.relative_to(ROOT).as_posix(), "seconds": seconds,
            "loop": ambience or machinery, "sampleRate": RATE, "channels": 1}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    rows = [write("UI", .13, [(0, 680, .12, .12)]),
            write("Engage", .48, [(0, 220, .4, .15), (.12, 440, .36, .15)]),
            write("Containment", .62, [(0, 170, .24, .22), (.15, 340, .32, .18), (.34, 680, .28, .12)]),
            write("Secured", 1.24, [(i*.16, hz, .65, .17) for i,hz in enumerate((330,440,554,660))]),
            write("Failure", .52, [(0, 250, .3, .14), (.18, 190, .32, .1)]),
            write("Rare", 1.4, [(i*.16, hz, .8, .09) for i,hz in enumerate((440,660,880,1100))]),
            write("Legendary", 1.9, [(i*.17, hz, 1, .09) for i,hz in enumerate((220,330,440,554,660,880))]),
            write("Energy", 1.5, [(i*.095, 320+i*42, .15, .09) for i in range(10)] + [(1.03,130,.44,.27),(1.03,660,.4,.12)]),
            write("Creature", .36, [(0,740,.16,.09),(.11,990,.24,.09)]),
            write("Reserve", 12, [(1.3,900,.24,.035),(1.43,1200,.25,.025),(6.6,760,.34,.03)], ambience=True),
            write("Machine", 8, machinery=True)]
    (OUT / "source_manifest.json").write_text(json.dumps(rows, indent=2) + "\n", encoding="utf-8")
    print(f"Generated {len(rows)} original mono clips, {sum(r['seconds'] for r in rows):.2f}s total")


if __name__ == "__main__":
    main()
