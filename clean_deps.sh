
if [ "$1" = "lock" ]; then
    echo "removing mix.lock"
    rm mix.lock
else
    echo -e "not trying to remove mix.lock, if you want to pass lock as the first argument to the script :::\n\n ./clean_deps.sh lock\n\n"
fi

for dir in _build*/; do
    echo "removing build dir: $dir";
    rm -rf $dir
done

for dir in deps_*/; do
    echo "removing deps dir: $dir";
    rm -rf $dir
done

for dir in apps/*/**/; do
    if [[ $dir =~ "_build" ]]; then
	echo "removing build dir: $dir";
        rm -rf $dir
    fi

    if [[ $dir =~ "deps_" ]]; then
	echo "removing deps dir: $dir";
	rm -rf $dir
    fi
done
