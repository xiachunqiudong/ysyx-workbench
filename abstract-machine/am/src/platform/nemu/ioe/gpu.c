#include <am.h>
#include <nemu.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

#define get_width()  (int)inw(VGACTL_ADDR + 2)
#define get_height() (int)inw(VGACTL_ADDR    )

void __am_gpu_init() {
  int i;
  int w = get_width(); 
  int h = get_height();
  uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
  for (i = 0; i < w * h; i ++) fb[i] = i;
  outl(SYNC_ADDR, 1); // flush the screen
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  int width, height, vmemsz;
  width  = get_width();
  height = get_height();
  vmemsz = width * height * 4;
  *cfg = (AM_GPU_CONFIG_T) {
    .present   = true, 
    .has_accel = false,
    .width     = width,
    .height    = height,
    .vmemsz    = vmemsz
  };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
  uint32_t *pixels = (uint32_t*)ctl->pixels;
  int x = ctl->x, y = ctl->y;
  int w = ctl->w, h = ctl->h;
  fb = fb + x + y*get_width();
  int i, j, pnt;
  for (i = 0; i < w; i++) {
    for (j = 0; j < h; j++) {
      pnt = j*get_width() + i;
      fb[pnt] = pixels[pnt];
    }
  }
  if (ctl->sync) {
    outl(SYNC_ADDR, 1);
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
