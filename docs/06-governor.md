# GPU clock governor

The board idles its shader clock at **1500 MHz** while 2000+ MHz is available —
roughly 33% of compute left unused.

All benchmark numbers in this repo were measured at **1500 MHz**, without the
governor. Enabling it should scale compute by ~1.37x; that was not measured.

---

## `power_dpm_force_performance_level` does not work here

It is not writable on the BC-250. The DPM table the kernel exposes tops out at
2000 MHz and the governor never climbs to it under compute load.

## The working path: `cyan-skillfish-governor-smu`

Talks to the SMU directly over MMIO and bypasses the kernel DPM table.

```bash
sudo systemctl start cyan-skillfish-governor-smu.service
sudo systemctl enable cyan-skillfish-governor-smu.service   # to persist
```

Config: `/etc/cyan-skillfish-governor-smu/config.toml`.
Ours is in [`config/governor-config.toml`](../config/governor-config.toml).

Safe points as run (2050 added on top of the packaged set):

```
1000 MHz @ 800 mV
1500 MHz @ 890 mV
1800 MHz @ 920 mV
2000 MHz @ 940 mV
2050 MHz @ 940 mV
throttling = 90 C, recovery = 80 C
```

The governor scales with load — at idle it drops to 1000 MHz. To see the top
clock you need real load.

---

## Power

Community figures put 2000 MHz around **190 W** and 2230 MHz around 235 W,
against **~59 W** idle at 1500 MHz here.

That matters for sustained work: a tuning run is hours of continuous load, not
game-length bursts. On the reference machine only one fan spins (1986 of
4477 RPM max), so there is headroom, and the governor throttles at 90 °C — but
watch temperatures if you push it.

Higher points exist (2100 / 2200 / 2230 MHz) with community-reported voltages.
Returns diminish above 2100 MHz: roughly +5-6% for +20-25% power.
