#!/bin/bash
#
# Bump kernel version in meta-aspeed recipe and create a commit
# message using git shortlog
#
# Customise location of KERNELGITDIR to point to your openbmc git tree.
# Run from root of openbmc checkout tree.
#
# Joel Stanley <joel@jms.id.au>
#

set -xe

SUMMARY=$1

KERNELGITDIR="$HOME/dev/kernels/openbmc/.git"

RECIPE="meta-aspeed/recipes-kernel/linux/linux-aspeed_git.bb"
BRANCH=dev-6.5

OLDSHA=$(grep -Po "(\w{40})" ${RECIPE})
SHA=$(GIT_DIR=${KERNELGITDIR} git rev-parse openbmc/${BRANCH})
SHORTLOG=$(GIT_DIR=${KERNELGITDIR} git shortlog "${OLDSHA}..${SHA}")
VERSION=$(GIT_DIR=${KERNELGITDIR} git describe --abbrev=0 | cut -c 2-)

cat << EOF > ${RECIPE}
KBRANCH ?= "${BRANCH}"
LINUX_VERSION ?= "${VERSION}"

SRCREV="${SHA}"

require linux-aspeed.inc
EOF

MESSAGE="
linux-aspeed: ${SUMMARY}

${SHORTLOG}
"

echo "$MESSAGE" | git commit -s -F - ${RECIPE}
