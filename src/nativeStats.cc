#include "napi.h"
#include <uv.h>
#include <v8.h>
#include <list>

using namespace v8;

uv_prepare_t prepare_handle;
uv_check_t check_handle;
std::list<uint64_t> durations;

uint64_t tick_start;
uint64_t gc_start;
uint64_t gc_count;
uint64_t gc_time;

void reset()
{
  durations.clear();
  gc_count = 0;
  gc_time = 0;
}

// http://docs.libuv.org/en/v1.x/design.html#the-i-o-loop
void on_check(uv_check_t *handle)
{
  tick_start = uv_hrtime() / static_cast<uint64_t>(1e6);
}

void on_prepare(uv_prepare_t *handle)
{
  if (!tick_start)
  {
    return;
  }
  const uint64_t tick_end = uv_hrtime() / static_cast<uint64_t>(1e6);
  if (tick_end < tick_start)
  {
    // Should not happen
    return;
  }
  const uint64_t duration = tick_end - tick_start;

  tick_start = 0;

  durations.push_back(duration);
}

// Callback before GC runs
void before_gc(v8::Isolate *isolate, v8::GCType type, v8::GCCallbackFlags flags)
{
  gc_start = uv_hrtime();
}

// Callback after GC runs
void after_gc(v8::Isolate *isolate, v8::GCType type, v8::GCCallbackFlags flags)
{
  // TODO: `int type` is defined which indicates the type of GC run
  // https://github.com/nodejs/node/blob/554fa24916c5c6d052b51c5cee9556b76489b3f7/deps/v8/include/v8.h#L6137-L6144
  // 1 = scavenge (new)
  // 2 = mark and sweep (old)
  // others = ??? unsure

  const uint64_t gc_end = uv_hrtime();
  const uint64_t duration = gc_end - gc_start;

  gc_count += 1;
  gc_time += duration;
}

void add_callbacks()
{
  reset();

  // Event loop callbacks
  uv_check_init(uv_default_loop(), &check_handle);
  uv_check_start(&check_handle, reinterpret_cast<uv_check_cb>(on_check));
  uv_unref(reinterpret_cast<uv_handle_t *>(&check_handle));

  uv_prepare_init(uv_default_loop(), &prepare_handle);
  uv_prepare_start(&prepare_handle, reinterpret_cast<uv_prepare_cb>(on_prepare));
  uv_unref(reinterpret_cast<uv_handle_t *>(&prepare_handle));

  // GC callbacks
  v8::Isolate::GetCurrent()->AddGCPrologueCallback(before_gc, v8::kGCTypeAll);
  v8::Isolate::GetCurrent()->AddGCEpilogueCallback(after_gc, v8::kGCTypeAll);
}

void remove_callbacks()
{
  reset();

  // Event loop callbacks
  uv_check_stop(&check_handle);
  uv_prepare_stop(&prepare_handle);

  // GC callbacks
  v8::Isolate::GetCurrent()->RemoveGCPrologueCallback(before_gc);
  v8::Isolate::GetCurrent()->RemoveGCEpilogueCallback(after_gc);
}

void Start(const Napi::CallbackInfo &info)
{
  add_callbacks();
}

void Stop(const Napi::CallbackInfo &info)
{
  remove_callbacks();
}

Napi::Object Sense(const Napi::CallbackInfo &info)
{
  Napi::Env env = info.Env();
  Napi::Object obj = Napi::Object::New(env);
  Napi::Array arr = Napi::Array::New(env, durations.size());

  std::list<uint64_t>::iterator it;
  uint32_t i = 0;
  for (it = durations.begin(); it != durations.end(); ++it)
  {
    arr.Set(i, Napi::Number::New(env, *it));
    i += 1;
  }

  obj.Set(Napi::String::New(env, "ticks"), arr);
  obj.Set(Napi::String::New(env, "gcCount"), Napi::Number::New(env, gc_count));
  obj.Set(Napi::String::New(env, "gcTime"), Napi::Number::New(env, gc_time));

  reset();

  return obj;
}

Napi::Object Init(Napi::Env env, Napi::Object exports)
{
  exports.Set(Napi::String::New(env, "sense"), Napi::Function::New(env, Sense));
  exports.Set(Napi::String::New(env, "start"), Napi::Function::New(env, Start));
  exports.Set(Napi::String::New(env, "stop"), Napi::Function::New(env, Stop));
  return exports;
}

NODE_API_MODULE(native_stats, Init);
