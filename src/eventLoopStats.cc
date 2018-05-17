#include <nan.h>
#include <list>
#include <iostream>

using namespace Nan;
using namespace v8;

uv_prepare_t prepare_handle;
uv_check_t check_handle;
std::list<uint64_t> durations;

uint64_t tick_start;

void reset() {
  durations.clear();
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

static NAN_METHOD(sense) {
  Local<Array> array = New<v8::Array>(durations.size());

  std::list<uint64_t>::iterator it;
  int i = 0;
  for (it = durations.begin(); it != durations.end(); ++it) {
    Nan::Set(array, i, Nan::New(static_cast<double>(*it)));
    i += 1;
  }

  reset();

  info.GetReturnValue().Set(array);
}

NAN_MODULE_INIT(init) {
  reset();

  uv_check_init(uv_default_loop(), &check_handle);
  uv_check_start(&check_handle, reinterpret_cast<uv_check_cb>(on_check));
  uv_unref(reinterpret_cast<uv_handle_t*>(&check_handle));

  uv_prepare_init(uv_default_loop(), &prepare_handle);
  uv_prepare_start(&prepare_handle, reinterpret_cast<uv_prepare_cb>(on_prepare));
  uv_unref(reinterpret_cast<uv_handle_t*>(&prepare_handle));

  Nan::Set(target,
    Nan::New("sense").ToLocalChecked(),
    Nan::GetFunction(Nan::New<FunctionTemplate>(sense)).ToLocalChecked()
  );
}

NODE_MODULE(eventLoopStats, init)
