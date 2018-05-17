#include <nan.h>
#include <list>
#include <iostream>

using namespace Nan;
using namespace v8;

uv_prepare_t prepare_handle;
uv_check_t check_handle;
std::list<uint64_t> durations;

uint64_t tick_start;
uint64_t gc_start;
uint64_t gc_count;
uint64_t gc_time;


void reset() {
  durations.clear();
  gc_count = 0;
  gc_time = 0;
}

// http://docs.libuv.org/en/v1.x/design.html#the-i-o-loop
void on_check(uv_check_t* handle) {
  tick_start = uv_hrtime() / static_cast<uint64_t>(1e6);
}

void on_prepare(uv_prepare_t* handle) {
  if (!tick_start) {
    return;
  }
  const uint64_t tick_end = uv_hrtime() / static_cast<uint64_t>(1e6);
  if (tick_end < tick_start) {
    // Should not happen
    return;
  }
  const uint64_t duration = tick_end - tick_start;

  tick_start = 0;

  durations.push_back(duration);
}

// Callback before GC runs
static NAN_GC_CALLBACK(recordBeforeGC) {
  gc_start = uv_hrtime();
}

// Callback after GC runs
NAN_GC_CALLBACK(afterGC) {
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

static NAN_METHOD(sense) {
  Local<Array> array = New<v8::Array>(durations.size());

  std::list<uint64_t>::iterator it;
  int i = 0;
  for (it = durations.begin(); it != durations.end(); ++it) {
    Nan::Set(array, i, Nan::New(static_cast<double>(*it)));
    i += 1;
  }

  Local<Object> obj = Nan::New<Object>();

  Nan::Set(obj, Nan::New("ticks").ToLocalChecked(), array);
  Nan::Set(obj, Nan::New("gcCount").ToLocalChecked(), Nan::New(static_cast<double>(gc_count)));
  Nan::Set(obj, Nan::New("gcTime").ToLocalChecked(), Nan::New(static_cast<double>(gc_time)));

  reset();

  info.GetReturnValue().Set(obj);
}

NAN_METHOD(start) {
  reset();

  // Event loop callbacks
  uv_check_init(uv_default_loop(), &check_handle);
  uv_check_start(&check_handle, reinterpret_cast<uv_check_cb>(on_check));
  uv_unref(reinterpret_cast<uv_handle_t *>(&check_handle));

  uv_prepare_init(uv_default_loop(), &prepare_handle);
  uv_prepare_start(&prepare_handle, reinterpret_cast<uv_prepare_cb>(on_prepare));
  uv_unref(reinterpret_cast<uv_handle_t *>(&prepare_handle));

  // GC callbacks
  Nan::AddGCPrologueCallback(recordBeforeGC);
  Nan::AddGCEpilogueCallback(afterGC);
}

NAN_METHOD(stop) {
  reset();

  // TODO unregister callbacks
}

NAN_MODULE_INIT(init) {
  Nan::Set(target,
    Nan::New("sense").ToLocalChecked(),
    Nan::GetFunction(Nan::New<FunctionTemplate>(sense)).ToLocalChecked()
  );

  Nan::Set(target,
    Nan::New("start").ToLocalChecked(),
    Nan::GetFunction(Nan::New<FunctionTemplate>(start)).ToLocalChecked()
  );

  Nan::Set(target,
    Nan::New("stop").ToLocalChecked(),
    Nan::GetFunction(Nan::New<FunctionTemplate>(stop)).ToLocalChecked()
  );
}

NODE_MODULE(eventLoopStats, init)
