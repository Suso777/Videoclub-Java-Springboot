#!/bin/sh
# ----------------------------------------------------------------------------
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Apache Maven Wrapper startup batch script, version 3.3.4
#
# Optional ENV vars
# -----------------
#   JAVA_HOME - location of a JDK home dir, required when download maven via java source
#   MVNW_REPOURL - repo url base for downloading maven distribution
#   MVNW_USERNAME/MVNW_PASSWORD - user and password for downloading maven
#   MVNW_VERBOSE - true: enable verbose log; false: disable verbose log
# ----------------------------------------------------------------------------

set -euf
[ "${MVNW_VERBOSE-}" != true ] || set -x

# OS specific support.
native_path() { printf '%s\n' "$1"; }
case "$(uname)" in
CYGWIN* | MINGW*)
  [ -z "${JAVA_HOME-}" ] || JAVA_HOME="$(cygpath --unix "$JAVA_HOME")"
  native_path() { cygpath --path --windows "$1"; }
  ;;
esac

# set JAVACMD and JAVACCMD
set_java_home() {
  # For Cygwin and MinGW, ensure paths are in Unix format before anything is touched
  if [ -n "${JAVA_HOME-}" ]; then
    if [ -x "$JAVA_HOME/jre/sh/java" ]; then
      # IBM's JDK on AIX uses strange locations for the executables
      JAVACMD="$JAVA_HOME/jre/sh/java"
      JAVACCMD="$JAVA_HOME/jre/sh/javac"
    else
      JAVACMD="$JAVA_HOME/bin/java"
      JAVACCMD="$JAVA_HOME/bin/javac"

      if [ ! -x "$JAVACMD" ] || [ ! -x "$JAVACCMD" ]; then
        echo "The JAVA_HOME environment variable is not defined correctly, so mvnw cannot run." >&2
        echo "JAVA_HOME is set to \"$JAVA_HOME\", but \"\$JAVA_HOME/bin/java\" or \"\$JAVA_HOME/bin/javac\" does not exist." >&2
        return 1
      fi
    fi
  else
    JAVACMD="$(
      'set' +e
      'unset' -f command 2>/dev/null
      'command' -v java
    )" || :
    JAVACCMD="$(
      'set' +e
      'unset' -f command 2>/dev/null
      'command' -v javac
    )" || :

    if [ ! -x "${JAVACMD-}" ] || [ ! -x "${JAVACCMD-}" ]; then
      echo "The java/javac command does not exist in PATH nor is JAVA_HOME set, so mvnw cannot run." >&2
      return 1
    fi
  fi
}

# hash string like Java String::hashCode
hash_string() {
  str="${1:-}" h=0
  while [ -n "$str" ]; do
    char="${str%"${str#?}"}"
    h=$(((h * 31 + $(LC_CTYPE=C printf '%d' "'${char}")) % 4294967296))
    str="${str#?}"
  done
  printf '%s' $h
}

verbose() { :; }
[ "${MVNW_VERBOSE-}" != true ] || verbose() { printf '%s\n' "${1-}"; }

die() {
  printf 'ERROR: %s\n' "${1-}" >&2
  exit 1
}

trim() {
  # Trims leading and trailing whitespace
  local var="$*"
  var="${var#"${var%%[![:space:]]*}"}"
  var="${var%"${var##*[![:space:]]}"}"
  printf '%s' "$var"
}

# parse distributionUrl and optional distributionSha256Sum, requires .mvn/wrapper/maven-wrapper.properties
while IFS="=" read -r key value; do
  case "${key-}" in
  distributionUrl) distributionUrl="$(trim "${value-}")" ;;
  distributionSha256Sum) distributionSha256Sum="$(trim "${value-}")" ;;
  esac
done <"${0%/*}/.mvn/wrapper/maven-wrapper.properties"
[ -n "${distributionUrl-}" ] || die "cannot read distributionUrl property in ${0%/*}/.mvn/wrapper/maven-wrapper.properties"

case "${distributionUrl##*/}" in
*.zip) unzipMethod=unzip ;;
*.tar.gz) unzipMethod=tar ;;
*) die "distributionUrl '${distributionUrl}' is not supported, only zip and tar.gz" ;;
esac

# find MAVEN_USER_HOME
[ -n "${MAVEN_USER_HOME-}" ] || MAVEN_USER_HOME="${HOME}/.m2"

distributionUrlName="${distributionUrl##*/}"
distributionUrlNameMain="${distributionUrlName%.*}"
distributionUrlNameMain="${distributionUrlNameMain%-bin}"
MAVEN_HOME="${MAVEN_USER_HOME}/wrapper/dists/${distributionUrlNameMain}/${distributionUrlName}"

if [ -d "$MAVEN_HOME" ]; then
  verbose "Found existing installation at $MAVEN_HOME"
