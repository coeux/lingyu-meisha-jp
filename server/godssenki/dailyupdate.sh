su nice -c "git stash"
su nice -c "git pull --rebase"
su nice -c "git stash pop"
make -j8
./restart-4.sh
