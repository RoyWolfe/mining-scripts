tmux new -s default -d
tmux split-window -v -t default
tmux split-window -v -t default

tmux send-keys -t default:0.0 'cd ./mining-scripts; sudo ./overclock-nvidia.sh; ./mine.sh' C-m
tmux send-keys -t default:0.1 'watch -n 20 dotnet ngw/NvidiaGpuWatcher.dll' C-m
tmux send-keys -t default:0.2 'watch -n 300 ./mining-scripts/wallet_value.sh' C-m

tmux select-pane -t default:0.0
tmux attach -t default
