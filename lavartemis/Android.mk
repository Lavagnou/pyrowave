# PyroWave C API plus the Granite subset it links, for ndk-build (LavArtemis
# Android). Produces the static library `pyrowave`; link it into the native
# renderer with LOCAL_STATIC_LIBRARIES := pyrowave.
#
# 64-bit only: PyroWave needs a Vulkan 1.3 GPU with subgroup size control, and
# no 32-bit Android device ships one. On other ABIs this file defines nothing
# and the app never offers PyroWave.
#
# Vulkan is loaded at runtime through volk (dlopen of libvulkan.so), so nothing
# links libvulkan and the app keeps minSdk 21.
#
# The source list mirrors lavartemis/pyrowave.pri (minus the Windows-only
# DXGI interop); keep both in sync when Granite is bumped.

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_ARCH_ABI),arm64-v8a)

PW_DIR := $(LOCAL_PATH)/..
GRANITE_DIR := $(PW_DIR)/Granite

include $(CLEAR_VARS)
LOCAL_MODULE := pyrowave

LOCAL_SRC_FILES := \
    ../pyrowave_c.cpp \
    ../pyrowave_common.cpp \
    ../pyrowave_decoder.cpp \
    ../pyrowave_encoder.cpp \
    ../Granite/video/scaler.cpp \
    volk_platform.c \
    ../Granite/math/aabb.cpp \
    ../Granite/math/frustum.cpp \
    ../Granite/math/interpolation.cpp \
    ../Granite/math/math.cpp \
    ../Granite/math/muglm/muglm.cpp \
    ../Granite/math/transforms.cpp \
    ../Granite/util/aligned_alloc.cpp \
    ../Granite/util/arena_allocator.cpp \
    ../Granite/util/cli_parser.cpp \
    ../Granite/util/dynamic_library.cpp \
    ../Granite/util/environment.cpp \
    ../Granite/util/logging.cpp \
    ../Granite/util/message_queue.cpp \
    ../Granite/util/slab_allocator.cpp \
    ../Granite/util/string_helpers.cpp \
    ../Granite/util/thread_id.cpp \
    ../Granite/util/thread_name.cpp \
    ../Granite/util/thread_priority.cpp \
    ../Granite/util/timeline_trace_file.cpp \
    ../Granite/util/timer.cpp \
    ../Granite/vulkan/breadcrumbs.cpp \
    ../Granite/vulkan/buffer.cpp \
    ../Granite/vulkan/buffer_pool.cpp \
    ../Granite/vulkan/command_buffer.cpp \
    ../Granite/vulkan/command_pool.cpp \
    ../Granite/vulkan/context.cpp \
    ../Granite/vulkan/cookie.cpp \
    ../Granite/vulkan/descriptor_set.cpp \
    ../Granite/vulkan/device.cpp \
    ../Granite/vulkan/event_manager.cpp \
    ../Granite/vulkan/fence.cpp \
    ../Granite/vulkan/fence_manager.cpp \
    ../Granite/vulkan/image.cpp \
    ../Granite/vulkan/indirect_layout.cpp \
    ../Granite/vulkan/memory_allocator.cpp \
    ../Granite/vulkan/pipeline_cache.cpp \
    ../Granite/vulkan/pipeline_event.cpp \
    ../Granite/vulkan/query_pool.cpp \
    ../Granite/vulkan/render_pass.cpp \
    ../Granite/vulkan/renderdoc_capture.cpp \
    ../Granite/vulkan/rtas.cpp \
    ../Granite/vulkan/sampler.cpp \
    ../Granite/vulkan/semaphore.cpp \
    ../Granite/vulkan/semaphore_manager.cpp \
    ../Granite/vulkan/shader.cpp \
    ../Granite/vulkan/texture/texture_format.cpp \
    ../Granite/vulkan/wsi.cpp \
    ../Granite/vulkan/wsi_pacer.cpp

LOCAL_C_INCLUDES := \
    $(PW_DIR) \
    $(PW_DIR)/shaders \
    $(GRANITE_DIR)/video \
    $(GRANITE_DIR)/vulkan \
    $(GRANITE_DIR)/util \
    $(GRANITE_DIR)/math \
    $(GRANITE_DIR)/application/global \
    $(GRANITE_DIR)/third_party/volk \
    $(GRANITE_DIR)/third_party/renderdoc \
    $(GRANITE_DIR)/third_party/khronos/vulkan-headers/include

# The consumer includes <pyrowave.h> after <vulkan/vulkan_core.h>.
LOCAL_EXPORT_C_INCLUDES := \
    $(PW_DIR) \
    $(GRANITE_DIR)/third_party/khronos/vulkan-headers/include

# Same configuration as upstream's standalone build (GRANITE_SHIPPING, FP32
# math with reduced-range storage). Hidden visibility keeps volk's global vk*
# pointers out of the shared library that links this archive.
LOCAL_CFLAGS := -DGRANITE_SHIPPING -DGRANITE_RENDERDOC_CAPTURE -DPYROWAVE_PRECISION=1 \
    -fvisibility=hidden -Wno-missing-field-initializers
LOCAL_CPPFLAGS := -std=c++14 -fvisibility-inlines-hidden
LOCAL_CPP_FEATURES := exceptions rtti
LOCAL_EXPORT_LDLIBS := -llog -ldl

include $(BUILD_STATIC_LIBRARY)

endif
