#!/bin/bash
################################################################################
# Augment Performance Monitor
# Real-time monitoring of Augment extension performance
################################################################################

set -euo pipefail

MONITOR_INTERVAL=5
MONITOR_DURATION=300  # 5 minutes default
LOG_FILE="/tmp/augment_performance_$(date +%Y%m%d_%H%M%S).log"

show_help() {
    cat << EOF
Augment Performance Monitor

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --interval, -i SECONDS    Monitoring interval (default: 5)
    --duration, -d SECONDS    Total monitoring duration (default: 300)
    --log-file, -l FILE       Log file path (default: /tmp/augment_performance_*.log)
    --continuous, -c          Monitor continuously (no time limit)
    --help, -h                Show this help

EXAMPLES:
    $0                        # Monitor for 5 minutes with 5-second intervals
    $0 -i 2 -d 600           # Monitor for 10 minutes with 2-second intervals
    $0 --continuous          # Monitor continuously until Ctrl+C

EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --interval|-i)
                MONITOR_INTERVAL="$2"
                shift 2
                ;;
            --duration|-d)
                MONITOR_DURATION="$2"
                shift 2
                ;;
            --log-file|-l)
                LOG_FILE="$2"
                shift 2
                ;;
            --continuous|-c)
                MONITOR_DURATION=0
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "❌ Unknown option: $1"
                exit 1
                ;;
        esac
    done
}

get_vscode_processes() {
    ps aux | grep -E "(code-insiders|Code.*Insiders)" | grep -v grep | grep -v "$(basename "$0")" || true
}

get_memory_usage() {
    local processes=$(get_vscode_processes)
    if [[ -z "$processes" ]]; then
        echo "0"
        return
    fi
    
    echo "$processes" | awk '{sum += $6} END {print sum/1024}' # Convert KB to MB
}

get_cpu_usage() {
    local processes=$(get_vscode_processes)
    if [[ -z "$processes" ]]; then
        echo "0"
        return
    fi
    
    echo "$processes" | awk '{sum += $3} END {print sum}'
}

get_process_count() {
    local processes=$(get_vscode_processes)
    if [[ -z "$processes" ]]; then
        echo "0"
        return
    fi
    
    echo "$processes" | wc -l
}

log_metrics() {
    local timestamp="$1"
    local memory="$2"
    local cpu="$3"
    local processes="$4"
    
    echo "$timestamp,$memory,$cpu,$processes" >> "$LOG_FILE"
}

display_metrics() {
    local timestamp="$1"
    local memory="$2"
    local cpu="$3"
    local processes="$4"
    
    printf "\r[%s] Memory: %6.1f MB | CPU: %5.1f%% | Processes: %2d" \
           "$timestamp" "$memory" "$cpu" "$processes"
}

