#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="${VALA_DOWNLOADER_REPO_URL:-https://github.com/JanGalek/vala-downloader-lib.git}"
REPO_REF="${VALA_DOWNLOADER_REF:-master}"

PROJECT_ROOT="${1:-$PWD}"
MESON_FILE="${PROJECT_ROOT}/meson.build"
VAPI_DIR="${PROJECT_ROOT}/vapi"
LIB_DIR="${PROJECT_ROOT}/lib"
INCLUDE_DIR="${PROJECT_ROOT}/include"

START_MARKER="# >>> vala-downloader-lib local setup >>>"
END_MARKER="# <<< vala-downloader-lib local setup <<<"

if [ ! -f "${MESON_FILE}" ]; then
    echo -e "${RED}[Error] meson.build not found in ${PROJECT_ROOT}.${NC}"
    echo -e "Run this script in the root of your Meson consumer project, or pass the project path as the first argument."
    exit 1
fi

echo -e "${BLUE}==> Installing vala-downloader-lib into local project folders...${NC}"
echo -e "Repository: ${REPO_URL}"
echo -e "Reference : ${REPO_REF}"

mkdir -p "${VAPI_DIR}" "${LIB_DIR}" "${INCLUDE_DIR}"

TMP_DIR="$(mktemp -d)"
cleanup() {
    rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

echo -e "${BLUE}==> Cloning source...${NC}"
git clone --depth 1 --branch "${REPO_REF}" "${REPO_URL}" "${TMP_DIR}/src" >/dev/null 2>&1

echo -e "${BLUE}==> Building release artifacts...${NC}"
meson setup "${TMP_DIR}/build" "${TMP_DIR}/src" --buildtype=release >/dev/null
meson compile -C "${TMP_DIR}/build" >/dev/null

SOURCE_VAPI="${TMP_DIR}/build/src/vapi/vala-downloader-lib.vapi"
SOURCE_HEADER="${TMP_DIR}/build/src/vala-downloader-lib.h"

if [ ! -f "${SOURCE_VAPI}" ] || [ ! -f "${SOURCE_HEADER}" ]; then
    echo -e "${RED}[Error] Build artifacts were not generated as expected.${NC}"
    exit 1
fi

echo -e "${BLUE}==> Copying artifacts...${NC}"
cp "${SOURCE_VAPI}" "${VAPI_DIR}/"
cp "${SOURCE_HEADER}" "${INCLUDE_DIR}/"
cp -a "${TMP_DIR}/build/src"/libvala-downloader-lib.so* "${LIB_DIR}/"

if ! grep -Fq "${START_MARKER}" "${MESON_FILE}"; then
    echo -e "${BLUE}==> Appending helper block to meson.build...${NC}"
    cat <<'EOF' >> "${MESON_FILE}"

# >>> vala-downloader-lib local setup >>>
vala_downloader_local_deps = [
  dependency('glib-2.0'),
  dependency('gio-2.0'),
  dependency('libsoup-3.0'),
]

vala_downloader_local_vala_args = [
  '--vapidir=' + meson.project_source_root() / 'vapi',
]

vala_downloader_local_c_args = [
  '-I' + meson.project_source_root() / 'include',
]

vala_downloader_local_link_args = [
  '-L' + meson.project_source_root() / 'lib',
  '-lvala-downloader-lib',
]
# <<< vala-downloader-lib local setup <<<
EOF
else
    echo -e "${BLUE}==> meson.build helper block already exists, skipping append.${NC}"
fi

echo -e "${GREEN}[Done] Local integration files prepared.${NC}"
echo -e ""
echo -e "Use these variables in your target definition:"
echo -e "  dependencies: vala_downloader_local_deps"
echo -e "  vala_args: vala_downloader_local_vala_args"
echo -e "  c_args: vala_downloader_local_c_args"
echo -e "  link_args: vala_downloader_local_link_args"
echo -e ""
echo -e "Run your app with local shared library path if needed:"
echo -e "  LD_LIBRARY_PATH=./lib ./your-binary"

SCRIPT_PATH="${BASH_SOURCE[0]:-}"
if [ "${KEEP_SCRIPT:-0}" != "1" ] && [ -n "${SCRIPT_PATH}" ] && [ -f "${SCRIPT_PATH}" ]; then
  rm -f -- "${SCRIPT_PATH}" || true
fi
