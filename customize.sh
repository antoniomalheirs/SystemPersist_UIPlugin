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
  ui_print "**********************************"
  ui_print "*     SystemPersist_UIPlugin     *"
  ui_print "**********************************"
  ui_print " "
  ui_print "For Android 12/13/14!"
  ui_print " "
  ui_print "Signature verification must be disabled"
  ui_print "mandatory for MIUI 14 users based on"
  ui_print "Android 12/13/14; otherwise, the module will"
  ui_print "not work."
  ui_print " "
  if [ -n "$KSU" ]; then
    ui_print "[*] Ambiente: KernelSU"
    ui_print "[*] Versão Do Modulo para KernelSU: $KSU_VER"
    ui_print "[*] Versão Do KernelSU: ${KSU_VER_CODE}" 
  else
    ui_print "[*] Ambiente: Magisk"
    ui_print "[*] Versão Do Modulo para Magisk: $MAGISK_VER"
    ui_print "[*] Versão Do Magisk: ${MAGISK_VER_CODE}" 
  fi

  Android=`getprop ro.build.version.release`

  case "$Android" in
  12)
    ui_print " "
    ui_print "Android 12 detected"
    cp -rf "$MODPATH/files/plugin/SystemUIPlugin.apk" "$MODPATH/system/app/MiuiSystemUIPlugin"
    ui_print " "
    ;;
  13|14) 
    ui_print " "
    ui_print "Android 13/14 detected"
    cp -rf "$MODPATH/files/plugin/SystemUIPlugin.apk" "$MODPATH/system/product/app/MiuiSystemUIPlugin"
    ui_print " "
    ;;
  *)
    ui_print "Android Version Incompatibility, check on Github for more informations about installation method"
    ui_print "Exiting the installation to avoid crashing the system"
    exit 1
    ;;
  esac 
  
  ui_print "[*] Uninstalling Updates..."
  pm uninstall-system-updates miui.systemui.plugin

  TMPAPKDIR=/data/local/tmp

  # Copiar e instalar o primeiro APK
  cp -rf "$MODPATH/files/plugin/SystemUIPlugin.apk" "$TMPAPKDIR"
  result1=$(pm install "${TMPAPKDIR}/SystemUIPlugin.apk" 2>&1)

  if [ "$result1" != "Success" ]; then
    ui_print "Error installing SystemUIPlugin.apk: $result1"
    exit 1
  fi

  # Copiar e instalar o segundo APK
  cp -rf "$MODPATH/files/plugin/MiuiSystemUI.apk" "$TMPAPKDIR"
  result2=$(pm install "${TMPAPKDIR}/MiuiSystemUI.apk" 2>&1)

  if [ "$result2" != "Success" ]; then
    ui_print " "
    ui_print "Error installing MiuiSystemUI - $result2"
    ui_print " "
    ui_print "[*] You can ignore that ERROR"
    ui_print " "
  fi

  # Copiar e instalar o terceiro APK
  cp -rf "$MODPATH/system/app/Cast/Cast.apk" "$TMPAPKDIR"
  result3=$(pm install "${TMPAPKDIR}/Cast.apk" 2>&1)

  if [ "$result3" != "Success" ]; then
    ui_print "Error installing Cast.apk: $result3"
    exit 1
  fi

  # Verificar se a verificação de assinatura foi desabilitada
  if [[ "$result1" == "Success" &&  "$result3" == "Success" ]]; then
    ui_print " "
    ui_print "Desativação da verificação de assinatura detectada"
    ui_print "Prosseguindo com a instalação como atualização."
    ui_print "Instalado com sucesso."
    ui_print "Agora você pode usá-lo sem reiniciar o dispositivo."
    ui_print " "
    ui_print " "
  else
    ui_print " "
    ui_print "Desativação da verificação de assinatura não detectada"
    ui_print "Prosseguindo com a instalação normal."
    ui_print " "
    ui_print " "
  fi
}

cleanup() {
  rm -rf $MODPATH/files 2>/dev/null
  rm -rf /data/resource-cache/*
  rm -rf /data/system/package_cache/*
  rm -rf /cache/*
  rm -rf /data/dalvik-cache/*
}

run_install() {
  unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2
  ui_print " "
  install_files
  sleep 1
  ui_print "[*] Cleaning up"
  ui_print " "
  cleanup
  sleep 1
}

set_permissions() {
  set_perm_recursive  $MODPATH  0  0  0755  0644
}

run_install