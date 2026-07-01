export ANDROID_HOME="$HOME/.nix-profile/libexec/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/27.1.12297006"
export NDK_HOME="$ANDROID_NDK_HOME"

path=(
    "$ANDROID_HOME/cmdline-tools/latest/bin"
    "$ANDROID_HOME/platform-tools"
    $path
)

# Resolve JAVA_HOME from the JDK exposed by the active Nix profile so this
# continues to work when Nix updates its store path.
if (( $+commands[java] )); then
    _java_bin="${commands[java]:A}"
    export JAVA_HOME="${_java_bin:h:h}"
    unset _java_bin
fi
