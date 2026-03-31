#ifndef EXAMPLE_NODE_H
#define EXAMPLE_NODE_H

#include <godot_cpp/classes/sprite2d.hpp>

namespace godot {
    class ExampleNode : public Sprite2D {
        GDCLASS(ExampleNode, Sprite2D)

    protected:
        static void _bind_methods();

    public:
        ExampleNode();
        ~ExampleNode();
        void _process(double delta) override; // 每帧执行的逻辑
    };
}
#endif