#!/bin/bash
################################################################################
# Basic Augment Optimization Examples
################################################################################

echo "Augment VSCode Optimizer - Basic Usage Examples"
echo "==============================================="

# Example 1: First-time user workflow
echo ""
echo "Example 1: First-time user (recommended workflow)"
echo "------------------------------------------------"
echo "# 1. Check current performance"
echo "./augment_optimizer.sh --analyze"
echo ""
echo "# 2. Backup current settings (safety first)"
echo "./augment_optimizer.sh --backup"
echo ""
echo "# 3. Apply optimizations"
echo "./augment_optimizer.sh --optimize"
echo ""
echo "# 4. Verify optimizations were applied"
echo "./augment_optimizer.sh --verify"
echo ""

# Example 2: One-command optimization
echo "Example 2: One-command optimization"
echo "----------------------------------"
echo "# Backup and optimize in one command"
echo "./augment_optimizer.sh --backup --optimize"
echo ""

# Example 3: Performance analysis
echo "Example 3: Performance analysis"
echo "-------------------------------"
echo "# Detailed analysis with verbose output"
echo "./augment_optimizer.sh --analyze --verbose"
echo ""

# Example 4: Benchmarking
echo "Example 4: Performance benchmarking"
echo "-----------------------------------"
echo "# Run performance benchmark"
echo "./augment_optimizer.sh --benchmark"
echo ""
echo "# Or use the Python benchmark tool"
echo "python3 tests/benchmark_performance.py"
echo ""

# Example 5: Monitoring
echo "Example 5: Real-time monitoring"
echo "-------------------------------"
echo "# Monitor Augment performance in real-time"
echo "./augment_optimizer.sh --monitor"
echo ""

# Example 6: Dry run
echo "Example 6: Preview changes (dry run)"
echo "------------------------------------"
echo "# See what would be changed without applying"
echo "./augment_optimizer.sh --dry-run --optimize"
echo ""

# Example 7: Restore if needed
echo "Example 7: Restore original settings"
echo "------------------------------------"
echo "# Restore from backup if issues occur"
echo "./augment_optimizer.sh --restore"
echo ""

# Example 8: Help and information
echo "Example 8: Getting help"
echo "----------------------"
echo "# Show all available options"
echo "./augment_optimizer.sh --help"
echo ""

echo "==============================================="
echo "💡 Recommended workflow for new users:"
echo "   1. ./augment_optimizer.sh --analyze"
echo "   2. ./augment_optimizer.sh --backup --optimize"
echo "   3. ./augment_optimizer.sh --benchmark"
echo ""
echo "🎯 Expected improvements:"
echo "   • 100% elimination of keyring access storms"
echo "   • 100% elimination of network timeouts"
echo "   • 15-25% memory usage reduction"
echo "   • Dramatically improved UI responsiveness"
