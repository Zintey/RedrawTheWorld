#include "example_node.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void ExampleNode::_bind_methods() {}

ExampleNode::ExampleNode() {
    // 可以在这里初始化，比如设置默认旋转速度
}

ExampleNode::~ExampleNode() {}

void ExampleNode::_process(double delta) {
    // 每帧旋转一点点
    rotate(2.0 * delta);
}