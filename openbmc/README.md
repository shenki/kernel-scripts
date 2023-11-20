# Updating OpenBMC kernel

## Setup

### Checkout this repo
```
cd ~/dev/kernels/
git clone https://github.com/shenki/kernels-scripts
```

### Checkout openbmc
```
cd ~/dev/openbmc/
git clone https://github.com/openbmc/openbmc
cd openbmc
curl -Lo .git/hooks/commit-msg https://gerrit.openbmc.org/tools/hooks/commit-msg
chmod +x .git/hooks/commit-msg
git remote add gerrit ssh://shenki@gerrit.openbmc.org:29418/openbmc/openbmc
cp ~/dev/kernels/kernel-scripts/openbmc/bump-kernel.sh .
```

### Checkout openbmc linux
```
cd ~/dev/kernels/
git clone --reference ~/dev/kernels/stable https://github.com/openbmc/linux openbmc
cd openbmc
# add push remote. name is referenced by the bump-kernel.sh script
git remote add openbmc git@github.com:openbmc/linux.git
git remote add stable https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
```

## Patch process

1. Apply patches
2. Add OpenBMC-Staging-Count tag (todo: automate this)
3. Push to openbmc remote
4. Go to openbmc-yocto dir, and run bump-kernel.sh
5. `git commit --amend` to fix subject

## Stable bump process
```
cd ~/dev/kernels/openbmc
git fetch stable
git merge v6.5.22
git commit --amend -s
```

## Rebase

When moving to a new kernel base:

1. Create a new branch and rebase
```
git checkout -b dev-7.2
git rebase --onto v7.2 v7.1.69
```

2. Use interactive rebase to clean the tree

* Update patches to the latest submitted versions
* Squash patch-revert-patch into the latest version of the patch
* Pull in latest devicetree changes from next kernel release (eg. if a v7.3 PR
  has been sent for aspeed, grab those patches)
* Move upstreamed patches to the start of the rebased history
* Drop patches that are unmaintained or have had no progress

4. Edit the kernel version in bump-staging-number.sh

3. Bump the staging version with bump-staging-version.sh

