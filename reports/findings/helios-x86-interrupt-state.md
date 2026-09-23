# Helios x86 interrupt-state corruption during the Wasmtime audit

Date: 2026-09-07 UTC
Auditor: GPT-6 Astra Medium Thinking
Host: Darwin arm64; x86-64 functional probe executed through Rosetta
Wasmtime revision: 39819b1f81f3912dddfdcb25de6d5924aef15783
Helios inspected revision: c4ede489ab7c3d3c168dc7f97b59f5c5b4b6b31b

## Classification

This is a reproduced Helios integration defect, not a Wasmtime finding.
No Wasmtime production source was changed. No public-API reproducer has
established a Wasmtime defect in the inspected resource-scope path.

## Evidence

Helios `.cargo/config.toml:9-12` explicitly enables SSE and SSE2 and disables
soft-float for its x86 kernel. Ordinary compiler-generated Rust therefore
may keep live data in XMM registers, including non-floating-point copies.

`x86/src/exceptions.S:163-202` saves only the general-purpose registers,
calls `helios_x86_interrupt_dispatch`, restores those registers, and executes
`iretq`. It does not save or restore XMM, x87, or MXCSR. The dispatch function
uses the ordinary C ABI, where XMM registers are caller-clobbered. An IRQ
can therefore corrupt live registers of its interrupted caller.

The functional probe uses the actual production assembly file, replacing
only its ELF section directive with the Mach-O `.text` directive. It sets
XMM0 to all ones, constructs an interrupt-return frame, enters the actual
`helios_x86_interrupt_timer` stub, and returns through its actual `iretq`.
The test dispatch function clears XMM0, which the C ABI permits. The probe
checks XMM0 immediately after return and exits nonzero when it changed.

Command from this repository:

```sh
python3 reports/helios-x86-irq-probe/run.py \
  /Users/lexoliu/Coding/helios-wt-tlsf/x86/src/exceptions.S
```

Result: exit code 1; `preserved_xmm0: false`.
Source SHA-256:
`4bdfa115886eb9af936b4b192399d6fb99b0f6b341b1f207aa20a701e6b702f1`.
The source path, hash, and result are in the adjacent probe's `result.json`.
This was a single functional test, not a benchmark or a Helios guest boot.

## Relationship to the observed DataFaults

The defect provides a concrete mechanism for corruption during kernel and
Wasmtime host calls. It does not establish that it caused either historical
DataFault. The failed images had no retained matching function symbols;
lookup in later builds cannot prove the original instruction identity.

`LowerContext::validate_scope_exit` delegates to store-owned tables and
scope validation. The non-concurrent scope lookup uses checked indexing;
a missing current scope becomes an error. The inspected host-trap wrapper
records errors using the current runtime activation in TLS. Neither source
path alone explains the observed null or near-null access.

Wasmtime fiber resume saves and restores runtime activation TLS, and Helios
provides separate per-processor slots. Those observations are not a proof
of complete TLS correctness, nor evidence of a novel Wasmtime defect.

A regression test must validate the complete enabled floating-point state,
not just XMM0. The production repair must preserve state across the actual
IRQ path, with independent storage for nested interrupts, while retaining
SSE support. Bare-metal CI remains necessary to validate real interrupt
entry and evaluate impact. Historical-crash attribution remains distinct
from verifying this deterministic state-corruption defect.
