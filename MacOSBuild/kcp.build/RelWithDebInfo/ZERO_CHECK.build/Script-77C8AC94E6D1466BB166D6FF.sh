#!/bin/sh
set -e
if test "$CONFIGURATION" = "Debug"; then :
  cd /Users/zhangyinan/Project/kcp-bulild/MacOSBuild
  make -f /Users/zhangyinan/Project/kcp-bulild/MacOSBuild/CMakeScripts/ReRunCMake.make
fi
if test "$CONFIGURATION" = "Release"; then :
  cd /Users/zhangyinan/Project/kcp-bulild/MacOSBuild
  make -f /Users/zhangyinan/Project/kcp-bulild/MacOSBuild/CMakeScripts/ReRunCMake.make
fi
if test "$CONFIGURATION" = "MinSizeRel"; then :
  cd /Users/zhangyinan/Project/kcp-bulild/MacOSBuild
  make -f /Users/zhangyinan/Project/kcp-bulild/MacOSBuild/CMakeScripts/ReRunCMake.make
fi
if test "$CONFIGURATION" = "RelWithDebInfo"; then :
  cd /Users/zhangyinan/Project/kcp-bulild/MacOSBuild
  make -f /Users/zhangyinan/Project/kcp-bulild/MacOSBuild/CMakeScripts/ReRunCMake.make
fi

