#!/usr/bin/env bash
set -euo pipefail
build_dir="build"
build_tests="ON"
run_tests="OFF"
configure_only="OFF"
parallel="24"
targets=()
build_args=()
usage() {
    cat <<'EOF'
Usage: ./b [options] [-- extra cmake --build args]
Options:
  --tests              Build tests and run ctest after the build
  --run-tests          Build tests and run ctest after the build
  --no-tests           Configure with tests disabled
  --configure-only     Configure CMake without building
  --build-dir DIR      Use a build directory other than ./build
  --target TARGET      Build a specific target
  -j, --parallel N     Build with N parallel jobs
  -h, --help           Show this help
EOF
}
while [[ $# -gt 0 ]]; do
    case "$1" in
        --tests|--run-tests)
            build_tests="ON"
            run_tests="ON"
            shift
            ;;
        --no-tests)
            build_tests="OFF"
            run_tests="OFF"
            shift
            ;;
        --configure-only)
            configure_only="ON"
            shift
            ;;
        --build-dir)
            build_dir="${2:?missing argument for --build-dir}"
            shift 2
            ;;
        --target)
            targets+=("${2:?missing argument for --target}")
            shift 2
            ;;
        -j|--parallel)
            parallel="${2:?missing argument for $1}"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            build_args+=("$@")
            break
            ;;
        *)
            build_args+=("$1")
            shift
            ;;
    esac
done
if [[ ! -f "$build_dir/CMakeCache.txt" ]]; then
    cmake -S . -B "$build_dir" -DBUILD_TESTS="$build_tests"
fi
if [[ "$configure_only" == "ON" ]]; then
    exit 0
fi
cmd=(cmake --build "$build_dir")
for target in "${targets[@]}"; do
    cmd+=(--target "$target")
done
if [[ -n "$parallel" ]]; then
    cmd+=(--parallel "$parallel")
fi
cmd+=("${build_args[@]}")
"${cmd[@]}"
if [[ "$run_tests" == "ON" ]]; then
    ctest --test-dir "$build_dir" --output-on-failure
fi
