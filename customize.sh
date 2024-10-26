MODID=template
AUTOMOUNT=true
SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=false

REPLACE="
/system/app/MIUISystemUIPlugin
/system/app/MiuiSystemUIPlugin
/system/app/SystemUIPlugin
/system/product/app/MIUISystemUIPlugin
/system/product/app/MiuiSystemUIPlugin
/system/product/app/SystemUIPlugin
"

install_files() {
ui_print " For Android 12/13/14! "
ui_print " "
ui_print " Signature verification must be disabled"
ui_print " mandatory for MIUI 14 users based on" 
ui_print " Android 12/13/14; otherwise, the module will"
ui_print " not work. "
ui_print " "
ui_print " "

Android=`getprop ro.build.version.release`

if [ $Android = 12 ]; then
    ui_print " Android 12 detected"
    ui_print " "
    cp -rf $MODPATH/files/plugin/SystemUIPlugin.apk $MODPATH/system/app/MiuiSystemUIPlugin
if [ $Android = 13 ]; then
    ui_print " Android 13 detected"
    ui_print " "
    cp -rf $MODPATH/files/plugin/SystemUIPlugin.apk $MODPATH/system/product/app/MiuiSystemUIPlugin
if [ $Android = 14 ]; then
    ui_print " Android 14 detected"
    ui_print " "
    cp -rf $MODPATH/files/plugin/SystemUIPlugin.apk $MODPATH/system/product/app/MiuiSystemUIPlugin
else
{
    ui_print "Android Version Incompatibility, check on Github for more informations about installation method"
    ui_print "Exiting the installation to avoid crashing the system"
    sleep 1
    exit 1
}

fi

ui_print "- Uninstalling Updates..."
    pm uninstall-system-updates miui.systemui.plugin

TMPAPKDIR=/data/local/tmp
cp -rf $MODPATH/files/plugin/SystemUIPlugin.apk $TMPAPKDIR
result=$(pm install ${TMPAPKDIR}/SystemUIPlugin.apk 2>&1)
cp -rf $MODPATH/system/app/PluginExtension/PluginExtension.apk $TMPAPKDIR
result2=$(pm install ${TMPAPKDIR}/PluginExtension.apk 2>&1)
cp -rf $MODPATH/system/app/Cast/Cast.apk $TMPAPKDIR
result2=$(pm install ${TMPAPKDIR}/Cast.apk 2>&1)

if [ $result = Success ] && [ $result2 = Success ];then
    ui_print " "
    ui_print " Signature verification disablement detected"
    ui_print " proceeding to install as an update."
    ui_print " Installed successfully."
    ui_print " Now you can use it without restarting your device."
    ui_print " "
    ui_print " "
else
{
    ui_print " "
    ui_print " Signature verification disablement not detected"
    ui_print " Proceeding with normal installation."
    ui_print " "
    ui_print " "
}

fi
  
}

cleanup() {
	rm -rf $MODPATH/files 2>/dev/null
	ui_print "- Deleting package cache files"
    rm -rf /data/resource-cache/*
    rm -rf /data/system/package_cache/*
    rm -rf /cache/*
    rm -rf /data/dalvik-cache/*
}

run_install() {
    unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2
	ui_print " "
	ui_print "- Installing files"
	ui_print " "
	install_files
	sleep 1
	ui_print "- Cleaning up"
	ui_print " "
	cleanup
	sleep 1
	ui_print "- Removing any Plugin folder to avoid issues"
}

set_permissions() {
    set_perm_recursive  $MODPATH  0  0  0755  0644
}

run_install