# Assignment 7: Faulty Driver Kernel Oops Analysis

## 1. Kernel oops output
```text
Unable to handle kernel NULL pointer dereference at virtual address 0000000000000000
Mem abort info:
  ESR = 0x0000000096000045
  EC = 0x25: DABT (current EL), IL = 32 bits
  SET = 0, FnV = 0
  EA = 0, S1PTW = 0
  FSC = 0x05: level 1 translation fault
Data abort info:
  ISV = 0, ISS = 0x00000045
  CM = 0, WnR = 1
user pgtable: 4k pages, 39-bit VAs, pgdp=0000000041bcd000
[0000000000000000] pgd=0000000000000000, p4d=0000000000000000, pud=0000000000000000
Internal error: Oops: 0000000096000045 [#2] SMP
Modules linked in: hello(O) faulty(O) scull(O)
CPU: 0 PID: 161 Comm: sh Tainted: G      D    O       6.1.44 #1
Hardware name: linux,dummy-virt (DT)
pstate: 80000005 (Nzcv daif -PAN -UAO -TCO -DIT -SSBS BTYPE=--)
pc : faulty_write+0x10/0x20 [faulty]
lr : vfs_write+0xc8/0x390
sp : ffffffc008da3d20
x29: ffffffc008da3d80 x28: ffffff8001b30d40 x27: 0000000000000000
x26: 0000000000000000 x25: 0000000000000000 x24: 0000000000000000
x23: 000000000000000c x22: 000000000000000c x21: ffffffc008da3dc0
x20: 0000005588ef8af0 x19: ffffff8001b5d000 x18: 0000000000000000
x17: 0000000000000000 x16: 0000000000000000 x15: 0000000000000000
x14: 0000000000000000 x13: 0000000000000000 x12: 0000000000000000
x11: 0000000000000000 x10: 0000000000000000 x9 : 0000000000000000
x8 : 0000000000000000 x7 : 0000000000000000 x6 : 0000000000000000
x5 : 0000000000000001 x4 : ffffffc000787000 x3 : ffffffc008da3dc0
x2 : 000000000000000c x1 : 0000000000000000 x0 : 0000000000000000
Call trace:
 faulty_write+0x10/0x20 [faulty]
 ksys_write+0x74/0x110
 __arm64_sys_write+0x1c/0x30
 invoke_syscall+0x54/0x130
 el0_svc_common.constprop.0+0x44/0xf0
 do_el0_svc+0x2c/0xc0
 el0_svc+0x2c/0x90
 el0t_64_sync_handler+0xf4/0x120
 el0t_64_sync+0x18c/0x190
Code: d2800001 d2800000 d503233f d50323bf (b900003f) 
---[ end trace 0000000000000000 ]---

## 2. Technical Breakdown & Analysis

### A. Type of Fault
The error: 
> `Unable to handle kernel NULL pointer dereference at virtual address 0000000000000000`

Read or write to address of `0x0` (NULL pointer).

### B. Faulting Instruction Pointer (`pc`)
Program counter is the place to find the last function called where the error triggered:
> `pc : faulty_write+0x10/0x20 [faulty]`

The fault happened directly inside the `faulty_write` 
* The total size of the compiled machine code for `faulty_write` is `0x20` bytes.
* The instruction that crashed occurred exactly at offset **`+0x10`** bytes into that specific function block.

### C. Write vs Read Direction
Under the `Data abort info` block, the log reveals a key tracking flag:
> `WnR = 1`

`WnR` stands for **Write not Read**. Because this bit is explicitly set to `1`, it confirms that the driver crashed while trying to **write data into** the null memory address rather than trying to read from it.

### D. Execution Trace (Call Trace)
The stack dump tracks the active kernel function branches in reverse order:
1. **`el0t_64_sync` -> `do_el0_svc` -> `invoke_syscall`**
2. **`__arm64_sys_write` -> `ksys_write`**
3. **`faulty_write`**

```

## 3. Locating the line in the driver source code

### Method 1: Address to line mapping
```bash
aarch64-linux-gnu-addr2line -e faulty.ko faulty_write+0x10
```

### Method 2: Disassembling the Kernel Object (objdump)
```bash
aarch64-linux-gnu-objdump -S faulty.o
```

By scrolling down to the assembly block mapping to faulty_write, the assembly tracking blocks can be tracked down to offset +0x10. 

The machine code line found at that position matches the signature marked in parentheses inside the Oops log:
> Code: d2800001 d2800000 d503233f d50323bf (b900003f)

The hex opcode value b900003f decodes directly into an ARM64 str (Store Register) instruction targeting the kernel's dedicated zero register (wzr) into an offset address of 0. This confirms the presence of an absolute memory store operation aimed at an initialized null pointer reference
