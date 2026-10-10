// Granite builds volk with the platform surface entry points enabled, but only
// for this one translation unit (the rest of Granite must not see <windows.h>
// through vulkan.h). qmake and ndk-build have no per-file defines, hence this
// wrapper.
#if defined(_WIN32)
#define VK_USE_PLATFORM_WIN32_KHR
#elif defined(__ANDROID__)
#define VK_USE_PLATFORM_ANDROID_KHR
#endif

#include "../Granite/third_party/volk/volk.c"
