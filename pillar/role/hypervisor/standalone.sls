include:
  - .common

infrastructure:
  image_type: qcow2

libvirt:
  guests:
    on_boot: start
    on_shutdown: shutdown
    parallel_shutdown: 4
    start_delay: 2
