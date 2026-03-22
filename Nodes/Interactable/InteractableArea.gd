class_name InteractableArea extends Area2D

# 强制规定的三个通用交互信号
signal focused
signal unfocused
signal interacted(interactor: Node2D)