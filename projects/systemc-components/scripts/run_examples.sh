#!/usr/bin/env bash
set -euo pipefail

SCC_DIR=${SCC_DIR:-/work/src}
PRESET=${SCC_BUILD_PRESET:-Release}
BUILD_DIR=${SCC_BUILD_DIR:-$SCC_DIR/build/$PRESET}
EXAMPLES_DIR=${SCC_EXAMPLES_DIR:-$BUILD_DIR/examples}
ARTIFACTS_DIR=${ARTIFACTS_DIR:-/artifacts}
MANIFEST=${SCC_ARTIFACTS_LIST:-/project/artifacts.list}
WORK_ROOT=${SCC_RUN_WORK_DIR:-/work/systemc-components}
RUN_DIR=$WORK_ROOT/runs
LOG_DIR=$WORK_ROOT/logs
STAGE_DIR=$WORK_ROOT/staged
WAVE_STAGE=$STAGE_DIR/waves
FTR_STAGE=$STAGE_DIR/ftr
CONVERT_STAGE=$STAGE_DIR/converted
SUMMARY=$WORK_ROOT/example-runs.tsv
CONVERSION_LOG=$WORK_ROOT/conversion.log
TIMEOUT_SECONDS=${SCC_EXAMPLE_TIMEOUT_SECONDS:-180}

declare -a EXPECTED_EXECUTABLES=(
    ace-ace/ace_ace_example
    ace-axi/ace_axi_example
    ahb_bfm/ahb_bfm
    apb_bfm/apb_bfm
    axi-axi/axi_axi_example
    axi4_tlm-pin-tlm/axi4_tlm_pin_tlm_example
    axi4lite_tlm-pin-tlm/axi4lite_tlm_pin_tlm_example
    cxs-channel/cxs_channel
    lwtr/lwtr_example
    lwtr4axi/lwtr4axi_example
    lwtr4tlm2/lwtr4tlm2
    scc-tlm_target_bfs/scc-tlm_target_bfs-example
    scp/scp_example
    simple_system/simple_system
    transaction_recording/transaction_recording
    transaction_recording/transaction_recording_cftr
    transaction_recording/transaction_recording_ftr
)

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

