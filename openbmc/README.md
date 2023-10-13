
# Checkout this repo
```
cd ~/dev/kernels/
git clone https://github.com/shenki/kernels-scripts
```

# Checkout openbmc
```
cd ~/dev/openbmc/
git clone https://github.com/openbmc/openbmc
cd openbmc
curl -Lo .git/hooks/commit-msg https://gerrit.openbmc.org/tools/hooks/commit-msg
chmod +x .git/hooks/commit-msg
git remote add gerrit ssh://shenki@gerrit.openbmc.org:29418/openbmc/openbmc
cp ~/dev/kernels/kernel-scripts/openbmc/bump-kernel.sh .
```

# Checkout openbmc linux
```
cd ~/dev/kernels/
git clone --reference ~/dev/kernels/stable https://github.com/openbmc/linux openbmc
cd openbmc
# add push remote. name is referenced by the bump-kernel.sh script
git remote add openbmc git@github.com:openbmc/linux.git
git remote add stable https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
```

# Patch process

1. Apply patches
2. Add OpenBMC-Staging-Count tag (todo: automate this)
3. Push to openbmc remote
4. Go to openbmc-yocto dir, and run bump-kernel.sh
5. `git commit --amend` to fix subject

# Stable bump process
```
cd ~/dev/kernels/openbmc
git fetch stable
git merge v6.5.22
git commit --amend -s
```
