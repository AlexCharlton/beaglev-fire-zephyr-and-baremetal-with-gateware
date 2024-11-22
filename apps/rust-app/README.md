Install [zephyr-rust](https://github.com/tylerwhall/zephyr-rust) somewhere:
```sh
$ git clone --recurse-submodules https://github.com/tylerwhall/zephyr-rust.git
```

Patch the rust submodule:
```diff
~/src/zephyr-rust/rust/rust$ git diff
diff --git a/library/std/src/sys/zephyr/thread.rs b/library/std/src/sys/zephyr/thread.rs
index ced4ffb6f..bde99c3f4 100644
--- a/library/std/src/sys/zephyr/thread.rs
+++ b/library/std/src/sys/zephyr/thread.rs
@@ -33,7 +33,7 @@ pub fn join(self) {
 }

 pub fn available_parallelism() -> io::Result<NonZeroUsize> {
-    Ok(unsafe { NonZeroUsize::new_unchecked(zephyr_sys::raw::CONFIG_MP_NUM_CPUS as usize) })
+    Ok(unsafe { NonZeroUsize::new_unchecked(zephyr_sys::raw::CONFIG_MP_MAX_NUM_CPUS as usize) })
 }

 pub mod guard {
```

Configure the environment variable in `scripts/script-config.sh`

Build the Zephyr application:
```sh
$ ./scripts/build.sh apps/rust-app
```