safe_name() {
    local rel=$1
    rel=${rel//\//__}
    rel=${rel//[^A-Za-z0-9_.-]/_}
    printf '%s\n' "$rel"
}

read_manifest() {
    local line
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -n "$line" ]] || continue
        [[ ${line:0:1} != '#' ]] || continue
        case "$line" in
            /*|../*|*/../*) die "unsafe artifact path in manifest: $line" ;;
        esac
        printf '%s\n' "$line"
    done < "$MANIFEST"
}

[[ -d "$EXAMPLES_DIR" ]] || die "examples directory not found: $EXAMPLES_DIR; run make prepare first"
[[ -f "$MANIFEST" ]] || die "artifact manifest not found: $MANIFEST"

for rel in "${EXPECTED_EXECUTABLES[@]}"; do
    [[ -x "$EXAMPLES_DIR/$rel" ]] || die "expected executable missing or not executable: $EXAMPLES_DIR/$rel"
done

mapfile -t FOUND_EXECUTABLES < <(find "$EXAMPLES_DIR" -maxdepth 2 -type f -perm -111 | LC_ALL=C sort)
if [[ ${#FOUND_EXECUTABLES[@]} -ne ${#EXPECTED_EXECUTABLES[@]} ]]; then
    printf 'expected %d executables, found %d under %s\n' "${#EXPECTED_EXECUTABLES[@]}" "${#FOUND_EXECUTABLES[@]}" "$EXAMPLES_DIR" >&2
    printf 'found executables:\n' >&2
    printf '  %s\n' "${FOUND_EXECUTABLES[@]#$EXAMPLES_DIR/}" >&2
    exit 1
fi

rm -rf "$WORK_ROOT"
mkdir -p "$RUN_DIR" "$LOG_DIR" "$WAVE_STAGE" "$FTR_STAGE" "$CONVERT_STAGE"
printf 'example\texecutable\texit_code\twave_count\tftr_count\tstdout\tstderr\targs\n' > "$SUMMARY"
printf 'conversion\tsource\toutput\tstatus\n' > "$CONVERSION_LOG"

overall=0
for rel in "${EXPECTED_EXECUTABLES[@]}"; do
    exe="$EXAMPLES_DIR/$rel"
    rel_dir=$(dirname -- "$rel")
    base=$(basename -- "$rel")
    safe=$(safe_name "$rel")
    one_run_dir="$RUN_DIR/$safe"
    one_wave_dir="$WAVE_STAGE/$safe"
    one_ftr_dir="$FTR_STAGE/$safe"
    stdout_log="$LOG_DIR/$safe.stdout.log"
    stderr_log="$LOG_DIR/$safe.stderr.log"
    src_dir="$SCC_DIR/examples/$rel_dir"
    mkdir -p "$one_run_dir" "$one_wave_dir" "$one_ftr_dir"

    if [[ -d "$src_dir" ]]; then
        while IFS= read -r input; do
            cp "$input" "$one_run_dir/"
        done < <(find "$src_dir" -maxdepth 1 -type f \( -name '*.json' -o -name '*.gtkw' \) | LC_ALL=C sort)
    fi

    args=()
    case "$base" in
        simple_system)
            args=(-t)
            ;;
        axi4_tlm_pin_tlm_example|axi4lite_tlm_pin_tlm_example)
            if [[ -f "$one_run_dir/axi-pin-axi.json" ]]; then
                args=(axi-pin-axi.json)
            fi
            ;;
    esac

    printf 'Running %s\n' "$rel"
    set +e
    (
        cd "$one_run_dir" || exit 99
        if [[ "$TIMEOUT_SECONDS" == "0" ]]; then
            "$exe" "${args[@]}" >"$stdout_log" 2>"$stderr_log"
        else
            timeout "$TIMEOUT_SECONDS" "$exe" "${args[@]}" >"$stdout_log" 2>"$stderr_log"
        fi
    )
    rc=$?
    set -e
    if [[ $rc -ne 0 ]]; then
        overall=1
    fi

    wave_count=0
    while IFS= read -r wave; do
        [[ -n "$wave" ]] || continue
        rel_wave=${wave#./}
        mkdir -p "$one_wave_dir/$(dirname -- "$rel_wave")"
        cp "$one_run_dir/$rel_wave" "$one_wave_dir/$rel_wave"
        wave_count=$((wave_count + 1))
    done < <(cd "$one_run_dir" && find . -type f \( -name '*.vcd' -o -name '*.fst' \) | LC_ALL=C sort)

    ftr_count=0
    while IFS= read -r ftr; do
        [[ -n "$ftr" ]] || continue
        rel_ftr=${ftr#./}
        mkdir -p "$one_ftr_dir/$(dirname -- "$rel_ftr")"
        cp "$one_run_dir/$rel_ftr" "$one_ftr_dir/$rel_ftr"
        ftr_count=$((ftr_count + 1))
    done < <(cd "$one_run_dir" && find . -type f -name '*.ftr' | LC_ALL=C sort)

    args_text=${args[*]:-}
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$safe" "$rel" "$rc" "$wave_count" "$ftr_count" "$stdout_log" "$stderr_log" "$args_text" >> "$SUMMARY"
done

if command -v vcd2fst >/dev/null 2>&1; then
    while IFS= read -r vcd; do
        rel_vcd=${vcd#"$WAVE_STAGE"/}
        out="$CONVERT_STAGE/${rel_vcd%.vcd}.fst"
        mkdir -p "$(dirname -- "$out")"
        if vcd2fst "$vcd" "$out" >/dev/null 2>&1; then
            printf 'vcd2fst\t%s\t%s\tok\n' "$vcd" "$out" >> "$CONVERSION_LOG"
        else
            rm -f "$out"
            printf 'vcd2fst\t%s\t%s\tfailed\n' "$vcd" "$out" >> "$CONVERSION_LOG"
        fi
    done < <(find "$WAVE_STAGE" -type f -name '*.vcd' | LC_ALL=C sort)
else
    printf 'vcd2fst\t-\t-\ttool-not-found\n' >> "$CONVERSION_LOG"
fi

if command -v fst2vcd >/dev/null 2>&1; then
    while IFS= read -r fst; do
        rel_fst=${fst#"$WAVE_STAGE"/}
        out="$CONVERT_STAGE/${rel_fst%.fst}.vcd"
        mkdir -p "$(dirname -- "$out")"
        if fst2vcd "$fst" > "$out" 2>/dev/null && [[ -s "$out" ]]; then
            printf 'fst2vcd\t%s\t%s\tok\n' "$fst" "$out" >> "$CONVERSION_LOG"
        else
            rm -f "$out"
            printf 'fst2vcd\t%s\t%s\tfailed\n' "$fst" "$out" >> "$CONVERSION_LOG"
        fi
    done < <(find "$WAVE_STAGE" -type f -name '*.fst' | LC_ALL=C sort)
else
    printf 'fst2vcd\t-\t-\ttool-not-found\n' >> "$CONVERSION_LOG"
fi

printf '\nRun summary:\n'
if command -v column >/dev/null 2>&1; then
    column -t -s $'\t' "$SUMMARY" || cat "$SUMMARY"
else
    cat "$SUMMARY"
fi

printf '\nCollected native waveforms in staging:\n'
find "$WAVE_STAGE" -type f \( -name '*.vcd' -o -name '*.fst' \) | LC_ALL=C sort
printf '\nCollected FTR artifacts in staging:\n'
find "$FTR_STAGE" -type f -name '*.ftr' | LC_ALL=C sort
printf '\nConverted waveforms in staging:\n'
find "$CONVERT_STAGE" -type f \( -name '*.vcd' -o -name '*.fst' \) | LC_ALL=C sort

if [[ $overall -ne 0 ]]; then
    die "one or more examples failed; leaving staged evidence under $WORK_ROOT and not updating $ARTIFACTS_DIR"
fi

mapfile -t MANIFEST_ARTIFACTS < <(read_manifest)
[[ ${#MANIFEST_ARTIFACTS[@]} -gt 0 ]] || die "artifact manifest is empty: $MANIFEST"

for rel in "${MANIFEST_ARTIFACTS[@]}"; do
    [[ -s "$STAGE_DIR/$rel" ]] || die "expected staged artifact missing or empty: $STAGE_DIR/$rel"
done

tmp_files=()
cleanup_tmp() {
    local tmp
    for tmp in "${tmp_files[@]:-}"; do
        rm -f "$tmp"
    done
}
trap cleanup_tmp EXIT

mkdir -p "$ARTIFACTS_DIR"
for rel in "${MANIFEST_ARTIFACTS[@]}"; do
    src="$STAGE_DIR/$rel"
    dest="$ARTIFACTS_DIR/$rel"
    mkdir -p "$(dirname -- "$dest")"
    tmp="$dest.tmp.$$"
    tmp_files+=("$tmp")
    cp "$src" "$tmp"
    mv "$tmp" "$dest"
done

printf '\nPublished %d artifacts to %s:\n' "${#MANIFEST_ARTIFACTS[@]}" "$ARTIFACTS_DIR"
printf '  %s\n' "${MANIFEST_ARTIFACTS[@]}"
