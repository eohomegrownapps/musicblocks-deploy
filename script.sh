lockfile -r 0 /tmp/cordova.lock || exit 1
cd /var/www/musicblocks-cordova/
echo "==git reset"
git reset --hard
echo "==git pull"
git pull
echo "==git subtree pull"
git subtree pull --prefix www https://github.com/walterbender/musicblocks.git master
echo "==cordova"
cordova build android
cp platforms/android/build/outputs/apk/android-debug.apk android-debug.apk
echo "==git push"
git add .
git commit -m "Android apk build"
git push
rm -f /tmp/cordova.lock