cleanup() {
    echo ""
    echo ""
    echo "📊 Monitoring completed"
    echo "📄 Log file: $LOG_FILE"
    
    if [[ -f "$LOG_FILE" ]] && [[ -s "$LOG_FILE" ]]; then
        echo ""
        echo "📈 Summary statistics:"
        
        # Calculate averages
        local avg_memory=$(awk -F',' '{sum+=$2; count++} END {print sum/count}' "$LOG_FILE")
        local avg_cpu=$(awk -F',' '{sum+=$3; count++} END {print sum/count}' "$LOG_FILE")
        local avg_processes=$(awk -F',' '{sum+=$4; count++} END {print sum/count}' "$LOG_FILE")
        
        # Calculate max values
        local max_memory=$(awk -F',' 'BEGIN{max=0} {if($2>max) max=$2} END {print max}' "$LOG_FILE")
        local max_cpu=$(awk -F',' 'BEGIN{max=0} {if($3>max) max=$3} END {print max}' "$LOG_FILE")
        local max_processes=$(awk -F',' 'BEGIN{max=0} {if($4>max) max=$4} END {print max}' "$LOG_FILE")
        
        printf "   Average Memory: %.1f MB (Peak: %.1f MB)\n" "$avg_memory" "$max_memory"
        printf "   Average CPU: %.1f%% (Peak: %.1f%%)\n" "$avg_cpu" "$max_cpu"
        printf "   Average Processes: %.1f (Peak: %.0f)\n" "$avg_processes" "$max_processes"
        
        # Performance assessment
        echo ""
        echo "🎯 Performance Assessment:"
        
        if (( $(echo "$avg_memory < 200" | bc -l) )); then
            echo "   ✅ Memory usage: Excellent (< 200 MB)"
        elif (( $(echo "$avg_memory < 400" | bc -l) )); then
            echo "   ⚡ Memory usage: Good (< 400 MB)"
        else
            echo "   ⚠️  Memory usage: High (> 400 MB) - consider optimization"
        fi
        
        if (( $(echo "$avg_cpu < 10" | bc -l) )); then
            echo "   ✅ CPU usage: Excellent (< 10%)"
        elif (( $(echo "$avg_cpu < 25" | bc -l) )); then
            echo "   ⚡ CPU usage: Good (< 25%)"
        else
            echo "   ⚠️  CPU usage: High (> 25%) - consider optimization"
        fi
        
        if (( $(echo "$avg_processes < 15" | bc -l) )); then
            echo "   ✅ Process count: Optimal (< 15 processes)"
        elif (( $(echo "$avg_processes < 25" | bc -l) )); then
            echo "   ⚡ Process count: Reasonable (< 25 processes)"
        else
            echo "   ⚠️  Process count: High (> 25 processes)"
        fi
        
        # Optimization recommendation
        if (( $(echo "$avg_memory > 300 || $avg_cpu > 20" | bc -l) )); then
            echo ""
            echo "💡 Recommendation: Run Augment optimization"
            echo "   ./augment_optimizer.sh --backup --optimize"
        fi
    fi
    
    exit 0
}

main() {
    echo "================================================================================"
    echo "                    Augment Performance Monitor"
    echo "                              $(date '+%Y-%m-%d %H:%M:%S')"
    echo "================================================================================"
    
    parse_arguments "$@"
    
    # Setup signal handlers
    trap cleanup SIGINT SIGTERM
    
    echo "📊 Monitoring Augment performance..."
    echo "⏱️  Interval: ${MONITOR_INTERVAL}s"
    if [[ $MONITOR_DURATION -gt 0 ]]; then
        echo "⏱️  Duration: ${MONITOR_DURATION}s"
    else
        echo "⏱️  Duration: Continuous (Ctrl+C to stop)"
    fi
    echo "📄 Log file: $LOG_FILE"
    echo ""
    
    # Check if VSCode is running
    if [[ -z "$(get_vscode_processes)" ]]; then
        echo "⚠️  No VSCode processes found. Start VSCode Insiders to begin monitoring."
        echo "Waiting for VSCode to start..."
        
        while [[ -z "$(get_vscode_processes)" ]]; do
            sleep 2
            echo -n "."
        done
        echo ""
        echo "✅ VSCode detected, starting monitoring..."
    fi
    
    # Create log file header
    echo "timestamp,memory_mb,cpu_percent,process_count" > "$LOG_FILE"
    
    # Monitoring loop
    local start_time=$(date +%s)
    local iteration=0
    
    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        # Check duration limit
        if [[ $MONITOR_DURATION -gt 0 ]] && [[ $elapsed -ge $MONITOR_DURATION ]]; then
            break
        fi
        
        # Get metrics
        local timestamp=$(date '+%H:%M:%S')
        local memory=$(get_memory_usage)
        local cpu=$(get_cpu_usage)
        local processes=$(get_process_count)
        
        # Log and display
        log_metrics "$timestamp" "$memory" "$cpu" "$processes"
        display_metrics "$timestamp" "$memory" "$cpu" "$processes"
        
        ((iteration++))
        sleep "$MONITOR_INTERVAL"
    done
    
    cleanup
}

# Check dependencies
if ! command -v bc &>/dev/null; then
    echo "❌ 'bc' calculator not found. Please install bc:"
    echo "   Ubuntu/Debian: sudo apt install bc"
    echo "   macOS: brew install bc"
    echo "   CentOS/RHEL: sudo yum install bc"
    exit 1
fi

main "$@"
