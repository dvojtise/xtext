#!/bin/sh


# First, update the version of the BOM, which is disconnected from the parent.
# For example, 2.31.0-SNAPSHOT becomes 2.31.0

mvn -f org.eclipse.xtext.dev-bom \
  build-helper:parse-version \
  versions:set \
  -DgenerateBackupPoms=false \
  -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion}

# The updated BOM must be installed, or the next runs will complain they can't find it.

mvn -f org.eclipse.xtext.dev-bom install

# Replace the property "xtext-dev-bom-version" in the parent POM, with the new version of the BOM.
# For example,
# <xtext-dev-bom-version>${project.version}</xtext-dev-bom-version>
# becomes
# <xtext-dev-bom-version>2.31.0</xtext-dev-bom-version>

mvn \
  build-helper:parse-version \
  versions:set-property \
  -DgenerateBackupPoms=false \
  -Dproperty=xtext-dev-bom-version \
  -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion}

# With Tycho, replace all versions (in POMs and Eclipse metadata) with the timestamp as the qualifier.
# For example, in POMs, 2.31.0-SNAPSHOT becomes 2.31.0.v2023...
# In MANIFEST and features, 2.31.0.qualifier becomes 2.31.0.v2023...

mvn \
  -Preplace-qualifier-with-timestamp \
  build-helper:parse-version \
  build-helper:timestamp-property@timestamp \
  org.eclipse.tycho:tycho-versions-plugin:set-version \
  -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion}.\${computedTimestamp} \
  -DgenerateBackupPoms=false

# Update the versions in the POMs only with the release number as the qualifier
# For example, in POMs, 2.31.0.v2023... becomes 2.31.0
# In MANIFEST and features, 2.31.0.v2023... stays the same

mvn \
  build-helper:parse-version \
  versions:set \
  -DgenerateBackupPoms=false \
  -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion}