else
  mkdir -p "${MAVEN_HOME%/*}"

  if [ -n "${MVNW_REPOURL-}" ]; then
    suffix="${distributionUrl#*//*/}"
    distributionUrl="${MVNW_REPOURL%/}/${suffix#*/}"
  fi

  verbose "Downloading $distributionUrl"

  if ! command -v unzip >/dev/null && ! command -v tar >/dev/null; then
    die "Neither 'unzip' nor 'tar' is available. Please install one of them."
  fi

  tmpdir="$(mktemp -d)" || die "Cannot create temp directory"

  if command -v wget >/dev/null; then
    if [ -n "${MVNW_USERNAME-}" ] && [ -n "${MVNW_PASSWORD-}" ]; then
      WGET_ARGS="--http-user=${MVNW_USERNAME} --http-password=${MVNW_PASSWORD}"
    fi
    wget ${WGET_ARGS-} --no-verbose -O "${tmpdir}/${distributionUrlName}" "$distributionUrl" || die "Could not download $distributionUrl"
  elif command -v curl >/dev/null; then
    if [ -n "${MVNW_USERNAME-}" ] && [ -n "${MVNW_PASSWORD-}" ]; then
      CURL_ARGS="-u ${MVNW_USERNAME}:${MVNW_PASSWORD}"
    fi
    curl ${CURL_ARGS-} -o "${tmpdir}/${distributionUrlName}" -LsS "$distributionUrl" || die "Could not download $distributionUrl"
  else
    set_java_home
    javaSource="${tmpdir}/MavenWrapperDownloader.java"
    javaClass="${tmpdir}/MavenWrapperDownloader"
    cat >"$javaSource" <<-END
        import java.net.*;
        import java.io.*;
        import java.nio.channels.*;
        import java.util.Properties;

        public class MavenWrapperDownloader {
            private static final String WRAPPER_VERSION = "3.3.4";
            private static final boolean verbose = Boolean.parseBoolean(System.getenv("MVNW_VERBOSE"));
            public static void main(String[] args) throws Exception {
                assert args.length == 2 : "Usage: MavenWrapperDownloader <distributionUrl> <outputFile>";
                String distributionUrl = args[0];
                String outputFile = args[1];
                if (verbose) {
                    System.err.println("Downloading " + distributionUrl);
                }
                URL url = URI.create(distributionUrl).toURL();
                String username = System.getenv("MVNW_USERNAME");
                String password = System.getenv("MVNW_PASSWORD");
                if (username != null && password != null) {
                    Authenticator.setDefault(new Authenticator() {
                        @Override
                        protected PasswordAuthentication getPasswordAuthentication() {
                            return new PasswordAuthentication(username, password.toCharArray());
                        }
                    });
                }
                try (ReadableByteChannel rbc = Channels.newChannel(url.openStream());
                     FileOutputStream fos = new FileOutputStream(outputFile)) {
                    fos.getChannel().transferFrom(rbc, 0, Long.MAX_VALUE);
                }
            }
        }
	END
    "$JAVACCMD" "$javaSource" -d "$tmpdir" >/dev/null 2>&1 || die "Failed to compile MavenWrapperDownloader"
    "$JAVACMD" -cp "$tmpdir" MavenWrapperDownloader "$distributionUrl" "${tmpdir}/${distributionUrlName}" || die "Could not download $distributionUrl"
  fi

  if [ -n "${distributionSha256Sum-}" ]; then
    distributionSha256Result=false
    if command -v sha256sum >/dev/null; then
      if echo "${distributionSha256Sum}  ${tmpdir}/${distributionUrlName}" | sha256sum --check >/dev/null 2>&1; then
        distributionSha256Result=true
      fi
    elif command -v shasum >/dev/null; then
      if echo "${distributionSha256Sum}  ${tmpdir}/${distributionUrlName}" | shasum -a 256 --check >/dev/null 2>&1; then
        distributionSha256Result=true
      fi
    else
      echo "Checksum validation was requested but neither 'sha256sum' nor 'shasum' is available." >&2
      echo "Please install either command, or disable validation by removing 'distributionSha256Sum' from your maven-wrapper.properties." >&2
    fi
    if [ $distributionSha256Result = false ]; then
      die "Error: Failed to validate Maven distribution SHA-256, your Maven distribution might be compromised. If you updated your Maven version, you need to update the specified distributionSha256Sum property."
    fi
  fi

  if [ "${unzipMethod}" = unzip ]; then
    unzip -q "${tmpdir}/${distributionUrlName}" -d "$tmpdir" || die "Could not unzip ${distributionUrlName}"
  else
    tar xzf "${tmpdir}/${distributionUrlName}" -C "$tmpdir" || die "Could not untar ${distributionUrlName}"
  fi

  find "$tmpdir" -maxdepth 1 -mindepth 1 -type d | xargs -I{} mv {} "$MAVEN_HOME"
  rm -rf "$tmpdir"
fi

MVN_CMD="${MAVEN_HOME}/bin/mvn"
[ -x "$MVN_CMD" ] || die "mvn command not found: $MVN_CMD"
exec "$MVN_CMD" "$@"
